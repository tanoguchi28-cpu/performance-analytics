// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_evaluation_criteria_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(evaluationCriteriaRepository)
final evaluationCriteriaRepositoryProvider =
    EvaluationCriteriaRepositoryProvider._();

final class EvaluationCriteriaRepositoryProvider
    extends
        $FunctionalProvider<
          EvaluationCriteriaRepository,
          EvaluationCriteriaRepository,
          EvaluationCriteriaRepository
        >
    with $Provider<EvaluationCriteriaRepository> {
  EvaluationCriteriaRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'evaluationCriteriaRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$evaluationCriteriaRepositoryHash();

  @$internal
  @override
  $ProviderElement<EvaluationCriteriaRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EvaluationCriteriaRepository create(Ref ref) {
    return evaluationCriteriaRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EvaluationCriteriaRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EvaluationCriteriaRepository>(value),
    );
  }
}

String _$evaluationCriteriaRepositoryHash() =>
    r'99cd1443b35457aebe5db5c6c5ffdb41fd552787';
