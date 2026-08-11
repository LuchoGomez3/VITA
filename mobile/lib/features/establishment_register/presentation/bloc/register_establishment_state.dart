part of 'register_establishment_bloc.dart';

/// Coordenadas mock devueltas por el botón "Usar mi ubicación actual".
///
/// No hay paquete de GPS en el proyecto todavía (ver
/// .claude/specs/registrar-establecimiento.md): el botón siempre vuelve a
/// fijar este mismo punto de referencia. Se exponen para que el envío al
/// backend pueda bloquearse mientras la ubicación sea este valor simulado
/// (ver [RegisterEstablishmentDraftValidation.isLocationMocked]).
const mockLocationLatitud = -33.7242;

/// Ver [mockLocationLatitud].
const mockLocationLongitud = -64.5891;

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

  /// Crea los valores iniciales del formulario, vacios salvo la superficie
  /// delimitada (paso 4, replica visual estatica sin mapa real editable: ver
  /// `.claude/specs/registrar-establecimiento.md`).
  factory RegisterEstablishmentDraft.initial() => const RegisterEstablishmentDraft(
    nombre: '',
    descripcion: '',
    tiposProduccion: {},
    cuitTitular: '',
    nroRenspa: '',
    provincia: '',
    departamento: '',
    localidad: '',
    latitud: 0,
    longitud: 0,
    ubicacionConfirmadaPorGps: false,
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
