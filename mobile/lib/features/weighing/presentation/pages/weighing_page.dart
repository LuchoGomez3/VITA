import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/weighing/domain/entities/animal_weighing.dart';
import 'package:frontend_mayoral/features/weighing/domain/use_cases/record_animal_weighing_use_case.dart';
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
  ///
  /// Desde la ficha de un animal llega [animal] (se pesa ese animal, no la
  /// cola ficticia) y la pestaña elegida en [initialTab].
  const WeighingPage({super.key, this.request, this.recordWeighing});

  /// Animal a pesar y pestaña inicial, o `null` para la cola ficticia.
  final WeighingRequest? request;

  /// Guarda el pesaje. Con [request] y este caso de uso, "Guardar pesaje"
  /// registra el peso de verdad (offline-first) y vuelve con `true`.
  final RecordAnimalWeighingUseCase? recordWeighing;

  @override
  State<WeighingPage> createState() => _WeighingPageState();
}

class _WeighingPageState extends State<WeighingPage> {
  late WeighingCaptureTab _tab = widget.request?.initialTab ?? WeighingCaptureTab.bluetooth;
  bool _isSaving = false;
  int _batchIndex = 0;
  int _batchPosition = weighingBatchStart;
  String _manualInput = '';
  bool _showSavedToast = false;

  WeighingAnimalMock get _currentAnimal =>
      widget.request?.animal ?? weighingBatchMock[_batchIndex % weighingBatchMock.length];

  /// Si se está pesando un animal real (desde su ficha) y no la cola ficticia.
  bool get _isRealWeighing => widget.request != null && widget.recordWeighing != null;

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

  Future<void> _handleSave() async {
    if (_isRealWeighing) {
      await _saveRealWeighing();
      return;
    }
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

  Future<void> _saveRealWeighing() async {
    final request = widget.request!;
    if (_tab == WeighingCaptureTab.bluetooth) {
      _showMessage(WeighingStrings.noScaleConnected);
      return;
    }
    final weightKg = double.tryParse(_manualInput.replaceAll(WeighingStrings.numpadDecimalSeparator, '.'));
    if (weightKg == null) {
      _showMessage(WeighingStrings.enterWeight);
      return;
    }
    if (_isSaving) {
      return;
    }

    setState(() => _isSaving = true);
    final result = await widget.recordWeighing!(
      establishmentId: request.establishmentId,
      animalId: request.animalId,
      weightKg: weightKg,
      source: AnimalWeighingSource.manual,
    );
    if (!mounted) {
      return;
    }
    switch (result) {
      case Success<AnimalWeighing>():
        setState(() => _showSavedToast = true);
        await Future<void>.delayed(_savedToastDuration);
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      case Failure<AnimalWeighing>(:final error):
        setState(() => _isSaving = false);
        _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
                  child: AppFilledButton(
                    label: WeighingStrings.saveCta,
                    onPressed: _isSaving ? null : _handleSave,
                  ),
                ),
              ],
            ),
            if (_showSavedToast)
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                top: AppSpacing.md,
                child: AppSuccessBanner(
                  message: _isRealWeighing
                      ? '${WeighingStrings.savedToastTitle}\n${WeighingStrings.savedOfflineSubtitle}'
                      : '${WeighingStrings.savedToastTitle}\n'
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

/// Pedido para abrir el pesaje de un animal puntual (por ejemplo, desde su
/// ficha). Viaja como `extra` de la ruta [WeighingPage].
@immutable
class WeighingRequest {
  /// Crea el pedido para pesar el animal [animalId] en la pestaña [initialTab].
  const WeighingRequest({
    required this.animalId,
    required this.establishmentId,
    required this.animal,
    required this.initialTab,
  });

  /// UUID del animal a pesar.
  final String animalId;

  /// Establecimiento del animal.
  final String establishmentId;

  /// Datos que se muestran en la cabecera (caravana, RFID, raza y categoría).
  final WeighingAnimalMock animal;

  /// Pestaña con la que abre.
  final WeighingCaptureTab initialTab;
}
