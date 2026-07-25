import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/database/local_database.dart';
import '../../../main.dart' show currentTeamSession;
import '../../../shared/providers/supabase_provider.dart';
import '../domain/measurement_item_repository.dart';
import 'supabase_measurement_item_repository.dart';

part 'local_measurement_item_repository.g.dart';

@riverpod
MeasurementItemRepository measurementItemRepository(Ref ref) {
  final session = currentTeamSession;
  if (session != null) {
    return SupabaseMeasurementItemRepository(ref.watch(supabaseProvider), session.teamId);
  }
  return LocalMeasurementItemRepository(ref.watch(appDatabaseProvider));
}

class LocalMeasurementItemRepository implements MeasurementItemRepository {
  LocalMeasurementItemRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  @override
  Future<List<MeasurementItem>> getAll({bool activeOnly = true}) {
    final query = _db.select(_db.measurementItems)
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]);
    if (activeOnly) {
      query.where((t) => t.isActive.equals(true));
    }
    return query.get();
  }

  @override
  Future<MeasurementItem?> getByKey(String key) {
    return (_db.select(_db.measurementItems)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
  }

  @override
  Future<String> create(MeasurementItemsCompanion companion) async {
    final id = companion.id.present ? companion.id.value : _uuid.v4();
    await _db
        .into(_db.measurementItems)
        .insert(companion.copyWith(id: Value(id)));
    return id;
  }

  @override
  Future<void> update(String id, MeasurementItemsCompanion companion) {
    return (_db.update(_db.measurementItems)..where((t) => t.id.equals(id)))
        .write(companion);
  }

  @override
  Future<void> deactivate(String id) {
    return (_db.update(_db.measurementItems)..where((t) => t.id.equals(id)))
        .write(const MeasurementItemsCompanion(isActive: Value(false)));
  }
}
