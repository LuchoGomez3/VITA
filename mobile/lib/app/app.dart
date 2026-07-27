import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/config/config.dart';
import 'package:frontend_mayoral/app/router/app_router.dart';
import 'package:frontend_mayoral/app/theme/app_theme.dart';
import 'package:frontend_mayoral/features/auth/auth_composition.dart' as auth_composition;
import 'package:frontend_mayoral/features/auth/presentation/session/cubit/auth_session_cubit.dart';

/// Factory usada para construir el cubit global de sesion.
typedef AuthSessionCubitFactory = AuthSessionCubit Function();

/// Widget raiz de la aplicacion mobile.
class FrontendMayoralApp extends StatelessWidget {
  /// Crea la app y configura el estado global de sesion.
  const FrontendMayoralApp({
    super.key,
    AuthSessionCubitFactory? createAuthSessionCubit,
  }) : _createAuthSessionCubit = createAuthSessionCubit;

  final AuthSessionCubitFactory? _createAuthSessionCubit;

  @override
  Widget build(BuildContext context) {
    final createCubit = _createAuthSessionCubit ?? auth_composition.createAuthSessionCubit;

    return BlocProvider<AuthSessionCubit>(
      create: (_) => createCubit()..restoreSession(),
      child: MaterialApp.router(
        title: AppConfig.current.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
