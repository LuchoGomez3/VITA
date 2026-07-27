import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';

/// Estado del proceso remoto de creacion de cuenta.
///
/// El resultado exitoso conserva solo el [AppUser] devuelto por backend. No se
/// guarda la contrasena ni se modela una sesion, porque el registro actual no
/// autentica al usuario automaticamente.
typedef SignUpState = ResultState<AppUser>;
