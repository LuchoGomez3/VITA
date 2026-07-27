/// Textos base de la pantalla de bienvenida.
class WelcomeStrings {
  const WelcomeStrings._();

  /// Titulo principal de la pantalla de bienvenida.
  static const title = 'Mayoral';

  /// Subtitulo de la pantalla de bienvenida.
  static const subtitle = 'Trazabilidad ganadera para productores de Córdoba. Funciona también sin señal en el campo.';

  /// Texto del boton que inicia el proceso de alta manual.
  static const createAccountButton = 'Crear cuenta';

  /// Texto del boton para usuarios que ya tienen una cuenta.
  static const loginButton = 'Ya tengo cuenta';
}

/// Textos de la pantalla de creación de cuenta.
class SignUpStrings {
  const SignUpStrings._();

  /// Titulo breve usado en el encabezado de la pantalla de registro.
  static const pageTitle = 'Crear cuenta';

  /// Titulo principal de bienvenida dentro del formulario de registro.
  static const introTitle = 'Bienvenido al campo';

  /// Texto introductorio que resume los datos necesarios para registrarse.
  static const introSubtitle = 'Sólo necesitás tu CUIT y un correo. Después configurás tu primer establecimiento.';

  /// Label del campo de nombre del usuario.
  static const firstNameLabel = 'Nombre';

  /// Label del campo de apellido del usuario.
  static const lastNameLabel = 'Apellido';

  /// Label del campo de CUIT o CUIL.
  static const cuitLabel = 'CUIT / CUIL ';

  /// Sufijo aclaratorio que indica relacion con el RENSPA.
  static const cuitRenspaSuffix = '· titular del RENSPA';

  /// Label del campo de correo electronico.
  static const emailLabel = 'Correo electrónico';

  /// Label del campo de contrasena.
  static const passwordLabel = 'Contraseña';

  /// Hint corto que indica la longitud minima de la contrasena.
  static const passwordHint = 'Mínimo 8 caracteres';

  /// Requisito de longitud minima de la contrasena.
  static const passwordLengthRequirement = 'Al menos 8 caracteres';

  /// Requisito de mayuscula de la contrasena.
  static const passwordUppercaseRequirement = 'Al menos una mayúscula';

  /// Requisito numerico de la contrasena.
  static const passwordNumberRequirement = 'Al menos un número';

  /// Etiqueta que acompana el nivel calculado de la contrasena.
  static const passwordStrengthLabel = 'Fortaleza';

  /// Nivel debil de fortaleza de contrasena.
  static const passwordStrengthWeak = 'Débil';

  /// Nivel normal de fortaleza de contrasena.
  static const passwordStrengthNormal = 'Normal';

  /// Nivel fuerte de fortaleza de contrasena.
  static const passwordStrengthStrong = 'Fuerte';

  /// Nivel maximo de fortaleza de contrasena.
  static const passwordStrengthVeryStrong = 'Muy fuerte';

  /// Hint del campo de correo electronico.
  static const emailHint = 'tu@correo.com';

  /// Hint vacio usado cuando un campo no debe mostrar placeholder.
  static const emptyInputHint = '';

  /// Mensaje mostrado cuando el CUIT/CUIL tiene sus 11 digitos.
  static const cuitValidFormatMessage = 'Formato de CUIT/CUIL válido.';

  /// Mensaje mostrado mientras faltan digitos del CUIT/CUIL.
  static const cuitIncompleteMessage = 'Ingresá los 11 dígitos del CUIT/CUIL.';

  /// Mensaje mostrado cuando el digito verificador no coincide.
  static const cuitInvalidCheckDigitMessage = 'CUIT/CUIL invalido';

  /// Mensaje mostrado cuando el correo cumple el formato esperado.
  static const emailValidFormatMessage = 'Formato de correo válido.';

  /// Mensaje mostrado cuando el correo no cumple el formato esperado.
  static const emailInvalidFormatMessage = 'Ingresá un correo con formato nombre@dominio.com.';

  /// Titulo del modal que informa que se necesita conexion.
  static const offlineModalTitle = 'Necesitás conexión a internet';

  /// Mensaje del modal que explica la necesidad de internet para registrarse.
  static const offlineModalMessage =
      'Para crear tu cuenta por primera vez necesitás conexión a internet. Una vez registrado, podrás usar la app en el campo sin señal.';

  /// Titulo de la recomendacion de conexion por Wi-Fi.
  static const offlineWifiTitle = 'Wi-Fi de la casa o galpón';

  /// Subtitulo que marca al Wi-Fi como opcion recomendada.
  static const offlineWifiSubtitle = 'Recomendado';

  /// Titulo de la alternativa de conexion por datos moviles.
  static const offlineMobileDataTitle = 'Datos móviles';

  /// Subtitulo que sugiere mejorar la senal antes de usar datos moviles.
  static const offlineMobileDataSubtitle = 'Probá cerca de la ruta';

  /// Texto del boton para intentar nuevamente la operacion.
  static const retryButton = 'Reintentar';

  /// Texto del boton principal que envia el formulario de registro.
  static const registerButton = 'Registrar cuenta';

  /// Texto del boton mientras el backend procesa el registro.
  static const registeringButton = 'Registrando cuenta...';

  /// Prefijo del saludo mostrado al completar el registro.
  static const successWelcomePrefix = '¡Bienvenido ';

  /// Sufijo del saludo mostrado al completar el registro.
  static const successWelcomeSuffix = '!';

  /// Confirmacion que aparece debajo del saludo final.
  static const successSubtitle = 'Tu cuenta fue creada con éxito.';

  /// Rol inicial asignado al productor registrado.
  static const ownerRole = 'Owner';

  /// Etiqueta que acompaña al identificador fiscal.
  static const successCuitLabel = 'CUIT';

  /// Titulo de la recomendacion posterior al registro.
  static const nextStepTitle = 'Próximo paso';

  /// Descripcion de la configuracion que sigue al alta.
  static const nextStepDescription = 'Configurá tu primer establecimiento (RENSPA, ubicación y superficie).';

  /// Accion para comenzar la configuracion del establecimiento.
  static const configureEstablishmentButton = 'Configurar mi establecimiento';

  /// Accion temporal para volver a la pantalla principal.
  static const temporaryBackHomeButton = 'Ir a iniciar sesion';

  /// Texto previo al link de inicio de sesion para usuarios existentes.
  static const alreadyHaveAccountPrefix = '¿Ya tenés cuenta? ';

  /// Texto del link inline hacia el inicio de sesion.
  static const loginLink = 'Iniciá sesión';

  /// Texto inicial de la aceptacion legal de terminos.
  static const termsPrefix = 'Soy ';

  /// Texto que declara al usuario como titular del RENSPA.
  static const termsOwner = 'titular del RENSPA ';

  /// Texto intermedio de la aceptacion legal de terminos.
  static const termsMiddle = 'que voy a registrar y acepto los ';

  /// Texto enlazable de terminos y politica de privacidad.
  static const termsPrivacy = 'términos y la política de privacidad.';

  // TODO(franco): Migrar los iconos a una fuente compartida de assets.

  /// Ruta del icono de flecha para volver.
  static const arrowBackIcon = 'assets/icons/arrow_back_ios.svg';

  /// Ruta del icono de flecha para avanzar.
  static const arrowForwardIcon = 'assets/icons/arrow_forward.svg';

  /// Ruta del icono de reintento o sincronizacion.
  static const cachedIcon = 'assets/icons/cached.svg';

  /// Ruta del icono de check de confirmacion.
  static const checkIcon = 'assets/icons/check.svg';

  /// Ruta del icono usado para un requisito de contrasena cumplido.
  static const passwordRequirementValidIcon = 'assets/icons/check_small.svg';

  /// Ruta del icono usado para un requisito de contrasena pendiente.
  static const passwordRequirementInvalidIcon = 'assets/icons/close_small.svg';

  /// Ruta del icono de nube conectada.
  static const cloudIcon = 'assets/icons/cloud.svg';

  /// Ruta del icono de nube sin conexion.
  static const cloudOffIcon = 'assets/icons/cloud_off.svg';

  /// Ruta del icono para mostrar la contrasena.
  static const visibilityIcon = 'assets/icons/visibility.svg';

  /// Ruta del icono para ocultar la contrasena.
  static const visibilityOffIcon = 'assets/icons/visibility_off.svg';
}
