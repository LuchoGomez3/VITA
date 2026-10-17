import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';

/// Establecimiento disponible para contextualizar el alta de un animal.
class AnimalRegistrationEstablishment {
  /// Crea una opcion seleccionable con identidad real y nombre visible.
  const AnimalRegistrationEstablishment({
    required this.id,
    required this.name,
  });

  /// UUID real del establecimiento.
  final String id;

  /// Nombre mostrado al productor.
  final String name;
}

/// Lote local disponible como destino del alta de un animal.
class AnimalRegistrationDestination {
  /// Crea una opción con UUID y texto listo para presentación.
  const AnimalRegistrationDestination({
    required this.id,
    required this.name,
    required this.details,
  });

  /// UUID real del lote.
  final String id;

  /// Nombre visible.
  final String name;

  /// Resumen productivo.
  final String details;
}

/// Contrato temporal para resolver el contexto de negocio del registro.
///
/// El formulario obtiene establecimientos y lotes para construir un
/// [AnimalRegistration] con IDs y nombres consistentes.
///
/// Este contrato mantiene esa resolucion fuera del BLoC mientras todavia no
/// existen todos los flujos reales de sesion y lotes.
///
/// Diseno final esperado:
/// - El usuario y el establecimiento seleccionado deberian venir de un
///   repository/use case de sesion.
/// - Los lotes deberian venir de un repository/use case propio.
///
/// Cuando esos datos reales existan, este contrato puede reducirse mucho o
/// eliminarse, reemplazandose por use cases especificos como
/// `WatchLotsUseCase`, `GetSelectedEstablishmentUseCase` o equivalentes.
abstract class AnimalRegistrationContext {
  /// Carga los establecimientos disponibles para el usuario autenticado.
  Future<List<AnimalRegistrationEstablishment>> loadEstablishments();

  /// Carga los lotes activos disponibles desde la caché local.
  Future<List<AnimalRegistrationDestination>> loadDestinations(
    String establishmentId,
  );

  /// Resuelve el ID de lote que espera backend desde la seleccion de destino.
  String resolveLotId(String destinationSelectionId);

  /// Resuelve el nombre visible del lote desde la seleccion de destino.
  String resolveLotName(String destinationSelectionId);
}
