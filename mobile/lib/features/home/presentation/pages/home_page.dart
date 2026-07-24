import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';
import 'package:go_router/go_router.dart';

/// Callback que valida la sesion actual contra el backend.
typedef VerifyAuthentication = Future<Result<String>> Function();

/// Callback que cierra la sesion actual.
typedef SignOut = Future<void> Function();

/// Pagina de inicio de la app. (TODO:Agus: Esto no va, es solo un mock para la demo.)
class HomePage extends StatefulWidget {
  /// Crea una nueva pagina de inicio.
  const HomePage({
    required this.signOut,
    required this.verifyAuthentication,
    super.key,
  });

  /// Cierra la sesion actual.
  final SignOut signOut;

  /// Verifica si el token vigente corresponde a un usuario autenticado.
  final VerifyAuthentication verifyAuthentication;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isCheckingAuthentication = false;
  bool _isSigningOut = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(HomeStrings.appTitle),
        actions: [
          IconButton(
            tooltip: HomeStrings.signOutTooltip,
            onPressed: _isSigningOut ? null : _signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                HomeStrings.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                HomeStrings.subtitle,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      HomeStrings.authCheckTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      HomeStrings.authCheckDescription,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppFilledButton(
                      label: HomeStrings.authCheckButton,
                      loadingLabel: HomeStrings.authCheckingButton,
                      isLoading: _isCheckingAuthentication,
                      icon: const Icon(Icons.verified_user_outlined),
                      onPressed: _verifyAuthentication,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      HomeStrings.animalRegisterTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      HomeStrings.animalRegisterDescription,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppFilledButton(
                      label: HomeStrings.animalRegisterButton,
                      onPressed: () => context.push(
                        AppRoutes.animalRegisterStep1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      HomeStrings.animalDetailTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      HomeStrings.animalDetailDescription,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppFilledButton(
                      label: HomeStrings.animalDetailButton,
                      onPressed: () => context.go(
                        AppRoutes.animalDetailById('A-001'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      HomeStrings.senasaReportTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      HomeStrings.senasaReportDescription,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppFilledButton(
                      label: HomeStrings.senasaReportButton,
                      onPressed: () => context.push(
                        AppRoutes.senasaMenu,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyAuthentication() async {
    setState(() {
      _isCheckingAuthentication = true;
    });

    final result = await widget.verifyAuthentication();

    if (!mounted) {
      return;
    }

    setState(() {
      _isCheckingAuthentication = false;
    });

    final message = switch (result) {
      Success<String>(:final data) => '${HomeStrings.authCheckSuccessPrefix} $data',
      Failure<String>(:final error) => error.message,
      _ => HomeStrings.authCheckUnknownError,
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  Future<void> _signOut() async {
    setState(() {
      _isSigningOut = true;
    });

    await widget.signOut();

    if (!mounted) {
      return;
    }

    context.go(AppRoutes.login);
  }
}
