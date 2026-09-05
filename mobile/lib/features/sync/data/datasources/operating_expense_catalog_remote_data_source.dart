import 'dart:convert';

import 'package:frontend_mayoral/brick/models/operating_expense_category.model.dart';
import 'package:http/http.dart' as http;

/// Descarga categorias financieras durante la preparacion offline inicial.
class OperatingExpenseCatalogRemoteDataSource {
  /// Crea la fuente sobre el cliente autenticado compartido por la composicion.
  const OperatingExpenseCatalogRemoteDataSource({
    required String backendBaseUrl,
    required http.Client client,
    DateTime Function()? now,
  }) : _backendBaseUrl = backendBaseUrl,
       _client = client,
       _now = now ?? DateTime.now;

  final String _backendBaseUrl;
  final http.Client _client;
  final DateTime Function() _now;

  /// Obtiene solo categorias personalizadas y las deja listas para SQLite.
  Future<List<BrickOperatingExpenseCategoryModel>> fetchCustomCategories(
    String establishmentId,
  ) async {
    final uri = Uri.parse(
      '$_backendBaseUrl/api/v1/egresos_operativos/catalogo',
    ).replace(queryParameters: {'establecimiento_id': establishmentId});
    final response = await _client.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException(
        'Operating expense catalog request failed.',
        uri,
      );
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic> || decoded['data'] is! List) {
      throw const FormatException('Invalid operating expense catalog.');
    }
    final timestamp = _now().toUtc();
    final categories = <BrickOperatingExpenseCategoryModel>[];
    for (final rawGroup in decoded['data'] as List) {
      if (rawGroup is! Map<String, dynamic> || rawGroup['valor'] is! String || rawGroup['categorias'] is! List) {
        throw const FormatException('Invalid operating expense catalog.');
      }
      final type = rawGroup['valor']! as String;
      for (final rawCategory in rawGroup['categorias'] as List) {
        if (rawCategory is! Map<String, dynamic> || rawCategory['personalizada'] != true) {
          continue;
        }
        final value = rawCategory['valor'];
        final label = rawCategory['etiqueta'];
        if (value is! String || label is! String) {
          throw const FormatException('Invalid operating expense catalog.');
        }
        categories.add(
          BrickOperatingExpenseCategoryModel(
            localId: 'catalog:$type:$value:$establishmentId',
            establishmentId: establishmentId,
            type: type,
            name: label,
            value: value,
            createdAt: timestamp,
            updatedAt: timestamp,
            syncStatus: BrickOperatingExpenseCategorySyncStatus.synchronized,
          ),
        );
      }
    }
    return categories;
  }
}
