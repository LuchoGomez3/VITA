import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/app.dart';
import 'package:frontend_mayoral/brick/brick_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BrickBootstrap.initialize();
  runApp(const FrontendMayoralApp());
}
