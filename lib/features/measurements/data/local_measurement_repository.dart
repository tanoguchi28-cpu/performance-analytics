import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/database/local_database.dart';
import '../../../main.dart' show currentTeamSession;
import '../../../shared/providers/supabase_provider.dart';
import '../domain/measurement_repository.dart';
import 'supabase_measurement_repository.dart';

part 'local_measurement_repository.g.dart';

@riverpod
MeasurementRepository measurementRepository(Ref ref) {
  final session = currentTeamSession;
  if (session != null) {
    return SupabaseMeasurementRepository(ref.watch(supabaseProvider), session.teamId);
  }
  return LocalMeasurementRepository(ref.watch(appDatabaseProvider));
}

class LocalMeasurementRepository implements MeasurementRepository {
  LocalMeasurementRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  @override
  Future<List<MeasurementSession>> getSessions() {
    return (_db.select(_db.measurementSessions)
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.measurementDate,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  @override
  Future<MeasurementSession?> getSession(String id) {
    return (_db.select(_db.measurementSessions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<String> createSession({
    required DateTime measurementDate,
    String? label,
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.measurementSessions).insert(
          MeasurementSessionsCompanion.insert(
            id: id,
            measurementDate: measurementDate,
            label: Value(label),
            note: Value(note),
          ),
        );
    return id;
  }

  @override
  Future<void> deleteSession(String id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.measurementRecords)..where((t) => t.sessionId.equals(id))).go();
      await (_db.delete(_db.measurementSessions)..where((t) => t.id.equals(id))).go();
    });
  }

  @override
  Future<void> upsertRecord({
    required String athleteId,
    required String sessionId,
    required String itemId,
    required double value,
  }) async {
    final existing = await (_db.select(_db.measurementRecords)
          ..where((t) =>
              t.athleteId.equals(athleteId) &
              t.sessionId.equals(sessionId) &
              t.itemId.equals(itemId)))
        .getSingleOrNull();

    if (existing != null) {
      await (_db.update(_db.measurementRecords)
            ..where((t) => t.id.equals(existing.id)))
          .write(MeasurementRecordsCompanion(value: Value(value)));
      return;
    }

    await _db.into(_db.measurementRecords).insert(
          MeasurementRecordsCompanion.insert(
            id: _uuid.v4(),
            athleteId: athleteId,
            sessionId: sessionId,
            itemId: itemId,
            value: value,
          ),
        );
  }

  @override
  Future<void> deleteRecord({
    required String athleteId,
    required String sessionId,
    required String itemId,
  }) {
    return (_db.delete(_db.measurementRecords)
          ..where((t) =>
              t.athleteId.equals(athleteId) &
              t.sessionId.equals(sessionId) &
              t.itemId.equals(itemId)))
        .go();
  }

  @override
  Future<List<MeasurementRecord>> getRecordsForAthlete(String athleteId) {
    final query = _db.select(_db.measurementRecords).join([
      innerJoin(
        _db.measurementSessions,
        _db.measurementSessions.id.equalsExp(_db.measurementRecords.sessionId),
      ),
    ])
      ..where(_db.measurementRecords.athleteId.equals(athleteId))
      ..orderBy([OrderingTerm(expression: _db.measurementSessions.measurementDate)]);

    return query
        .map((row) => row.readTable(_db.measurementRecords))
        .get();
  }

  @override
  Future<List<MeasurementRecord>> getRecordsForSession(String sessionId) {
    return (_db.select(_db.measurementRecords)
          ..where((t) => t.sessionId.equals(sessionId)))
        .get();
  }
}
