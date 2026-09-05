import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/layout/main_layout_page.dart';
import 'package:frontend_mayoral/app/layout/shell_placeholder_page.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/authentication/get_establishment_role_use_case.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
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
import 'package:frontend_mayoral/features/field/presentation/pages/field_detail_page.dart';
import 'package:frontend_mayoral/features/field/presentation/pages/field_list_page.dart';
import 'package:frontend_mayoral/features/field/presentation/pages/field_map_page.dart';
import 'package:frontend_mayoral/features/home/home_composition.dart';
import 'package:frontend_mayoral/features/home/presentation/pages/home_page.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';
import 'package:frontend_mayoral/features/livestock/presentation/pages/livestock_page.dart';
import 'package:frontend_mayoral/features/operating_expenses/operating_expenses_composition.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/pages/financial_access_denied_page.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/pages/operating_expense_history_page.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/pages/operating_expenses_page.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/strings/operating_expense_strings.dart';
import 'package:frontend_mayoral/features/profile/presentation/pages/profile_page.dart';
import 'package:frontend_mayoral/features/profile/presentation/strings/profile_strings.dart';
import 'package:frontend_mayoral/features/profile/profile_composition.dart';
import 'package:frontend_mayoral/features/rfid_scan/data/datasources/hid_rfid_reading_source.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/pages/rfid_scan_page.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/strings/rfid_scan_strings.dart';
import 'package:frontend_mayoral/features/rfid_scan/rfid_scan_composition.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/pages/senasa_menu_page.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/pages/senasa_report_error_page.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/pages/senasa_report_generation_page.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/pages/senasa_report_page.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/pages/senasa_report_success_page.dart';
import 'package:frontend_mayoral/features/senasa_report/senasa_report_composition.dart';
import 'package:go_router/go_router.dart';

/// Configuracion central de rutas y proteccion de sesion de la aplicacion.
class AppRouter {
  const AppRouter._();

  /// Crea el router protegido por el estado global de autenticacion.
  static GoRouter create({
    required AuthSessionCubit authSessionCubit,
    required Listenable refreshListenable,
    required GetEstablishmentRoleUseCase getEstablishmentRole,
  }) {
    return GoRouter(
      initialLocation: AppRoutes.authCheck,
      refreshListenable: refreshListenable,
      redirect: (context, state) => redirectFor(
        authState: authSessionCubit.state,
        location: state.uri.path,
        hasSignUpSuccessData: state.extra is AppUser,
      ),
      routes: [
        GoRoute(
          path: AppRoutes.authCheck,
          builder: (context, state) => const AuthCheckPage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          pageBuilder: (context, state) => BackwardPage(
            state: state,
            child: const LoginPage(createBloc: createLoginBloc),
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
                  builder: (context, state) => SenasaMenuPage(
                    key: ValueKey(state.extra),
                    createCubit: createSenasaMenuCubit,
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
                        createCubit: createProfileCubit,
                        signOut: context.read<AuthSessionCubit>().signOut,
                      ),
                      _ => ProfilePage(
                        userId: ProfileStrings.emptyCredential,
                        email: ProfileStrings.emptyCredential,
                        firstName: ProfileStrings.emptyCredential,
                        lastName: ProfileStrings.emptyCredential,
                        cuit: null,
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
          builder: (context, state) => RegisterAnimalPage(
            createBloc: createRegisterAnimalBloc,
            initialRfid: state.uri.queryParameters['rfid'] ?? '',
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
            return RegistrarAnimalSuccessPage(registeredAnimal: registeredAnimal);
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
          path: AppRoutes.rfidScan,
          builder: (context, state) {
            final establishmentId = state.uri.queryParameters['establecimientoId'];
            if (establishmentId == null || establishmentId.trim().isEmpty) {
              return const ShellPlaceholderPage(
                title: RfidScanStrings.requiredEstablishment,
              );
            }

            final readingSource = HidRfidReadingSource();
            return RfidScanPage(
              establishmentId: establishmentId,
              createBloc: ({required establishmentId}) => createRfidScanBloc(
                readingSource: readingSource,
                establishmentId: establishmentId,
              ),
              onHidKeyEvent: readingSource.handleKeyEvent,
              onAnimalDetailRequested: (animalId) => context.push(AppRoutes.animalDetailById(animalId)),
              onRegisterAnimalRequested: (rfid) => context.push(AppRoutes.animalRegisterWithRfid(rfid)),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.field,
          builder: (context, state) => const FieldMapPage(),
        ),
        GoRoute(
          path: AppRoutes.fieldList,
          builder: (context, state) => const FieldListPage(),
        ),
        GoRoute(
          path: AppRoutes.fieldDetail,
          builder: (context, state) {
            final potreroId = state.pathParameters['potreroId']!;
            return FieldDetailPage(potreroId: potreroId);
          },
        ),
        GoRoute(
          path: AppRoutes.expenseRecords,
          builder: (context, state) => _operatingExpenseHistoryPage(
            context,
            state,
            getEstablishmentRole,
          ),
        ),
        GoRoute(
          path: AppRoutes.expenseRegister,
          builder: (context, state) => _operatingExpensesPage(
            context,
            state,
            getEstablishmentRole,
          ),
        ),
        GoRoute(
          path: AppRoutes.incomeRegister,
          builder: (context, state) => const ShellPlaceholderPage(
            title: HomeStrings.registerIncome,
          ),
        ),
        GoRoute(
          path: AppRoutes.senasaReport,
          builder: (context, state) => const SenasaReportPage(
            createCubit: createSenasaReportCubit,
          ),
        ),
        GoRoute(
          path: AppRoutes.senasaReportGeneration,
          builder: (context, state) {
            final request = state.extra! as SenasaReportRequest;
            return SenasaReportGenerationPage(
              request: request,
              createCubit: createSenasaReportGenerationCubit,
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

  static Widget _operatingExpensesPage(
    BuildContext context,
    GoRouterState state,
    GetEstablishmentRoleUseCase getEstablishmentRole,
  ) {
    final establishmentId = state.uri.queryParameters['establecimientoId'];
    final establishmentName = state.uri.queryParameters['establecimientoNombre'];
    final sessionState = context.read<AuthSessionCubit>().state;
    final missingEstablishment =
        establishmentId == null ||
        establishmentId.trim().isEmpty ||
        establishmentName == null ||
        establishmentName.trim().isEmpty;
    if (missingEstablishment || sessionState is! AuthSessionAuthenticated) {
      return const ShellPlaceholderPage(
        title: OperatingExpenseStrings.requiredEstablishment,
      );
    }

    final user = sessionState.session.user;
    return FinancialRouteGuard(
      establishmentId: establishmentId,
      getEstablishmentRole: getEstablishmentRole,
      child: OperatingExpensesPage(
        establishmentName: establishmentName,
        createCubit: () => createOperatingExpenseCubit(
          establishmentId: establishmentId,
          userId: user.id,
          userName: '${user.firstName} ${user.lastName}'.trim(),
        ),
      ),
    );
  }

  static Widget _operatingExpenseHistoryPage(
    BuildContext context,
    GoRouterState state,
    GetEstablishmentRoleUseCase getEstablishmentRole,
  ) {
    final establishmentId = state.uri.queryParameters['establecimientoId'];
    final establishmentName = state.uri.queryParameters['establecimientoNombre'];
    final sessionState = context.read<AuthSessionCubit>().state;
    if (sessionState is! AuthSessionAuthenticated ||
        establishmentId == null ||
        establishmentId.trim().isEmpty ||
        establishmentName == null ||
        establishmentName.trim().isEmpty) {
      return const ShellPlaceholderPage(title: OperatingExpenseStrings.requiredEstablishment);
    }
    return FinancialRouteGuard(
      establishmentId: establishmentId,
      getEstablishmentRole: getEstablishmentRole,
      child: OperatingExpenseHistoryPage(
        establishmentName: establishmentName,
        createCubit: () => createOperatingExpenseHistoryCubit(
          establishmentId: establishmentId,
        ),
      ),
    );
  }

  /// Evalua el rol del establecimiento solicitado, nunca un rol global.
  static Future<bool> canAccessFinancialRoute({
    required String establishmentId,
    required Future<UserRole> Function(String establishmentId) getRole,
  }) async {
    final role = await getRole(establishmentId);
    return role.canViewFinancialInformation;
  }

  /// Decide el destino permitido sin realizar navegacion por su cuenta.
  static String? redirectFor({
    required AuthSessionState authState,
    required String location,
    bool hasSignUpSuccessData = false,
  }) {
    if (authState is AuthSessionChecking) {
      return location == AppRoutes.authCheck ? null : AppRoutes.authCheck;
    }

    final isAuthenticated = authState is AuthSessionAuthenticated;
    final isPublicAuthRoute = _publicAuthRoutes.contains(location);
    final isValidSignUpSuccess = location == AppRoutes.signUpSuccess && hasSignUpSuccessData;

    if (!isAuthenticated) {
      if (location == AppRoutes.authCheck || (!isPublicAuthRoute && !isValidSignUpSuccess)) {
        return AppRoutes.signUp;
      }
      return null;
    }

    if (location == AppRoutes.authCheck || isPublicAuthRoute) {
      return AppRoutes.home;
    }
    if (location == AppRoutes.signUpSuccess && !hasSignUpSuccessData) {
      return AppRoutes.home;
    }
    return null;
  }

  static const Set<String> _publicAuthRoutes = {
    AppRoutes.signUp,
    AppRoutes.signUpForm,
    AppRoutes.login,
  };
}

/// Protege las rutas financieras con la membresia offline del establecimiento.
class FinancialRouteGuard extends StatelessWidget {
  /// Crea el guard que falla cerrado ante permisos ausentes o invalidos.
  const FinancialRouteGuard({
    required this.establishmentId,
    required this.getEstablishmentRole,
    required this.child,
    super.key,
  });

  /// UUID cuyo permiso financiero se evalua.
  final String establishmentId;

  /// Caso de uso inyectado por la composicion de la aplicacion.
  final GetEstablishmentRoleUseCase getEstablishmentRole;

  /// Contenido que se muestra exclusivamente a roles autorizados.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AppRouter.canAccessFinancialRoute(
        establishmentId: establishmentId,
        getRole: getEstablishmentRole.call,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return (snapshot.data ?? false) ? child : const FinancialAccessDeniedPage();
      },
    );
  }
}

/// Adapta el stream del Cubit al mecanismo reactivo requerido por GoRouter.
class AuthRouterRefreshNotifier extends ChangeNotifier {
  /// Escucha cambios de sesion y solicita reevaluar los guards.
  AuthRouterRefreshNotifier(AuthSessionCubit cubit) {
    _subscription = cubit.stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthSessionState> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
