// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_data_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dashboardData)
final dashboardDataProvider = DashboardDataProvider._();

final class DashboardDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<DashboardData>,
          DashboardData,
          FutureOr<DashboardData>
        >
    with $FutureModifier<DashboardData>, $FutureProvider<DashboardData> {
  DashboardDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardDataHash();

  @$internal
  @override
  $FutureProviderElement<DashboardData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DashboardData> create(Ref ref) {
    return dashboardData(ref);
  }
}

String _$dashboardDataHash() => r'231bcfd22b6b2678e88a3f11ddf501c53e9f5a82';

/// 指定セッション時点のチーム能力プロファイル。ダッシュボードの「チーム能力」
/// カードは既定で最新セッション（[dashboardData]が計算済みのもの）を表示するが、
/// ユーザーが別のセッションを選んだ場合にこのproviderで都度計算し直す。

@ProviderFor(teamAbilityProfileForSession)
final teamAbilityProfileForSessionProvider =
    TeamAbilityProfileForSessionFamily._();

/// 指定セッション時点のチーム能力プロファイル。ダッシュボードの「チーム能力」
/// カードは既定で最新セッション（[dashboardData]が計算済みのもの）を表示するが、
/// ユーザーが別のセッションを選んだ場合にこのproviderで都度計算し直す。

final class TeamAbilityProfileForSessionProvider
    extends
        $FunctionalProvider<
          AsyncValue<AbilityProfile>,
          AbilityProfile,
          FutureOr<AbilityProfile>
        >
    with $FutureModifier<AbilityProfile>, $FutureProvider<AbilityProfile> {
  /// 指定セッション時点のチーム能力プロファイル。ダッシュボードの「チーム能力」
  /// カードは既定で最新セッション（[dashboardData]が計算済みのもの）を表示するが、
  /// ユーザーが別のセッションを選んだ場合にこのproviderで都度計算し直す。
  TeamAbilityProfileForSessionProvider._({
    required TeamAbilityProfileForSessionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'teamAbilityProfileForSessionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$teamAbilityProfileForSessionHash();

  @override
  String toString() {
    return r'teamAbilityProfileForSessionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AbilityProfile> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AbilityProfile> create(Ref ref) {
    final argument = this.argument as String;
    return teamAbilityProfileForSession(ref, sessionId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TeamAbilityProfileForSessionProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$teamAbilityProfileForSessionHash() =>
    r'a0eb62b9a3d30da1891b424456c3ba8adb9827dc';

/// 指定セッション時点のチーム能力プロファイル。ダッシュボードの「チーム能力」
/// カードは既定で最新セッション（[dashboardData]が計算済みのもの）を表示するが、
/// ユーザーが別のセッションを選んだ場合にこのproviderで都度計算し直す。

final class TeamAbilityProfileForSessionFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AbilityProfile>, String> {
  TeamAbilityProfileForSessionFamily._()
    : super(
        retry: null,
        name: r'teamAbilityProfileForSessionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 指定セッション時点のチーム能力プロファイル。ダッシュボードの「チーム能力」
  /// カードは既定で最新セッション（[dashboardData]が計算済みのもの）を表示するが、
  /// ユーザーが別のセッションを選んだ場合にこのproviderで都度計算し直す。

  TeamAbilityProfileForSessionProvider call({required String sessionId}) =>
      TeamAbilityProfileForSessionProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'teamAbilityProfileForSessionProvider';
}
