import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/profile/domain/entities/establishment_details.dart';
import 'package:frontend_mayoral/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:frontend_mayoral/features/profile/presentation/strings/profile_strings.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/profile_establishments_section.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/profile_user_card.dart';
import 'package:go_router/go_router.dart';

/// Callback que cierra la sesión actual.
typedef SignOut = Future<void> Function();

/// Factory que crea el Cubit responsable de los establecimientos de Perfil.
typedef ProfileCubitFactory = ProfileCubit Function();

/// Pantalla que muestra el usuario y sus establecimientos.
class ProfilePage extends StatefulWidget {
  /// Crea la pantalla con los datos de la sesión autenticada.
  const ProfilePage({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.cuit,
    required this.role,
    required this.createCubit,
    required this.signOut,
    super.key,
  });

  /// ID interno del usuario.
  final String userId;

  /// Correo usado para iniciar sesión.
  final String email;

  /// Nombre del usuario.
  final String firstName;

  /// Apellido del usuario.
  final String lastName;

  /// CUIT opcional del usuario.
  final String? cuit;

  /// Rol persistido en la sesión.
  final String role;

  /// Crea el Cubit perteneciente a esta página.
  final ProfileCubitFactory createCubit;

  /// Cierra la sesión actual.
  final SignOut signOut;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isSigningOut = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (_) => widget.createCubit()..load(),
      child: Scaffold(
        appBar: const AppHeader(title: ProfileStrings.title),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.xl,
            ),
            children: [
              ProfileUserCard(
                userId: widget.userId,
                email: widget.email,
                firstName: widget.firstName,
                lastName: widget.lastName,
                cuit: widget.cuit,
                role: widget.role,
              ),
              const SizedBox(height: AppSpacing.xl),
              const _EstablishmentsContent(),
              const SizedBox(height: AppSpacing.lg),
              AppFilledButton(
                label: ProfileStrings.signOutButton,
                loadingLabel: ProfileStrings.signingOutButton,
                isLoading: _isSigningOut,
                icon: const Icon(Icons.logout),
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.onError,
                onPressed: _signOut,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    await widget.signOut();

    if (mounted) {
      context.go(AppRoutes.login);
    }
  }
}

class _EstablishmentsContent extends StatelessWidget {
  const _EstablishmentsContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ResultState<List<EstablishmentDetails>>>(
      builder: (context, state) => switch (state) {
        Data<List<EstablishmentDetails>>(:final data) => ProfileEstablishmentsSection(establishments: data),
        ResultError<List<EstablishmentDetails>>(:final error) => Column(
          children: [
            Text(error.message),
            const SizedBox(height: AppSpacing.sm),
            AppOutlinedButton(
              label: ProfileStrings.retry,
              onPressed: context.read<ProfileCubit>().load,
            ),
          ],
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
