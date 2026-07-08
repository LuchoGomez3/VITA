import 'package:frontend_mayoral/features/auth/domain/entities/user_role.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';

@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String username,
    required String email,
    required String nombre,
    required String apellido,
    required String cuilCuit,
    required UserRole role,
    required DateTime createdAt,
  }) = _AppUser;
}
