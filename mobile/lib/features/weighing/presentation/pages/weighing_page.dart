import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/weighing/presentation/mock/weighing_mock.dart';
import 'package:frontend_mayoral/features/weighing/presentation/strings/weighing_strings.dart';
import 'package:frontend_mayoral/features/weighing/presentation/widgets/weighing_animal_header.dart';
import 'package:frontend_mayoral/features/weighing/presentation/widgets/weighing_connection_pill.dart';
import 'package:frontend_mayoral/features/weighing/presentation/widgets/weighing_numpad.dart';
import 'package:frontend_mayoral/features/weighing/presentation/widgets/weighing_tab_selector.dart';

/// Duración que permanece visible el toast de confirmación de pesaje.
const _savedToastDuration = Duration(seconds: 2);

/// Pantalla de pesaje en manga: una sola página con tabs Bluetooth/Manual
/// (más "Por foto" deshabilitada) y un toast de confirmación que avanza al
/// siguiente animal del lote mock.
///
/// Réplica visual estática del diseño `PesajeShell` (ver
/// `.claude/specs/pesaje-en-manga.md`); no hay balanza real, cola de
/// sincronización ni cálculo real de GPD.
class WeighingPage extends StatefulWidget {
  /// Crea la pantalla de pesaje.
  const WeighingPage({super.key});

  @override
  State<WeighingPage> createState() => _WeighingPageState();
}

class _WeighingPageState extends State<WeighingPage> {
  WeighingCaptureTab _tab = WeighingCaptureTab.bluetooth;
  int _batchIndex = 0;
  int _batchPosition = weighingBatchStart;
  String _manualInput = '';
  bool _showSavedToast = false;

  WeighingAnimalMock get _currentAnimal => weighingBatchMock[_batchIndex % weighingBatchMock.length];

  void _handleNumpadKey(String key) {
    setState(() {
      if (key == WeighingStrings.numpadBackspaceLabel) {
        if (_manualInput.isNotEmpty) {
          _manualInput = _manualInput.substring(0, _manualInput.length - 1);
        }
        return;
      }
      if (key == WeighingStrings.numpadDecimalSeparator && _manualInput.contains(key)) {
        return;
      }
      _manualInput += key;
    });
  }

  void _handleSave() {
    setState(() => _showSavedToast = true);
    Future.delayed(_savedToastDuration, () {
      if (!mounted) return;
      setState(() {
        _showSavedToast = false;
        _batchIndex++;
        _batchPosition++;
        _tab = WeighingCaptureTab.bluetooth;
        _manualInput = '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                WeighingAnimalHeader(
                  animal: _currentAnimal,
                  batchPosition: _batchPosition,
                  onClose: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: _tab == WeighingCaptureTab.bluetooth
                      ? _BluetoothTabContent(weightKg: _currentAnimal.weightKg)
                      : _ManualTabContent(input: _manualInput, onKeyPressed: _handleNumpadKey),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: WeighingTabSelector(
                    activeTab: _tab,
                    onChanged: (tab) => setState(() => _tab = tab),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: AppFilledButton(label: WeighingStrings.saveCta, onPressed: _handleSave),
                ),
              ],
            ),
            if (_showSavedToast)
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                top: AppSpacing.md,
                child: AppSuccessBanner(
                  message:
                      '${WeighingStrings.savedToastTitle}\n'
                      '${WeighingStrings.savedToastSubtitle(weighingGpdDelta)}',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BluetoothTabContent extends StatelessWidget {
  const _BluetoothTabContent({required this.weightKg});

  final int weightKg;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$weightKg ${WeighingStrings.weightUnit}',
            style: AppTypography.bigTitle.copyWith(fontSize: 64, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.sm),
          const _GpdChip(delta: weighingGpdDelta),
          const SizedBox(height: AppSpacing.lg),
          const WeighingConnectionPill(scaleName: weighingScaleName),
        ],
      ),
    );
  }
}

class _ManualTabContent extends StatelessWidget {
  const _ManualTabContent({required this.input, required this.onKeyPressed});

  final String input;
  final ValueChanged<String> onKeyPressed;

  @override
  Widget build(BuildContext context) {
    final displayValue = input.isEmpty ? WeighingStrings.manualWeightPlaceholder : input;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$displayValue ${WeighingStrings.weightUnit}',
            style: AppTypography.bigTitle.copyWith(fontSize: 48, color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.lg),
          WeighingNumpad(onKeyPressed: onKeyPressed),
        ],
      ),
    );
  }
}

class _GpdChip extends StatelessWidget {
  const _GpdChip({required this.delta});

  final String delta;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.trending_up, size: 16, color: AppColors.primary),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              '${WeighingStrings.gpdLabel} $delta ${WeighingStrings.gpdUnit}',
              style: AppTypography.smallEmphasis.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
