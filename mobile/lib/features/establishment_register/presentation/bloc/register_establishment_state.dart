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
    required int cantidadUnidadesProductivas,

    /// Vértices del polígono dibujado en el paso 4, en orden de recorrido.
    @Default(<BoundaryPoint>[]) List<BoundaryPoint> poligono,

    /// Superficie cargada a mano cuando no se dibuja el polígono. Si hay
    /// polígono, la superficie sale de su área y este valor se ignora.
    double? superficieManualHectareas,
  }) = _RegisterEstablishmentDraft;

  /// Crea los valores iniciales del formulario, todos vacíos.
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
    @Default(ResultState<CurrentLocation>.initial()) ResultState<CurrentLocation> locationResult,

    /// Lectura del GPS para marcar un vértice del paso 4. Separada de
    /// [locationResult] para que cada paso muestre solo sus propios errores.
    @Default(ResultState<CurrentLocation>.initial()) ResultState<CurrentLocation> boundaryGpsResult,

    /// Polígonos anteriores a cada edición del paso 4, para "Deshacer".
    @Default(<List<BoundaryPoint>>[]) List<List<BoundaryPoint>> boundaryHistory,
  }) = _RegisterEstablishmentState;
}
