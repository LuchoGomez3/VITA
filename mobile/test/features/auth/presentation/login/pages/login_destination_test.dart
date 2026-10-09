import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/features/auth/presentation/login/bloc/login_bloc.dart';
import 'package:frontend_mayoral/features/auth/presentation/login/pages/login_destination.dart';

void main() {
  group('LoginDestination', () {
    test('opens the empty state when the sync confirms there are no establishments', () {
      final state = LoginState.initial().copyWith(
        postAuthenticationSummary: PostAuthenticationSummary(establishmentIds: const []),
      );

      expect(state.destinationAfterSignIn, AppRoutes.establishmentRegisterEmpty);
    });

    test('opens Inicio when the user has establishments', () {
      final state = LoginState.initial().copyWith(
        postAuthenticationSummary: PostAuthenticationSummary(establishmentIds: const ['establishment-1']),
      );

      expect(state.destinationAfterSignIn, AppRoutes.home);
    });

    test('opens Inicio when the sync failed and the establishments are unknown', () {
      expect(LoginState.initial().destinationAfterSignIn, AppRoutes.home);
    });
  });
}
