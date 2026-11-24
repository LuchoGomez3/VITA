import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/composition/health_composition.dart';
import 'package:frontend_mayoral/app/config/config.dart';
import 'package:frontend_mayoral/app/router/app_router.dart';
import 'package:frontend_mayoral/app/theme/app_theme.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/get_establishment_role_use_case.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/core/widgets/app_toast_host.dart';
import 'package:frontend_mayoral/features/auth/auth_composition.dart' as auth_composition;
import 'package:frontend_mayoral/features/auth/presentation/session/cubit/auth_session_cubit.dart';
import 'package:frontend_mayoral/features/sync/sync_composition.dart';
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
  StreamSubscription<AuthSessionState>? _healthSession;
  StreamSubscription<List<ConnectivityResult>>? _healthConnection;
  StreamSubscription<Type>? _healthAnimals;

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
    if (widget._createAuthSessionCubit == null) {
      _healthSession = _authSessionCubit.stream.listen(_onHealthSession);
      _healthAnimals = watchHealthAnimalDependencies();
    }
    unawaited(_authSessionCubit.restoreSession());
  }

  void _onHealthSession(AuthSessionState state) {
    setHealthSessionActive(active: state is AuthSessionAuthenticated);
    if (state is! AuthSessionAuthenticated) {
      unawaited(_healthConnection?.cancel());
      _healthConnection = null;
      return;
    }
    _healthConnection ??= Connectivity().onConnectivityChanged.listen((results) {
      if (results.any((value) => value != ConnectivityResult.none)) {
        unawaited(requestHealthSync());
      } else {
        pauseHealthSync();
      }
    });
    unawaited(requestHealthSync());
  }

  @override
  void dispose() {
    unawaited(_healthSession?.cancel());
    unawaited(_healthConnection?.cancel());
    unawaited(_healthAnimals?.cancel());
    disposeHealthSync();
    _router.dispose();
    _routerRefreshNotifier.dispose();
    unawaited(_authSessionCubit.close());
    unawaited(disposeOfflineSyncCoordinator());
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
        builder: (context, child) => AppToastHost(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
