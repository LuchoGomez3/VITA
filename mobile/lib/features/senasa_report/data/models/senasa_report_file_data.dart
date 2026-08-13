import 'dart:typed_data';

/// Respuesta binaria cruda obtenida por el data source remoto.
class SenasaReportFileData {
  /// Crea un archivo todavía independiente de las entidades de dominio.
  const SenasaReportFileData({
    required this.bytes,
    required this.filename,
    required this.mediaType,
  });

  /// Contenido exacto enviado por el backend.
  final Uint8List bytes;

  /// Nombre indicado por `Content-Disposition`.
  final String filename;

  /// Tipo MIME indicado por la respuesta HTTP.
  final String mediaType;
}
