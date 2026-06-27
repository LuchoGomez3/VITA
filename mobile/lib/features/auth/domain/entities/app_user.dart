import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/user_role.dart';

part 'app_user.freezed.dart';

/// Authenticated user profile used by the app domain.
@freezed
abstract class AppUser with _$AppUser {
  /// Creates an authenticated user profile.
  const factory AppUser({
    required int id,
    required String username,
    required String email,
    required String nombre,
    required String apellido,
    required String cuilCuit,
    required UserRole role,
    required DateTime createdAt,
  }) = _AppUser;
}
