import 'package:flutter/material.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';

/// Pantalla de éxito del alta de establecimiento. Maquetado en un commit posterior.
class EstablishmentRegisterSuccessPage extends StatelessWidget {
  /// Crea la pantalla de éxito con el establecimiento registrado.
  const EstablishmentRegisterSuccessPage({
    required this.registeredEstablishment,
    super.key,
  });

  /// Establecimiento devuelto por el flujo de alta.
  final RegisteredEstablishment registeredEstablishment;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Éxito (WIP)')),
    );
  }
}
