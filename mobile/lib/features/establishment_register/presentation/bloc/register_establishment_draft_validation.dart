import 'package:frontend_mayoral/core/formatters/formatters.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/bloc/register_establishment_bloc.dart';

/// Reglas de validacion por paso, documentadas en
/// `.claude/specs/registrar-establecimiento.md`.
///
/// Se implementan como funciones puras sobre el draft para que el mismo
/// criterio sirva tanto para habilitar/deshabilitar "Siguiente"/"Crear
/// establecimiento" en la UI como para la revalidacion defensiva del BLoC
/// antes de armar el request.
extension RegisterEstablishmentDraftValidation on RegisterEstablishmentDraft {
  /// Paso 1: nombre obligatorio (hasta 60 caracteres) y al menos un tipo de
  /// produccion seleccionado.
  bool get isIdentificationStepValid => nombre.trim().isNotEmpty && nombre.length <= 60 && tiposProduccion.isNotEmpty;

  /// Paso 2: CUIT con digito verificador valido y RENSPA con formato
  /// `NN.NNN.N.NNNNN/NN` completo.
  bool get isRenspaStepValid =>
      CuitInputFormatter.validationError(cuitTitular) == null &&
      RenspaInputFormatter.validationError(nroRenspa) == null;

  /// Paso 3: provincia/departamento/localidad seleccionados y ubicacion
  /// confirmada explicitamente (no se puede avanzar con coordenadas sin
  /// confirmar, ya que hoy no hay mapa real para verificarlas a simple vista).
  bool get isLocationStepValid =>
      provincia.isNotEmpty && departamento.isNotEmpty && localidad.isNotEmpty && ubicacionConfirmadaPorGps;

  /// Indica si la ubicación sigue siendo el valor mock de "Usar mi ubicación
  /// actual" (no hay GPS real todavía). Bloquea el envío al backend sin
  /// impedir recorrer el resto del wizard.
  bool get isLocationMocked => latitud == mockLocationLatitud && longitud == mockLocationLongitud;

  /// Paso 4: superficie y vertices positivos. Hoy son siempre valores mock
  /// (replica visual estatica, ver spec), asi que la regla es trivialmente
  /// cierta hasta que exista un mapa real editable.
  bool get isSurfaceStepValid => superficieHectareas > 0 && cantidadVertices >= 3;

  /// Indica si el paso dado puede avanzar al siguiente / revisar puede crear.
  bool isValidForStep(RegisterEstablishmentStep step) => switch (step) {
    RegisterEstablishmentStep.identification => isIdentificationStepValid,
    RegisterEstablishmentStep.renspa => isRenspaStepValid,
    RegisterEstablishmentStep.location => isLocationStepValid,
    RegisterEstablishmentStep.surface => isSurfaceStepValid,
    RegisterEstablishmentStep.review =>
      isIdentificationStepValid && isRenspaStepValid && isLocationStepValid && isSurfaceStepValid,
  };
}
