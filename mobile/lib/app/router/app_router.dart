import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/pages/animal_detail_page.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/pages/registrar_animal_page.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/pages/senasa_report_page.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/pages/senasa_menu_page.dart';
import 'package:frontend_mayoral/features/home/presentation/pages/home_page.dart';
import 'package:go_router/go_router.dart';

/// Configuracion del router de la app.
class AppRouter {
  /// Router de la app.
  static final GoRouter router = GoRouter(
    /// Ruta inicial de la app.
    initialLocation: AppRoutes.home,

    /// Rutas de la app.
    routes: [
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
        path: AppRoutes.animalDetail,
        builder: (context, state) {
          final animalId = state.pathParameters['animalId']!;
          return AnimalDetailPage(animalId: animalId);
        },
      ),
      GoRoute(
        path: AppRoutes.senasaMenu,
        builder: (context, state) => const SenasaMenuPage(),
      ),
      GoRoute(
        path: AppRoutes.senasaReport,
        builder: (context, state) => const SenasaReportPage(),
      ),
    ],
  );
}
