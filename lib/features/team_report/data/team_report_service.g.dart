// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_report_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(teamReport)
final teamReportProvider = TeamReportProvider._();

final class TeamReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<TeamReportData>,
          TeamReportData,
          FutureOr<TeamReportData>
        >
    with $FutureModifier<TeamReportData>, $FutureProvider<TeamReportData> {
  TeamReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamReportHash();

  @$internal
  @override
  $FutureProviderElement<TeamReportData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TeamReportData> create(Ref ref) {
    return teamReport(ref);
  }
}

String _$teamReportHash() => r'dbe78a755d2d2871092af7482315aed5f3c8e34a';
