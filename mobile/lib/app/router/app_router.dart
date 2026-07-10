import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:frontend_mayoral/features/home/presentation/pages/home_page.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/models/sign_up_user_data.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/pages/sign_up_creating_account_page.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/pages/sign_up_page.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/pages/sign_up_success_page.dart';
import 'package:frontend_mayoral/features/sign_up/presentation/pages/sign_up_welcome_first_time.dart';
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
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: AppRoutes.signUpForm,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: AppRoutes.signUpCreatingAccount,
        builder: (context, state) => SignUpCreatingAccountPage(
          userData: state.extra! as SignUpUserData,
        ),
      ),
      GoRoute(
        path: AppRoutes.signUpSuccess,
        builder: (context, state) => SignUpSuccessPage(
          userData: state.extra! as SignUpUserData,
        ),
      ),

      /// Ruta de la pantalla de inicio.
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => FadePage(
          state: state,
          child: HomePage(
            signOut: context.read<AuthSessionCubit>().signOut,
            verifyAuthentication: verifyAuthenticatedUser,
          ),
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
    ],
  );
}
