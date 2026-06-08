import 'package:frontend_mayoral/app/config/config.dart';
import 'package:frontend_mayoral/app/router/app_router.dart';
import 'package:frontend_mayoral/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FrontendMayoralApp extends StatelessWidget {
  const FrontendMayoralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.current.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: AppRouter.router,
    );
  }
}
