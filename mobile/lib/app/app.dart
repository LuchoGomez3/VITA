import 'package:frontend_mayoral/app/config/config.dart';
import 'package:frontend_mayoral/app/router/app_router.dart';
import 'package:frontend_mayoral/app/theme/app_theme.dart';
import 'package:frontend_mayoral/features/auth/data/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FrontendMayoralApp extends StatefulWidget {
  const FrontendMayoralApp({required this.sessionManager, super.key});

  /// Sesión compartida; alimenta el guard de autenticación del router.
  final SessionManager sessionManager;

  @override
  State<FrontendMayoralApp> createState() => _FrontendMayoralAppState();
}

class _FrontendMayoralAppState extends State<FrontendMayoralApp> {
  // El router se construye una sola vez: escucha al SessionManager para
  // reevaluar el guard, así que no debe recrearse en cada rebuild.
  late final GoRouter _router = AppRouter.build(widget.sessionManager);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.current.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: _router,
    );
  }
}
