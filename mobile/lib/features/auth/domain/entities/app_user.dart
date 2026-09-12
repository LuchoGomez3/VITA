import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';

/// Usuario autenticado devuelto por el backend.
@freezed
abstract class AppUser with _$AppUser {
  /// Crea un usuario autenticado.
  const factory AppUser({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    String? cuit,
  }) = _AppUser;
}
