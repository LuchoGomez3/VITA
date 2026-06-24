/// Textos base de la pantalla de bienvenida.
class WelcomeStrings {
  const WelcomeStrings._();

  /// Titulo principal de la pantalla de bienvenida.
  static const title = 'Mayoral';

  /// Subtitulo de la pantalla de bienvenida.
  static const subtitle =
      'Trazabilidad ganadera para productores de Córdoba. Funciona también sin señal en el campo.';

  /// Texto del boton para iniciar el proceso de alta manual.
  static const createAccountButton = 'Crear cuenta';

  /// Texto del boton para iniciar sesión si ya se tiene una cuenta.
  static const loginButton = 'Ya tengo cuenta';
}

/// Textos de la pantalla de creación de cuenta.
class SignUpStrings {
  const SignUpStrings._();

  static const pageTitle = 'Crear cuenta';
  static const introTitle = 'Bienvenido al campo';
  static const introSubtitle =
      'Sólo necesitás tu CUIT y un correo. Después configurás tu primer establecimiento.';

  static const firstNameLabel = 'Nombre';
  static const lastNameLabel = 'Apellido';
  static const cuitLabel = 'CUIT / CUIL ';
  static const cuitRenspaSuffix = '· titular del RENSPA';
  static const emailLabel = 'Correo electrónico';
  static const passwordLabel = 'Contraseña';
  static const passwordHint = 'Mínimo 8 caracteres';
  static const passwordRequirements =
      'Te pedimos al menos 8 caracteres, con un número o una mayúscula.';

  static const emailHint = 'tu@correo.com';
  static const emptyInputHint = '';
  static const cuitMockValue = '20-34567890-2';
  static const emailMockValue = 'juan@campo.com';
  static const cuitValidMessage = 'Dígito verificador correcto.';
  static const cuitInvalidMessage = 'Revisá el dígito verificador.';
  static const emailAlreadyRegisteredMessage =
      'Ya existe una cuenta con este correo.';
  static const emailAvailableMessage = 'Correo disponible.';

  static const existingAccountTitle = 'Cuenta ya existente';
  static const existingAccountMessage =
      'El CUIT o Correo ingresado ya se encuentran asociados a una cuenta activa. Por favor, iniciá sesión.';
  static const loginButton = 'Iniciar sesión';
  static const useAnotherEmailButton = 'Usar otro correo';

  static const offlinePreviewButton = 'Ver modal sin conexión';
  static const offlineModalTitle = 'Necesitás conexión a internet';
  static const offlineModalMessage =
      'Para crear tu cuenta por primera vez necesitás conexión a internet. Una vez registrado, podrás usar la app en el campo sin señal.';
  static const offlineWifiTitle = 'Wi-Fi de la casa o galpón';
  static const offlineWifiSubtitle = 'Recomendado';
  static const offlineMobileDataTitle = 'Datos móviles';
  static const offlineMobileDataSubtitle = 'Probá cerca de la ruta';
  static const retryButton = 'Reintentar';

  static const registerButton = 'Registrar cuenta';
  static const alreadyHaveAccountPrefix = '¿Ya tenés cuenta? ';
  static const loginLink = 'Iniciá sesión';

  static const termsPrefix = 'Soy ';
  static const termsOwner = 'titular del RENSPA ';
  static const termsMiddle = 'que voy a registrar y acepto los ';
  static const termsPrivacy = 'términos y la política de privacidad.';

  static const arrowBackIcon = 'assets/icons/arrow_back_ios.svg';
  static const arrowForwardIcon = 'assets/icons/arrow_forward.svg';
  static const cachedIcon = 'assets/icons/cached.svg';
  static const cloudIcon = 'assets/icons/cloud.svg';
  static const cloudOffIcon = 'assets/icons/cloud_off.svg';
  static const visibilityIcon = 'assets/icons/visibility.svg';
  static const visibilityOffIcon = 'assets/icons/visibility_off.svg';
}
