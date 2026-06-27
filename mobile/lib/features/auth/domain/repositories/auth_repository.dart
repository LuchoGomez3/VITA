import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';

/// Contract for authentication operations used by the domain layer.
abstract class AuthRepository {
  /// Signs in with username and password.
  Future<Result<AppUser>> signIn({
    required String username,
    required String password,
  });

  /// Returns the currently authenticated user when available.
  Future<Result<AppUser>> getCurrentUser();

  /// Ends the current authenticated session.
  Future<void> signOut();
}
