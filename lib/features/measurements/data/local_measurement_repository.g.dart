// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_measurement_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(measurementRepository)
final measurementRepositoryProvider = MeasurementRepositoryProvider._();

final class MeasurementRepositoryProvider
    extends
        $FunctionalProvider<
          MeasurementRepository,
          MeasurementRepository,
          MeasurementRepository
        >
    with $Provider<MeasurementRepository> {
  MeasurementRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'measurementRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$measurementRepositoryHash();

  @$internal
  @override
  $ProviderElement<MeasurementRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MeasurementRepository create(Ref ref) {
    return measurementRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MeasurementRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MeasurementRepository>(value),
    );
  }
}

String _$measurementRepositoryHash() =>
    r'740f63600462f82b7b3489fc47cda331f96a5eda';
