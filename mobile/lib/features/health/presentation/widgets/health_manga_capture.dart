import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/constants/health_registration_strings.dart';
import 'package:frontend_mayoral/core/formatters/rfid_input_formatter.dart';
import 'package:frontend_mayoral/core/rfid/hid_rfid_reading_source.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/hid_rfid_keyboard_listener.dart';

/// Captura sucesiva con bastón HID o caravana ingresada a mano.
class HealthMangaCapture extends StatefulWidget {
  /// Conecta las lecturas a la selección en curso.
  const HealthMangaCapture({required this.onTag, required this.enabled, super.key});

  /// Recibe una caravana completa, con su clase explícita.
  final void Function(String, {required bool electronic}) onTag;

  /// Pausa la captura durante el guardado.
  final bool enabled;

  @override
  State<HealthMangaCapture> createState() => _HealthMangaCaptureState();
}

class _HealthMangaCaptureState extends State<HealthMangaCapture> {
  final _hid = HidRfidReadingSource();
  final _tag = TextEditingController();
  late final StreamSubscription<String> _readings;
  bool _manual = false;
  bool _readerRequested = false;
  bool _electronic = true;
  int _focusGeneration = 0;

  @override
  void initState() {
    super.initState();
    _readings = _hid.readings.listen((tag) {
      if (mounted && widget.enabled && !_manual) widget.onTag(tag, electronic: true);
    });
    unawaited(_hid.startReading());
  }

  @override
  void dispose() {
    unawaited(_readings.cancel());
    unawaited(_hid.dispose());
    _tag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final waiting = widget.enabled && _readerRequested && !_manual;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HidRfidKeyboardListener(
          key: ValueKey(_focusGeneration),
          isListening: widget.enabled && !_manual,
          onKeyEvent: _hid.handleKeyEvent,
          child: Text(
            waiting ? HealthRegistrationStrings.readerReady : HealthRegistrationStrings.scanHint,
            style: waiting ? AppTypography.formFieldSuccess : null,
          ),
        ),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton(
              onPressed: widget.enabled ? _useReader : null,
              child: const Text(HealthRegistrationStrings.useReader),
            ),
            OutlinedButton(
              onPressed: widget.enabled ? _useManual : null,
              child: const Text(HealthRegistrationStrings.useManual),
            ),
          ],
        ),
        if (_manual) ...[
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text(HealthRegistrationStrings.electronic)),
              ButtonSegment(value: false, label: Text(HealthRegistrationStrings.visual)),
            ],
            selected: {_electronic},
            onSelectionChanged: !widget.enabled
                ? null
                : (value) => setState(() {
                    _electronic = value.single;
                    _tag.clear();
                  }),
          ),
          TextField(
            controller: _tag,
            enabled: widget.enabled,
            autofocus: true,
            keyboardType: _electronic ? TextInputType.number : TextInputType.text,
            inputFormatters: _electronic ? [RfidInputFormatter()] : null,
            decoration: InputDecoration(
              labelText: _electronic ? HealthRegistrationStrings.electronic : HealthRegistrationStrings.visual,
            ),
            onSubmitted: (_) => _add(),
          ),
          TextButton(
            onPressed: widget.enabled ? _add : null,
            child: const Text(HealthRegistrationStrings.addTag),
          ),
        ],
      ],
    );
  }

  void _useReader() {
    unawaited(_hid.startReading());
    setState(() {
      _manual = false;
      _readerRequested = true;
      _focusGeneration++;
    });
  }

  void _useManual() {
    unawaited(_hid.stopReading());
    setState(() => _manual = true);
  }

  void _add() {
    final tag = _tag.text.trim();
    if (tag.isEmpty) return;
    _tag.clear();
    widget.onTag(tag, electronic: _electronic);
  }
}
