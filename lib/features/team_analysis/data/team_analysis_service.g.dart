// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_analysis_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// チーム分析画面が必要とするデータ一式を集計する。
/// [sessionId]を省略すると最新セッションを対象にする。

@ProviderFor(teamAnalysisData)
final teamAnalysisDataProvider = TeamAnalysisDataFamily._();

/// チーム分析画面が必要とするデータ一式を集計する。
/// [sessionId]を省略すると最新セッションを対象にする。

final class TeamAnalysisDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<TeamAnalysisData>,
          TeamAnalysisData,
          FutureOr<TeamAnalysisData>
        >
    with $FutureModifier<TeamAnalysisData>, $FutureProvider<TeamAnalysisData> {
  /// チーム分析画面が必要とするデータ一式を集計する。
  /// [sessionId]を省略すると最新セッションを対象にする。
  TeamAnalysisDataProvider._({
    required TeamAnalysisDataFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'teamAnalysisDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$teamAnalysisDataHash();

  @override
  String toString() {
    return r'teamAnalysisDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<TeamAnalysisData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TeamAnalysisData> create(Ref ref) {
    final argument = this.argument as String?;
    return teamAnalysisData(ref, sessionId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TeamAnalysisDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$teamAnalysisDataHash() => r'c5e11bcaa30e38c338b83afa355c939ea6555235';

/// チーム分析画面が必要とするデータ一式を集計する。
/// [sessionId]を省略すると最新セッションを対象にする。

final class TeamAnalysisDataFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<TeamAnalysisData>, String?> {
  TeamAnalysisDataFamily._()
    : super(
        retry: null,
        name: r'teamAnalysisDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// チーム分析画面が必要とするデータ一式を集計する。
  /// [sessionId]を省略すると最新セッションを対象にする。

  TeamAnalysisDataProvider call({String? sessionId}) =>
      TeamAnalysisDataProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'teamAnalysisDataProvider';
}
