import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'senasa_report_models.freezed.dart';

/// An establishment available to the authenticated user.
@freezed
sealed class SenasaEstablishment with _$SenasaEstablishment {
  /// Creates an establishment used by SENASA report filters.
  const factory SenasaEstablishment({
    required String id,
    required String name,
    String? renspa,
  }) = _SenasaEstablishment;
}

/// Parameters accepted by the SENASA report endpoint.
@freezed
sealed class SenasaReportRequest with _$SenasaReportRequest {
  /// Creates a report request.
  const factory SenasaReportRequest({
    required String establishmentId,
    required String format,
    required DateTime from,
    required DateTime to,
    required String eventType,
    required String responsibleName,
    required String responsibleDni,
  }) = _SenasaReportRequest;
}

/// File returned by the SENASA report endpoint.
@freezed
sealed class GeneratedSenasaReport with _$GeneratedSenasaReport {
  /// Creates a generated report file.
  const factory GeneratedSenasaReport({
    required Uint8List bytes,
    required String filename,
    required String mediaType,
  }) = _GeneratedSenasaReport;
}
