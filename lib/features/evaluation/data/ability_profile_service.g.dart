// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ability_profile_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 指定セッションにおける選手の[AbilityProfile]をriverpod経由で取得する。

@ProviderFor(athleteAbilityProfile)
final athleteAbilityProfileProvider = AthleteAbilityProfileFamily._();

/// 指定セッションにおける選手の[AbilityProfile]をriverpod経由で取得する。

final class AthleteAbilityProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<AbilityProfile>,
          AbilityProfile,
          FutureOr<AbilityProfile>
        >
    with $FutureModifier<AbilityProfile>, $FutureProvider<AbilityProfile> {
  /// 指定セッションにおける選手の[AbilityProfile]をriverpod経由で取得する。
  AthleteAbilityProfileProvider._({
    required AthleteAbilityProfileFamily super.from,
    required ({String athleteId, String sessionId}) super.argument,
  }) : super(
         retry: null,
         name: r'athleteAbilityProfileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$athleteAbilityProfileHash();

  @override
  String toString() {
    return r'athleteAbilityProfileProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<AbilityProfile> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AbilityProfile> create(Ref ref) {
    final argument = this.argument as ({String athleteId, String sessionId});
    return athleteAbilityProfile(
      ref,
      athleteId: argument.athleteId,
      sessionId: argument.sessionId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AthleteAbilityProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$athleteAbilityProfileHash() =>
    r'f3a9393efd944827af324032abf70cff2726ba6e';

/// 指定セッションにおける選手の[AbilityProfile]をriverpod経由で取得する。

final class AthleteAbilityProfileFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<AbilityProfile>,
          ({String athleteId, String sessionId})
        > {
  AthleteAbilityProfileFamily._()
    : super(
        retry: null,
        name: r'athleteAbilityProfileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 指定セッションにおける選手の[AbilityProfile]をriverpod経由で取得する。

  AthleteAbilityProfileProvider call({
    required String athleteId,
    required String sessionId,
  }) => AthleteAbilityProfileProvider._(
    argument: (athleteId: athleteId, sessionId: sessionId),
    from: this,
  );

  @override
  String toString() => r'athleteAbilityProfileProvider';
}
