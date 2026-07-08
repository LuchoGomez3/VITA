import 'package:flutter/material.dart';
import 'package:frontend_mayoral/app/app.dart';
import 'package:frontend_mayoral/brick/brick_bootstrap.dart';
import 'package:frontend_mayoral/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:frontend_mayoral/features/auth/data/session_backend_access_token_provider.dart';
import 'package:frontend_mayoral/features/auth/data/session_manager.dart';
import 'package:frontend_mayoral/features/auth/data/storage/session_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sesión: fuente única compartida por el guard del router, el login y el sync.
  // Se rehidrata desde almacenamiento seguro para poder entrar offline.
  final sessionManager = SessionManager(
    storage: SessionStorage(),
    remote: AuthRemoteDataSource(),
  );
  await sessionManager.load();

  // Brick usa la sesión real para adjuntar y renovar el JWT al sincronizar.
  await BrickBootstrap.initialize(
    tokenProvider: SessionBackendAccessTokenProvider(sessionManager),
  );

  runApp(FrontendMayoralApp(sessionManager: sessionManager));
}
