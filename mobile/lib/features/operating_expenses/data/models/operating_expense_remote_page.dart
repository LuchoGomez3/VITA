import 'package:freezed_annotation/freezed_annotation.dart';

part 'operating_expense_remote_page.freezed.dart';

/// Respuesta remota tipada antes de reconciliarla con SQLite.
@freezed
sealed class OperatingExpenseRemotePage with _$OperatingExpenseRemotePage {
  /// Crea una pagina con total central exacto y modelos sincronizados.
  const factory OperatingExpenseRemotePage({
    required List<OperatingExpenseRemoteDto> expenses,
    required int totalCents,
  }) = _OperatingExpenseRemotePage;
}

/// DTO de un egreso recibido desde HTTP, independiente de Brick y dominio.
@freezed
sealed class OperatingExpenseRemoteDto with _$OperatingExpenseRemoteDto {
  /// Crea un egreso remoto validado por el datasource.
  const factory OperatingExpenseRemoteDto({
    required String id,
    required String establishmentId,
    required String amount,
    required String type,
    required String category,
    required String supply,
    required DateTime date,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? description,
    String? receiptNumber,
    String? loadedById,
    String? loadedByName,
    DateTime? deletedAt,
  }) = _OperatingExpenseRemoteDto;
}

/// DTO de un tipo y sus categorias devueltos por el catalogo central.
@freezed
sealed class OperatingExpenseRemoteCatalogType with _$OperatingExpenseRemoteCatalogType {
  /// Crea un grupo remoto validado.
  const factory OperatingExpenseRemoteCatalogType({
    required String type,
    required List<OperatingExpenseRemoteCategory> categories,
  }) = _OperatingExpenseRemoteCatalogType;
}

/// DTO de una categoria del catalogo financiero.
@freezed
sealed class OperatingExpenseRemoteCategory with _$OperatingExpenseRemoteCategory {
  /// Crea una categoria remota validada.
  const factory OperatingExpenseRemoteCategory({
    required String value,
    required String label,
    required bool custom,
    String? id,
  }) = _OperatingExpenseRemoteCategory;
}
