import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/database/local_database.dart';
import '../../../main.dart' show currentTeamSession;
import '../../../shared/providers/supabase_provider.dart';
import '../domain/evaluation_criteria_repository.dart';
import 'supabase_evaluation_criteria_repository.dart';

part 'local_evaluation_criteria_repository.g.dart';

@riverpod
EvaluationCriteriaRepository evaluationCriteriaRepository(Ref ref) {
  final session = currentTeamSession;
  if (session != null) {
    return SupabaseEvaluationCriteriaRepository(ref.watch(supabaseProvider), session.teamId);
  }
  return LocalEvaluationCriteriaRepository(ref.watch(appDatabaseProvider));
}

/// 評価基準・得点帯はダッシュボード/チーム分析/チームレポートで選手数×項目数分
/// 繰り返し参照される（[evaluate]がその都度[getCriteriaForItem]・[getBands]を
/// 呼ぶため）。基準データは設定画面からの編集以外では変化しないため、
/// itemKey単位・criteriaId単位でメモリキャッシュし、変更系メソッドの完了時に
/// 破棄することでN+1的なDB往復を避ける。
class LocalEvaluationCriteriaRepository implements EvaluationCriteriaRepository {
  LocalEvaluationCriteriaRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  final _criteriaCache = <String, List<EvaluationCriterion>>{};
  final _bandsCache = <String, List<ScoreBand>>{};

  void _invalidateCache() {
    _criteriaCache.clear();
    _bandsCache.clear();
  }

  @override
  Future<List<EvaluationCriterion>> getCriteriaForItem(String itemKey) async {
    final cached = _criteriaCache[itemKey];
    if (cached != null) return cached;

    final result = await (_db.select(_db.evaluationCriteria)
          ..where((t) => t.itemKey.equals(itemKey)))
        .get();
    _criteriaCache[itemKey] = result;
    return result;
  }

  @override
  Future<List<ScoreBand>> getBands(String criteriaId) async {
    final cached = _bandsCache[criteriaId];
    if (cached != null) return cached;

    final result = await (_db.select(_db.scoreBands)
          ..where((t) => t.criteriaId.equals(criteriaId)))
        .get();
    _bandsCache[criteriaId] = result;
    return result;
  }

  @override
  Future<int?> evaluate({
    required String itemKey,
    required double value,
    String? position,
  }) async {
    final criteria = await getCriteriaForItem(itemKey);
    if (criteria.isEmpty) return null;

    // ポジション別基準があれば優先し、無ければポジション共通(position=null)を使う。
    // 将来、選手の性別・学年でもフィルタする際はここを拡張する。
    EvaluationCriterion? findBy(bool Function(EvaluationCriterion) test) {
      for (final c in criteria) {
        if (test(c)) return c;
      }
      return null;
    }

    final matched = (position != null ? findBy((c) => c.position == position) : null) ??
        findBy((c) => c.position == null) ??
        criteria.first;

    final bands = await getBands(matched.id);
    for (final band in bands) {
      final aboveMin = band.minValue == null || value >= band.minValue!;
      final belowMax = band.maxValue == null || value <= band.maxValue!;
      if (aboveMin && belowMax) return band.score;
    }
    return null;
  }

  @override
  Future<String> createCriterion({
    required String itemKey,
    required String name,
    String? position,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.evaluationCriteria).insert(
          EvaluationCriteriaCompanion.insert(
            id: id,
            name: name,
            itemKey: itemKey,
            position: Value(position),
          ),
        );
    _invalidateCache();
    return id;
  }

  @override
  Future<void> deleteCriterion(String id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.scoreBands)..where((t) => t.criteriaId.equals(id))).go();
      await (_db.delete(_db.evaluationCriteria)..where((t) => t.id.equals(id))).go();
    });
    _invalidateCache();
  }

  @override
  Future<String> upsertBand({
    String? id,
    required String criteriaId,
    required int score,
    double? minValue,
    double? maxValue,
  }) async {
    final bandId = id ?? _uuid.v4();
    await _db.into(_db.scoreBands).insertOnConflictUpdate(
          ScoreBandsCompanion(
            id: Value(bandId),
            criteriaId: Value(criteriaId),
            score: Value(score),
            minValue: Value(minValue),
            maxValue: Value(maxValue),
          ),
        );
    _invalidateCache();
    return bandId;
  }

  @override
  Future<void> deleteBand(String id) async {
    await (_db.delete(_db.scoreBands)..where((t) => t.id.equals(id))).go();
    _invalidateCache();
  }
}
