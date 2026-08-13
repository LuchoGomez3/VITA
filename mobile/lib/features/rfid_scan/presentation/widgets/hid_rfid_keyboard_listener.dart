import 'package:flutter/material.dart';

/// Mantiene el foco de teclado mientras una lectura HID esta activa.
///
/// El widget no interpreta los caracteres recibidos. Solo entrega los eventos
/// de teclado al callback para que la fuente HID acumule la lectura y detecte
/// el Enter final enviado por el baston.
class HidRfidKeyboardListener extends StatefulWidget {
  /// Crea el contenedor que captura las teclas del baston RFID.
  const HidRfidKeyboardListener({
    required this.isListening,
    required this.onKeyEvent,
    required this.child,
    super.key,
  });

  /// Indica si el contenedor debe conservar el foco para recibir lecturas HID.
  final bool isListening;

  /// Recibe las teclas emitidas por el baston HID.
  final ValueChanged<KeyEvent> onKeyEvent;

  /// Contenido visual que se muestra durante la captura.
  final Widget child;

  @override
  State<HidRfidKeyboardListener> createState() => _HidRfidKeyboardListenerState();
}

class _HidRfidKeyboardListenerState extends State<HidRfidKeyboardListener> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.isListening) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant HidRfidKeyboardListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !oldWidget.isListening) {
      _focusNode.requestFocus();
      return;
    }

    if (!widget.isListening && oldWidget.isListening) {
      _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: widget.isListening ? widget.onKeyEvent : (_) {},
      child: widget.child,
    );
  }
}
