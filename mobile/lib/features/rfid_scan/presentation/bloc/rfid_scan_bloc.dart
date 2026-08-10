import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/entities/identified_animal.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/repositories/rfid_reading_source.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/use_cases/find_animal_by_rfid_use_case.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/use_cases/validate_rfid_reading_use_case.dart';

part 'rfid_scan_bloc.freezed.dart';
part 'rfid_scan_event.dart';
part 'rfid_scan_state.dart';

/// Coordina el ciclo de lectura RFID y los resultados que muestra la UI.
///
/// La validacion de formato y la busqueda offline se incorporan mediante los
/// eventos de resultado. El BLoC no conoce si la lectura llega desde HID, BLE
/// o Bluetooth serial: solo controla el contrato [RfidReadingSource].
class RfidScanBloc extends Bloc<RfidScanEvent, RfidScanState> {
  /// Crea el BLoC para identificar animales desde una fuente de lecturas.
  RfidScanBloc({
    required RfidReadingSource readingSource,
    required ValidateRfidReadingUseCase validateRfidReadingUseCase,
    required FindAnimalByRfidUseCase findAnimalByRfidUseCase,
    required String establishmentId,
    this.readingTimeout = const Duration(seconds: 30),
  }) : _readingSource = readingSource,
       _validateRfidReadingUseCase = validateRfidReadingUseCase,
       _findAnimalByRfidUseCase = findAnimalByRfidUseCase,
       _establishmentId = establishmentId,
       super(const RfidScanState.inactive()) {
    on<_ListeningRequested>(_onListeningRequested);
    on<_Stopped>(_onStopped);
    on<_ReadingReceived>(_onReadingReceived);
    on<_InvalidReadingDetected>(_onInvalidReadingDetected);
    on<_AnimalFound>(_onAnimalFound);
    on<_AnimalNotFound>(_onAnimalNotFound);
    on<_TimeoutElapsed>(_onTimeoutElapsed);
    on<_ErrorOccurred>(_onErrorOccurred);
  }

  final RfidReadingSource _readingSource;
  final ValidateRfidReadingUseCase _validateRfidReadingUseCase;
  final FindAnimalByRfidUseCase _findAnimalByRfidUseCase;
  final String _establishmentId;

  /// Tiempo maximo para esperar una lectura antes de informar un timeout.
  final Duration readingTimeout;
  StreamSubscription<String>? _readingSubscription;
  Timer? _readingTimeoutTimer;

  /// Activa la fuente configurada y deja la UI lista para recibir una lectura.
  Future<void> _onListeningRequested(
    _ListeningRequested event,
    Emitter<RfidScanState> emit,
  ) async {
    try {
      _readingSubscription ??= _readingSource.readings.listen(
        (reading) => add(RfidScanEvent.readingReceived(reading: reading)),
        onError: (_, _) => add(const RfidScanEvent.errorOccurred()),
      );
      await _readingSource.startReading();
      _readingTimeoutTimer?.cancel();
      _readingTimeoutTimer = Timer(
        readingTimeout,
        () => add(const RfidScanEvent.timeoutElapsed()),
      );
      emit(const RfidScanState.listening());
    } on Object {
      await _stopReadingSource();
      emit(const RfidScanState.error());
    }
  }

  /// Detiene la fuente y descarta cualquier lectura HID que haya quedado parcial.
  Future<void> _onStopped(
    _Stopped event,
    Emitter<RfidScanState> emit,
  ) async {
    await _stopReadingSource();
    emit(const RfidScanState.inactive());
  }

  /// Valida la lectura recibida y busca el animal solo en la base local.
  Future<void> _onReadingReceived(
    _ReadingReceived event,
    Emitter<RfidScanState> emit,
  ) async {
    if (!_validateRfidReadingUseCase(event.reading)) {
      await _stopReadingSource();
      emit(RfidScanState.invalid(reading: event.reading));
      return;
    }

    await _stopReadingSource();
    final result = await _findAnimalByRfidUseCase(
      rfidTagNumber: event.reading,
      establishmentId: _establishmentId,
    );
    switch (result) {
      case Success<IdentifiedAnimal?>(:final data):
        if (data == null) {
          emit(RfidScanState.notFound(rfid: event.reading));
        } else {
          emit(RfidScanState.found(animal: data));
        }
      case Failure<IdentifiedAnimal?>():
        emit(const RfidScanState.error());
    }
  }

  /// Muestra el valor que rechazo la validacion de formato RFID.
  Future<void> _onInvalidReadingDetected(
    _InvalidReadingDetected event,
    Emitter<RfidScanState> emit,
  ) async {
    await _stopReadingSource();
    emit(RfidScanState.invalid(reading: event.reading));
  }

  /// Expone que la busqueda offline encontro un animal para el RFID leido.
  void _onAnimalFound(
    _AnimalFound event,
    Emitter<RfidScanState> emit,
  ) {
    emit(RfidScanState.found(animal: event.animal));
  }

  /// Expone que la busqueda offline no encontro un animal para el RFID leido.
  void _onAnimalNotFound(
    _AnimalNotFound event,
    Emitter<RfidScanState> emit,
  ) {
    emit(RfidScanState.notFound(rfid: event.rfid));
  }

  /// Informa que no llego una lectura antes de vencer el tiempo configurado.
  Future<void> _onTimeoutElapsed(
    _TimeoutElapsed event,
    Emitter<RfidScanState> emit,
  ) async {
    await _stopReadingSource();
    emit(const RfidScanState.timeout());
  }

  /// Muestra el error generico informado por la fuente de lecturas.
  Future<void> _onErrorOccurred(
    _ErrorOccurred event,
    Emitter<RfidScanState> emit,
  ) async {
    await _stopReadingSource();
    emit(const RfidScanState.error());
  }

  /// Cancela timeout, stream y captura de la fuente antes de mostrar un resultado.
  Future<void> _stopReadingSource() async {
    _readingTimeoutTimer?.cancel();
    _readingTimeoutTimer = null;
    await _readingSubscription?.cancel();
    _readingSubscription = null;
    await _readingSource.stopReading();
  }

  /// Cancela la suscripcion a la fuente cuando se libera el BLoC.
  @override
  Future<void> close() async {
    await _stopReadingSource();
    await _readingSource.dispose();
    return super.close();
  }
}
