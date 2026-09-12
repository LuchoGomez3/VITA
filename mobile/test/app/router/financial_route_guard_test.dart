import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/router/app_router.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/get_establishment_role_use_case.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/pages/financial_access_denied_page.dart';

void main() {
  testWidgets('allows the protected content for an owner', (tester) async {
    final storage = _MemoryStorage(
      jsonEncode([
        {'id': 'allowed', 'name': 'Campo', 'role': 'owner'},
      ]),
    );

    await tester.pumpWidget(_app(storage, 'allowed'));
    await tester.pumpAndSettle();

    expect(find.text('Contenido financiero'), findsOneWidget);
    expect(find.byType(FinancialAccessDeniedPage), findsNothing);
  });

  testWidgets('denies an employee and a missing membership', (tester) async {
    final storage = _MemoryStorage(
      jsonEncode([
        {'id': 'employee', 'name': 'Campo', 'role': 'employee'},
      ]),
    );

    for (final id in ['employee', 'missing']) {
      await tester.pumpWidget(_app(storage, id));
      await tester.pumpAndSettle();
      expect(find.byType(FinancialAccessDeniedPage), findsOneWidget);
    }
  });

  testWidgets('fails closed when the catalog is corrupt', (tester) async {
    final storage = _MemoryStorage('{invalid json');

    await tester.pumpWidget(_app(storage, 'allowed'));
    await tester.pumpAndSettle();

    expect(find.byType(FinancialAccessDeniedPage), findsOneWidget);
  });
}

Widget _app(SecureStorageService storage, String establishmentId) => MaterialApp(
  home: FinancialRouteGuard(
    establishmentId: establishmentId,
    getEstablishmentRole: GetEstablishmentRoleUseCase(
      EstablishmentCatalog(secureStorage: storage),
    ),
    child: const Text('Contenido financiero'),
  ),
);

class _MemoryStorage implements SecureStorageService {
  _MemoryStorage(this.catalog);

  final String? catalog;

  @override
  Future<void> delete(String key) async {}

  @override
  Future<String?> read(String key) async => catalog;

  @override
  Future<void> write({required String key, required String value}) async {}
}
