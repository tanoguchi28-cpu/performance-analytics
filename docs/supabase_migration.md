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
  アクセスできる、という信頼モデルをユーザーが了承済み）。起動時にSupabase Anonymous
  Sign-inを1回行う（ログインUI無し）。
- **全テーブルへの直接アクセス（PostgRESTの`/rest/v1/<table>`経由）を完全に禁止し、
  `team_id`を必須パラメータとするSECURITY DEFINER RPC関数経由でのみ読み書きできるように
  している。** 当初は`using (true)`の緩いRLSポリシーで運用していたが、これだと
  「認証さえされていれば`team_id`を一切知らなくても全チーム分のデータを読み書きできて
  しまう」という重大な抜けがあったため是正した（2026年7月修正）。現在は`teams`テーブルと
  同じ考え方を選手データの全テーブルに適用しており、「正しいチームIDを知っている場合のみ、
  そのチームのデータにアクセスできる」という当初の信頼モデル通りの状態になっている。
- `measurement_records`・`score_bands`には`team_id`を非正規化して持たせ、親行
  （session/criteria）からトリガーで自動セットする（クライアントからは設定不可）。

## テーブルDDL（Postgres）

新規にSupabaseプロジェクトを作る場合はこのテーブル定義から始める。

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

alter table athletes enable row level security;
alter table measurement_items enable row level security;
alter table measurement_sessions enable row level security;
alter table measurement_records enable row level security;
alter table evaluation_criteria enable row level security;
alter table score_bands enable row level security;
alter table teams enable row level security;
```

RLSは全テーブルで有効化するのみで、**ポリシーは一切追加しない**（ポリシー無し＝
PostgREST経由の直接アクセスは常に拒否される）。読み書きは下記のRPC関数経由のみ。

## RPC関数・権限（Postgres）

Supabase SQL Editorで一度だけ実行する。`teams`用（`find_team`/`create_team`/
`rename_team`）に加え、選手データの全テーブルを同じ考え方でRPC経由に限定する。

```sql
-- ==================== teams ====================
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

-- ==================== athletes ====================
create or replace function athletes_list(p_team_id text, p_active_only boolean default true)
returns setof athletes
language sql security definer set search_path = public as $$
  select * from athletes
  where team_id = p_team_id and (not p_active_only or is_active)
  order by name;
$$;

create or replace function athletes_get(p_team_id text, p_id uuid)
returns setof athletes
language sql security definer set search_path = public as $$
  select * from athletes where team_id = p_team_id and id = p_id;
$$;

-- p_dataは選手データのJSON（例: {"name": "...", "grade": 1, ...}）。
-- Dart側はdriftのCompanionのうち値が設定されたフィールドのみを含めて渡す。
create or replace function athletes_create(p_team_id text, p_data jsonb)
returns setof athletes
language plpgsql security definer set search_path = public as $$
declare
  v_id uuid;
begin
  insert into athletes (team_id, name, kana, grade, position, birth_date, photo_path, jersey_number, is_active, coach_comment)
  values (
    p_team_id,
    p_data->>'name',
    p_data->>'kana',
    coalesce((p_data->>'grade')::int, 1),
    p_data->>'position',
    (p_data->>'birth_date')::date,
    p_data->>'photo_path',
    (p_data->>'jersey_number')::int,
    coalesce((p_data->>'is_active')::boolean, true),
    p_data->>'coach_comment'
  )
  returning id into v_id;
  return query select * from athletes where id = v_id;
end;
$$;

-- p_patchに存在するキーのみ更新する（部分更新。JSONで明示的にnullを指定すればクリアできる）。
create or replace function athletes_update(p_team_id text, p_id uuid, p_patch jsonb)
returns void
language plpgsql security definer set search_path = public as $$
begin
  update athletes set
    name = case when p_patch ? 'name' then p_patch->>'name' else name end,
    kana = case when p_patch ? 'kana' then p_patch->>'kana' else kana end,
    grade = case when p_patch ? 'grade' then (p_patch->>'grade')::int else grade end,
    position = case when p_patch ? 'position' then p_patch->>'position' else position end,
    birth_date = case when p_patch ? 'birth_date' then (p_patch->>'birth_date')::date else birth_date end,
    photo_path = case when p_patch ? 'photo_path' then p_patch->>'photo_path' else photo_path end,
    jersey_number = case when p_patch ? 'jersey_number' then (p_patch->>'jersey_number')::int else jersey_number end,
    is_active = case when p_patch ? 'is_active' then (p_patch->>'is_active')::boolean else is_active end,
    coach_comment = case when p_patch ? 'coach_comment' then p_patch->>'coach_comment' else coach_comment end
  where team_id = p_team_id and id = p_id;
end;
$$;

create or replace function athletes_deactivate(p_team_id text, p_id uuid)
returns void
language sql security definer set search_path = public as $$
  update athletes set is_active = false where team_id = p_team_id and id = p_id;
$$;

create or replace function athletes_delete(p_team_id text, p_id uuid)
returns void
language sql security definer set search_path = public as $$
  delete from athletes where team_id = p_team_id and id = p_id;
$$;

-- ==================== measurement_items ====================
create or replace function measurement_items_list(p_team_id text, p_active_only boolean default true)
returns setof measurement_items
language sql security definer set search_path = public as $$
  select * from measurement_items
  where team_id = p_team_id and (not p_active_only or is_active)
  order by sort_order;
$$;

create or replace function measurement_items_get_by_key(p_team_id text, p_key text)
returns setof measurement_items
language sql security definer set search_path = public as $$
  select * from measurement_items where team_id = p_team_id and key = p_key;
$$;

create or replace function measurement_items_create(p_team_id text, p_data jsonb)
returns setof measurement_items
language plpgsql security definer set search_path = public as $$
declare
  v_id uuid;
begin
  insert into measurement_items (team_id, key, name, unit, higher_is_better, ability_category, is_active, sort_order)
  values (
    p_team_id,
    p_data->>'key',
    p_data->>'name',
    p_data->>'unit',
    coalesce((p_data->>'higher_is_better')::boolean, true),
    coalesce(p_data->>'ability_category', 'none'),
    coalesce((p_data->>'is_active')::boolean, true),
    coalesce((p_data->>'sort_order')::int, 0)
  )
  returning id into v_id;
  return query select * from measurement_items where id = v_id;
end;
$$;

create or replace function measurement_items_update(p_team_id text, p_id uuid, p_patch jsonb)
returns void
language plpgsql security definer set search_path = public as $$
begin
  update measurement_items set
    key = case when p_patch ? 'key' then p_patch->>'key' else key end,
    name = case when p_patch ? 'name' then p_patch->>'name' else name end,
    unit = case when p_patch ? 'unit' then p_patch->>'unit' else unit end,
    higher_is_better = case when p_patch ? 'higher_is_better' then (p_patch->>'higher_is_better')::boolean else higher_is_better end,
    ability_category = case when p_patch ? 'ability_category' then p_patch->>'ability_category' else ability_category end,
    is_active = case when p_patch ? 'is_active' then (p_patch->>'is_active')::boolean else is_active end,
    sort_order = case when p_patch ? 'sort_order' then (p_patch->>'sort_order')::int else sort_order end
  where team_id = p_team_id and id = p_id;
end;
$$;

create or replace function measurement_items_deactivate(p_team_id text, p_id uuid)
returns void
language sql security definer set search_path = public as $$
  update measurement_items set is_active = false where team_id = p_team_id and id = p_id;
$$;

-- ==================== measurement_sessions ====================
create or replace function measurement_sessions_list(p_team_id text)
returns setof measurement_sessions
language sql security definer set search_path = public as $$
  select * from measurement_sessions where team_id = p_team_id order by measurement_date desc;
$$;

create or replace function measurement_sessions_get(p_team_id text, p_id uuid)
returns setof measurement_sessions
language sql security definer set search_path = public as $$
  select * from measurement_sessions where team_id = p_team_id and id = p_id;
$$;

create or replace function measurement_sessions_create(p_team_id text, p_measurement_date date, p_label text, p_note text)
returns setof measurement_sessions
language plpgsql security definer set search_path = public as $$
declare
  v_id uuid;
begin
  insert into measurement_sessions (team_id, measurement_date, label, note)
  values (p_team_id, p_measurement_date, p_label, p_note)
  returning id into v_id;
  return query select * from measurement_sessions where id = v_id;
end;
$$;

create or replace function measurement_sessions_update(p_team_id text, p_id uuid, p_measurement_date date, p_label text, p_note text)
returns void
language sql security definer set search_path = public as $$
  update measurement_sessions
  set measurement_date = p_measurement_date, label = p_label, note = p_note
  where team_id = p_team_id and id = p_id;
$$;

create or replace function measurement_sessions_delete(p_team_id text, p_id uuid)
returns void
language sql security definer set search_path = public as $$
  delete from measurement_sessions where team_id = p_team_id and id = p_id;
$$;

-- ==================== measurement_records ====================
create or replace function measurement_records_upsert(
  p_team_id text, p_athlete_id uuid, p_session_id uuid, p_item_id uuid, p_value double precision
) returns void
language plpgsql security definer set search_path = public as $$
begin
  if not exists (select 1 from measurement_sessions where id = p_session_id and team_id = p_team_id) then
    raise exception 'session not found for team';
  end if;
  insert into measurement_records (athlete_id, session_id, item_id, value)
  values (p_athlete_id, p_session_id, p_item_id, p_value)
  on conflict (athlete_id, session_id, item_id) do update set value = excluded.value;
end;
$$;

create or replace function measurement_records_delete(
  p_team_id text, p_athlete_id uuid, p_session_id uuid, p_item_id uuid
) returns void
language sql security definer set search_path = public as $$
  delete from measurement_records
  where team_id = p_team_id and athlete_id = p_athlete_id and session_id = p_session_id and item_id = p_item_id;
$$;

create or replace function measurement_records_for_athlete(p_team_id text, p_athlete_id uuid)
returns setof measurement_records
language sql security definer set search_path = public as $$
  select r.* from measurement_records r
  join measurement_sessions s on s.id = r.session_id
  where r.team_id = p_team_id and r.athlete_id = p_athlete_id
  order by s.measurement_date asc;
$$;

create or replace function measurement_records_for_session(p_team_id text, p_session_id uuid)
returns setof measurement_records
language sql security definer set search_path = public as $$
  select * from measurement_records where team_id = p_team_id and session_id = p_session_id;
$$;

-- ==================== evaluation_criteria / score_bands ====================
create or replace function evaluation_criteria_for_item(p_team_id text, p_item_key text)
returns setof evaluation_criteria
language sql security definer set search_path = public as $$
  select * from evaluation_criteria where team_id = p_team_id and item_key = p_item_key;
$$;

create or replace function evaluation_criteria_create(p_team_id text, p_item_key text, p_name text, p_position text)
returns setof evaluation_criteria
language plpgsql security definer set search_path = public as $$
declare
  v_id uuid;
begin
  insert into evaluation_criteria (team_id, item_key, name, position)
  values (p_team_id, p_item_key, p_name, p_position)
  returning id into v_id;
  return query select * from evaluation_criteria where id = v_id;
end;
$$;

create or replace function evaluation_criteria_delete(p_team_id text, p_id uuid)
returns void
language sql security definer set search_path = public as $$
  delete from evaluation_criteria where team_id = p_team_id and id = p_id;
$$;

create or replace function score_bands_for_criteria(p_team_id text, p_criteria_id uuid)
returns setof score_bands
language sql security definer set search_path = public as $$
  select * from score_bands where team_id = p_team_id and criteria_id = p_criteria_id;
$$;

create or replace function score_bands_upsert(
  p_team_id text, p_id uuid, p_criteria_id uuid, p_score int,
  p_min_value double precision, p_max_value double precision
) returns setof score_bands
language plpgsql security definer set search_path = public as $$
declare
  v_id uuid := coalesce(p_id, gen_random_uuid());
begin
  if not exists (select 1 from evaluation_criteria where id = p_criteria_id and team_id = p_team_id) then
    raise exception 'criteria not found for team';
  end if;
  insert into score_bands (id, criteria_id, score, min_value, max_value)
  values (v_id, p_criteria_id, p_score, p_min_value, p_max_value)
  on conflict (id) do update set
    criteria_id = excluded.criteria_id, score = excluded.score,
    min_value = excluded.min_value, max_value = excluded.max_value;
  return query select * from score_bands where id = v_id;
end;
$$;

create or replace function score_bands_delete(p_team_id text, p_id uuid)
returns void
language sql security definer set search_path = public as $$
  delete from score_bands where team_id = p_team_id and id = p_id;
$$;

-- ==================== 直接アクセスの遮断・実行権限 ====================
revoke all on teams from anon, authenticated;
revoke all on athletes from anon, authenticated;
revoke all on measurement_items from anon, authenticated;
revoke all on measurement_sessions from anon, authenticated;
revoke all on measurement_records from anon, authenticated;
revoke all on evaluation_criteria from anon, authenticated;
revoke all on score_bands from anon, authenticated;

drop policy if exists team_scoped_all on athletes;
drop policy if exists team_scoped_all on measurement_items;
drop policy if exists team_scoped_all on measurement_sessions;
drop policy if exists team_scoped_all on measurement_records;
drop policy if exists team_scoped_all on evaluation_criteria;
drop policy if exists team_scoped_all on score_bands;

grant execute on function find_team(text) to authenticated;
grant execute on function create_team(text, text) to authenticated;
grant execute on function rename_team(text, text) to authenticated;

grant execute on function athletes_list(text, boolean) to authenticated;
grant execute on function athletes_get(text, uuid) to authenticated;
grant execute on function athletes_create(text, jsonb) to authenticated;
grant execute on function athletes_update(text, uuid, jsonb) to authenticated;
grant execute on function athletes_deactivate(text, uuid) to authenticated;
grant execute on function athletes_delete(text, uuid) to authenticated;

grant execute on function measurement_items_list(text, boolean) to authenticated;
grant execute on function measurement_items_get_by_key(text, text) to authenticated;
grant execute on function measurement_items_create(text, jsonb) to authenticated;
grant execute on function measurement_items_update(text, uuid, jsonb) to authenticated;
grant execute on function measurement_items_deactivate(text, uuid) to authenticated;

grant execute on function measurement_sessions_list(text) to authenticated;
grant execute on function measurement_sessions_get(text, uuid) to authenticated;
grant execute on function measurement_sessions_create(text, date, text, text) to authenticated;
grant execute on function measurement_sessions_update(text, uuid, date, text, text) to authenticated;
grant execute on function measurement_sessions_delete(text, uuid) to authenticated;

grant execute on function measurement_records_upsert(text, uuid, uuid, uuid, double precision) to authenticated;
grant execute on function measurement_records_delete(text, uuid, uuid, uuid) to authenticated;
grant execute on function measurement_records_for_athlete(text, uuid) to authenticated;
grant execute on function measurement_records_for_session(text, uuid) to authenticated;

grant execute on function evaluation_criteria_for_item(text, text) to authenticated;
grant execute on function evaluation_criteria_create(text, text, text, text) to authenticated;
grant execute on function evaluation_criteria_delete(text, uuid) to authenticated;

grant execute on function score_bands_for_criteria(text, uuid) to authenticated;
grant execute on function score_bands_upsert(text, uuid, uuid, int, double precision, double precision) to authenticated;
grant execute on function score_bands_delete(text, uuid) to authenticated;
```

Supabaseダッシュボードで **Authentication → Sign In / Providers → Anonymous Sign-ins** を
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

## セキュリティ上の残課題（許容している範囲）

- 本人確認の仕組みが無いため、正しいチームIDを知っている人は誰でもそのチームの
  全データを読み書きできる（役割による閲覧・編集制限はアプリのUI層のみで、
  DB層では強制していない）。これはユーザーが了承済みの信頼モデル。
- 上記に加えて、以前は`team_id`によるDB層での絞り込みが無く「チームIDを知らなくても
  全チーム分見える」状態だったが、RPC限定化により是正済み（本セクション参照）。

## 未実装・対象外のもの

- `backup_screen.dart`（`BackupService`）はローカルdrift DBを直接操作する機能のため、
  チーム共有モードでは意味を持たない。チームセッションがある場合は設定画面から
  「データバックアップ」タイル自体を非表示にする。
- リアルタイム同期（Supabase Realtime）は導入していない。他端末の変更を見るには
  画面の再読み込み（pull-to-refresh等）が必要。
- オフライン時の競合解決は未実装（チーム共有モードは常時ネットワーク接続が前提）。
