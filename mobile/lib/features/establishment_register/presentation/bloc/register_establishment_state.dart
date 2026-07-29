part of 'register_establishment_bloc.dart';

/// Pasos del flujo de registro de establecimiento.
enum RegisterEstablishmentStep {
  /// Nombre, descripcion y tipo de produccion.
  identification,

  /// CUIT del titular y numero de RENSPA.
  renspa,

  /// Provincia, departamento, localidad y coordenadas.
  location,

  /// Delimitacion de la superficie del campo.
  surface,

  /// Revision final antes de crear el establecimiento.
  review,
}

/// Valores recolectados a lo largo del registro de establecimiento.
@freezed
sealed class RegisterEstablishmentDraft with _$RegisterEstablishmentDraft {
  /// Crea un borrador de registro de establecimiento.
  const factory RegisterEstablishmentDraft({
    required String nombre,
    required String descripcion,
    required Set<String> tiposProduccion,
    required String cuitTitular,
    required String nroRenspa,
    required String provincia,
    required String departamento,
    required String localidad,
    required double latitud,
    required double longitud,
    required bool ubicacionConfirmadaPorGps,
    required double superficieHectareas,
    required int cantidadVertices,
    required int cantidadUnidadesProductivas,
  }) = _RegisterEstablishmentDraft;

  /// Crea los valores iniciales mostrados actualmente por el flujo.
  ///
  // TODO(lucho): Son datos ficticios para la Etapa 1 (maquetado). La Etapa 2
  // los reemplaza por valores vacios una vez que exista validacion real.
  factory RegisterEstablishmentDraft.initial() => const RegisterEstablishmentDraft(
    nombre: 'La Sirena',
    descripcion: 'Cría y recría de Aberdeen Angus. 2.847 cab. en producción.',
    tiposProduccion: {'Cría', 'Recría'},
    cuitTitular: '20-21456789-3',
    nroRenspa: '07.123.0.00456/01',
    provincia: 'Córdoba',
    departamento: 'Río Cuarto',
    localidad: 'Coronel Moldes',
    latitud: -33.7242,
    longitud: -64.5891,
    ubicacionConfirmadaPorGps: true,
    superficieHectareas: 847,
    cantidadVertices: 7,
    cantidadUnidadesProductivas: 1,
  );
}

/// Estado inmutable del flujo completo de registro.
@freezed
sealed class RegisterEstablishmentState with _$RegisterEstablishmentState {
  /// Crea el estado del registro de establecimiento.
  const factory RegisterEstablishmentState({
    required RegisterEstablishmentStep currentStep,
    required RegisterEstablishmentDraft draft,
    @Default(ResultState<RegisteredEstablishment>.initial()) ResultState<RegisteredEstablishment> submitResult,
  }) = _RegisterEstablishmentState;
}
