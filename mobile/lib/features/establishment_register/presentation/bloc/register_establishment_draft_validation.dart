import 'package:frontend_mayoral/core/formatters/formatters.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/services/field_boundary_geometry.dart';
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
  /// leida del GPS (no se puede avanzar con coordenadas sin confirmar, ya que
  /// hoy no hay mapa real para verificarlas a simple vista).
  bool get isLocationStepValid =>
      provincia.isNotEmpty && departamento.isNotEmpty && localidad.isNotEmpty && ubicacionConfirmadaPorGps;

  /// Paso 4: un polígono válido o, si no se dibujó, una superficie cargada a
  /// mano mayor a cero. Ver [surfaceStepIssue].
  bool get isSurfaceStepValid => surfaceStepIssue == null;

  /// Qué le falta al paso 4 para poder avanzar, o `null` si está completo.
  SurfaceStepIssue? get surfaceStepIssue {
    if (poligono.isEmpty) {
      return (superficieManualHectareas ?? 0) > 0 ? null : SurfaceStepIssue.missingSurface;
    }
    if (poligono.length < 3) {
      return SurfaceStepIssue.tooFewVertices;
    }
    if (FieldBoundaryGeometry.selfIntersects(poligono)) {
      return SurfaceStepIssue.selfIntersecting;
    }
    if (superficieHectareas <= 0) {
      return SurfaceStepIssue.missingSurface;
    }
    return null;
  }

  /// Superficie del campo: el área del polígono si hay al menos 3 vértices,
  /// si no la cargada a mano (0 si no hay ninguna).
  double get superficieHectareas => poligono.length >= 3
      ? FieldBoundaryGeometry.areaHectares(poligono)
      : poligono.isEmpty
      ? superficieManualHectareas ?? 0
      : 0;

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

/// Motivo por el que el paso 4 todavía no puede avanzar.
enum SurfaceStepIssue {
  /// No hay polígono ni superficie cargada a mano.
  missingSurface,

  /// El polígono tiene 1 o 2 vértices.
  tooFewVertices,

  /// Dos lados del polígono se cruzan.
  selfIntersecting,
}
