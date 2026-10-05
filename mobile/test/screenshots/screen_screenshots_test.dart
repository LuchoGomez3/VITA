import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/layout/main_layout_page.dart';
import 'package:frontend_mayoral/app/layout/shell_placeholder_page.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/app/theme/app_theme.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal_registration.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/pages/registrar_animal_success_page.dart';
import 'package:frontend_mayoral/features/auth/domain/entities/app_user.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/pages/sign_up_success_page.dart';
import 'package:frontend_mayoral/features/auth/presentation/sign_up/pages/sign_up_welcome_first_time.dart';
import 'package:frontend_mayoral/features/establishment_register/domain/entities/establishment_registration.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/pages/establishment_empty_state_page.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/pages/establishment_register_success_page.dart';
import 'package:frontend_mayoral/features/field/presentation/pages/field_detail_page.dart';
import 'package:frontend_mayoral/features/field/presentation/pages/field_list_page.dart';
import 'package:frontend_mayoral/features/field/presentation/pages/field_map_page.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/domain/repositories/home_dashboard_repository.dart';
import 'package:frontend_mayoral/features/home/domain/use_cases/get_home_dashboard_use_case.dart';
import 'package:frontend_mayoral/features/home/domain/use_cases/get_home_establishments_use_case.dart';
import 'package:frontend_mayoral/features/home/presentation/bloc/home_dashboard_cubit.dart';
import 'package:frontend_mayoral/features/home/presentation/pages/home_page.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';
import 'package:frontend_mayoral/features/livestock/presentation/pages/livestock_page.dart';
import 'package:frontend_mayoral/features/profile/domain/entities/establishment_details.dart';
import 'package:frontend_mayoral/features/profile/domain/repositories/profile_repository.dart';
import 'package:frontend_mayoral/features/profile/domain/use_cases/get_profile_establishments_use_case.dart';
import 'package:frontend_mayoral/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:frontend_mayoral/features/profile/presentation/pages/profile_page.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/repositories/senasa_report_repository.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/download_generated_senasa_report_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/get_generated_senasa_reports_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/use_cases/get_senasa_establishments_use_case.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/bloc/senasa_menu_cubit.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/pages/senasa_menu_page.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/pages/senasa_report_error_page.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/pages/senasa_report_success_page.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/widgets/report_step1_filters.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/widgets/report_step2_validation.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;

const _screenSize = Size(430, 932);
const _captureKey = ValueKey<String>('screen-capture');

void main() {
  setUpAll(_loadTestFonts);

  final scenarios = <_ScreenshotScenario>[
    const _ScreenshotScenario(
      name: '01_auth_welcome',
      child: WelcomePage(),
    ),
    const _ScreenshotScenario(
      name: '02_auth_sign_up_success',
      child: SignUpSuccessPage(userData: _sampleUser),
    ),
    const _ScreenshotScenario(
      name: '03_establishment_empty',
      child: EstablishmentEmptyStatePage(onSignOut: _completeImmediately),
    ),
    _ScreenshotScenario(
      name: '04_establishment_register_success',
      child: EstablishmentRegisterSuccessPage(
        registeredEstablishment: _sampleEstablishment,
      ),
    ),
    _ScreenshotScenario(
      name: '05_animal_register_success',
      child: RegistrarAnimalSuccessPage(registeredAnimal: _sampleAnimal),
    ),
    const _ScreenshotScenario(
      name: '06_livestock',
      child: LivestockPage(),
      mainSectionPath: AppRoutes.livestock,
    ),
    const _ScreenshotScenario(
      name: '07_field_map',
      child: FieldMapPage(),
    ),
    const _ScreenshotScenario(
      name: '08_field_list',
      child: FieldListPage(),
    ),
    const _ScreenshotScenario(
      name: '09_field_detail',
      child: FieldDetailPage(potreroId: 'la-loma'),
    ),
    _ScreenshotScenario(
      name: '10_senasa_report_success',
      child: SenasaReportSuccessPage(report: _sampleReport),
    ),
    _ScreenshotScenario(
      name: '11_senasa_report_error',
      child: SenasaReportErrorPage(
        args: SenasaReportErrorArgs(
          message: 'No se pudo generar el archivo solicitado.',
          request: _sampleReportRequest,
        ),
      ),
    ),
    const _ScreenshotScenario(
      name: '12_expense_records_coming_soon',
      child: ShellPlaceholderPage(
        title: 'Registros de gastos',
        message: 'Próximamente',
      ),
    ),
    const _ScreenshotScenario(
      name: '13_income_register_placeholder',
      child: ShellPlaceholderPage(title: 'Registrar ingreso'),
    ),
    const _ScreenshotScenario(
      name: '14_rfid_missing_establishment',
      child: ShellPlaceholderPage(
        title: 'Seleccioná un establecimiento para identificar animales',
      ),
    ),
    _ScreenshotScenario(
      name: '15_home_loading',
      child: _homePage(const _LoadingHomeRepository()),
      settleBeforeCapture: false,
      mainSectionPath: AppRoutes.home,
    ),
    _ScreenshotScenario(
      name: '16_home_dashboard_with_data',
      child: _homePage(
        const _SuccessfulHomeRepository(dashboard: _sampleHomeDashboard),
      ),
      mainSectionPath: AppRoutes.home,
    ),
    _ScreenshotScenario(
      name: '17_home_dashboard_empty',
      child: _homePage(
        const _SuccessfulHomeRepository(dashboard: _emptyHomeDashboard),
      ),
      mainSectionPath: AppRoutes.home,
    ),
    _ScreenshotScenario(
      name: '18_home_error',
      child: _homePage(const _ErrorHomeRepository()),
      mainSectionPath: AppRoutes.home,
    ),
    _ScreenshotScenario(
      name: '19_home_establishment_selector',
      child: _homePage(
        const _SuccessfulHomeRepository(dashboard: _sampleHomeDashboard),
      ),
      prepare: _expandHomeEstablishmentSelector,
      mainSectionPath: AppRoutes.home,
    ),
    _ScreenshotScenario(
      name: '20_home_dashboard_metrics',
      child: _homePage(
        const _SuccessfulHomeRepository(dashboard: _sampleHomeDashboard),
      ),
      prepare: _scrollHomeToMetrics,
      mainSectionPath: AppRoutes.home,
    ),
    _ScreenshotScenario(
      name: '25_home_dashboard_bottom',
      child: _homePage(
        const _SuccessfulHomeRepository(dashboard: _sampleHomeDashboard),
      ),
      prepare: _scrollHomeToBottom,
      mainSectionPath: AppRoutes.home,
    ),
    const _ScreenshotScenario(
      name: '21_procedures_senasa_history',
      child: SenasaMenuPage(createCubit: _createSenasaMenuCubit),
      mainSectionPath: AppRoutes.procedures,
    ),
    _ScreenshotScenario(
      name: '22_profile',
      child: ProfilePage(
        userId: _sampleUser.id,
        email: _sampleUser.email,
        firstName: _sampleUser.firstName,
        lastName: _sampleUser.lastName,
        cuit: _sampleUser.cuit,
        role: 'Productor',
        createCubit: _createProfileCubit,
        signOut: _completeImmediately,
      ),
      mainSectionPath: AppRoutes.profile,
    ),
    const _ScreenshotScenario(
      name: '23_senasa_documentation_step_1',
      child: _SenasaDocumentationStepOne(),
    ),
    const _ScreenshotScenario(
      name: '24_senasa_documentation_step_2',
      child: _SenasaDocumentationStepTwo(),
    ),
  ];

  group('capturas de pantallas', () {
    for (final scenario in scenarios) {
      testWidgets(scenario.name, (tester) async {
        await _configurePhoneSurface(tester);
        final router = scenario.mainSectionPath == null
            ? _routerFor(scenario.child)
            : _mainShellRouterFor(
                initialLocation: scenario.mainSectionPath!,
                selectedChild: scenario.child,
              );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            routerConfig: router,
          ),
        );
        if (scenario.settleBeforeCapture) {
          await tester.pumpAndSettle();
        } else {
          await tester.pump();
        }
        await scenario.prepare?.call(tester);

        await expectLater(
          find.byKey(_captureKey),
          matchesGoldenFile('goldens/${scenario.name}.png'),
        );
      });
    }
  });
}

/// Carga las fuentes del SDK para reemplazar Ahem por glifos legibles.
Future<void> _loadTestFonts() async {
  final fontsDirectory = _flutterMaterialFontsDirectory();
  await Future.wait([
    _loadFontFamily(
      family: 'sans-serif',
      file: File(path.join(fontsDirectory.path, 'Roboto-Regular.ttf')),
    ),
    _loadFontFamily(
      family: 'MaterialIcons',
      file: File(
        path.join(fontsDirectory.path, 'MaterialIcons-Regular.otf'),
      ),
    ),
  ]);
}

/// Ubica las fuentes distribuidas con el mismo Flutter que ejecuta el test.
Directory _flutterMaterialFontsDirectory() {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null) {
    return Directory(
      path.join(flutterRoot, 'bin', 'cache', 'artifacts', 'material_fonts'),
    );
  }

  final dartExecutable = File(Platform.resolvedExecutable).resolveSymbolicLinksSync();
  return Directory(
    path.normalize(
      path.join(
        path.dirname(dartExecutable),
        '..',
        '..',
        'artifacts',
        'material_fonts',
      ),
    ),
  );
}

/// Registra una fuente local con el nombre utilizado por los widgets.
Future<void> _loadFontFamily({
  required String family,
  required File file,
}) async {
  final bytes = await file.readAsBytes();
  final loader = FontLoader(family)..addFont(Future.value(ByteData.sublistView(bytes)));
  await loader.load();
}

/// Define una pantalla y el nombre estable con el que se guarda su captura.
class _ScreenshotScenario {
  const _ScreenshotScenario({
    required this.name,
    required this.child,
    this.prepare,
    this.settleBeforeCapture = true,
    this.mainSectionPath,
  });

  final String name;
  final Widget child;
  final Future<void> Function(WidgetTester tester)? prepare;
  final bool settleBeforeCapture;
  final String? mainSectionPath;
}

/// Renderiza el primer paso documentado con fechas y origen estables.
class _SenasaDocumentationStepOne extends StatefulWidget {
  const _SenasaDocumentationStepOne();

  @override
  State<_SenasaDocumentationStepOne> createState() => _SenasaDocumentationStepOneState();
}

class _SenasaDocumentationStepOneState extends State<_SenasaDocumentationStepOne> {
  final _formKey = GlobalKey<FormState>();
  final _fileNameController = TextEditingController(
    text: 'declaracion_senasa_agosto_2026',
  );
  String? _selectedOrigin = 'establishment-screenshot';

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarHeader(
        title: SenasaStrings.pageTitle,
        onBackPressed: () {},
      ),
      body: SafeArea(
        child: Column(
          children: [
            const StepProgressBar(
              currentStep: 1,
              totalSteps: 2,
              stepTitle: SenasaStrings.step1Title,
            ),
            Expanded(
              child: ReportStep1Filters(
                formKey: _formKey,
                establishments: const [
                  SenasaEstablishment(
                    id: 'establishment-screenshot',
                    name: 'Estancia La Esperanza',
                    renspa: '01.001.0.00001/00',
                  ),
                ],
                startDate: DateTime(2026, 8),
                endDate: DateTime(2026, 8, 25),
                onDatesChanged: (_, _) {},
                selectedOrigin: _selectedOrigin,
                onOriginChanged: (value) {
                  setState(() => _selectedOrigin = value);
                },
                fileNameController: _fileNameController,
              ),
            ),
            const _SenasaDocumentationButton(
              label: SenasaStrings.btnContinue,
              icon: Icons.arrow_forward,
            ),
          ],
        ),
      ),
    );
  }
}

/// Renderiza el paso de validación exitoso previo a generar el documento.
class _SenasaDocumentationStepTwo extends StatelessWidget {
  const _SenasaDocumentationStepTwo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarHeader(
        title: SenasaStrings.pageTitle,
        onBackPressed: () {},
      ),
      body: SafeArea(
        child: Column(
          children: [
            const StepProgressBar(
              currentStep: 2,
              totalSteps: 2,
              stepTitle: SenasaStrings.step2Title,
            ),
            Expanded(
              child: ReportStep2Validation(
                startDate: _senasaStartDate,
                endDate: _senasaEndDate,
                validation: const ResultState.data(
                  SenasaValidationResult(exportableAnimals: 148),
                ),
                onRetry: _doNothing,
              ),
            ),
            const _SenasaDocumentationButton(
              label: SenasaStrings.btnGenerate,
              icon: Icons.download,
            ),
          ],
        ),
      ),
    );
  }
}

/// Replica el pie de acción que permanece visible durante ambos pasos.
class _SenasaDocumentationButton extends StatelessWidget {
  const _SenasaDocumentationButton({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AppFilledButton(
        label: label,
        icon: Icon(icon),
        onPressed: _doNothing,
      ),
    );
  }
}

void _doNothing() {}

final _senasaStartDate = DateTime(2026, 8);
final _senasaEndDate = DateTime(2026, 8, 25);

/// Construye Inicio con casos de uso respaldados por un repositorio de prueba.
Widget _homePage(HomeDashboardRepository repository) {
  return HomePage(
    userName: 'Ana',
    now: _fixedHomeTime,
    createCubit: () => HomeDashboardCubit(
      getHomeDashboardUseCase: GetHomeDashboardUseCase(repository),
      getHomeEstablishmentsUseCase: GetHomeEstablishmentsUseCase(repository),
    ),
  );
}

DateTime _fixedHomeTime() => DateTime(2026, 8, 25, 15);

/// Despliega el selector después de que el tablero terminó de cargar.
Future<void> _expandHomeEstablishmentSelector(WidgetTester tester) async {
  await tester.tap(find.textContaining(HomeStrings.allEstablishments));
  await tester.pumpAndSettle();
}

/// Desplaza Inicio para registrar las métricas que quedan debajo del pliegue.
Future<void> _scrollHomeToMetrics(WidgetTester tester) async {
  await tester.drag(find.byType(ListView), const Offset(0, -700));
  await tester.pumpAndSettle();
}

/// Lleva el tablero hasta su última sección para completar la documentación.
Future<void> _scrollHomeToBottom(WidgetTester tester) async {
  await tester.dragUntilVisible(
    find.text(HomeStrings.categoryDistribution),
    find.byType(ListView),
    const Offset(0, -300),
  );
  await tester.pumpAndSettle();
}

/// Fija el viewport para que los PNG no dependan del equipo que ejecuta el test.
Future<void> _configurePhoneSurface(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = _screenSize;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

/// Provee GoRouter porque varias pantallas resuelven sus botones por ruta.
GoRouter _routerFor(Widget child) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => RepaintBoundary(
          key: _captureKey,
          child: child,
        ),
      ),
    ],
  );
}

/// Monta una sección dentro del mismo shell y navbar usados por la aplicación.
GoRouter _mainShellRouterFor({
  required String initialLocation,
  required Widget selectedChild,
}) {
  Widget childFor(String path) {
    if (path == initialLocation) {
      return selectedChild;
    }
    return const SizedBox.shrink();
  }

  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => RepaintBoundary(
          key: _captureKey,
          child: MainLayoutPage(navigationShell: navigationShell),
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => childFor(AppRoutes.home),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.livestock,
                builder: (context, state) => childFor(AppRoutes.livestock),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.procedures,
                builder: (context, state) => childFor(AppRoutes.procedures),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => childFor(AppRoutes.profile),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

Future<void> _completeImmediately() async {}

const _sampleUser = AppUser(
  id: 'user-screenshot',
  email: 'ana.perez@example.com',
  firstName: 'Ana',
  lastName: 'Pérez',
  cuit: '20123456786',
);

final _sampleEstablishment = RegisteredEstablishment(
  id: 'establishment-screenshot',
  registration: const EstablishmentRegistration(
    nombre: 'Estancia La Esperanza',
    descripcion: 'Establecimiento ganadero de cría',
    tiposProduccion: ['Cría', 'Recría'],
    cuitTitular: '20-12345678-6',
    nroRenspa: '01.001.0.00001/00',
    provincia: 'Córdoba',
    departamento: 'Río Cuarto',
    localidad: 'Sampacho',
    latitud: -33.3833,
    longitud: -64.7167,
    superficieHectareas: 850,
    cantidadVertices: 6,
  ),
  createdAt: DateTime.utc(2026, 8, 25),
);

final _sampleAnimal = RegisteredAnimal(
  id: 'animal-screenshot',
  registration: AnimalRegistration(
    rfidTagNumber: '032981000123456',
    visualTag: 'AR-1042',
    sex: AnimalSex.female,
    breed: 'Aberdeen Angus',
    birthDate: DateTime.utc(2025, 9, 10),
    lotId: 'lot-screenshot',
    lotName: 'La Loma',
    establishmentId: 'establishment-screenshot',
    categoryId: 'category-screenshot',
    categoryName: 'Vaquillona',
    initialWeight: 286,
  ),
  syncStatus: AnimalSyncStatus.pending,
  createdAt: DateTime.utc(2026, 8, 25),
  updatedAt: DateTime.utc(2026, 8, 25),
  displayDestination: 'La Loma',
  displayCategory: 'Vaquillona',
);

final _sampleReportRequest = SenasaReportRequest(
  establishmentId: 'establishment-screenshot',
  from: DateTime.utc(2026, 8),
  to: DateTime.utc(2026, 8, 25),
  fileName: 'declaracion_senasa_2026_08.txt',
  animalCount: 148,
);

final _sampleReport = GeneratedSenasaReport(
  bytes: Uint8List.fromList([86, 73, 84, 65]),
  filename: 'declaracion_senasa_2026_08.txt',
  mediaType: 'text/plain',
  generatedAt: DateTime.utc(2026, 8, 25, 12),
  animalCount: 148,
);

const _sampleHomeDashboard = HomeDashboard(
  activeAnimals: 148,
  monthlyAdditions: 12,
  monthlyRemovals: 4,
  knownLiveWeightKg: 52180,
  animalsWithCurrentWeight: 132,
  animalsWithDailyGain: 96,
  averageDailyGainKg: 0.82,
  estimatedStockCents: 845000000,
  operatingExpensesCents: 123000000,
  categories: [
    CategoryInventoryMetric(name: 'Vacas', animals: 74, percentage: 50),
    CategoryInventoryMetric(name: 'Vaquillonas', animals: 38, percentage: 25.7),
    CategoryInventoryMetric(name: 'Terneros', animals: 36, percentage: 24.3),
  ],
  lots: [
    LotWeightMetric(
      name: 'La Loma',
      animals: 62,
      animalsWithWeight: 58,
      averageWeightKg: 386,
      weightStandardDeviationKg: 34,
    ),
    LotWeightMetric(
      name: 'Potrero Norte',
      animals: 48,
      animalsWithWeight: 44,
      averageWeightKg: 312,
      weightStandardDeviationKg: 28,
    ),
  ],
);

const _emptyHomeDashboard = HomeDashboard(
  activeAnimals: 0,
  monthlyAdditions: 0,
  monthlyRemovals: 0,
  knownLiveWeightKg: 0,
  animalsWithCurrentWeight: 0,
  animalsWithDailyGain: 0,
  categories: [],
  lots: [],
);

/// Repositorio determinista que entrega el contenido visible del tablero.
class _SuccessfulHomeRepository implements HomeDashboardRepository {
  const _SuccessfulHomeRepository({required this.dashboard});

  final HomeDashboard dashboard;

  @override
  Future<Result<HomeDashboard>> getDashboard({
    Set<String>? establishmentIds,
  }) async => Result.success(dashboard);

  @override
  Future<Result<Map<String, String>>> getEstablishments() async {
    return const Result.success({
      'establishment-screenshot': 'Estancia La Esperanza',
      'establishment-north': 'Campo Norte',
    });
  }
}

/// Mantiene la primera consulta pendiente para capturar el indicador de carga.
class _LoadingHomeRepository implements HomeDashboardRepository {
  const _LoadingHomeRepository();

  @override
  Future<Result<HomeDashboard>> getDashboard({
    Set<String>? establishmentIds,
  }) => Completer<Result<HomeDashboard>>().future;

  @override
  Future<Result<Map<String, String>>> getEstablishments() {
    return Completer<Result<Map<String, String>>>().future;
  }
}

/// Simula una falla legible sin depender de almacenamiento ni red.
class _ErrorHomeRepository implements HomeDashboardRepository {
  const _ErrorHomeRepository();

  @override
  Future<Result<HomeDashboard>> getDashboard({
    Set<String>? establishmentIds,
  }) async {
    return const Result.failure(
      DomainException(message: 'No se pudo cargar el resumen del establecimiento.'),
    );
  }

  @override
  Future<Result<Map<String, String>>> getEstablishments() async {
    return const Result.success({
      'establishment-screenshot': 'Estancia La Esperanza',
    });
  }
}

/// Crea el estado de Perfil con establecimientos de ejemplo legibles.
ProfileCubit _createProfileCubit() {
  return ProfileCubit(
    const GetProfileEstablishmentsUseCase(_ScreenshotProfileRepository()),
  );
}

/// Entrega el contenido offline que Perfil necesita para la captura.
class _ScreenshotProfileRepository implements ProfileRepository {
  const _ScreenshotProfileRepository();

  @override
  Future<Result<List<EstablishmentDetails>>> getEstablishments() async {
    return Result.success([
      (
        id: 'establishment-screenshot',
        ownerId: _sampleUser.id,
        name: 'Estancia La Esperanza',
        renspaNumber: '01.001.0.00001/00',
        cuit: '20-12345678-6',
        areaHectares: 850,
        province: 'Córdoba',
        department: 'Río Cuarto',
        locality: 'Sampacho',
        createdAt: DateTime.utc(2026, 1, 10),
        updatedAt: DateTime.utc(2026, 8, 25),
      ),
    ]);
  }
}

/// Crea el historial SENASA mostrado dentro de la pestaña Trámites.
SenasaMenuCubit _createSenasaMenuCubit() {
  const repository = _ScreenshotSenasaRepository();
  return SenasaMenuCubit(
    getEstablishments: const GetSenasaEstablishmentsUseCase(repository),
    getGeneratedReports: const GetGeneratedSenasaReportsUseCase(repository),
    downloadGeneratedReport: const DownloadGeneratedSenasaReportUseCase(
      repository,
    ),
  );
}

/// Simula las respuestas de documentación SENASA usadas por las capturas.
class _ScreenshotSenasaRepository implements SenasaReportRepository {
  const _ScreenshotSenasaRepository();

  @override
  Future<List<SenasaEstablishment>> getEstablishments() async {
    return const [
      SenasaEstablishment(
        id: 'establishment-screenshot',
        name: 'Estancia La Esperanza',
        renspa: '01.001.0.00001/00',
      ),
    ];
  }

  @override
  Future<List<SenasaExportHistoryItem>> getGeneratedReports(
    String establishmentId,
  ) async {
    return [
      SenasaExportHistoryItem(
        id: 'report-august',
        establishmentId: establishmentId,
        filename: 'declaracion_senasa_agosto_2026.txt',
        mediaType: 'text/plain',
        animalCount: 148,
        generatedAt: DateTime.utc(2026, 8, 25),
      ),
      SenasaExportHistoryItem(
        id: 'report-july',
        establishmentId: establishmentId,
        filename: 'declaracion_senasa_julio_2026.txt',
        mediaType: 'text/plain',
        animalCount: 141,
        generatedAt: DateTime.utc(2026, 7, 25),
      ),
    ];
  }

  @override
  Future<GeneratedSenasaReport> downloadGeneratedReport(String exportId) async {
    return _sampleReport;
  }

  @override
  Future<GeneratedSenasaReport> generateReport(
    SenasaReportRequest request,
  ) async {
    return _sampleReport;
  }

  @override
  Future<SenasaValidationResult> validateRecords(
    SenasaReportValidationRequest request,
  ) async {
    return const SenasaValidationResult(exportableAnimals: 148);
  }
}
