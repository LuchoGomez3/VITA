import 'package:freezed_annotation/freezed_annotation.dart';

part 'operating_expense_remote_page.freezed.dart';
part 'operating_expense_remote_page.g.dart';

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
  @JsonSerializable(checked: true)
  const factory OperatingExpenseRemoteDto({
    required String id,
    @JsonKey(name: 'establecimiento_id') required String establishmentId,
    @JsonKey(name: 'monto') required String amount,
    @JsonKey(name: 'tipo') required String type,
    @JsonKey(name: 'categoria') required String category,
    @JsonKey(name: 'insumo') required String supply,
    @JsonKey(name: 'fecha') required DateTime date,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'descripcion') String? description,
    @JsonKey(name: 'numero_comprobante') String? receiptNumber,
    @JsonKey(name: 'cargado_por_id') String? loadedById,
    @JsonKey(name: 'cargado_por') OperatingExpenseRemoteUserDto? loadedBy,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  }) = _OperatingExpenseRemoteDto;

  /// Deserializa el contrato JSON de un egreso.
  factory OperatingExpenseRemoteDto.fromJson(Map<String, dynamic> json) => _$OperatingExpenseRemoteDtoFromJson(json);
}

/// Datos remotos mínimos del usuario que cargó el egreso.
@freezed
sealed class OperatingExpenseRemoteUserDto with _$OperatingExpenseRemoteUserDto {
  /// Crea los datos de auditoría recibidos desde backend.
  @JsonSerializable(checked: true)
  const factory OperatingExpenseRemoteUserDto({
    @JsonKey(name: 'nombre') String? firstName,
    @JsonKey(name: 'apellido') String? lastName,
    String? email,
  }) = _OperatingExpenseRemoteUserDto;

  /// Deserializa el contrato JSON de auditoría.
  factory OperatingExpenseRemoteUserDto.fromJson(Map<String, dynamic> json) =>
      _$OperatingExpenseRemoteUserDtoFromJson(json);
}

/// DTO de un tipo y sus categorias devueltos por el catalogo central.
@freezed
sealed class OperatingExpenseRemoteCatalogType with _$OperatingExpenseRemoteCatalogType {
  /// Crea un grupo remoto validado.
  @JsonSerializable(checked: true)
  const factory OperatingExpenseRemoteCatalogType({
    @JsonKey(name: 'valor') required String type,
    @JsonKey(name: 'categorias') required List<OperatingExpenseRemoteCategory> categories,
  }) = _OperatingExpenseRemoteCatalogType;

  /// Deserializa un grupo del catálogo remoto.
  factory OperatingExpenseRemoteCatalogType.fromJson(
    Map<String, dynamic> json,
  ) => _$OperatingExpenseRemoteCatalogTypeFromJson(json);
}

/// DTO de una categoria del catalogo financiero.
@freezed
sealed class OperatingExpenseRemoteCategory with _$OperatingExpenseRemoteCategory {
  /// Crea una categoria remota validada.
  @JsonSerializable(checked: true)
  const factory OperatingExpenseRemoteCategory({
    @JsonKey(name: 'valor') required String value,
    @JsonKey(name: 'etiqueta') required String label,
    @JsonKey(name: 'personalizada') required bool custom,
    String? id,
  }) = _OperatingExpenseRemoteCategory;

  /// Deserializa una categoría del catálogo remoto.
  factory OperatingExpenseRemoteCategory.fromJson(Map<String, dynamic> json) =>
      _$OperatingExpenseRemoteCategoryFromJson(json);
}
