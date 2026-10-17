import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/join_establishment_cubit.dart';
import 'package:frontend_mayoral/features/team/presentation/strings/team_strings.dart';
import 'package:go_router/go_router.dart';

/// "Sumarme a otro establecimiento": se escribe el código del email, se ve a
/// qué campo y con qué rol, y se confirma. Online-only.
///
/// Vuelve con `true` cuando la persona quedó sumada, para que Perfil recargue
/// el catálogo.
class JoinEstablishmentPage extends StatelessWidget {
  /// Crea la pantalla.
  const JoinEstablishmentPage({required this.createCubit, super.key});

  /// Construye el Cubit (inyectado para los tests).
  final JoinEstablishmentCubit Function() createCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => createCubit(), child: const _JoinView());
  }
}

class _JoinView extends StatefulWidget {
  const _JoinView();

  @override
  State<_JoinView> createState() => _JoinViewState();
}

class _JoinViewState extends State<_JoinView> {
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _codeController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  bool get _codeComplete =>
      JoinEstablishmentCubit.normalize(_codeController.text).length == JoinEstablishmentCubit.codeLength;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JoinEstablishmentCubit, JoinEstablishmentState>(
      listenWhen: (previous, current) => current.error != null || current.step == JoinStep.joined,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        final joined = state.joined;
        if (joined != null) {
          messenger.showSnackBar(SnackBar(content: Text(TeamStrings.joinedNotice(joined.name))));
          context.pop(true);
          return;
        }
        final error = state.error;
        if (error != null) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(TeamStrings.error(error))));
        }
      },
      builder: (context, state) {
        final cubit = context.read<JoinEstablishmentCubit>();
        final preview = state.preview;
        final confirming = state.step == JoinStep.confirm || state.step == JoinStep.joining;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: AppColors.background,
            centerTitle: true,
            title: const Text(TeamStrings.joinTitle, style: AppTypography.appBarTitle),
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                const Text(TeamStrings.joinIntro, style: AppTypography.secondaryEmphasis),
                const SizedBox(height: AppSpacing.lg),
                AppTextFormField(
                  title: TeamStrings.codeLabel,
                  hintText: TeamStrings.codeHint,
                  controller: _codeController,
                  enabled: !confirming && state.step != JoinStep.checking,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9- ]')),
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (preview != null && confirming) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            TeamStrings.previewMessage(preview.establishmentName, preview.role),
                            style: AppTypography.mediumEmphasis,
                          ),
                          if (preview.invitedBy.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xxs),
                            Text(TeamStrings.previewInvitedBy(preview.invitedBy), style: AppTypography.smallEmphasis),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppFilledButton(
                    label: TeamStrings.joinCta,
                    isLoading: state.step == JoinStep.joining,
                    loadingLabel: TeamStrings.joiningCta,
                    onPressed: cubit.confirm,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextButton(
                    onPressed: state.step == JoinStep.joining ? null : cubit.editCode,
                    child: const Text(TeamStrings.otherCodeCta),
                  ),
                ] else
                  AppFilledButton(
                    label: TeamStrings.checkCta,
                    isLoading: state.step == JoinStep.checking,
                    loadingLabel: TeamStrings.checkingCta,
                    onPressed: _codeComplete ? () => cubit.check(_codeController.text) : null,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
