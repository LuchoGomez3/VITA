import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/entities/identified_animal.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/bloc/rfid_scan_bloc.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/strings/rfid_scan_strings.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/widgets/hid_rfid_keyboard_listener.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/widgets/identified_animal_card.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/widgets/manual_rfid_entry.dart';

/// Factory usada por composition root para crear el BLoC de identificacion.
typedef RfidScanBlocFactory = RfidScanBloc Function({required String establishmentId});

/// Pantalla para identificar un animal usando un baston RFID HID.
class RfidScanPage extends StatelessWidget {
  /// Crea la pantalla con el establecimiento activo y callbacks de navegacion.
  const RfidScanPage({
    required this.establishmentId,
    required this.createBloc,
    required this.onHidKeyEvent,
    required this.onAnimalDetailRequested,
    required this.onRegisterAnimalRequested,
    super.key,
  });

  /// Establecimiento sobre el que se ejecuta la busqueda local.
  final String establishmentId;

  /// Crea el BLoC con sus dependencias ya resueltas.
  final RfidScanBlocFactory createBloc;

  /// Reenvia las teclas del baston a la fuente HID configurada.
  final ValueChanged<KeyEvent> onHidKeyEvent;

  /// Navega a la ficha completa del animal identificado.
  final ValueChanged<String> onAnimalDetailRequested;

  /// Navega al alta con [String] como RFID precargado.
  final ValueChanged<String> onRegisterAnimalRequested;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createBloc(establishmentId: establishmentId),
      child: _RfidScanView(
        onHidKeyEvent: onHidKeyEvent,
        onAnimalDetailRequested: onAnimalDetailRequested,
        onRegisterAnimalRequested: onRegisterAnimalRequested,
      ),
    );
  }
}

class _RfidScanView extends StatelessWidget {
  const _RfidScanView({
    required this.onHidKeyEvent,
    required this.onAnimalDetailRequested,
    required this.onRegisterAnimalRequested,
  });

  final ValueChanged<KeyEvent> onHidKeyEvent;
  final ValueChanged<String> onAnimalDetailRequested;
  final ValueChanged<String> onRegisterAnimalRequested;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(RfidScanStrings.pageTitle)),
      body: BlocListener<RfidScanBloc, RfidScanState>(
        listenWhen: (previous, current) {
          return previous != current && current.maybeWhen(found: (_) => true, orElse: () => false);
        },
        listener: (_, _) {
          unawaited(HapticFeedback.mediumImpact());
        },
        child: BlocBuilder<RfidScanBloc, RfidScanState>(
          builder: (context, state) {
            final isListening = state.maybeWhen(
              listening: () => true,
              orElse: () => false,
            );
            return HidRfidKeyboardListener(
              isListening: isListening,
              onKeyEvent: onHidKeyEvent,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _ScanMethodsHeader(),
                        const SizedBox(height: AppSpacing.md),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            final offset = Tween<Offset>(
                              begin: const Offset(0, 0.06),
                              end: Offset.zero,
                            ).animate(animation);
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(position: offset, child: child),
                            );
                          },
                          child: _RfidScanBody(
                            key: ValueKey(state.runtimeType),
                            state: state,
                            onStart: () => context.read<RfidScanBloc>().add(const RfidScanEvent.listeningRequested()),
                            onCancel: () => context.read<RfidScanBloc>().add(const RfidScanEvent.stopped()),
                            onAnimalDetailRequested: onAnimalDetailRequested,
                            onRegisterAnimalRequested: onRegisterAnimalRequested,
                          ),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          child: isListening
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: const EdgeInsets.only(top: AppSpacing.md),
                                  child: ManualRfidEntry(
                                    onSubmitted: (reading) => context.read<RfidScanBloc>().add(
                                      RfidScanEvent.readingReceived(reading: reading),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RfidScanBody extends StatelessWidget {
  const _RfidScanBody({
    required this.state,
    required this.onStart,
    required this.onCancel,
    required this.onAnimalDetailRequested,
    required this.onRegisterAnimalRequested,
    super.key,
  });

  final RfidScanState state;
  final VoidCallback onStart;
  final VoidCallback onCancel;
  final ValueChanged<String> onAnimalDetailRequested;
  final ValueChanged<String> onRegisterAnimalRequested;

  @override
  Widget build(BuildContext context) {
    return state.when(
      inactive: () => _MessageAction(
        title: RfidScanStrings.idleTitle,
        description: RfidScanStrings.idleDescription,
        actionLabel: RfidScanStrings.startReading,
        onAction: onStart,
      ),
      listening: () => _ReadingShimmer(
        child: _MessageAction(
          title: RfidScanStrings.listeningTitle,
          description: RfidScanStrings.listeningDescription,
          actionLabel: RfidScanStrings.cancelReading,
          onAction: onCancel,
          icon: Icons.radar,
        ),
      ),
      invalid: (reading) => _MessageAction(
        title: RfidScanStrings.invalidTitle,
        description: '${RfidScanStrings.invalidDescription}\n$reading',
        actionLabel: RfidScanStrings.scanAgain,
        onAction: onStart,
        icon: Icons.error_outline,
      ),
      found: (animal) => _FoundContent(
        animal: animal,
        onDetail: onAnimalDetailRequested,
        onScanAgain: onStart,
      ),
      notFound: (rfid) => _NotFoundContent(
        rfid: rfid,
        onRegister: onRegisterAnimalRequested,
        onScanAgain: onStart,
      ),
      timeout: () => _MessageAction(
        title: RfidScanStrings.timeoutTitle,
        description: RfidScanStrings.timeoutDescription,
        actionLabel: RfidScanStrings.scanAgain,
        onAction: onStart,
        icon: Icons.timer_off_outlined,
      ),
      error: () => _MessageAction(
        title: RfidScanStrings.errorTitle,
        description: RfidScanStrings.errorDescription,
        actionLabel: RfidScanStrings.scanAgain,
        onAction: onStart,
        icon: Icons.error_outline,
      ),
    );
  }
}

class _ScanMethodsHeader extends StatelessWidget {
  const _ScanMethodsHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(RfidScanStrings.methodQuestion, style: AppTypography.pageTitle),
        SizedBox(height: AppSpacing.xxs),
        Text(RfidScanStrings.methodDescription, style: AppTypography.formFieldHelper),
      ],
    );
  }
}

class _MessageAction extends StatelessWidget {
  const _MessageAction({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
    this.icon = Icons.bluetooth_searching,
  });
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: AppSurfaceCard(
      elevation: 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(color: AppColors.backgroundSecondary, shape: BoxShape.circle),
            child: Icon(icon, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTypography.pageTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(description, textAlign: TextAlign.center, style: AppTypography.pageBodyTitle),
          const SizedBox(height: AppSpacing.lg),
          AppFilledButton(
            label: actionLabel,
            icon: Icon(icon == Icons.radar ? Icons.close : Icons.bluetooth_searching),
            onPressed: onAction,
          ),
        ],
      ),
    ),
  );
}

class _ReadingShimmer extends StatefulWidget {
  const _ReadingShimmer({required this.child});

  final Widget child;

  @override
  State<_ReadingShimmer> createState() => _ReadingShimmerState();
}

class _ReadingShimmerState extends State<_ReadingShimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: LayoutBuilder(
                builder: (context, constraints) => AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(
                      -constraints.maxWidth + (constraints.maxWidth * 2 * _controller.value),
                      0,
                    ),
                    child: child,
                  ),
                  child: Container(
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.transparent,
                          AppColors.primary.withValues(alpha: 0.14),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotFoundContent extends StatelessWidget {
  const _NotFoundContent({required this.rfid, required this.onRegister, required this.onScanAgain});
  final String rfid;
  final ValueChanged<String> onRegister;
  final VoidCallback onScanAgain;
  @override
  Widget build(BuildContext context) => _MessageActions(
    title: RfidScanStrings.notFoundTitle,
    description: '${RfidScanStrings.notFoundDescription}\n$rfid',
    primaryLabel: RfidScanStrings.registerAnimal,
    onPrimary: () => onRegister(rfid),
    onSecondary: onScanAgain,
  );
}

class _FoundContent extends StatelessWidget {
  const _FoundContent({required this.animal, required this.onDetail, required this.onScanAgain});
  final IdentifiedAnimal animal;
  final ValueChanged<String> onDetail;
  final VoidCallback onScanAgain;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      IdentifiedAnimalCard(animal: animal),
      const SizedBox(height: AppSpacing.lg),
      AppFilledButton(label: RfidScanStrings.viewDetail, onPressed: () => onDetail(animal.id)),
      const SizedBox(height: AppSpacing.sm),
      AppOutlinedButton(label: RfidScanStrings.scanAgain, onPressed: onScanAgain),
    ],
  );
}

class _MessageActions extends StatelessWidget {
  const _MessageActions({
    required this.title,
    required this.description,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onSecondary,
  });
  final String title;
  final String description;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;
  @override
  Widget build(BuildContext context) => Center(
    child: AppSurfaceCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: AppTypography.pageTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(description, textAlign: TextAlign.center, style: AppTypography.pageBodyTitle),
          const SizedBox(height: AppSpacing.lg),
          AppFilledButton(label: primaryLabel, onPressed: onPrimary),
          const SizedBox(height: AppSpacing.sm),
          AppOutlinedButton(label: RfidScanStrings.scanAgain, onPressed: onSecondary),
        ],
      ),
    ),
  );
}
