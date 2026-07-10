/// Textos base de la pantalla de bienvenida.
class WelcomeStrings {
  const WelcomeStrings._();

  /// Titulo principal de la pantalla de bienvenida.
  static const title = 'Mayoral';

  /// Subtitulo de la pantalla de bienvenida.
  static const subtitle =
      'Trazabilidad ganadera para productores de Córdoba. Funciona también sin señal en el campo.';

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
  static const introSubtitle =
      'Sólo necesitás tu CUIT y un correo. Después configurás tu primer establecimiento.';

  /// Label del campo de nombre del usuario.
  static const firstNameLabel = 'Nombre';

  /// Nombre de ejemplo precargado mientras el alta permanece mockeada.
  static const firstNameMockValue = 'Juan';

  /// Label del campo de apellido del usuario.
  static const lastNameLabel = 'Apellido';

  /// Apellido de ejemplo precargado mientras el alta permanece mockeada.
  static const lastNameMockValue = 'Pérez';

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

  /// Texto de ayuda con los requisitos completos de la contrasena.
  static const passwordRequirements =
      'Te pedimos al menos 8 caracteres, con un número o una mayúscula.';

  /// Hint del campo de correo electronico.
  static const emailHint = 'tu@correo.com';

  /// Hint vacio usado cuando un campo no debe mostrar placeholder.
  static const emptyInputHint = '';

  /// Valor de ejemplo para el campo de CUIT en la maqueta.
  static const cuitMockValue = '20-34567890-2';

  /// Valor de ejemplo para el campo de correo en la maqueta.
  static const emailMockValue = 'juan@campo.com';

  /// Mensaje de validacion positiva del digito verificador del CUIT.
  static const cuitValidMessage = 'Dígito verificador correcto.';

  /// Mensaje de validacion negativa del digito verificador del CUIT.
  static const cuitInvalidMessage = 'Revisá el dígito verificador.';

  /// Mensaje mostrado cuando el correo ya esta registrado.
  static const emailAlreadyRegisteredMessage =
      'Ya existe una cuenta con este correo.';

  /// Mensaje mostrado cuando el correo esta disponible.
  static const emailAvailableMessage = 'Correo disponible.';

  /// Titulo del aviso de cuenta ya existente.
  static const existingAccountTitle = 'Cuenta ya existente';

  /// Mensaje que explica que el CUIT o correo ya estan asociados.
  static const existingAccountMessage =
      'El CUIT o Correo ingresado ya se encuentran asociados a una cuenta activa. Por favor, iniciá sesión.';

  /// Texto del boton que lleva al inicio de sesion.
  static const loginButton = 'Iniciar sesión';

  /// Texto del boton que permite probar con otro correo.
  static const useAnotherEmailButton = 'Usar otro correo';

  /// Texto del boton para previsualizar el modal sin conexion.
  static const offlinePreviewButton = 'Ver modal sin conexión';

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

  /// Titulo principal de la pantalla de progreso de registro.
  static const creatingAccountTitle = 'Creando tu cuenta...';

  /// Subtitulo de la pantalla de progreso de registro.
  static const creatingAccountSubtitle =
      'Estamos guardando tus datos y preparando el dispositivo para que después funcione sin señal.';

  /// Etiqueta de estado para la validacion que esta corriendo.
  static const creatingAccountInProgress = 'en curso';

  /// Validacion de CUIT dentro del alta de cuenta.
  static const creatingAccountValidateCuit = 'Validando CUIT';

  /// Validacion de correo dentro del alta de cuenta.
  static const creatingAccountVerifyEmail = 'Verificando correo';

  /// Validacion de credenciales dentro del alta de cuenta.
  static const creatingAccountGenerateCredentials = 'Generando credenciales';

  /// Validacion de configuracion inicial dentro del alta de cuenta.
  static const creatingAccountDownloadInitialConfig =
      'Descargando configuración inicial';

  /// Prefijo del saludo mostrado al completar el registro.
  static const successWelcomePrefix = '¡Bienvenido ';

  /// Sufijo del saludo mostrado al completar el registro.
  static const successWelcomeSuffix = '!';

  /// Confirmacion que aparece debajo del saludo final.
  static const successSubtitle =
      'Tu cuenta fue creada con éxito. Ya iniciaste sesión.';

  /// Rol inicial asignado al productor registrado.
  static const ownerRole = 'Owner';

  /// Etiqueta que acompaña al identificador fiscal.
  static const successCuitLabel = 'CUIT';

  /// Titulo de la recomendacion posterior al registro.
  static const nextStepTitle = 'Próximo paso';

  /// Descripcion de la configuracion que sigue al alta.
  static const nextStepDescription =
      'Configurá tu primer establecimiento (RENSPA, ubicación y superficie).';

  /// Accion para comenzar la configuracion del establecimiento.
  static const configureEstablishmentButton = 'Configurar mi establecimiento';

  /// Accion temporal para volver a la pantalla principal.
  static const temporaryBackHomeButton = 'Volver a la pantalla principal';

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


  /// TODO: (FRANCO) Migrar luego a archivo de assets general para que pueda ser usado en otras pantallas.


  /// Ruta del icono de flecha para volver.
  static const arrowBackIcon = 'assets/icons/arrow_back_ios.svg';


  /// Ruta del icono de flecha para avanzar.
  static const arrowForwardIcon = 'assets/icons/arrow_forward.svg';

  /// Ruta del icono de reintento o sincronizacion.
  static const cachedIcon = 'assets/icons/cached.svg';

  /// Ruta del icono de check de confirmacion.
  static const checkIcon = 'assets/icons/check.svg';

  /// Ruta del icono de nube conectada.
  static const cloudIcon = 'assets/icons/cloud.svg';

  /// Ruta del icono de nube sin conexion.
  static const cloudOffIcon = 'assets/icons/cloud_off.svg';

  /// Ruta del icono para mostrar la contrasena.
  static const visibilityIcon = 'assets/icons/visibility.svg';

  /// Ruta del icono para ocultar la contrasena.
  static const visibilityOffIcon = 'assets/icons/visibility_off.svg';
}
