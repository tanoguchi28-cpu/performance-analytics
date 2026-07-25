# Supabase移行ガイド（チーム共有機能・実装済み）

`performance_analytics`は「チーム共有・役割別アクセス制御機能」により、Supabaseバックエンドに
接続する。**ローカル専用モード（drift/SQLite、`LocalXRepository`）は完全には廃止せず、
チームセッション（`currentTeamSession`）が存在しない場合のフォールバックとして温存している。**
テストは常にローカル専用モードを通るため、既存のテストコードには影響しない。

## 方針まとめ

- 各featureの`XRepository`は抽象インターフェース + `Local*Repository`/`Supabase*Repository`の
  2実装という構成。`xRepositoryProvider`が`currentTeamSession`の有無で実装を出し分ける
  （`lib/features/athletes/data/local_athlete_repository.dart`等を参照）。
- チームIDは`teams.id`自体を8桁の短いコード（`TeamCodeGenerator`、紛らわしい文字を除いた
  英数字）とし、UUIDは使わない。人が手入力・共有しやすいことを優先。
- 認証は導入しない（本人確認の仕組みは無い。チームIDを知っていればそのチームのデータに
  アクセスできる、という信頼モデルをユーザーが了承済み）。ただし起動時に
  Supabase Anonymous Sign-inを1回行い（ログインUI無し）、全RLSポリシーを`authenticated`
  ロール限定にすることで、素の匿名キーだけでは何も触れないベースラインを確保している。
- `teams`テーブルへの直接アクセスは完全に禁止し、`create_team`/`find_team`/`rename_team`と
  いうSECURITY DEFINER RPC経由のみに限定する。直接SELECTを許すと匿名キーを持つ誰か1人が
  `select * from teams`で全チーム分のIDを一括収集でき、「チームIDが秘密」という前提が
  崩れるため。
- `measurement_records`・`score_bands`には`team_id`を非正規化して持たせ、親行
  （session/criteria）からトリガーで自動セットする（クライアントからは設定不可）。

## テーブルDDL・RLS・RPC（Postgres）

Supabase SQL Editorで一度だけ実行する。

```sql
create table teams (
  id text primary key,
  name text not null,
  created_at timestamptz not null default now()
);

create table athletes (
  id uuid primary key default gen_random_uuid(),
  team_id text not null references teams(id) on delete cascade,
  name text not null, kana text, grade integer not null, position text,
  birth_date date, photo_path text, jersey_number integer,
  is_active boolean not null default true, coach_comment text
);
create index idx_athletes_team_id on athletes(team_id);

create table measurement_items (
  id uuid primary key default gen_random_uuid(),
  team_id text not null references teams(id) on delete cascade,
  key text not null, name text not null, unit text not null,
  higher_is_better boolean not null default true, ability_category text not null,
  is_active boolean not null default true, sort_order integer not null default 0,
  unique (team_id, key)
);
create index idx_measurement_items_team_id on measurement_items(team_id);

create table measurement_sessions (
  id uuid primary key default gen_random_uuid(),
  team_id text not null references teams(id) on delete cascade,
  measurement_date date not null, label text, note text
);
create index idx_measurement_sessions_team_id on measurement_sessions(team_id);

create table evaluation_criteria (
  id uuid primary key default gen_random_uuid(),
  team_id text not null references teams(id) on delete cascade,
  name text not null, item_key text not null, gender text,
  age_group_min integer, age_group_max integer, position text
);
create index idx_evaluation_criteria_team_id on evaluation_criteria(team_id);

-- team_idは非正規化（親行からトリガーで自動セット、クライアントからは設定しない）
create table measurement_records (
  id uuid primary key default gen_random_uuid(),
  team_id text not null references teams(id) on delete cascade,
  athlete_id uuid not null references athletes(id) on delete cascade,
  session_id uuid not null references measurement_sessions(id) on delete cascade,
  item_id uuid not null references measurement_items(id) on delete cascade,
  value double precision not null,
  unique (athlete_id, session_id, item_id)
);
create index idx_measurement_records_team_id on measurement_records(team_id);

create table score_bands (
  id uuid primary key default gen_random_uuid(),
  team_id text not null references teams(id) on delete cascade,
  criteria_id uuid not null references evaluation_criteria(id) on delete cascade,
  min_value double precision, max_value double precision, score integer not null
);
create index idx_score_bands_team_id on score_bands(team_id);

create or replace function set_measurement_record_team_id() returns trigger
language plpgsql as $$
begin select team_id into new.team_id from measurement_sessions where id = new.session_id; return new; end;
$$;
create trigger trg_measurement_records_team_id before insert or update of session_id
on measurement_records for each row execute function set_measurement_record_team_id();

create or replace function set_score_band_team_id() returns trigger
language plpgsql as $$
begin select team_id into new.team_id from evaluation_criteria where id = new.criteria_id; return new; end;
$$;
create trigger trg_score_bands_team_id before insert or update of criteria_id
on score_bands for each row execute function set_score_band_team_id();

-- teamsは直接SELECT/INSERT/UPDATE不可。RPC経由のみ。
create or replace function find_team(p_code text)
returns table(id text, name text, created_at timestamptz)
language sql security definer set search_path = public as $$
  select id, name, created_at from teams where id = p_code;
$$;

create or replace function create_team(p_id text, p_name text)
returns table(id text, name text, created_at timestamptz)
language sql security definer set search_path = public as $$
  insert into teams (id, name) values (p_id, p_name) returning id, name, created_at;
$$;

create or replace function rename_team(p_id text, p_name text)
returns table(id text, name text, created_at timestamptz)
language sql security definer set search_path = public as $$
  update teams set name = p_name where id = p_id returning id, name, created_at;
$$;

revoke all on teams from anon, authenticated;
grant execute on function find_team(text) to authenticated;
grant execute on function create_team(text, text) to authenticated;
grant execute on function rename_team(text, text) to authenticated;

alter table athletes enable row level security;
alter table measurement_items enable row level security;
alter table measurement_sessions enable row level security;
alter table measurement_records enable row level security;
alter table evaluation_criteria enable row level security;
alter table score_bands enable row level security;
alter table teams enable row level security; -- ポリシー無し＝直接アクセス不可

create policy team_scoped_all on athletes for all to authenticated using (true) with check (true);
create policy team_scoped_all on measurement_items for all to authenticated using (true) with check (true);
create policy team_scoped_all on measurement_sessions for all to authenticated using (true) with check (true);
create policy team_scoped_all on measurement_records for all to authenticated using (true) with check (true);
create policy team_scoped_all on evaluation_criteria for all to authenticated using (true) with check (true);
create policy team_scoped_all on score_bands for all to authenticated using (true) with check (true);
```

上記実行後、Supabaseダッシュボードで **Authentication → Providers → Anonymous Sign-ins** を
有効化すること（アプリ起動時に`signInAnonymously()`を呼ぶため）。

## 環境変数セットアップ

`lib/core/constants/supabase_env.dart`が`SUPABASE_URL`/`SUPABASE_ANON_KEY`を
`String.fromEnvironment`で読む。

1. `.env.json`（gitignore対象）に実際の値を設定
2. `flutter run --dart-define-from-file=.env.json`で起動
3. `lib/main.dart`は`SupabaseEnv.supabaseUrl`が空でなければ自動的に`Supabase.initialize()`
   と匿名サインインを行う（空の場合は何もせず、従来通りローカル専用モードで起動する）

## リポジトリの出し分け

`currentTeamSession`（`lib/main.dart`）が非nullの間だけ、各`xRepositoryProvider`は
`Supabase*Repository`を返す。nullなら（テスト環境を含め）常に`Local*Repository`を返す。
これにより既存のローカル専用モードのテストは無変更で動作し続ける。

## 未実装・対象外のもの

- `backup_screen.dart`（`BackupService`）はローカルdrift DBを直接操作する機能のため、
  チーム共有モードでは意味を持たない。チームセッションがある場合は設定画面から
  「データバックアップ」タイル自体を非表示にする。
- リアルタイム同期（Supabase Realtime）は導入していない。他端末の変更を見るには
  画面の再読み込み（pull-to-refresh等）が必要。
- オフライン時の競合解決は未実装（チーム共有モードは常時ネットワーク接続が前提）。
