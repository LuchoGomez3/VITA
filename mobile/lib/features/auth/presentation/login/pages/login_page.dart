import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/presentation/login/bloc/login_bloc.dart';
import 'package:frontend_mayoral/features/auth/presentation/login/strings/login_strings.dart';
import 'package:frontend_mayoral/features/auth/presentation/login/widgets/login_form.dart';
import 'package:frontend_mayoral/features/auth/presentation/login/widgets/login_header.dart';
import 'package:frontend_mayoral/features/auth/presentation/session/cubit/auth_session_cubit.dart';
import 'package:go_router/go_router.dart';

/// Factory usada por el router para construir el bloc de login.
typedef LoginBlocFactory = LoginBloc Function();

/// Pantalla inicial de autenticacion.
class LoginPage extends StatelessWidget {
  /// Crea la pantalla de login.
  const LoginPage({
    required this.createBloc,
    super.key,
  });

  /// Crea el bloc con dependencias resueltas fuera de presentation.
  final LoginBlocFactory createBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createBloc(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (previous, current) => previous.signInResult != current.signInResult,
      listener: (context, state) {
        switch (state.signInResult) {
          case Data<AuthSession>(:final data):
            context.read<AuthSessionCubit>().setAuthenticated(data);
            final initialDataSyncError = state.initialDataSyncError;
            if (initialDataSyncError != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text(initialDataSyncError.message)),
                );
            }
            context.go(AppRoutes.home);
          case ResultError<AuthSession>(:final error):
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(error.message)),
              );
          default:
            break;
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        buildWhen: (previous, current) => previous.signInResult != current.signInResult,
        builder: (context, state) {
          final isSubmitting = state.signInResult is Loading<AuthSession>;
          final loadingLabel = state.isPreparingOfflineData
              ? LoginStrings.preparingOfflineDataButton
              : LoginStrings.submittingButton;

          return Scaffold(
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const LoginHeader(),
                        const SizedBox(height: AppSpacing.lg),
                        AppSurfaceCard(
                          child: LoginForm(
                            formKey: _formKey,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            obscurePassword: _obscurePassword,
                            isSubmitting: isSubmitting,
                            loadingLabel: loadingLabel,
                            onPasswordVisibilityPressed: _togglePasswordVisibility,
                            onSubmit: () => _submit(context),
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
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    context.read<LoginBloc>().add(
      LoginSubmitted(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }
}
