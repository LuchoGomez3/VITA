import 'package:flutter/material.dart';

/// Pantalla tecnica de arranque mientras se restaura la sesion local.
///
/// No valida contra backend. Solo espera el resultado de secure storage:
/// - si hay sesion, entra a la app aunque no haya internet;
/// - si no hay sesion, deriva a la welcome publica.
class AuthCheckPage extends StatelessWidget {
  /// Crea la pantalla de restauracion.
  const AuthCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
