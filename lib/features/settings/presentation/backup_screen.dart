import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/services/backup_service.dart';
import '../../../shared/widgets/confirm_delete_dialog.dart';
import '../../team_session/data/team_session_provider.dart';

/// 全データをJSONファイルにエクスポート/インポートするバックアップ画面。
/// インポートは既存データを全て置き換えるため、確認ダイアログを挟む。
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final bytes = await BackupService.exportToJson(db);
      final fileName =
          'performance_analytics_backup_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.json';

      final savedPath = await FilePicker.saveFile(
        dialogTitle: 'バックアップの保存先を選択',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(savedPath == null ? '保存をキャンセルしました' : 'エクスポートしました: $savedPath')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final bytes = result.files.single.bytes;
    if (bytes == null) return;
    if (!mounted) return;

    final confirmed = await confirmDelete(
      context,
      title: 'インポートしますか？',
      message: '選択したファイルの内容で、現在登録されている選手・測定データ・評価基準を'
          '全て置き換えます。この操作は取り消せません。',
      confirmLabel: '置き換える',
    );
    if (!confirmed) return;

    setState(() => _busy = true);
    try {
      final db = ref.read(appDatabaseProvider);
      await BackupService.importFromJson(db, bytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('インポートしました')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('インポートに失敗しました: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = ref.watch(canEditProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('データバックアップ')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('エクスポート', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        const Text('選手・測定データ・評価基準など全データをJSONファイルに書き出します。'),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _busy ? null : _export,
                          icon: const Icon(Icons.file_download_outlined),
                          label: const Text('エクスポートする'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('インポート', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        const Text(
                          'バックアップファイルから復元します。現在のデータは全て置き換えられるため、'
                          '事前に現在のデータもエクスポートしておくことをおすすめします。',
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: (_busy || !canEdit) ? null : _import,
                          icon: const Icon(Icons.file_upload_outlined),
                          label: const Text('インポートする'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_busy) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
