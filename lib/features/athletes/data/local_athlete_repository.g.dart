// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_athlete_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// チームセッションがあればSupabase実装、無ければローカル実装を返す。
/// テストは`currentTeamSession`を設定しないため常にローカル実装を使う。

@ProviderFor(athleteRepository)
final athleteRepositoryProvider = AthleteRepositoryProvider._();

/// チームセッションがあればSupabase実装、無ければローカル実装を返す。
/// テストは`currentTeamSession`を設定しないため常にローカル実装を使う。

final class AthleteRepositoryProvider
    extends
        $FunctionalProvider<
          AthleteRepository,
          AthleteRepository,
          AthleteRepository
        >
    with $Provider<AthleteRepository> {
  /// チームセッションがあればSupabase実装、無ければローカル実装を返す。
  /// テストは`currentTeamSession`を設定しないため常にローカル実装を使う。
  AthleteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'athleteRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$athleteRepositoryHash();

  @$internal
  @override
  $ProviderElement<AthleteRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AthleteRepository create(Ref ref) {
    return athleteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AthleteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AthleteRepository>(value),
    );
  }
}

String _$athleteRepositoryHash() => r'4e74e4121b7159d71986d8f4a83f71f05b363bb9';
