import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/registration_request.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/bloc/sign_up_cubit.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/bloc/sign_up_state.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/models/sign_up_user_data.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/widgets/sign_up_widgets.dart';
import 'package:go_router/go_router.dart';

/// Factory que construye el Cubit del registro fuera de presentation.
typedef SignUpCubitFactory = SignUpCubit Function();

/// Pantalla de creacion de cuenta.
class SignUpPage extends StatelessWidget {
  /// Crea la pantalla con la fabrica de su Cubit.
  const SignUpPage({
    required this.createCubit,
    super.key,
  });

  /// Crea el Cubit con sus dependencias ya resueltas.
  final SignUpCubitFactory createCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createCubit(),
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

  SignUpUserData get _userData => SignUpUserData(
    firstName: _firstNameController.text.trim(),
    lastName: _lastNameController.text.trim(),
    email: _emailController.text.trim(),
    cuit: _cuitController.text.trim(),
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
    final isSubmitting = context.select<SignUpCubit, bool>(
      (cubit) => cubit.state is Loading<void>,
    );

    return BlocListener<SignUpCubit, SignUpState>(
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
      case Data<void>():
        final userData = _userData;
        _passwordController.clear();
        // TODO(sign-up): Insertar aca la pantalla de verificacion mediante el
        // codigo enviado al email antes de confirmar la cuenta creada.
        context.go(AppRoutes.signUpSuccess, extra: userData);
      case ResultError<void>(:final error):
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
    context.read<SignUpCubit>().register(
      request: _registrationRequest,
    );
  }
}
