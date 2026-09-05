import 'dart:convert';
import 'dart:typed_data';

import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/formatters/decimal_amount_formatter.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/models/operating_expense_remote_page.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/services/operating_expense_api_service.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense_history.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/errors/operating_expense_error.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

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
    if (total is! String) {
      throw _invalidResponse();
    }
    return OperatingExpenseRemotePage(
      expenses: expenses,
      totalCents: _parse(
        () => _decimalToCents(total, allowZero: true),
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
      if (decoded is Map<String, dynamic> && decoded['success'] == true) {
        return decoded;
      }
    } on FormatException {
      throw _invalidResponse();
    }
    throw _invalidResponse();
  }

  OperatingExpenseRemoteDto _expenseFrom(Object? raw) {
    if (raw is! Map<String, dynamic>) throw _invalidResponse();
    return _parse(() {
      final expense = OperatingExpenseRemoteDto.fromJson(raw);
      _requireValues([
        expense.id,
        expense.establishmentId,
        expense.category,
        expense.supply,
      ]);
      _validateType(expense.type);
      _decimalToCents(expense.amount);
      return expense;
    });
  }

  OperatingExpenseRemoteCatalogType _catalogTypeFrom(Object? raw) {
    if (raw is! Map<String, dynamic>) throw _invalidResponse();
    return _parse(() {
      final group = OperatingExpenseRemoteCatalogType.fromJson(raw);
      _validateType(group.type);
      for (final category in group.categories) {
        _requireValues([category.value, category.label]);
      }
      return group;
    });
  }

  int _decimalToCents(String amount, {bool allowZero = false}) {
    if (!RegExp(r'^\d+(?:\.\d{1,2})?$').hasMatch(amount)) {
      throw _invalidResponse();
    }
    final cents = DecimalAmountFormatter.decimalToCents(amount);
    if (cents < 0 || (!allowZero && cents == 0)) throw _invalidResponse();
    return cents;
  }

  void _validateType(String value) {
    if (!OperatingExpenseType.values.any((type) => type.value == value)) {
      throw _invalidResponse();
    }
  }

  void _requireValues(Iterable<String> values) {
    if (values.any((value) => value.trim().isEmpty)) throw _invalidResponse();
  }

  T _parse<T>(T Function() parse) {
    try {
      return parse();
    } on DomainException {
      rethrow;
    } on CheckedFromJsonException {
      throw _invalidResponse();
    } on FormatException {
      throw _invalidResponse();
    }
  }

  String? _filename(String? disposition) => RegExp('filename="?([^";]+)').firstMatch(disposition ?? '')?.group(1);

  DomainException _invalidResponse() => const DomainException(
    message: 'invalidResponse',
    reason: OperatingExpenseFailure.invalidResponse,
  );
}
