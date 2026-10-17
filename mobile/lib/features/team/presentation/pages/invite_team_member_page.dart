import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/authentication/user_role_strings.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/invite_team_member_cubit.dart';
import 'package:frontend_mayoral/features/team/presentation/strings/team_strings.dart';
import 'package:go_router/go_router.dart';

IconData _roleIcon(UserRole role) => switch (role) {
  UserRole.owner => Icons.workspace_premium,
  UserRole.admin => Icons.admin_panel_settings,
  UserRole.employee => Icons.agriculture,
  UserRole.veterinarian => Icons.medical_services,
  UserRole.unknown => Icons.person_outline,
};

/// Invitar a una persona al equipo (`EquipoInvitar`): email y rol.
///
/// Vuelve a Equipo con la invitación creada (`CreatedInvitation`) cuando la invitación quedó
/// creada (aunque el email no haya salido), para mostrar el código.
class InviteTeamMemberPage extends StatefulWidget {
  /// Crea la pantalla para [establishmentId].
  const InviteTeamMemberPage({required this.establishmentId, required this.createCubit, super.key});

  /// Establecimiento al que se invita.
  final String establishmentId;

  /// Construye el Cubit (inyectado para los tests). `null` si la persona no
  /// puede invitar en este establecimiento.
  final Future<InviteTeamMemberCubit?> Function(String establishmentId) createCubit;

  @override
  State<InviteTeamMemberPage> createState() => _InviteTeamMemberPageState();
}

class _InviteTeamMemberPageState extends State<InviteTeamMemberPage> {
  late final Future<InviteTeamMemberCubit?> _cubit = widget.createCubit(widget.establishmentId);
  InviteTeamMemberCubit? _created;

  @override
  void initState() {
    super.initState();
    _cubit.then((cubit) {
      _created = cubit;
      if (cubit == null && mounted) {
        context.pop();
      }
    });
  }

  @override
  void dispose() {
    _created?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<InviteTeamMemberCubit?>(
      future: _cubit,
      builder: (context, snapshot) {
        final cubit = snapshot.data;
        if (cubit == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return BlocProvider.value(value: cubit, child: const _InviteView());
      },
    );
  }
}

class _InviteView extends StatefulWidget {
  const _InviteView();

  @override
  State<_InviteView> createState() => _InviteViewState();
}

class _InviteViewState extends State<_InviteView> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InviteTeamMemberCubit, InviteTeamMemberState>(
      listenWhen: (previous, current) => current.sent != null || current.error != null,
      listener: (context, state) {
        final sent = state.sent;
        final messenger = ScaffoldMessenger.of(context);
        if (sent != null) {
          // Equipo abre "Invitación creada" con el código para compartir.
          context.pop(sent);
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
        final cubit = context.read<InviteTeamMemberCubit>();
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: TeamStrings.closeTooltip,
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Text(TeamStrings.inviteTitle, style: AppTypography.appBarTitle),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
                    children: [
                      AppTextFormField(
                        title: TeamStrings.emailLabel,
                        hintText: 'nombre@ejemplo.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        enableSuggestions: false,
                        enabled: !state.isSending,
                        helperText: TeamStrings.emailHelper,
                        validation: state.emailError == null ? AppFieldValidation.neutral : AppFieldValidation.invalid,
                        validationMessage: switch (state.emailError) {
                          InviteEmailError.required => TeamStrings.emailRequired,
                          InviteEmailError.invalid => TeamStrings.emailInvalid,
                          null => null,
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Text(TeamStrings.roleSection, style: AppTypography.pageTitle),
                      const SizedBox(height: AppSpacing.sm),
                      for (final role in cubit.assignableRoles) ...[
                        AppSelectableCard<UserRole>(
                          value: role,
                          groupValue: state.role,
                          title: UserRoleStrings.name(role),
                          subtitle: TeamStrings.roleDescription(role),
                          icon: _roleIcon(role),
                          onChanged: state.isSending ? (_) {} : cubit.selectRole,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: AppFilledButton(
                    label: TeamStrings.sendCta,
                    isLoading: state.isSending,
                    loadingLabel: TeamStrings.sendingCta,
                    onPressed: () => cubit.submit(_emailController.text),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
