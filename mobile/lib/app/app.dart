import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/config/config.dart';
import 'package:frontend_mayoral/app/router/app_router.dart';
import 'package:frontend_mayoral/app/theme/app_theme.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/get_establishment_role_use_case.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/auth/auth_composition.dart' as auth_composition;
import 'package:frontend_mayoral/features/auth/presentation/session/cubit/auth_session_cubit.dart';
import 'package:go_router/go_router.dart';

/// Factory usada para construir el cubit global de sesion.
typedef AuthSessionCubitFactory = AuthSessionCubit Function();

/// Widget raiz de la aplicacion mobile.
class FrontendMayoralApp extends StatefulWidget {
  /// Crea la app y configura el estado global de sesion.
  const FrontendMayoralApp({
    super.key,
    AuthSessionCubitFactory? createAuthSessionCubit,
  }) : _createAuthSessionCubit = createAuthSessionCubit;

  final AuthSessionCubitFactory? _createAuthSessionCubit;

  @override
  State<FrontendMayoralApp> createState() => _FrontendMayoralAppState();
}

class _FrontendMayoralAppState extends State<FrontendMayoralApp> {
  late final AuthSessionCubit _authSessionCubit;
  late final AuthRouterRefreshNotifier _routerRefreshNotifier;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final createCubit = widget._createAuthSessionCubit ?? auth_composition.createAuthSessionCubit;
    _authSessionCubit = createCubit();
    _routerRefreshNotifier = AuthRouterRefreshNotifier(_authSessionCubit);
    _router = AppRouter.create(
      authSessionCubit: _authSessionCubit,
      refreshListenable: _routerRefreshNotifier,
      getEstablishmentRole: const GetEstablishmentRoleUseCase(
        EstablishmentCatalog(
          secureStorage: FlutterSecureStorageService(),
        ),
      ),
    );
    unawaited(_authSessionCubit.restoreSession());
  }

  @override
  void dispose() {
    _router.dispose();
    _routerRefreshNotifier.dispose();
    unawaited(_authSessionCubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthSessionCubit>.value(
      value: _authSessionCubit,
      child: MaterialApp.router(
        title: AppConfig.current.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: _router,
      ),
    );
  }
}
