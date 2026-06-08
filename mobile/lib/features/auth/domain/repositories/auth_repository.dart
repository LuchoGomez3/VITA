import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<Result<AppUser>> signIn({
    required String username,
    required String password,
  });

  Future<Result<AppUser>> getCurrentUser();

  Future<void> signOut();
}
