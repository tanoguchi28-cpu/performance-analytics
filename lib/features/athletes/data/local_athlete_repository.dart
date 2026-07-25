import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/database/local_database.dart';
import '../../../main.dart' show currentTeamSession;
import '../../../shared/providers/supabase_provider.dart';
import '../domain/athlete_repository.dart';
import 'supabase_athlete_repository.dart';

part 'local_athlete_repository.g.dart';

/// チームセッションがあればSupabase実装、無ければローカル実装を返す。
/// テストは`currentTeamSession`を設定しないため常にローカル実装を使う。
@riverpod
AthleteRepository athleteRepository(Ref ref) {
  final session = currentTeamSession;
  if (session != null) {
    return SupabaseAthleteRepository(ref.watch(supabaseProvider), session.teamId);
  }
  return LocalAthleteRepository(ref.watch(appDatabaseProvider));
}

class LocalAthleteRepository implements AthleteRepository {
  LocalAthleteRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  @override
  Future<List<Athlete>> getAll({bool activeOnly = true}) {
    final query = _db.select(_db.athletes)
      ..orderBy([(t) => OrderingTerm(expression: t.name)]);
    if (activeOnly) {
      query.where((t) => t.isActive.equals(true));
    }
    return query.get();
  }

  @override
  Future<Athlete?> getById(String id) {
    return (_db.select(_db.athletes)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<String> create(AthletesCompanion companion) async {
    final id = companion.id.present ? companion.id.value : _uuid.v4();
    await _db.into(_db.athletes).insert(companion.copyWith(id: Value(id)));
    return id;
  }

  @override
  Future<void> update(String id, AthletesCompanion companion) {
    return (_db.update(_db.athletes)..where((t) => t.id.equals(id)))
        .write(companion);
  }

  @override
  Future<void> deactivate(String id) {
    return (_db.update(_db.athletes)..where((t) => t.id.equals(id)))
        .write(const AthletesCompanion(isActive: Value(false)));
  }

  @override
  Future<void> delete(String id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.measurementRecords)..where((t) => t.athleteId.equals(id))).go();
      await (_db.delete(_db.athletes)..where((t) => t.id.equals(id))).go();
    });
  }
}
