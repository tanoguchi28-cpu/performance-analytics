// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_measurement_item_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(measurementItemRepository)
final measurementItemRepositoryProvider = MeasurementItemRepositoryProvider._();

final class MeasurementItemRepositoryProvider
    extends
        $FunctionalProvider<
          MeasurementItemRepository,
          MeasurementItemRepository,
          MeasurementItemRepository
        >
    with $Provider<MeasurementItemRepository> {
  MeasurementItemRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'measurementItemRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$measurementItemRepositoryHash();

  @$internal
  @override
  $ProviderElement<MeasurementItemRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MeasurementItemRepository create(Ref ref) {
    return measurementItemRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MeasurementItemRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MeasurementItemRepository>(value),
    );
  }
}

String _$measurementItemRepositoryHash() =>
    r'ae36bdf389686792c25c9b8fab01f48fa6f7f3b7';
