part of 'livestock_sale_bloc.dart';

/// Eventos aceptados por [LivestockSaleBloc].
@freezed
sealed class LivestockSaleEvent with _$LivestockSaleEvent {
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
}
