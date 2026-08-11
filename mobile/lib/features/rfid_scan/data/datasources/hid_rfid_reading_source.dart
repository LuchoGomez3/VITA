import 'dart:async';

import 'package:flutter/services.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/repositories/rfid_reading_source.dart';

/// Convierte las teclas emitidas por un baston HID en lecturas RFID completas.
///
/// El sistema operativo se encarga del emparejamiento Bluetooth y presenta el
/// baston como un teclado externo. Presentation debe reenviar cada caracter
/// recibido a [addKeystroke] y llamar [submitReading] cuando recibe Enter.
class HidRfidReadingSource implements RfidReadingSource {
  final StreamController<String> _readingsController = StreamController<String>.broadcast();
  final StringBuffer _readingBuffer = StringBuffer();
  bool _isReading = false;

  @override
  Stream<String> get readings => _readingsController.stream;

  @override
  bool get isReading => _isReading;

  @override
  Future<void> startReading() async {
    _readingBuffer.clear();
    _isReading = true;
  }

  @override
  Future<void> stopReading() async {
    _readingBuffer.clear();
    _isReading = false;
  }

  /// Agrega un caracter recibido desde el baston HID a la lectura en curso.
  ///
  /// No filtra caracteres: la validacion de los 15 digitos pertenece al caso
  /// de uso de identificacion, que debe poder informar una lectura invalida.
  void addKeystroke(String character) {
    if (!_isReading || character.isEmpty) {
      return;
    }

    _readingBuffer.write(character);
  }

  /// Procesa una tecla HID y publica la lectura al recibir Enter.
  void handleKeyEvent(KeyEvent event) {
    if (!_isReading || event is! KeyDownEvent) {
      return;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      submitReading();
      return;
    }

    final character = event.character;
    if (character != null) {
      addKeystroke(character);
    }
  }

  /// Publica la lectura acumulada cuando el baston envia su Enter final.
  void submitReading() {
    if (!_isReading || _readingBuffer.isEmpty) {
      return;
    }

    final reading = _readingBuffer.toString();
    _readingBuffer.clear();
    _readingsController.add(reading);
  }

  @override
  Future<void> dispose() async {
    _readingBuffer.clear();
    _isReading = false;
    await _readingsController.close();
  }
}
