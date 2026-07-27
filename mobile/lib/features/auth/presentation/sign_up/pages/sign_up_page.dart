import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/registration_request.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/bloc/sign_up_bloc.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/bloc/sign_up_event.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/bloc/sign_up_state.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/widgets/sign_up_widgets.dart';
import 'package:go_router/go_router.dart';

/// Factory que construye el Bloc del registro fuera de presentation.
typedef SignUpBlocFactory = SignUpBloc Function();

/// Pantalla de creacion de cuenta.
class SignUpPage extends StatelessWidget {
  /// Crea la pantalla con la fabrica de su Cubit.
  const SignUpPage({
    required this.createBloc,
    super.key,
  });

  /// Crea el Bloc con sus dependencias ya resueltas.
  final SignUpBlocFactory createBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createBloc(),
      child: const _SignUpView(),
    );
  }
}

class _SignUpView extends StatefulWidget {
  const _SignUpView();

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
    final isSubmitting = context.select<SignUpBloc, bool>(
      (bloc) => bloc.state is Loading<AppUser>,
    );

    return BlocListener<SignUpBloc, SignUpState>(
      listener: _handleRegistrationState,
      child: Scaffold(
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
      ),
    );
  }

  void _handleRegistrationState(
    BuildContext context,
    SignUpState state,
  ) {
    switch (state) {
      case Data<AppUser>(:final data):
        _passwordController.clear();
        // TODO(sign-up): Insertar aca la pantalla de verificacion mediante el
        // codigo enviado al email antes de confirmar la cuenta creada.
        context.go(AppRoutes.signUpSuccess, extra: data);
      case ResultError<AppUser>(:final error):
        if (error.code == DomainErrorCode.offline) {
          unawaited(_showOfflineModal());
          return;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(error.message)),
          );
      default:
        break;
    }
  }

  void _submit(BuildContext context) {
    context.read<SignUpBloc>().add(
      SignUpSubmitted(request: _registrationRequest),
    );
  }
}
