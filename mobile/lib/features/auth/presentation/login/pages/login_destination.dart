import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/features/auth/presentation/login/bloc/login_bloc.dart';

/// Decide a qué pantalla se entra después de un login exitoso.
extension LoginDestination on LoginState {
  /// Ruta de destino tras iniciar sesión.
  ///
  /// Si la sincronización inicial confirmó que el usuario no tiene ningún
  /// establecimiento, lo lleva al estado vacío para que cree uno: Inicio no
  /// tiene nada que mostrarle. Si la sincronización falló (p. ej. sin conexión)
  /// no se sabe cuántos tiene, así que entra a Inicio con lo que haya cacheado.
  String get destinationAfterSignIn {
    return postAuthenticationSummary?.hasEstablishments == false
        ? AppRoutes.establishmentRegisterEmpty
        : AppRoutes.home;
  }
}
