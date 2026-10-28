part of 'livestock_sale_bloc.dart';

/// Eventos aceptados por [LivestockSaleBloc].
@freezed
sealed class LivestockSaleEvent with _$LivestockSaleEvent {
  /// Busca una venta incompleta al ingresar al flujo.
  const factory LivestockSaleEvent.draftLoadRequested() = _DraftLoadRequested;

  /// Restaura el borrador que el usuario decidió continuar.
  const factory LivestockSaleEvent.draftRestoreAccepted() = _DraftRestoreAccepted;

  /// Descarta el borrador encontrado y comienza una venta vacía.
  const factory LivestockSaleEvent.savedDraftDiscardRequested() = _SavedDraftDiscardRequested;

  /// Reemplaza los campos editables conservados entre pasos.
  const factory LivestockSaleEvent.formChanged(
    LivestockSaleFormDraft form,
  ) = _FormChanged;

  /// Busca localmente una caravana y la agrega a la seleccion.
  const factory LivestockSaleEvent.animalAddRequested(
    String rfidTagNumber,
  ) = _AnimalAddRequested;

  /// Actualiza las sugerencias locales para el prefijo RFID ingresado.
  const factory LivestockSaleEvent.rfidPrefixChanged(String prefix) = _RfidPrefixChanged;

  /// Quita un animal de la seleccion actual.
  const factory LivestockSaleEvent.animalRemoveRequested(
    String animalId,
  ) = _AnimalRemoveRequested;

  /// Valida el paso actual y avanza si esta completo.
  const factory LivestockSaleEvent.nextStepRequested() = _NextStepRequested;

  /// Vuelve un paso sin modificar el borrador.
  const factory LivestockSaleEvent.previousStepRequested() = _PreviousStepRequested;

  /// Confirma localmente la venta mostrada en el resumen.
  const factory LivestockSaleEvent.submitRequested() = _SubmitRequested;

  /// Fuerza el último guardado antes de abandonar el flujo.
  const factory LivestockSaleEvent.saveAndExitRequested() = _SaveAndExitRequested;

  /// Elimina el progreso cuando el usuario confirma que desea descartarlo.
  const factory LivestockSaleEvent.discardAndExitRequested() = _DiscardAndExitRequested;
}
