import 'package:frontend_mayoral/core/result/result_state.dart';

/// Estado del proceso remoto de creacion de cuenta.
///
/// El resultado exitoso no conserva los datos ingresados ni la contrasena.
typedef SignUpState = ResultState<void>;
