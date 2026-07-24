import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/user_role.dart';

part 'app_user.freezed.dart';

/// Usuario autenticado devuelto por el backend.
@freezed
sealed class AppUser with _$AppUser {
  /// Crea un usuario autenticado.
  const factory AppUser({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    String? cuit,
    @Default(UserRole.unknown) UserRole role,
  }) = _AppUser;
}
