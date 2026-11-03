import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/app_spacing.dart';
import 'package:frontend_mayoral/core/widgets/buttons/app_filled_button.dart';
import 'package:frontend_mayoral/features/auth/presentation/session/cubit/auth_session_cubit.dart';
import 'package:frontend_mayoral/features/auth/presentation/session/strings/auth_session_strings.dart';

/// Pantalla tecnica de arranque mientras se restaura la sesion local.
///
/// No valida contra backend. Solo espera el resultado de secure storage:
/// - si hay sesion, entra a la app aunque no haya internet;
/// - si no hay sesion, deriva a la welcome publica.
/// Una limpieza de sesión fallida muestra un reintento antes de permitir login.
class AuthCheckPage extends StatelessWidget {
  /// Crea la pantalla de restauracion.
  const AuthCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthSessionCubit, AuthSessionState>(
        builder: (context, state) => state is AuthSessionCleanupFailed
            ? SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(AuthSessionStrings.cleanupFailed, textAlign: TextAlign.center),
                        const SizedBox(height: AppSpacing.lg),
                        AppFilledButton(
                          label: AuthSessionStrings.retryCleanup,
                          onPressed: context.read<AuthSessionCubit>().signOut,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
