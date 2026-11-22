import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/formatters/rfid_input_formatter.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/validators/rfid_validator.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/strings/rfid_scan_strings.dart';

/// Permite iniciar la misma identificacion RFID mediante ingreso manual.
class ManualRfidEntry extends StatefulWidget {
  /// Crea el formulario de ingreso manual.
  const ManualRfidEntry({required this.onSubmitted, super.key});

  /// Recibe el valor que debe procesar el BLoC.
  final ValueChanged<String> onSubmitted;

  @override
  State<ManualRfidEntry> createState() => _ManualRfidEntryState();
}

class _ManualRfidEntryState extends State<ManualRfidEntry> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.keyboard_outlined, color: AppColors.primary),
              SizedBox(width: AppSpacing.xs),
              Text(RfidScanStrings.manualEntryTitle, style: AppTypography.secondaryEmphasis),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextFormField(
            controller: _controller,
            hintText: RfidScanStrings.manualEntryHint,
            keyboardType: TextInputType.number,
            maxCharacters: RfidValidator.length,
            inputFormatters: [RfidInputFormatter()],
            autocorrect: false,
            enableSuggestions: false,
          ),
          const SizedBox(height: AppSpacing.xs),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) => AppOutlinedButton(
              label: RfidScanStrings.searchManualRfid,
              icon: const Icon(Icons.search),
              onPressed: RfidValidator.isValid(value.text) ? () => widget.onSubmitted(value.text) : null,
            ),
          ),
        ],
      ),
    );
  }
}
