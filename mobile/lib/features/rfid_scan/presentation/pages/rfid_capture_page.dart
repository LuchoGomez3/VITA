import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/bloc/rfid_scan_bloc.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/strings/rfid_scan_strings.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/widgets/hid_rfid_keyboard_listener.dart';

/// Captura una caravana con el mismo lector HID usado para identificar animales.
class RfidCapturePage extends StatelessWidget {
  /// Crea la pantalla y entrega el RFID válido al flujo que la abrió.
  const RfidCapturePage({
    required this.createBloc,
    required this.onHidKeyEvent,
    required this.onCaptured,
    super.key,
  });

  /// Construye el lector en modo captura.
  final RfidScanBloc Function() createBloc;

  /// Reenvía las teclas HID a la fuente de lectura.
  final ValueChanged<KeyEvent> onHidKeyEvent;

  /// Devuelve el RFID válido al flujo anterior.
  final ValueChanged<String> onCaptured;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => createBloc(),
    child: BlocListener<RfidScanBloc, RfidScanState>(
      listener: (context, state) {
        state.maybeWhen(captured: onCaptured, orElse: () {});
      },
      child: Scaffold(
        appBar: AppBar(title: const Text(RfidScanStrings.captureTitle)),
        body: BlocBuilder<RfidScanBloc, RfidScanState>(
          builder: (context, state) {
            final listening = state.maybeWhen(listening: () => true, orElse: () => false);
            return HidRfidKeyboardListener(
              isListening: listening,
              onKeyEvent: onHidKeyEvent,
              child: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: AppSurfaceCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bluetooth_searching, size: 48, color: AppColors.primary),
                          const SizedBox(height: AppSpacing.md),
                          Text(_title(state), style: AppTypography.pageTitle),
                          const SizedBox(height: AppSpacing.sm),
                          Text(_description(state), textAlign: TextAlign.center),
                          const SizedBox(height: AppSpacing.lg),
                          AppFilledButton(
                            label: listening ? RfidScanStrings.cancelReading : RfidScanStrings.startReading,
                            onPressed: () => context.read<RfidScanBloc>().add(
                              listening ? const RfidScanEvent.stopped() : const RfidScanEvent.listeningRequested(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );

  String _title(RfidScanState state) => state.maybeWhen(
    listening: () => RfidScanStrings.listeningTitle,
    invalid: (_) => RfidScanStrings.invalidTitle,
    timeout: () => RfidScanStrings.timeoutTitle,
    error: () => RfidScanStrings.errorTitle,
    orElse: () => RfidScanStrings.captureTitle,
  );

  String _description(RfidScanState state) => state.maybeWhen(
    listening: () => RfidScanStrings.listeningDescription,
    invalid: (_) => RfidScanStrings.invalidDescription,
    timeout: () => RfidScanStrings.timeoutDescription,
    error: () => RfidScanStrings.errorDescription,
    orElse: () => RfidScanStrings.idleDescription,
  );
}
