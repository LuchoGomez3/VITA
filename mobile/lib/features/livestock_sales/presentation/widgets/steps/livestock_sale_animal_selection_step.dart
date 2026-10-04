import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_mayoral/core/formatters/rfid_input_formatter.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_selection.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/bloc/livestock_sale_bloc.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_strings.dart';

/// Primer paso del flujo: selecciona animales desde el inventario local.
class LivestockSaleAnimalSelectionStep extends StatefulWidget {
  /// Crea la pantalla conectada al BLoC propietario del wizard.
  const LivestockSaleAnimalSelectionStep({
    required this.onRfidScanRequested,
    super.key,
  });

  /// Abre el lector y devuelve la caravana confirmada por el usuario.
  final Future<String?> Function() onRfidScanRequested;

  @override
  State<LivestockSaleAnimalSelectionStep> createState() => _LivestockSaleAnimalSelectionStepState();
}

class _LivestockSaleAnimalSelectionStepState extends State<LivestockSaleAnimalSelectionStep> {
  final _rfidController = TextEditingController();

  // Evita abrir dos lecturas RFID mientras la ruta del lector sigue activa.
  bool _isRfidScanOpen = false;

  @override
  void dispose() {
    _rfidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LivestockSaleBloc, LivestockSaleState>(
      // El campo se limpia unicamente cuando el animal fue incorporado; ante un
      // error queda disponible para que el productor pueda corregirlo.
      listenWhen: (previous, current) {
        return current.selection.animals.length > previous.selection.animals.length;
      },
      listener: (_, _) => _rfidController.clear(),
      buildWhen: (previous, current) {
        return previous.selection != current.selection ||
            previous.animalSelectionResult != current.animalSelectionResult;
      },
      builder: (context, state) {
        final animals = state.selection.animals;
        final isLoading = state.animalSelectionResult is Loading<LivestockSaleSelection>;
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          itemCount: animals.isEmpty ? 1 : animals.length + 1,
          itemBuilder: (context, index) {
            // El encabezado ocupa siempre la primera posicion y la lista de
            // animales se construye de forma perezosa debajo de el.
            if (index == 0) {
              return _SelectionHeader(
                controller: _rfidController,
                selectedCount: animals.length,
                isLoading: isLoading,
                onAdd: _addAnimal,
                onScan: _scanAnimal,
                isScanning: _isRfidScanOpen,
                showEmptyState: animals.isEmpty,
              );
            }
            final animal = animals[index - 1];
            return Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: _SelectedAnimalCard(
                animal: animal,
                onRemove: () => context.read<LivestockSaleBloc>().add(
                  LivestockSaleEvent.animalRemoveRequested(animal.id),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _addAnimal() {
    // El caso de uso resolvera la caravana exclusivamente contra SQLite.
    FocusScope.of(context).unfocus();
    context.read<LivestockSaleBloc>().add(
      LivestockSaleEvent.animalAddRequested(_rfidController.text),
    );
  }

  Future<void> _scanAnimal() async {
    if (_isRfidScanOpen) return;
    setState(() => _isRfidScanOpen = true);
    final reading = await widget.onRfidScanRequested();
    // La pantalla puede haberse cerrado mientras el lector estaba abierto.
    if (!mounted) return;
    setState(() => _isRfidScanOpen = false);
    if (reading == null || reading.isEmpty) return;
    context.read<LivestockSaleBloc>().add(
      LivestockSaleEvent.animalAddRequested(reading),
    );
  }
}

class _SelectionHeader extends StatelessWidget {
  const _SelectionHeader({
    required this.controller,
    required this.selectedCount,
    required this.isLoading,
    required this.onAdd,
    required this.onScan,
    required this.isScanning,
    required this.showEmptyState,
  });

  final TextEditingController controller;
  final int selectedCount;
  final bool isLoading;
  final VoidCallback onAdd;
  final VoidCallback onScan;
  final bool isScanning;
  final bool showEmptyState;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          LivestockSaleStrings.animalSelectionTitle,
          style: AppTypography.pageTitle,
        ),
        const SizedBox(height: AppSpacing.xxs),
        const Text(
          LivestockSaleStrings.animalSelectionDescription,
          style: AppTypography.formFieldHelper,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppSurfaceCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                LivestockSaleStrings.addAnimalTitle,
                style: AppTypography.secondaryEmphasis,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppOutlinedButton(
                key: const Key('livestockSaleRfidScanButton'),
                label: LivestockSaleStrings.scanWithRfidReader,
                icon: SvgPicture.asset(
                  'assets/icons/bluetooth.svg',
                  width: AppSpacing.lg,
                  height: AppSpacing.lg,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: isLoading || isScanning ? null : onScan,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                LivestockSaleStrings.manualRfidTitle,
                style: AppTypography.smallEmphasis,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextFormField(
                key: const Key('livestockSaleRfidInput'),
                controller: controller,
                title: LivestockSaleStrings.rfidFieldLabel,
                hintText: LivestockSaleStrings.rfidFieldHint,
                keyboardType: TextInputType.number,
                inputFormatters: [RfidInputFormatter()],
                maxCharacters: 15,
                enabled: !isLoading,
                textInputAction: TextInputAction.done,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: SvgPicture.asset(
                    'assets/icons/search.svg',
                    colorFilter: const ColorFilter.mode(
                      AppColors.textSecondary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppFilledButton(
                key: const Key('livestockSaleAddAnimalButton'),
                label: LivestockSaleStrings.addAnimal,
                loadingLabel: LivestockSaleStrings.addingAnimal,
                isLoading: isLoading,
                icon: const Icon(Icons.add),
                onPressed: isLoading ? null : onAdd,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _SelectedAnimalsHeader(count: selectedCount),
        if (showEmptyState) ...[
          const SizedBox(height: AppSpacing.sm),
          const _EmptySelection(),
        ],
      ],
    );
  }
}

class _SelectedAnimalsHeader extends StatelessWidget {
  const _SelectedAnimalsHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            LivestockSaleStrings.selectedAnimals,
            style: AppTypography.pageTitle,
          ),
        ),
        Container(
          constraints: const BoxConstraints(minWidth: AppSpacing.lg),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xxs,
          ),
          decoration: const ShapeDecoration(
            color: AppColors.primary,
            shape: StadiumBorder(),
          ),
          child: Text(
            LivestockSaleStrings.selectedAnimalCount(count),
            key: const Key('livestockSaleSelectedAnimalCount'),
            textAlign: TextAlign.center,
            style: AppTypography.mapBadge,
          ),
        ),
      ],
    );
  }
}

class _EmptySelection extends StatelessWidget {
  const _EmptySelection();

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      key: const Key('livestockSaleEmptySelection'),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/icons/cow.svg',
            width: AppSpacing.xl,
            height: AppSpacing.xl,
            colorFilter: const ColorFilter.mode(
              AppColors.iconMuted,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            LivestockSaleStrings.emptySelectionTitle,
            textAlign: TextAlign.center,
            style: AppTypography.mediumEmphasis,
          ),
          const SizedBox(height: AppSpacing.xxs),
          const Text(
            LivestockSaleStrings.emptySelectionDescription,
            textAlign: TextAlign.center,
            style: AppTypography.formFieldHelper,
          ),
        ],
      ),
    );
  }
}

class _SelectedAnimalCard extends StatelessWidget {
  const _SelectedAnimalCard({
    required this.animal,
    required this.onRemove,
  });

  final LivestockSaleAnimal animal;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      key: ValueKey('selected-sale-animal-${animal.id}'),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          _AnimalTag(value: _tagValue),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_category, style: AppTypography.formFieldValueEmphasis),
                const SizedBox(height: AppSpacing.xxs),
                Text(_lot, style: AppTypography.formFieldHelper),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  LivestockSaleStrings.animalRfid(animal.rfidTagNumber),
                  style: AppTypography.monoValueEmphasis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: LivestockSaleStrings.removeAnimal,
            onPressed: onRemove,
            icon: SvgPicture.asset(
              'assets/icons/close_small.svg',
              width: AppSpacing.lg,
              height: AppSpacing.lg,
              colorFilter: const ColorFilter.mode(
                AppColors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _category =>
      animal.categoryName.trim().isEmpty ? LivestockSaleStrings.unavailableCategory : animal.categoryName;

  String get _lot => animal.lotName.trim().isEmpty ? LivestockSaleStrings.unavailableLot : animal.lotName;

  String get _tagValue {
    // Si no existe caravana visual, los ultimos cuatro digitos RFID ofrecen un
    // identificador compacto sin perder el numero completo mostrado debajo.
    final visualTag = animal.visualTag.trim();
    if (visualTag.isNotEmpty) return visualTag;
    final rfid = animal.rfidTagNumber;
    return rfid.length <= 4 ? rfid : rfid.substring(rfid.length - 4);
  }
}

class _AnimalTag extends StatelessWidget {
  const _AnimalTag({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 56),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: AppTypography.smallEmphasis.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }
}
