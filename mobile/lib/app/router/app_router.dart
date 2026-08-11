import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/layout/main_layout_page.dart';
import 'package:frontend_mayoral/app/layout/main_layout_strings.dart';
import 'package:frontend_mayoral/app/layout/shell_placeholder_page.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/navigation/backward_page.dart';
import 'package:frontend_mayoral/core/navigation/fade_page.dart';
import 'package:frontend_mayoral/features/animal_detail/animal_detail_composition.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/pages/animal_detail_page.dart';
import 'package:frontend_mayoral/features/animal_register/animal_register_composition.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/bloc/register_animal_bloc.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/pages/register_animal_page.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/pages/registrar_animal_success_page.dart';
import 'package:frontend_mayoral/features/auth/auth_composition.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/presentation/login/pages/login_page.dart';
import 'package:frontend_mayoral/features/auth/presentation/pages/auth_check_page.dart';
import 'package:frontend_mayoral/features/auth/presentation/session/cubit/auth_session_cubit.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/pages/sign_up_page.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/pages/sign_up_success_page.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/pages/sign_up_welcome_first_time.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';
import 'package:frontend_mayoral/features/establishment_register/establishment_register_composition.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/bloc/register_establishment_bloc.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/pages/establishment_empty_state_page.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/pages/establishment_register_page.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/pages/establishment_register_success_page.dart';
import 'package:frontend_mayoral/features/home/home_composition.dart';
import 'package:frontend_mayoral/features/home/presentation/pages/home_page.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';
import 'package:frontend_mayoral/features/livestock/presentation/pages/livestock_page.dart';
import 'package:frontend_mayoral/features/profile/presentation/pages/profile_page.dart';
import 'package:frontend_mayoral/features/profile/presentation/strings/profile_strings.dart';
import 'package:frontend_mayoral/features/profile/profile_composition.dart';
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
            createBloc: createLoginBloc,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: AppRoutes.signUpForm,
        builder: (context, state) => const SignUpPage(
          createBloc: createSignUpBloc,
        ),
      ),
      GoRoute(
        path: AppRoutes.signUpSuccess,
        builder: (context, state) => SignUpSuccessPage(
          userData: state.extra! as AppUser,
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
                      userId: session.user.id,
                      email: session.user.email,
                      firstName: session.user.firstName,
                      lastName: session.user.lastName,
                      cuit: session.user.cuit,
                      role: session.user.role.name,
                      createCubit: createProfileCubit,
                      signOut: context.read<AuthSessionCubit>().signOut,
                    ),
                    _ => ProfilePage(
                      userId: ProfileStrings.emptyCredential,
                      email: ProfileStrings.emptyCredential,
                      firstName: ProfileStrings.emptyCredential,
                      lastName: ProfileStrings.emptyCredential,
                      cuit: null,
                      role: 'unknown',
                      createCubit: createProfileCubit,
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
            createCubit: createAnimalDetailCubit,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.establishmentRegisterEmpty,
        builder: (context, state) => EstablishmentEmptyStatePage(
          onSignOut: context.read<AuthSessionCubit>().signOut,
        ),
      ),
      GoRoute(
        path: AppRoutes.establishmentRegisterStep1,
        builder: (context, state) => const EstablishmentRegisterPage(
          createBloc: createRegisterEstablishmentBloc,
        ),
      ),
      GoRoute(
        path: AppRoutes.establishmentRegisterStep2,
        // Sin persistencia de borrador entre rutas, entrar directo acá
        // siempre da un BLoC con estado inicial vacío: se redirige al paso 1
        // hasta que exista hidratación real de deep-link.
        redirect: (context, state) => AppRoutes.establishmentRegisterStep1,
        builder: (context, state) => const EstablishmentRegisterPage(
          createBloc: createRegisterEstablishmentBloc,
          initialStep: RegisterEstablishmentStep.renspa,
        ),
      ),
      GoRoute(
        path: AppRoutes.establishmentRegisterStep3,
        redirect: (context, state) => AppRoutes.establishmentRegisterStep1,
        builder: (context, state) => const EstablishmentRegisterPage(
          createBloc: createRegisterEstablishmentBloc,
          initialStep: RegisterEstablishmentStep.location,
        ),
      ),
      GoRoute(
        path: AppRoutes.establishmentRegisterStep4,
        redirect: (context, state) => AppRoutes.establishmentRegisterStep1,
        builder: (context, state) => const EstablishmentRegisterPage(
          createBloc: createRegisterEstablishmentBloc,
          initialStep: RegisterEstablishmentStep.surface,
        ),
      ),
      GoRoute(
        path: AppRoutes.establishmentRegisterReview,
        redirect: (context, state) => AppRoutes.establishmentRegisterStep1,
        builder: (context, state) => const EstablishmentRegisterPage(
          createBloc: createRegisterEstablishmentBloc,
          initialStep: RegisterEstablishmentStep.review,
        ),
      ),
      GoRoute(
        path: AppRoutes.establishmentRegisterSuccess,
        builder: (context, state) {
          final registeredEstablishment = state.extra! as RegisteredEstablishment;
          return EstablishmentRegisterSuccessPage(
            registeredEstablishment: registeredEstablishment,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.expenseRecords,
        builder: (context, state) => const ShellPlaceholderPage(
          title: HomeStrings.movements,
        ),
      ),
      GoRoute(
        path: AppRoutes.expenseRegister,
        builder: (context, state) => const ShellPlaceholderPage(
          title: HomeStrings.registerExpense,
        ),
      ),
      GoRoute(
        path: AppRoutes.incomeRegister,
        builder: (context, state) => const ShellPlaceholderPage(
          title: HomeStrings.registerIncome,
        ),
      ),
    ],
  );
}
