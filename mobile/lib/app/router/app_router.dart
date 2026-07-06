import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/config/config.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
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
import 'package:frontend_mayoral/features/home/presentation/pages/home_page.dart';
import 'package:frontend_mayoral/features/senasa_report/data/repositories/senasa_report_repository_impl.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/generate_senasa_report_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/get_senasa_establishments_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/pages/senasa_menu_page.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/pages/senasa_report_error_page.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/pages/senasa_report_generation_page.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/pages/senasa_report_page.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/pages/senasa_report_success_page.dart';
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
        builder: (context, state) => const LoginPage(
          createCubit: createLoginCubit,
        ),
      ),

      /// Ruta de la pantalla de inicio.
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => HomePage(
          signOut: context.read<AuthSessionCubit>().signOut,
          verifyAuthentication: verifyAuthenticatedUser,
        ),
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
      GoRoute(
        path: AppRoutes.senasaMenu,
        builder: (context, state) => const SenasaMenuPage(),
      ),
      GoRoute(
        path: AppRoutes.senasaReport,
        builder: (context, state) {
          final repository = _createSenasaReportRepository();
          return SenasaReportPage(
            getEstablishments: GetSenasaEstablishmentsUseCase(repository),
            generateReport: GenerateSenasaReportUseCase(repository),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.senasaReportGeneration,
        builder: (context, state) {
          final request = state.extra! as SenasaReportRequest;
          return SenasaReportGenerationPage(
            request: request,
            generateReport: GenerateSenasaReportUseCase(
              _createSenasaReportRepository(),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.senasaReportSuccess,
        builder: (context, state) {
          final report = state.extra! as GeneratedSenasaReport;
          return SenasaReportSuccessPage(report: report);
        },
      ),
      GoRoute(
        path: AppRoutes.senasaReportError,
        builder: (context, state) {
          final args = state.extra! as SenasaReportErrorArgs;
          return SenasaReportErrorPage(args: args);
        },
      ),
    ],
  );
}

SenasaReportRepositoryImpl _createSenasaReportRepository() {
  return SenasaReportRepositoryImpl(
    baseUrl: AppConfig.current.backendBaseUrl,
    tokenProvider: SessionBackendAccessTokenProvider.instance,
  );
}
