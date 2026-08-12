import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/auth_session.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/registration_request.dart';
import 'package:frontend_mayoral/features/auth/presentation/session/cubit/auth_session_cubit.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/bloc/sign_up_bloc.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/bloc/sign_up_event.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/bloc/sign_up_state.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/strings/sign_up_strings.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/widgets/sign_up_widgets.dart';
import 'package:go_router/go_router.dart';

/// Factory que construye el Bloc del registro fuera de presentation.
typedef SignUpBlocFactory = SignUpBloc Function();

/// Callback inyectable usado al completar el auto-login.
typedef AuthenticatedSessionHandler = void Function(AuthSession session);

/// Pantalla de creacion de cuenta.
class SignUpPage extends StatelessWidget {
  /// Crea la pantalla con la fabrica de su Bloc.
  const SignUpPage({
    required this.createBloc,
    this.onAuthenticated,
    super.key,
  });

  /// Crea el Bloc con sus dependencias ya resueltas.
  final SignUpBlocFactory createBloc;

  /// Actualiza la sesion global; puede reemplazarse en widget tests.
  final AuthenticatedSessionHandler? onAuthenticated;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createBloc(),
      child: _SignUpView(onAuthenticated: onAuthenticated),
    );
  }
}

class _SignUpView extends StatefulWidget {
  const _SignUpView({this.onAuthenticated});

  final AuthenticatedSessionHandler? onAuthenticated;

  @override
  State<_SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<_SignUpView> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cuitController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Refleja el estado del modal para que el header muestre conectividad offline.
  bool _isOfflineModalOpen = false;
  bool _isFormValid = false;

  void _updateFormValidity(bool isValid) {
    if (_isFormValid == isValid) {
      return;
    }
    setState(() {
      _isFormValid = isValid;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _cuitController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  RegistrationRequest get _registrationRequest => RegistrationRequest(
    firstName: _firstNameController.text.trim(),
    lastName: _lastNameController.text.trim(),
    email: _emailController.text.trim(),
    cuit: _cuitController.text.trim(),
    password: _passwordController.text,
  );

  Future<void> _showOfflineModal() async {
    setState(() {
      _isOfflineModalOpen = true;
    });

    await showDialog<void>(
      context: context,
      barrierColor: AppColors.modalBarrier,
      builder: (context) => const SignUpOfflineModal(),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isOfflineModalOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpBloc, SignUpState>(
      listener: _handleRegistrationState,
      child: BlocBuilder<SignUpBloc, SignUpState>(
        builder: (context, state) {
          final isSubmitting = state.isProcessing;
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SignUpHeader(isOffline: _isOfflineModalOpen),
                    const SizedBox(height: AppSpacing.md),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.border,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const SignUpIntro(),
                    const SizedBox(height: AppSpacing.lg),
                    SignUpForm(
                      cuitController: _cuitController,
                      emailController: _emailController,
                      firstNameController: _firstNameController,
                      lastNameController: _lastNameController,
                      passwordController: _passwordController,
                      onValidityChanged: _updateFormValidity,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SignUpActions(
                      isSubmitting: isSubmitting,
                      loadingLabel: _loadingLabel(state.stage),
                      onLoginPressed: () {
                        context.push(AppRoutes.login);
                      },
                      onRegisterPressed: _isFormValid && !isSubmitting ? () => _submit(context) : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleRegistrationState(
    BuildContext context,
    SignUpState state,
  ) {
    switch (state.stage) {
      case SignUpStage.success:
        final session = state.session!;
        _passwordController.clear();
        final preparationError = state.preparationError;
        if (preparationError != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(preparationError.message)));
        }
        context.go(
          AppRoutes.signUpSuccessFor(
            hasEstablishments: state.preparationSummary?.hasEstablishments ?? false,
          ),
          extra: session.user,
        );
        final onAuthenticated = widget.onAuthenticated;
        if (onAuthenticated == null) {
          context.read<AuthSessionCubit>().setAuthenticated(session);
        } else {
          onAuthenticated(session);
        }
      case SignUpStage.failure:
        if (state.accountCreated) {
          _passwordController.clear();
        }
        final error = state.error!;
        if (error.code == DomainErrorCode.offline && !state.accountCreated) {
          unawaited(_showOfflineModal());
          return;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(error.message)),
          );
      case SignUpStage.idle || SignUpStage.registering || SignUpStage.signingIn || SignUpStage.preparingOfflineData:
        break;
    }
  }

  String _loadingLabel(SignUpStage stage) {
    return switch (stage) {
      SignUpStage.signingIn => SignUpStrings.signingInButton,
      SignUpStage.preparingOfflineData => SignUpStrings.preparingOfflineDataButton,
      SignUpStage.idle ||
      SignUpStage.registering ||
      SignUpStage.success ||
      SignUpStage.failure => SignUpStrings.registeringButton,
    };
  }

  void _submit(BuildContext context) {
    context.read<SignUpBloc>().add(
      SignUpSubmitted(request: _registrationRequest),
    );
  }
}
