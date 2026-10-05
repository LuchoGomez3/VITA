import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/bloc/register_animal_bloc.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/strings/register_animal_strings.dart';

/// Identification form shown in the first step of animal registration.
class RegisterAnimalIdentificationStep extends StatefulWidget {
  /// Creates the animal identification step.
  const RegisterAnimalIdentificationStep({
    required this.onBluetoothRequested,
    super.key,
  });

  /// Called when the user requests an RFID Bluetooth reading.
  final VoidCallback onBluetoothRequested;

  @override
  State<RegisterAnimalIdentificationStep> createState() => _RegisterAnimalIdentificationStepState();
}

class _RegisterAnimalIdentificationStepState extends State<RegisterAnimalIdentificationStep> {
  final _rfidController = TextEditingController();
  final _seriesController = TextEditingController();
  final _visualTagNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final draft = context.read<RegisterAnimalBloc>().state.draft;
    _rfidController.text = draft.rfid;
    _seriesController.text = draft.visualTagSeries;
    _visualTagNumberController.text = draft.visualTagNumber;
  }

  @override
  void dispose() {
    _rfidController.dispose();
    _seriesController.dispose();
    _visualTagNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RegisterAnimalBloc>().state;
    final draft = state.draft;
    if (_rfidController.text != draft.rfid) {
      _rfidController.value = TextEditingValue(
        text: draft.rfid,
        selection: TextSelection.collapsed(offset: draft.rfid.length),
      );
    }
    final rfidError = switch (state.rfidCheckState) {
      Data<bool>(data: true) => AnimalRegisterStrings.rfidAlreadyRegistered,
      ResultError<bool>(:final error) => error.message,
      _ => null,
    };

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AnimalRegisterStrings.manualEntryTitle,
              style: AppTypography.pageTitle,
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              AnimalRegisterStrings.manualEntryDescription,
              style: AppTypography.pageBodyTitle,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextFormField(
              controller: _rfidController,
              title: AnimalRegisterStrings.rfidFieldTitle,
              hintText: AnimalRegisterStrings.rfidFieldHint,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(15),
              ],
              helperText: ' ',
              validation: rfidError == null ? AppFieldValidation.neutral : AppFieldValidation.invalid,
              validationMessage: rfidError,
              onChanged: (value) {
                _updateDraft(draft.copyWith(rfid: value));
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextFormField(
                    controller: _seriesController,
                    title: AnimalRegisterStrings.seriesFieldTitle,
                    hintText: AnimalRegisterStrings.seriesFieldHint,
                    onChanged: (value) {
                      _updateDraft(draft.copyWith(visualTagSeries: value));
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppTextFormField(
                    controller: _visualTagNumberController,
                    title: AnimalRegisterStrings.visualNumberFieldTitle,
                    hintText: AnimalRegisterStrings.visualNumberFieldHint,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _updateDraft(draft.copyWith(visualTagNumber: value));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.earTagBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: AppOutlinedButton(
                label: AnimalRegisterStrings.bluetoothButtonLabel,
                icon: const Icon(Icons.bluetooth, color: AppColors.textPrimary),
                onPressed: widget.onBluetoothRequested,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateDraft(RegisterAnimalDraft draft) {
    context.read<RegisterAnimalBloc>().add(
      RegisterAnimalEvent.draftChanged(draft),
    );
  }
}
