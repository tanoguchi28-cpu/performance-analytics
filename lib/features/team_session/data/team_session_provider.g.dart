// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// [currentTeamSession]（main.dartのグローバル、ルーターが同期参照）をリアクティブに
/// 公開するプロバイダ。オンボーディング完了時・サインアウト時に画面側から更新する。

@ProviderFor(TeamSessionState)
final teamSessionStateProvider = TeamSessionStateProvider._();

/// [currentTeamSession]（main.dartのグローバル、ルーターが同期参照）をリアクティブに
/// 公開するプロバイダ。オンボーディング完了時・サインアウト時に画面側から更新する。
final class TeamSessionStateProvider
    extends $NotifierProvider<TeamSessionState, TeamSession?> {
  /// [currentTeamSession]（main.dartのグローバル、ルーターが同期参照）をリアクティブに
  /// 公開するプロバイダ。オンボーディング完了時・サインアウト時に画面側から更新する。
  TeamSessionStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamSessionStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamSessionStateHash();

  @$internal
  @override
  TeamSessionState create() => TeamSessionState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TeamSession? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TeamSession?>(value),
    );
  }
}

String _$teamSessionStateHash() => r'448d459cfd5afffd8f257998ef23b5b3fcb1984d';

/// [currentTeamSession]（main.dartのグローバル、ルーターが同期参照）をリアクティブに
/// 公開するプロバイダ。オンボーディング完了時・サインアウト時に画面側から更新する。

abstract class _$TeamSessionState extends $Notifier<TeamSession?> {
  TeamSession? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TeamSession?, TeamSession?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TeamSession?, TeamSession?>,
              TeamSession?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
