import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/datasources/operating_expense_remote_data_source.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/mappers/operating_expense_brick_mapper.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/services/operating_expense_api_service.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense_history.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/errors/operating_expense_error.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final tokenProvider = SessionBackendAccessTokenProvider.instance;

  setUp(() {
    tokenProvider.session = BackendTokenSession(
      accessToken: 'token',
      refreshToken: 'refresh',
      accessTokenExpiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
    );
  });

  tearDown(tokenProvider.clearAccessToken);

  test('parsea monto string, auditoria y respuesta no vacia', () async {
    final source = _source(
      tokenProvider,
      '{"success":true,"data":[{'
      '"id":"expense-id","establecimiento_id":"establishment-id","monto":"150000.25",'
      '"tipo":"costo_produccion","categoria":"sanidad","insumo":"Vacunas",'
      '"fecha":"2026-08-26","cargado_por_id":"user-id",'
      '"cargado_por":{"nombre":"Juan","apellido":"Pérez","email":"juan@example.com"},'
      '"created_at":"2026-08-26T12:00:00Z","updated_at":"2026-08-26T12:00:00Z","deleted_at":null'
      '}],"meta":{"total_egresos":"150000.25"},"errors":null}',
    );

    final page = await source.getExpenses(
      'establishment-id',
      const OperatingExpenseFilters(period: OperatingExpensePeriod.allHistory),
    );

    expect(page.totalCents, 15000025);
    expect(page.expenses.single.amount, '150000.25');
    expect(page.expenses.single.loadedBy?.firstName, 'Juan');
    expect(
      OperatingExpenseBrickMapper.fromRemote(page.expenses.single).loadedByName,
      'Juan Pérez',
    );
  });

  test('acepta respuesta vacia y total decimal cero', () async {
    final source = _source(
      tokenProvider,
      '{"success":true,"data":[],"meta":{"total_egresos":"0.00"},"errors":null}',
    );

    final page = await source.getExpenses(
      'establishment-id',
      const OperatingExpenseFilters(period: OperatingExpensePeriod.allHistory),
    );

    expect(page.expenses, isEmpty);
    expect(page.totalCents, 0);
  });

  for (final invalid in <String, Map<String, dynamic>>{
    'deleted_at inválido': _expense(deletedAt: 'fecha-inválida'),
    'tipo de egreso desconocido': _expense(type: 'otro_tipo'),
    'monto decimal inválido': _expense(amount: '150.999'),
  }.entries) {
    test('clasifica ${invalid.key} como invalidResponse', () async {
      final source = _source(
        tokenProvider,
        jsonEncode({
          'success': true,
          'data': [invalid.value],
          'meta': {'total_egresos': '150.00'},
        }),
      );

      await _expectInvalid(
        source.getExpenses(
          'establishment-id',
          const OperatingExpenseFilters(
            period: OperatingExpensePeriod.allHistory,
          ),
        ),
      );
    });
  }

  test('clasifica un tipo inválido del catálogo como invalidResponse', () async {
    final source = _source(
      tokenProvider,
      jsonEncode({
        'success': true,
        'data': [
          {
            'valor': 'otro_tipo',
            'categorias': [
              {
                'valor': 'reparacion',
                'etiqueta': 'Reparación',
                'personalizada': true,
              },
            ],
          },
        ],
      }),
    );

    await _expectInvalid(source.getCatalog('establishment-id'));
  });

  test('clasifica un total decimal inválido como invalidResponse', () async {
    final source = _source(
      tokenProvider,
      jsonEncode({
        'success': true,
        'data': <Object?>[],
        'meta': {'total_egresos': '0.999'},
      }),
    );

    await _expectInvalid(
      source.getExpenses(
        'establishment-id',
        const OperatingExpenseFilters(
          period: OperatingExpensePeriod.allHistory,
        ),
      ),
    );
  });
}

Future<void> _expectInvalid(Future<Object?> request) => expectLater(
  request,
  throwsA(
    isA<DomainException>().having(
      (error) => error.reason,
      'reason',
      OperatingExpenseFailure.invalidResponse,
    ),
  ),
);

Map<String, dynamic> _expense({
  String amount = '150.00',
  String type = 'costo_produccion',
  Object? deletedAt,
}) => {
  'id': 'expense-id',
  'establecimiento_id': 'establishment-id',
  'monto': amount,
  'tipo': type,
  'categoria': 'sanidad',
  'insumo': 'Vacunas',
  'fecha': '2026-08-26',
  'cargado_por_id': 'user-id',
  'created_at': '2026-08-26T12:00:00Z',
  'updated_at': '2026-08-26T12:00:00Z',
  'deleted_at': deletedAt,
};

OperatingExpenseRemoteDataSource _source(
  SessionBackendAccessTokenProvider tokenProvider,
  String body,
) => OperatingExpenseRemoteDataSource(
  service: OperatingExpenseApiService(
    baseUrl: 'https://example.test',
    tokenProvider: tokenProvider,
    client: MockClient(
      (_) async => http.Response(
        body,
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ),
    ),
  ),
);
