import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/ai_insights/domain/athlete_insight.dart';
import '../../features/evaluation/domain/ability_profile.dart';
import '../../features/player_report/domain/player_report_models.dart';
import '../../features/team_report/domain/team_report_models.dart';

/// 選手個人ページのPDF（A4）を生成する。
///
/// 日本語表示のため `assets/fonts/NotoSansJP-Regular.ttf`（Noto Sans JP,
/// SIL Open Font License）を埋め込む。fl_chartで描画しているレーダー
/// チャート・推移グラフの画像化は今回のスコープでは行わず、テキスト・
/// 表形式の情報（プロフィール・測定結果一覧・評価・順位・AI分析・
/// コーチコメント）で構成する。
class PdfReportService {
  const PdfReportService._();

  static Future<Uint8List> buildPlayerReportPdf(PlayerReportData data) async {
    final fontData = await rootBundle.load('assets/fonts/NotoSansJP-Regular.ttf');
    final font = pw.Font.ttf(fontData);
    final theme = pw.ThemeData.withFont(base: font, bold: font);

    final doc = pw.Document(theme: theme);
    final athlete = data.athlete;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        footer: _buildFooter,
        build: (context) => [
          pw.Text(
            '選手個人ページ',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '出力日: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      athlete.name,
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                    ),
                    if (athlete.kana != null) pw.Text(athlete.kana!),
                    pw.SizedBox(height: 4),
                    if (athlete.position != null || athlete.jerseyNumber != null)
                      pw.Text(
                        [
                          if (athlete.position != null) athlete.position!,
                          if (athlete.jerseyNumber != null) '#${athlete.jerseyNumber}',
                        ].join(' / '),
                      ),
                    if (athlete.birthDate != null)
                      pw.Text('生年月日: ${DateFormat('yyyy/MM/dd').format(athlete.birthDate!)}'),
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('総合順位', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text(
                      data.overallRanking == null
                          ? '-'
                          : '${data.overallRanking!.rank} / ${data.overallRankingTeamSize}',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text('測定結果一覧', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          _buildResultsTable(data),
          pw.SizedBox(height: 16),
          _buildInsightSection(data.insight),
          if ((athlete.coachComment ?? '').trim().isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text('コーチコメント', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text(athlete.coachComment!),
            ),
          ],
        ],
      ),
    );

    return doc.save();
  }

  /// 複数ページになった際にページ番号を表示するフッター（1ページのみの場合は非表示）。
  static pw.Widget _buildFooter(pw.Context context) {
    if (context.pagesCount <= 1) return pw.SizedBox.shrink();
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        '${context.pageNumber} / ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
      ),
    );
  }

  /// チームレポートのPDF（A4）を生成する。選手個人ページと同様、
  /// チャート画像の埋め込みは行わずテキスト・表形式で構成する。
  static Future<Uint8List> buildTeamReportPdf(TeamReportData data) async {
    final fontData = await rootBundle.load('assets/fonts/NotoSansJP-Regular.ttf');
    final font = pw.Font.ttf(fontData);
    final theme = pw.ThemeData.withFont(base: font, bold: font);

    final doc = pw.Document(theme: theme);
    final insight = generateAthleteInsight(data.teamAbilityProfile);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        footer: _buildFooter,
        build: (context) => [
          pw.Text('チームレポート', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(
            '出力日: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}'
            '${data.session != null ? ' / 測定日: ${DateFormat('yyyy/MM/dd').format(data.session!.measurementDate)}' : ''}'
            ' / 登録選手数: ${data.athleteCount}名',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Text('チーム能力', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          _buildAbilityScoreTable(data.teamAbilityProfile),
          pw.SizedBox(height: 16),
          _buildInsightSection(insight),
          pw.SizedBox(height: 16),
          pw.Text('総合ランキング TOP10', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          _buildOverallRankingTable(data),
          pw.SizedBox(height: 16),
          pw.Text('項目別ランキング TOP3', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          _buildItemRankingTable(data),
          pw.SizedBox(height: 16),
          pw.Text('ポジション別比較（平均値）', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          _buildComparisonTable(data.positionComparison),
          pw.SizedBox(height: 16),
          pw.Text('年度別比較（平均値）', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          _buildComparisonTable(data.yearComparison),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildAbilityScoreTable(AbilityProfile profile) {
    return pw.TableHelper.fromTextArray(
      headers: const ['能力', '評価'],
      data: [
        for (final s in profile.scores)
          [s.category.label, s.hasData ? '${s.roundedScore}（${s.score!.toStringAsFixed(1)}）' : '評価なし'],
      ],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 10),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
    );
  }

  static pw.Widget _buildOverallRankingTable(TeamReportData data) {
    final top = data.overallRanking.take(10).toList();
    if (top.isEmpty) {
      return pw.Text('データがありません', style: const pw.TextStyle(fontSize: 10));
    }
    return pw.TableHelper.fromTextArray(
      headers: const ['順位', '選手名', '偏差値相当'],
      data: [
        for (final e in top) ['${e.rank}', e.athlete.name, e.averageDeviationScore.toStringAsFixed(1)],
      ],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 10),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
    );
  }

  static pw.Widget _buildItemRankingTable(TeamReportData data) {
    final itemsWithRanking =
        data.items.where((i) => (data.itemRankingsByItemId[i.id]?.isNotEmpty ?? false)).toList();
    if (itemsWithRanking.isEmpty) {
      return pw.Text('データがありません', style: const pw.TextStyle(fontSize: 10));
    }

    String rankLabel(String itemId, int index, String unit) {
      final ranking = data.itemRankingsByItemId[itemId]!;
      if (index >= ranking.length) return '-';
      final e = ranking[index];
      return '${e.athlete.name} (${e.value}$unit)';
    }

    return pw.TableHelper.fromTextArray(
      headers: const ['項目', '1位', '2位', '3位'],
      data: [
        for (final item in itemsWithRanking)
          [
            item.name,
            rankLabel(item.id, 0, item.unit),
            rankLabel(item.id, 1, item.unit),
            rankLabel(item.id, 2, item.unit),
          ],
      ],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
    );
  }

  static pw.Widget _buildComparisonTable(ComparisonTable table) {
    if (table.isEmpty) {
      return pw.Text('データがありません', style: const pw.TextStyle(fontSize: 10));
    }
    return pw.TableHelper.fromTextArray(
      headers: ['項目', ...table.columnLabels],
      data: [
        for (final row in table.rows)
          [row.item.name, for (final v in row.values) v == null ? '-' : v.toStringAsFixed(1)],
      ],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
    );
  }

  static pw.Widget _buildResultsTable(PlayerReportData data) {
    return pw.TableHelper.fromTextArray(
      headers: const ['項目', '記録', '前回比', '評価', '順位'],
      data: [
        for (final r in data.results)
          [
            r.item.name,
            r.latestValue == null ? '未測定' : '${r.latestValue} ${r.item.unit}',
            r.percentChange == null
                ? '-'
                : '${r.percentChange! > 0 ? '+' : ''}${r.percentChange!.toStringAsFixed(1)}%',
            r.evaluationScore == null ? '評価なし' : '${r.evaluationScore}',
            r.rank == null ? '-' : '${r.rank} / ${r.teamSize}',
          ],
      ],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 10),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellAlignment: pw.Alignment.centerLeft,
      cellAlignments: const {
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.center,
        4: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildInsightSection(AthleteInsight insight) {
    if (!insight.hasData) {
      return pw.Text('AI分析: 測定データが不足しているため分析できません', style: const pw.TextStyle(fontSize: 10));
    }

    pw.Widget bulletList(String title, List<String> items) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          for (final item in items)
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 12, top: 2),
              child: pw.Text('・$item', style: const pw.TextStyle(fontSize: 10)),
            ),
          pw.SizedBox(height: 8),
        ],
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('AI分析', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        bulletList(
          '強み',
          [for (final s in insight.strengths) '${s.category.label}（評価${s.roundedScore}）'],
        ),
        bulletList(
          '改善点',
          [for (final w in insight.weaknesses) '${w.category.label}（評価${w.roundedScore}）'],
        ),
        if (insight.trainingSuggestions.isNotEmpty)
          bulletList('トレーニング提案', insight.trainingSuggestions),
      ],
    );
  }
}
