import 'dart:convert';
import 'dart:typed_data';

import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/formatters/decimal_amount_formatter.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/models/operating_expense_remote_page.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/services/operating_expense_api_service.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense_history.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/errors/operating_expense_error.dart';
import 'package:http/http.dart' as http;

/// Interpreta respuestas HTTP de egresos sin exponer JSON al repositorio.
class OperatingExpenseRemoteDataSource {
  /// Crea la fuente remota.
  const OperatingExpenseRemoteDataSource({required OperatingExpenseApiService service}) : _service = service;

  final OperatingExpenseApiService _service;

  /// Descarga registros y conserva el total decimal informado por meta.
  Future<OperatingExpenseRemotePage> getExpenses(
    String establishmentId,
    OperatingExpenseFilters filters,
  ) async {
    final envelope = _envelope(await _service.getExpenses(establishmentId, filters));
    final rawData = envelope['data'];
    if (rawData is! List) throw _invalidResponse();
    final expenses = rawData.map(_expenseFrom).toList(growable: false);
    final meta = envelope['meta'];
    final total = meta is Map<String, dynamic> ? meta['total_egresos'] : null;
    return OperatingExpenseRemotePage(
      expenses: expenses,
      totalCents: total is String
          ? DecimalAmountFormatter.decimalToCents(total)
          : expenses
                .where((item) => item.deletedAt == null)
                .fold(
                  0,
                  (sum, item) => sum + DecimalAmountFormatter.decimalToCents(item.amount),
                ),
    );
  }

  /// Descarga categorias base y personalizadas agrupadas por tipo.
  Future<List<OperatingExpenseRemoteCatalogType>> getCatalog(String establishmentId) async {
    final data = _envelope(await _service.getCatalog(establishmentId))['data'];
    if (data is! List) throw _invalidResponse();
    return data.map(_catalogTypeFrom).toList(growable: false);
  }

  /// Descarga bytes y metadatos del CSV central.
  Future<OperatingExpenseExport> export(
    String establishmentId,
    OperatingExpenseFilters filters,
  ) async {
    final response = await _service.exportExpenses(establishmentId, filters);
    return OperatingExpenseExport(
      bytes: Uint8List.fromList(response.bodyBytes),
      filename: _filename(response.headers['content-disposition']) ?? 'egresos_operativos.csv',
      mediaType: response.headers['content-type']?.split(';').first ?? 'text/csv',
    );
  }

  Map<String, dynamic> _envelope(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      throw _invalidResponse();
    }
    throw _invalidResponse();
  }

  OperatingExpenseRemoteDto _expenseFrom(Object? raw) {
    if (raw is! Map<String, dynamic>) throw _invalidResponse();
    final loadedBy = raw['cargado_por'];
    return OperatingExpenseRemoteDto(
      id: _string(raw, 'id'),
      establishmentId: _string(raw, 'establecimiento_id'),
      amount: _string(raw, 'monto'),
      type: _string(raw, 'tipo'),
      category: _string(raw, 'categoria'),
      supply: _string(raw, 'insumo'),
      date: _date(raw, 'fecha'),
      description: _nullableString(raw, 'descripcion'),
      receiptNumber: _nullableString(raw, 'numero_comprobante'),
      loadedById: _nullableString(raw, 'cargado_por_id'),
      loadedByName: _loadedByName(loadedBy),
      createdAt: _date(raw, 'created_at'),
      updatedAt: _date(raw, 'updated_at'),
      deletedAt: _nullableDate(raw, 'deleted_at'),
    );
  }

  OperatingExpenseRemoteCatalogType _catalogTypeFrom(Object? raw) {
    if (raw is! Map<String, dynamic>) throw _invalidResponse();
    final typeValue = _string(raw, 'valor');
    final categories = raw['categorias'];
    if (categories is! List) throw _invalidResponse();
    return OperatingExpenseRemoteCatalogType(
      type: typeValue,
      categories: categories
          .map((item) {
            if (item is! Map<String, dynamic>) throw _invalidResponse();
            return OperatingExpenseRemoteCategory(
              value: _string(item, 'valor'),
              label: _string(item, 'etiqueta'),
              custom: item['personalizada'] == true,
              id: _nullableString(item, 'id'),
            );
          })
          .toList(growable: false),
    );
  }

  String _string(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
    throw _invalidResponse();
  }

  String? _nullableString(Map<String, dynamic> json, String key) {
    final value = json[key];
    return value is String && value.isNotEmpty ? value : null;
  }

  DateTime _date(Map<String, dynamic> json, String key) {
    final parsed = DateTime.tryParse(_string(json, key));
    if (parsed == null) throw _invalidResponse();
    return parsed;
  }

  DateTime? _nullableDate(Map<String, dynamic> json, String key) {
    final value = _nullableString(json, key);
    return value == null ? null : DateTime.tryParse(value);
  }

  String? _filename(String? disposition) => RegExp('filename="?([^";]+)').firstMatch(disposition ?? '')?.group(1);

  String? _loadedByName(Object? data) {
    if (data is! Map<String, dynamic>) return null;
    final firstName = data['nombre'] is String ? data['nombre']! as String : '';
    final lastName = data['apellido'] is String ? data['apellido']! as String : '';
    final fullName = '$firstName $lastName'.trim();
    if (fullName.isNotEmpty) return fullName;
    final email = data['email'];
    return email is String && email.isNotEmpty ? email : null;
  }

  DomainException _invalidResponse() => const DomainException(
    message: 'invalidResponse',
    reason: OperatingExpenseFailure.invalidResponse,
  );
}
