import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/config/app_config.dart';
import 'package:frontend_mayoral/app/app.dart';
import 'package:frontend_mayoral/brick/brick_bootstrap.dart';
import 'package:frontend_mayoral/demo/demo_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BrickBootstrap.initialize();
  if (AppConfig.demoMode) {
    await DemoBootstrap.initialize(reset: AppConfig.resetDemoData);
  }
  runApp(const FrontendMayoralApp());
}
