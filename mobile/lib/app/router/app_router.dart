import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/layout/main_layout_page.dart';
import 'package:frontend_mayoral/app/layout/main_layout_strings.dart';
import 'package:frontend_mayoral/app/layout/shell_placeholder_page.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/navigation/backward_page.dart';
import 'package:frontend_mayoral/core/navigation/fade_page.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/pages/animal_detail_page.dart';
import 'package:frontend_mayoral/features/animal_register/animal_register_composition.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/bloc/register_animal_bloc.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/pages/register_animal_page.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/pages/registrar_animal_success_page.dart';
import 'package:frontend_mayoral/features/auth/auth_composition.dart';
import 'package:frontend_mayoral/features/auth/presentation/bloc/auth_session_cubit.dart';
import 'package:frontend_mayoral/features/auth/presentation/pages/auth_check_page.dart';
import 'package:frontend_mayoral/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_mayoral/features/home/home_composition.dart';
import 'package:frontend_mayoral/features/home/presentation/pages/home_page.dart';
import 'package:frontend_mayoral/features/livestock/presentation/pages/livestock_page.dart';
import 'package:frontend_mayoral/features/profile/presentation/pages/profile_page.dart';
import 'package:frontend_mayoral/features/profile/presentation/strings/profile_strings.dart';
import 'package:go_router/go_router.dart';

/// Configuracion del router de la app.
class AppRouter {
  /// Router de la app.
  static final GoRouter router = GoRouter(
    /// La app arranca restaurando sesion local antes de decidir login/home.
    initialLocation: AppRoutes.authCheck,

    /// Rutas de la app.
    routes: [
      GoRoute(
        path: AppRoutes.authCheck,
        builder: (context, state) => const AuthCheckPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => BackwardPage(
          state: state,
          child: const LoginPage(
            createCubit: createLoginCubit,
          ),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainLayoutPage(
          navigationShell: navigationShell,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                pageBuilder: (context, state) {
                  final sessionState = context.watch<AuthSessionCubit>().state;
                  final userName = switch (sessionState) {
                    AuthSessionAuthenticated(:final session) => session.user.firstName,
                    _ => '',
                  };

                  return FadePage(
                    state: state,
                    child: HomePage(
                      createCubit: createHomeDashboardCubit,
                      userName: userName,
                    ),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.livestock,
                builder: (context, state) => const LivestockPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.procedures,
                builder: (context, state) => const ShellPlaceholderPage(
                  title: MainLayoutStrings.proceduresPlaceholder,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) {
                  final sessionState = context.watch<AuthSessionCubit>().state;

                  return switch (sessionState) {
                    AuthSessionAuthenticated(:final session) => ProfilePage(
                      username: session.user.email,
                      firstName: session.user.firstName,
                      lastName: session.user.lastName,
                      signOut: context.read<AuthSessionCubit>().signOut,
                    ),
                    _ => ProfilePage(
                      username: ProfileStrings.emptyCredential,
                      firstName: ProfileStrings.emptyCredential,
                      lastName: ProfileStrings.emptyCredential,
                      signOut: context.read<AuthSessionCubit>().signOut,
                    ),
                  };
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.animalRegisterStep1,
        builder: (context, state) => const RegisterAnimalPage(
          createBloc: createRegisterAnimalBloc,
        ),
      ),
      GoRoute(
        path: AppRoutes.animalRegisterStep2,
        builder: (context, state) => const RegisterAnimalPage(
          createBloc: createRegisterAnimalBloc,
          initialStep: RegisterAnimalStep.basicData,
        ),
      ),
      GoRoute(
        path: AppRoutes.animalRegisterStep3,
        builder: (context, state) => const RegisterAnimalPage(
          createBloc: createRegisterAnimalBloc,
          initialStep: RegisterAnimalStep.genealogy,
        ),
      ),
      GoRoute(
        path: AppRoutes.animalRegisterStep4,
        builder: (context, state) => const RegisterAnimalPage(
          createBloc: createRegisterAnimalBloc,
          initialStep: RegisterAnimalStep.review,
        ),
      ),
      GoRoute(
        path: AppRoutes.animalRegisterSuccess,
        builder: (context, state) {
          final registeredAnimal = state.extra! as RegisteredAnimal;
          return RegistrarAnimalSuccessPage(
            registeredAnimal: registeredAnimal,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.animalDetail,
        builder: (context, state) {
          final animalId = state.pathParameters['animalId']!;
          return AnimalDetailPage(
            animalId: animalId,
          );
        },
      ),
    ],
  );
}
