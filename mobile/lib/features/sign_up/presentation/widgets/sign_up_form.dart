import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_mayoral/core/formatters/formatters.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/validators/validators.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/strings/sign_up_strings.dart';

/// Formulario visual del alta de usuario.
class SignUpForm extends StatefulWidget {
  /// Crea el formulario con los controladores administrados por la pagina.
  const SignUpForm({
    required this.cuitController,
    required this.emailController,
    required this.firstNameController,
    required this.lastNameController,
    required this.passwordController,
    this.onValidityChanged,
    super.key,
  });

  /// Controlador del CUIT/CUIL.
  final TextEditingController cuitController;

  /// Controlador del correo electronico.
  final TextEditingController emailController;

  /// Controlador del nombre.
  final TextEditingController firstNameController;

  /// Controlador del apellido.
  final TextEditingController lastNameController;

  /// Controlador de la contrasena.
  final TextEditingController passwordController;

  /// Notifica si todos los campos cumplen sus validaciones locales.
  final ValueChanged<bool>? onValidityChanged;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

enum _SignUpField { firstName, lastName, cuit, email, password }

class _SignUpFormState extends State<SignUpForm> {
  late final Map<_SignUpField, bool> _fieldValidity;
  bool _lastReportedValidity = false;

  @override
  void initState() {
    super.initState();
    _fieldValidity = {
      _SignUpField.firstName:
          widget.firstNameController.text.trim().isNotEmpty &&
          FormValidators.nameError(widget.firstNameController.text) == null,
      _SignUpField.lastName:
          widget.lastNameController.text.trim().isNotEmpty &&
          FormValidators.nameError(widget.lastNameController.text) == null,
      _SignUpField.cuit: CuitInputFormatter.validationError(widget.cuitController.text) == null,
      _SignUpField.email: FormValidators.isEmailValid(
        widget.emailController.text,
      ),
      _SignUpField.password: FormValidators.validatePassword(
        widget.passwordController.text,
      ).isValid,
    };
  }

  void _updateFieldValidity(_SignUpField field, bool isValid) {
    _fieldValidity[field] = isValid;
    final isFormValid = _fieldValidity.values.every((isValid) => isValid);
    if (_lastReportedValidity == isFormValid) {
      return;
    }
    _lastReportedValidity = isFormValid;
    widget.onValidityChanged?.call(isFormValid);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _SignUpNameField(
                controller: widget.firstNameController,
                onValidityChanged: (isValid) => _updateFieldValidity(
                  _SignUpField.firstName,
                  isValid,
                ),
                title: SignUpStrings.firstNameLabel,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _SignUpNameField(
                controller: widget.lastNameController,
                onValidityChanged: (isValid) => _updateFieldValidity(
                  _SignUpField.lastName,
                  isValid,
                ),
                title: SignUpStrings.lastNameLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _SignUpCuitField(
          controller: widget.cuitController,
          onValidityChanged: (isValid) => _updateFieldValidity(
            _SignUpField.cuit,
            isValid,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _SignUpEmailField(
          controller: widget.emailController,
          onValidityChanged: (isValid) => _updateFieldValidity(
            _SignUpField.email,
            isValid,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _SignUpPasswordField(
          controller: widget.passwordController,
          onValidityChanged: (isValid) => _updateFieldValidity(
            _SignUpField.password,
            isValid,
          ),
        ),
      ],
    );
  }
}

class _SignUpNameField extends StatelessWidget {
  const _SignUpNameField({
    required this.controller,
    required this.onValidityChanged,
    required this.title,
  });

  final TextEditingController controller;
  final ValueChanged<bool> onValidityChanged;
  final String title;

  static const _maxCharacters = 50;

  void _handleValueChanged(String value) {
    onValidityChanged(value.trim().isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      controller: controller,
      title: title,
      hintText: SignUpStrings.emptyInputHint,
      maxCharacters: _maxCharacters,
      inputFormatters: [NameInputFormatter()],
      onChanged: _handleValueChanged,
      validation: AppFieldValidation.valid,
    );
  }
}

class _SignUpEmailField extends StatefulWidget {
  const _SignUpEmailField({
    required this.controller,
    required this.onValidityChanged,
  });

  final TextEditingController controller;
  final ValueChanged<bool> onValidityChanged;

  @override
  State<_SignUpEmailField> createState() => _SignUpEmailFieldState();
}

class _SignUpEmailFieldState extends State<_SignUpEmailField> {
  late bool _isValid;

  @override
  void initState() {
    super.initState();
    _isValid = FormValidators.isEmailValid(widget.controller.text);
  }

  void _validateEmail(String value) {
    final isValid = FormValidators.isEmailValid(value);
    if (_isValid == isValid) {
      return;
    }
    setState(() {
      _isValid = isValid;
    });
    widget.onValidityChanged(isValid);
  }

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      controller: widget.controller,
      title: SignUpStrings.emailLabel,
      hintText: SignUpStrings.emailHint,
      keyboardType: TextInputType.emailAddress,
      onChanged: _validateEmail,
      validation: _isValid ? AppFieldValidation.valid : AppFieldValidation.invalid,
      validationMessage: _isValid ? SignUpStrings.emailValidFormatMessage : SignUpStrings.emailInvalidFormatMessage,
    );
  }
}

class _SignUpCuitField extends StatefulWidget {
  const _SignUpCuitField({
    required this.controller,
    required this.onValidityChanged,
  });

  final TextEditingController controller;
  final ValueChanged<bool> onValidityChanged;

  @override
  State<_SignUpCuitField> createState() => _SignUpCuitFieldState();
}

class _SignUpCuitFieldState extends State<_SignUpCuitField> {
  late CuitValidationError? _validationError;

  @override
  void initState() {
    super.initState();
    _validationError = CuitInputFormatter.validationError(
      widget.controller.text,
    );
  }

  void _updateValidation(CuitValidationError? error) {
    if (error == CuitValidationError.invalidCharacters || error == CuitValidationError.maxLength) {
      return;
    }
    if (_validationError == error) {
      return;
    }
    setState(() {
      _validationError = error;
    });
    widget.onValidityChanged(error == null);
  }

  void _handleValueChanged(String value) {
    final error = CuitInputFormatter.validationError(value);
    if (_validationError != error) {
      setState(() {
        _validationError = error;
      });
    }
    widget.onValidityChanged(error == null);
  }

  String get _validationMessage => switch (_validationError) {
    null => SignUpStrings.cuitValidFormatMessage,
    CuitValidationError.invalidCheckDigit => SignUpStrings.cuitInvalidCheckDigitMessage,
    _ => SignUpStrings.cuitIncompleteMessage,
  };

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      controller: widget.controller,
      titleWidget: RichText(
        text: const TextSpan(
          style: AppTypography.secondaryEmphasis,
          children: [
            TextSpan(text: SignUpStrings.cuitLabel),
            TextSpan(
              text: SignUpStrings.cuitRenspaSuffix,
              style: AppTypography.pageBodyTitle,
            ),
          ],
        ),
      ),
      hintText: SignUpStrings.emptyInputHint,
      keyboardType: TextInputType.number,
      inputFormatters: [
        CuitInputFormatter(onValidationChanged: _updateValidation),
      ],
      onChanged: _handleValueChanged,
      validation: _validationError == null ? AppFieldValidation.valid : AppFieldValidation.invalid,
      validationMessage: _validationMessage,
    );
  }
}

class _SignUpPasswordField extends StatefulWidget {
  const _SignUpPasswordField({
    required this.controller,
    required this.onValidityChanged,
  });

  final TextEditingController controller;
  final ValueChanged<bool> onValidityChanged;

  @override
  State<_SignUpPasswordField> createState() => _SignUpPasswordFieldState();
}

class _SignUpPasswordFieldState extends State<_SignUpPasswordField> {
  static const _maxCharacters = 50;

  bool _isPasswordVisible = false;
  late PasswordValidation _validation;
  late bool _hasInput;

  @override
  void initState() {
    super.initState();
    _validation = FormValidators.validatePassword(widget.controller.text);
    _hasInput = widget.controller.text.isNotEmpty;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _validatePassword(String value) {
    setState(() {
      _validation = FormValidators.validatePassword(value);
      _hasInput = value.isNotEmpty;
    });
    widget.onValidityChanged(_validation.isValid);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextFormField(
          controller: widget.controller,
          title: SignUpStrings.passwordLabel,
          hintText: SignUpStrings.passwordHint,
          keyboardType: TextInputType.visiblePassword,
          obscureText: !_isPasswordVisible,
          autocorrect: false,
          enableSuggestions: false,
          maxCharacters: _maxCharacters,
          onChanged: _validatePassword,
          validation: _validation.isValid ? AppFieldValidation.valid : AppFieldValidation.invalid,
          suffixIcon: IconButton(
            onPressed: _togglePasswordVisibility,
            icon: SvgPicture.asset(
              _isPasswordVisible ? SignUpStrings.visibilityOffIcon : SignUpStrings.visibilityIcon,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.iconMuted,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _PasswordRequirement(
          isMet: _validation.hasMinimumLength,
          label: SignUpStrings.passwordLengthRequirement,
        ),
        const SizedBox(height: AppSpacing.xs),
        _PasswordRequirement(
          isMet: _validation.hasUppercase,
          label: SignUpStrings.passwordUppercaseRequirement,
        ),
        const SizedBox(height: AppSpacing.xs),
        _PasswordRequirement(
          isMet: _validation.hasNumber,
          label: SignUpStrings.passwordNumberRequirement,
        ),
        if (_hasInput) ...[
          const SizedBox(height: AppSpacing.sm),
          _PasswordStrengthIndicator(strength: _validation.strength),
        ],
      ],
    );
  }
}

class _PasswordRequirement extends StatelessWidget {
  const _PasswordRequirement({required this.isMet, required this.label});

  final bool isMet;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = isMet ? AppColors.primary : AppColors.error;
    return Row(
      children: [
        SvgPicture.asset(
          isMet ? SignUpStrings.passwordRequirementValidIcon : SignUpStrings.passwordRequirementInvalidIcon,
          width: 18,
          height: 18,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: isMet ? AppTypography.formFieldSuccess : AppTypography.formFieldError,
        ),
      ],
    );
  }
}

class _PasswordStrengthIndicator extends StatelessWidget {
  const _PasswordStrengthIndicator({required this.strength});

  final PasswordStrength strength;

  double get _progress => switch (strength) {
    PasswordStrength.weak => 0.25,
    PasswordStrength.normal => 0.5,
    PasswordStrength.strong => 0.75,
    PasswordStrength.veryStrong => 1,
  };

  Color get _color => switch (strength) {
    PasswordStrength.weak => AppColors.error,
    PasswordStrength.normal => AppColors.passwordStrengthNormal,
    PasswordStrength.strong => AppColors.primary,
    PasswordStrength.veryStrong => AppColors.passwordStrengthVeryStrong,
  };

  String get _label => switch (strength) {
    PasswordStrength.weak => SignUpStrings.passwordStrengthWeak,
    PasswordStrength.normal => SignUpStrings.passwordStrengthNormal,
    PasswordStrength.strong => SignUpStrings.passwordStrengthStrong,
    PasswordStrength.veryStrong => SignUpStrings.passwordStrengthVeryStrong,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 6,
            backgroundColor: AppColors.border,
            color: _color,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${SignUpStrings.passwordStrengthLabel}: $_label',
          style: AppTypography.formFieldHelper.copyWith(color: _color),
        ),
      ],
    );
  }
}
