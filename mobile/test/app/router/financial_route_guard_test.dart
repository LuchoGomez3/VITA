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

  testWidgets('preserves protected content across parent rebuilds', (
    tester,
  ) async {
    final storage = _MemoryStorage(
      jsonEncode([
        {'id': 'allowed', 'name': 'Campo', 'role': 'owner'},
      ]),
    );
    final getRole = GetEstablishmentRoleUseCase(
      EstablishmentCatalog(secureStorage: storage),
    );

    await tester.pumpWidget(_RebuildableGuard(getRole: getRole));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Incrementar'));
    await tester.pump();

    expect(find.text('Estado: 1'), findsOneWidget);

    await tester.tap(find.textContaining('Reconstruir'));
    await tester.pump();

    expect(find.text('Estado: 1'), findsOneWidget);
    expect(storage.readCount, 1);
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
  int readCount = 0;

  @override
  Future<void> delete(String key) async {}

  @override
  Future<String?> read(String key) async {
    readCount++;
    return catalog;
  }

  @override
  Future<void> write({required String key, required String value}) async {}
}

class _RebuildableGuard extends StatefulWidget {
  const _RebuildableGuard({required this.getRole});

  final GetEstablishmentRoleUseCase getRole;

  @override
  State<_RebuildableGuard> createState() => _RebuildableGuardState();
}

class _RebuildableGuardState extends State<_RebuildableGuard> {
  var _rebuildCount = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            TextButton(
              onPressed: () => setState(() => _rebuildCount++),
              child: Text('Reconstruir $_rebuildCount'),
            ),
            Expanded(
              child: FinancialRouteGuard(
                establishmentId: 'allowed',
                getEstablishmentRole: widget.getRole,
                child: const _StatefulProtectedContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatefulProtectedContent extends StatefulWidget {
  const _StatefulProtectedContent();

  @override
  State<_StatefulProtectedContent> createState() => _StatefulProtectedContentState();
}

class _StatefulProtectedContentState extends State<_StatefulProtectedContent> {
  var _value = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Estado: $_value'),
        TextButton(
          onPressed: () => setState(() => _value++),
          child: const Text('Incrementar'),
        ),
      ],
    );
  }
}
