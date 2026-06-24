import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/pages/animal_detail_page.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/pages/registrar_animal_page.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/pages/registrar_animal_step_four_page.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/pages/registrar_animal_step_three_page.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/pages/registrar_animal_step_two_page.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/pages/registrar_animal_success_page.dart';
import 'package:frontend_mayoral/features/home/presentation/pages/home_page.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/pages/sign_up_page.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/pages/sign_up_welcome_first_time.dart';
import 'package:go_router/go_router.dart';

/// Configuracion del router de la app.
class AppRouter {
  /// Router de la app.
  static final GoRouter router = GoRouter(
    /// Ruta inicial de la app.
    initialLocation: AppRoutes.home,

    /// Rutas de la app.
    routes: [

      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomePage(),
      ),

      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpPage(),
      ),

      /// Ruta de la pantalla de inicio.
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.animalRegisterStep1,
        builder: (context, state) => const RegistrarAnimalPage(),
      ),
      GoRoute(
        path: AppRoutes.animalRegisterStep2,
        builder: (context, state) => const RegistrarAnimalStepTwoPage(),
      ),
      GoRoute(
        path: AppRoutes.animalRegisterStep3,
        builder: (context, state) => const RegistrarAnimalStepThreePage(),
      ),
      GoRoute(
        path: AppRoutes.animalRegisterStep4,
        builder: (context, state) => const RegistrarAnimalStepFourPage(),
      ),
      GoRoute(
        path: AppRoutes.animalRegisterSuccess,
        builder: (context, state) => const RegistrarAnimalSuccessPage(),
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
