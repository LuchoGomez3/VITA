import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/features/operating_expenses/data/services/operating_expense_api_service.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/entities/operating_expense_history.dart';
import 'package:frontend_mayoral/features/operating_expenses/domain/errors/operating_expense_error.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final tokenProvider = SessionBackendAccessTokenProvider.instance;

  setUp(() {
    tokenProvider
      ..clearAccessToken()
      ..session = BackendTokenSession(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        accessTokenExpiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
      );
  });

  tearDown(() {
    tokenProvider
      ..refreshCallback = null
      ..clearAccessToken();
  });

  test('exportacion envia exactamente establecimiento y filtros activos', () async {
    late http.Request captured;
    final service = _service(
      tokenProvider,
      MockClient((request) async {
        captured = request;
        return http.Response('csv', 200, headers: {'content-type': 'text/csv'});
      }),
    );
    final filters = OperatingExpenseFilters(
      period: OperatingExpensePeriod.custom,
      from: DateTime(2026, 8, 1),
      to: DateTime(2026, 8, 26),
      type: OperatingExpenseType.productionCost,
      category: 'sanidad',
    );

    await service.exportExpenses('establishment-id', filters);

    expect(captured.url.path, '/api/v1/egresos_operativos/exportar');
    expect(captured.url.queryParameters, {
      'establecimiento_id': 'establishment-id',
      'fecha_desde': '2026-08-01',
      'fecha_hasta': '2026-08-26',
      'tipo': 'costo_produccion',
      'categoria': 'sanidad',
    });
  });

  test('ante 401 renueva y reintenta una sola vez', () async {
    var calls = 0;
    tokenProvider.refreshCallback = (_) async => BackendTokenSession(
      accessToken: 'renewed-token',
      refreshToken: 'renewed-refresh',
      accessTokenExpiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
    );
    final service = _service(
      tokenProvider,
      MockClient((request) async {
        calls++;
        if (calls == 1) return http.Response('{}', 401);
        expect(request.headers['Authorization'], 'Bearer renewed-token');
        return http.Response('csv', 200);
      }),
    );

    await service.exportExpenses(
      'establishment-id',
      const OperatingExpenseFilters(period: OperatingExpensePeriod.allHistory),
    );

    expect(calls, 2);
  });

  test('mapea el codigo 403 financiero a una falla tipada', () async {
    final service = _service(
      tokenProvider,
      MockClient(
        (_) async => http.Response(
          '{"errors":[{"code":"acceso_financiero_denegado","message":"denied"}]}',
          403,
        ),
      ),
    );

    expect(
      () => service.getCatalog('establishment-id'),
      throwsA(
        isA<DomainException>().having(
          (error) => error.reason,
          'reason',
          OperatingExpenseFailure.accessDenied,
        ),
      ),
    );
  });

  test('mapea error de red como offline recuperable', () async {
    final service = _service(
      tokenProvider,
      MockClient((_) => throw http.ClientException('offline')),
    );

    expect(
      () => service.getCatalog('establishment-id'),
      throwsA(isA<DomainException>().having((error) => error.code, 'code', DomainErrorCode.offline)),
    );
  });
}

OperatingExpenseApiService _service(
  SessionBackendAccessTokenProvider tokenProvider,
  http.Client client,
) => OperatingExpenseApiService(baseUrl: 'https://example.test', tokenProvider: tokenProvider, client: client);
