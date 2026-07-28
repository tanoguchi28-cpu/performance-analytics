// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_report_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(playerReport)
final playerReportProvider = PlayerReportFamily._();

final class PlayerReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<PlayerReportData>,
          PlayerReportData,
          FutureOr<PlayerReportData>
        >
    with $FutureModifier<PlayerReportData>, $FutureProvider<PlayerReportData> {
  PlayerReportProvider._({
    required PlayerReportFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'playerReportProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$playerReportHash();

  @override
  String toString() {
    return r'playerReportProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PlayerReportData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PlayerReportData> create(Ref ref) {
    final argument = this.argument as String;
    return playerReport(ref, athleteId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlayerReportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$playerReportHash() => r'ee26e3452829826ceed0b7998a44d406c272082e';

final class PlayerReportFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PlayerReportData>, String> {
  PlayerReportFamily._()
    : super(
        retry: null,
        name: r'playerReportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PlayerReportProvider call({required String athleteId}) =>
      PlayerReportProvider._(argument: athleteId, from: this);

  @override
  String toString() => r'playerReportProvider';
}
