import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';

/// Contrato temporal para resolver el contexto de negocio del registro.
///
/// El formulario trabaja con selecciones de UI: potrero elegido, categoria
/// visible, madre/padre seleccionados, etc. Para construir un
/// [AnimalRegistration] valido necesitamos convertir esas selecciones a IDs y
/// nombres consistentes con el backend.
///
/// Este contrato mantiene esa resolucion fuera del BLoC mientras todavia no
/// existen los flujos reales de sesion y catalogos. Hoy lo implementa un mock
/// temporal.
///
/// Diseno final esperado:
/// - El usuario y el establecimiento seleccionado deberian venir de un
///   repository/use case de sesion.
/// - Los lotes y categorias deberian venir de repositories/use cases propios,
///   idealmente cacheados localmente con Brick.
/// - Madre/padre deberian seleccionarse desde animales reales disponibles en el
///   establecimiento.
/// - El draft del formulario deberia guardar IDs reales, no claves mock de UI.
///
/// Cuando esos datos reales existan, este contrato puede reducirse mucho o
/// eliminarse, reemplazandose por use cases especificos como
/// `WatchLotsUseCase`, `WatchCategoriesUseCase`, `GetSelectedEstablishmentUseCase`
/// o equivalentes.
abstract class AnimalRegistrationContext {
  /// ID del establecimiento seleccionado para la sesion actual de registro.
  String get establishmentId;

  /// Resuelve el ID de lote que espera backend desde la seleccion de destino.
  String resolveLotId(String destinationSelectionId);

  /// Resuelve el nombre visible del lote desde la seleccion de destino.
  String resolveLotName(String destinationSelectionId);

  /// Resuelve el ID de categoria que espera backend desde el label de UI.
  String resolveCategoryId(String categoryName);

  /// Resuelve el ID backend de la madre desde la seleccion de UI.
  String? resolveMotherId(String? motherSelectionId);

  /// Resuelve el ID backend del padre desde la seleccion de UI.
  String? resolveFatherId(String? fatherSelectionId);
}
