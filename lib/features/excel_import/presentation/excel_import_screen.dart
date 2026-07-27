import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/local_database.dart';
import '../../../core/services/excel_workbook.dart';
import '../../athletes/data/local_athlete_repository.dart';
import '../../measurements/data/local_measurement_item_repository.dart';
import '../../measurements/data/local_measurement_repository.dart';
import '../../team_session/data/team_session_provider.dart';
import '../domain/excel_column_mapping.dart';
import '../domain/excel_import_row.dart';

const _newSessionValue = '__new__';

/// Excel(.xlsx)から測定データを取り込むウィザード。
/// ファイル選択 → 測定セッション選択 → 列マッピング → 確認・実行 の4ステップ。
class ExcelImportScreen extends ConsumerStatefulWidget {
  const ExcelImportScreen({super.key});

  @override
  ConsumerState<ExcelImportScreen> createState() => _ExcelImportScreenState();
}

class _ExcelImportScreenState extends ConsumerState<ExcelImportScreen> {
  int _currentStep = 0;
  bool _loadingRefData = true;

  // Step 0: ファイル・シート・ヘッダー行
  String? _fileName;
  ExcelWorkbook? _workbook;
  String? _selectedSheet;
  int _headerRowCount = 2;
  int _headerStartRow = 0;

  // 参照データ
  List<MeasurementItem> _items = [];
  List<Athlete> _existingAthletes = [];

  // Step 1: 測定セッション
  List<MeasurementSession> _sessions = [];
  String _sessionSelection = _newSessionValue;
  DateTime _newSessionDate = DateTime.now();
  final _newSessionLabelController = TextEditingController();

  // Step 2: 列マッピング
  List<ExcelColumnMapping> _mappings = [];

  // Step 3: 実行結果
  bool _importing = false;
  String? _resultSummary;

  @override
  void initState() {
    super.initState();
    _loadRefData();
  }

  @override
  void dispose() {
    _newSessionLabelController.dispose();
    super.dispose();
  }

  Future<void> _loadRefData() async {
    final items = await ref.read(measurementItemRepositoryProvider).getAll();
    final athletes = await ref.read(athleteRepositoryProvider).getAll();
    final sessions = await ref.read(measurementRepositoryProvider).getSessions();
    if (!mounted) return;
    setState(() {
      _items = items;
      _existingAthletes = athletes;
      _sessions = sessions;
      _loadingRefData = false;
    });
  }

  List<List<String?>> get _rows =>
      _selectedSheet == null ? const [] : (_workbook?.sheetRows(_selectedSheet!) ?? const []);

  List<String> get _columnLabels {
    final rows = _rows;
    if (rows.isEmpty) return const [];
    final colCount = rows.map((r) => r.length).fold<int>(0, (a, b) => a > b ? a : b);
    return List.generate(colCount, (col) {
      final parts = <String>[];
      for (var r = _headerStartRow; r < _headerStartRow + _headerRowCount && r < rows.length; r++) {
        final v = col < rows[r].length ? rows[r][col] : null;
        final cleaned = v?.replaceAll('\n', '').trim();
        if (cleaned != null && cleaned.isNotEmpty) parts.add(cleaned);
      }
      return parts.isEmpty ? '列${col + 1}' : parts.join(' ');
    });
  }

  int get _dataStartRow => _headerStartRow + _headerRowCount;

  List<ExcelImportRow> get _parsedRows {
    final rows = _rows;
    final result = <ExcelImportRow>[];
    for (var r = _dataStartRow; r < rows.length; r++) {
      final parsed = parseExcelRow(rows[r], _mappings);
      if (!parsed.isEmpty) result.add(parsed);
    }
    return result;
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) return;

    final workbook = ExcelWorkbook.fromBytes(bytes);
    setState(() {
      _fileName = file.name;
      _workbook = workbook;
      _selectedSheet = workbook.sheetNames.isNotEmpty ? workbook.sheetNames.first : null;
      _rebuildMappings();
    });
  }

  void _rebuildMappings() {
    final labels = _columnLabels;
    _mappings = List.generate(labels.length, (col) => _autoSuggest(col, labels[col]));
  }

  ExcelColumnMapping _autoSuggest(int col, String label) {
    final normalized = label.trim();

    if (normalized.toUpperCase().startsWith('NO') || normalized.contains('順位')) {
      return ExcelColumnMapping(columnIndex: col, headerLabel: label);
    }
    if (normalized.contains('名前') || normalized.contains('氏名')) {
      return ExcelColumnMapping(
        columnIndex: col,
        headerLabel: label,
        role: ExcelColumnRole.athleteName,
      );
    }
    if (normalized == 'P' || normalized.contains('ポジション')) {
      return ExcelColumnMapping(
        columnIndex: col,
        headerLabel: label,
        role: ExcelColumnRole.position,
      );
    }
    for (final item in _items) {
      if (normalized.contains(item.name)) {
        return ExcelColumnMapping(
          columnIndex: col,
          headerLabel: label,
          role: ExcelColumnRole.measurementItem,
          measurementItemId: item.id,
        );
      }
    }
    return ExcelColumnMapping(columnIndex: col, headerLabel: label);
  }

  Future<void> _executeImport() async {
    setState(() => _importing = true);

    final athleteRepo = ref.read(athleteRepositoryProvider);
    final measurementRepo = ref.read(measurementRepositoryProvider);

    final String sessionId;
    if (_sessionSelection == _newSessionValue) {
      sessionId = await measurementRepo.createSession(
        measurementDate: _newSessionDate,
        label: _newSessionLabelController.text.trim().isEmpty
            ? null
            : _newSessionLabelController.text.trim(),
      );
    } else {
      sessionId = _sessionSelection;
    }

    var createdAthletes = 0;
    var matchedAthletes = 0;
    var importedValues = 0;
    var skippedCells = 0;

    // 氏名で既存選手を照合するキャッシュ（新規作成した選手もここに追加していく）。
    // 作成直後のgetById再取得はネットワーク往復を無駄に増やすだけなので、
    // create()が返すidだけを保持する（後続行での重複名照合にはidで十分）。
    final athleteIdByName = {for (final a in _existingAthletes) a.name.trim(): a.id};

    for (final row in _parsedRows) {
      skippedCells += row.skippedCellCount;
      final name = row.athleteName?.trim();
      if (name == null || name.isEmpty) continue;

      String athleteId;
      final existingId = athleteIdByName[name];
      if (existingId == null) {
        athleteId = await athleteRepo.create(
          AthletesCompanion(
            name: Value(name),
            // gradeはUIから廃止済み。NOT NULL制約を満たすための内部固定値。
            grade: const Value(1),
            position: Value(row.position),
          ),
        );
        athleteIdByName[name] = athleteId;
        createdAthletes++;
      } else {
        athleteId = existingId;
        matchedAthletes++;
      }

      await Future.wait(row.values.entries.map((entry) => measurementRepo.upsertRecord(
            athleteId: athleteId,
            sessionId: sessionId,
            itemId: entry.key,
            value: entry.value,
          )));
      importedValues += row.values.length;
    }

    if (!mounted) return;
    setState(() {
      _importing = false;
      _resultSummary = '取り込み完了\n'
          '選手: 新規$createdAthletes名 / 既存$matchedAthletes名\n'
          '測定値: $importedValues件を保存'
          '${skippedCells > 0 ? '\n数値として読み取れず$skippedCells件をスキップしました' : ''}';
    });
  }

  static const _stepTitles = ['ファイル選択', '測定セッション', '列マッピング', '確認・実行'];

  @override
  Widget build(BuildContext context) {
    if (_loadingRefData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Excelインポート')),
      body: Column(
        children: [
          _buildStepHeader(context),
          const Divider(height: 1),
          Expanded(
            // 実機でStepperウィジェットを使うと、ステップ内容の高さが変わる際の
            // アニメーションと外側のSingleChildScrollViewのスクロール可能範囲の
            // 計算がずれ、最後まで下スクロールできなくなる不具合が確認されたため、
            // Stepperは使わず現在のステップの内容だけをシンプルにスクロール表示する。
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildCurrentStepContent(),
            ),
          ),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildStepHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ステップ ${_currentStep + 1} / ${_stepTitles.length}: ${_stepTitles[_currentStep]}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: (_currentStep + 1) / _stepTitles.length),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildFileStep();
      case 1:
        return _buildSessionStep();
      case 2:
        return _buildMappingStep();
      default:
        return _buildConfirmStep();
    }
  }

  Widget _buildBottomControls() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
        ),
        child: Row(
          children: [
            if (_currentStep > 0 && _resultSummary == null) ...[
              OutlinedButton(
                onPressed: () => setState(() => _currentStep -= 1),
                child: const Text('戻る'),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(child: _buildPrimaryButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton() {
    if (_resultSummary != null) {
      return FilledButton(
        onPressed: () => context.pop(),
        child: const Text('完了'),
      );
    }
    if (_currentStep == 3) {
      final canEdit = ref.watch(canEditProvider);
      return FilledButton(
        onPressed: (_importing || !canEdit) ? null : _executeImport,
        child: _importing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('インポートを実行'),
      );
    }
    return FilledButton(
      onPressed: _onStepContinue,
      child: const Text('次へ'),
    );
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      if (_workbook == null || _selectedSheet == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Excelファイルを選択してください')),
        );
        return;
      }
    }
    if (_currentStep == 1) {
      if (_sessionSelection == _newSessionValue && _newSessionDate.isAfter(DateTime.now())) {
        // 未来日でも許容する（大会前の目標登録等）。特にバリデーション不要。
      }
    }
    if (_currentStep < 3) {
      setState(() => _currentStep += 1);
    }
  }

  Widget _buildFileStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.upload_file),
          label: Text(_fileName ?? 'ファイルを選択 (.xlsx)'),
        ),
        if (_workbook != null) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedSheet,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'シート'),
            items: _workbook!.sheetNames
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() {
              _selectedSheet = v;
              _rebuildMappings();
            }),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StepperField(
                  label: 'ヘッダー開始行',
                  value: _headerStartRow + 1,
                  min: 1,
                  onChanged: (v) => setState(() {
                    _headerStartRow = v - 1;
                    _rebuildMappings();
                  }),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StepperField(
                  label: 'ヘッダー行数',
                  value: _headerRowCount,
                  min: 1,
                  max: 3,
                  onChanged: (v) => setState(() {
                    _headerRowCount = v;
                    _rebuildMappings();
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('検出された列（${_columnLabels.length}列）', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _columnLabels.take(40).map((l) => Chip(label: Text(l))).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSessionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final s in _sessions)
          RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            value: s.id,
            groupValue: _sessionSelection,
            title: Text(s.label ?? DateFormat('yyyy/MM/dd').format(s.measurementDate)),
            subtitle: Text(DateFormat('yyyy/MM/dd').format(s.measurementDate)),
            onChanged: (v) => setState(() => _sessionSelection = v!),
          ),
        RadioListTile<String>(
          contentPadding: EdgeInsets.zero,
          value: _newSessionValue,
          groupValue: _sessionSelection,
          title: const Text('新規セッションを作成'),
          onChanged: (v) => setState(() => _sessionSelection = v!),
        ),
        if (_sessionSelection == _newSessionValue) ...[
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _newSessionDate,
                firstDate: DateTime(DateTime.now().year - 5),
                lastDate: DateTime(DateTime.now().year + 1),
              );
              if (picked != null) setState(() => _newSessionDate = picked);
            },
            child: InputDecorator(
              decoration: const InputDecoration(labelText: '測定日 *'),
              child: Text(DateFormat('yyyy/MM/dd').format(_newSessionDate)),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _newSessionLabelController,
            decoration: const InputDecoration(labelText: 'ラベル'),
          ),
        ],
      ],
    );
  }

  Widget _buildMappingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '各列がアプリのどの項目に対応するか確認してください。'
          '「無視」のままの列は取り込まれません。',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < _mappings.length; i++) _buildMappingRow(i),
      ],
    );
  }

  Widget _buildMappingRow(int index) {
    final mapping = _mappings[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(mapping.headerLabel, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<ExcelColumnRole>(
              initialValue: mapping.role,
              isDense: true,
              isExpanded: true,
              items: ExcelColumnRole.values
                  .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                  .toList(),
              onChanged: (role) => setState(() {
                _mappings[index] = mapping.copyWith(
                  role: role,
                  clearMeasurementItemId: role != ExcelColumnRole.measurementItem,
                );
              }),
            ),
          ),
          if (mapping.role == ExcelColumnRole.measurementItem) ...[
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<String>(
                initialValue: mapping.measurementItemId,
                isDense: true,
                isExpanded: true,
                hint: const Text('項目を選択'),
                items: _items
                    .map((item) => DropdownMenuItem(value: item.id, child: Text(item.name)))
                    .toList(),
                onChanged: (itemId) => setState(() {
                  _mappings[index] = _mappings[index].copyWith(measurementItemId: itemId);
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfirmStep() {
    if (_resultSummary != null) {
      return Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(_resultSummary!),
        ),
      );
    }

    final rows = _parsedRows;
    final namedRows = rows.where((r) => (r.athleteName ?? '').isNotEmpty).toList();
    final existingNames = _existingAthletes.map((a) => a.name.trim()).toSet();
    final newCount = namedRows
        .map((r) => r.athleteName!.trim())
        .toSet()
        .where((n) => !existingNames.contains(n))
        .length;
    final totalValues = namedRows.fold<int>(0, (sum, r) => sum + r.values.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('対象行数: ${namedRows.length}行'),
        Text('新規選手: $newCount名 / 既存選手: ${namedRows.length - newCount}名'),
        Text('取り込む測定値: $totalValues件'),
        const SizedBox(height: 12),
        Text('プレビュー（先頭5行）', style: Theme.of(context).textTheme.labelLarge),
        for (final row in namedRows.take(5))
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(row.athleteName ?? ''),
            subtitle: Text(
              '${row.position ?? ''} / ${row.values.length}項目',
            ),
          ),
      ],
    );
  }
}

class _StepperField extends StatelessWidget {
  const _StepperField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 10,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: value > min ? () => onChanged(value - 1) : null,
        ),
        Text('$value'),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}
