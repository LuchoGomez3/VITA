import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/pages/animal_detail_page.dart';
import 'package:frontend_mayoral/features/animal_register/animal_register_composition.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/bloc/register_animal_bloc.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/pages/register_animal_page.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/pages/registrar_animal_success_page.dart';
import 'package:frontend_mayoral/features/auth/auth_composition.dart';
import 'package:frontend_mayoral/features/auth/data/session_manager.dart';
import 'package:frontend_mayoral/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_mayoral/features/home/presentation/pages/home_page.dart';
import 'package:go_router/go_router.dart';

/// Configuracion del router de la app.
class AppRouter {
  const AppRouter._();

  /// Construye el router con el guard de autenticación.
  ///
  /// El [sessionManager] es el `refreshListenable`: cuando la sesión cambia
  /// (login/logout/refresh muerto) GoRouter reevalúa la redirección. Si no hay
  /// sesión cacheada se fuerza `/login`; si hay, se permite operar (incluso
  /// offline, porque la sesión se rehidrató desde almacenamiento seguro).
  static GoRouter build(SessionManager sessionManager) => GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: sessionManager,
    redirect: (context, state) {
      final goingToLogin = state.matchedLocation == AppRoutes.login;
      if (!sessionManager.isAuthenticated) {
        return goingToLogin ? null : AppRoutes.login;
      }
      if (goingToLogin) {
        return AppRoutes.home;
      }
      return null;
    },

    /// Rutas de la app.
    routes: [
      /// Ruta de la pantalla de login.
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => LoginPage(
          createCubit: () => createAuthCubit(sessionManager),
        ),
      ),

      /// Ruta de la pantalla de inicio.
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
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
          return AnimalDetailPage(animalId: animalId);
        },
      ),
    ],
  );
}
