import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/features/auth/presentation/session/cubit/auth_session_cubit.dart';
import 'package:go_router/go_router.dart';

/// Pantalla tecnica de arranque mientras se restaura la sesion local.
///
/// No valida contra backend. Solo espera el resultado de secure storage:
/// - si hay sesion, entra a la app aunque no haya internet;
/// - si no hay sesion, deriva al login, que si requiere conectividad.
class AuthCheckPage extends StatelessWidget {
  /// Crea la pantalla de restauracion.
  const AuthCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthSessionCubit, AuthSessionState>(
      listener: _redirect,
      builder: (context, state) {
        // El listener cubre cambios futuros. Este post-frame cubre el caso en
        // que la restauracion haya terminado antes de construir esta pantalla.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            _redirect(context, state);
          }
        });

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  void _redirect(BuildContext context, AuthSessionState state) {
    switch (state) {
      case AuthSessionAuthenticated():
        context.go(AppRoutes.home);
      case AuthSessionUnauthenticated():
        context.go(AppRoutes.login);
      case AuthSessionChecking():
        break;
    }
  }
}
