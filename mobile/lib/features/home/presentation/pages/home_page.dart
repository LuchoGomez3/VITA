import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/presentation/bloc/home_dashboard_cubit.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_asset_icon.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_dashboard_content.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_dashboard_error.dart';

/// Factory que crea el cubit responsable de los indicadores de Inicio.
typedef HomeDashboardCubitFactory = HomeDashboardCubit Function();

/// Pantalla principal con el resumen productivo del establecimiento.
class HomePage extends StatelessWidget {
  /// Crea Inicio e inyecta el estado de sus KPIs.
  const HomePage({
    required this.createCubit,
    required this.userName,
    super.key,
  });

  /// Construye una instancia de cubit cuyo ciclo de vida pertenece a la pagina.
  final HomeDashboardCubitFactory createCubit;

  /// Nombre visible de la persona autenticada.
  final String userName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeDashboardCubit>(
      create: (_) => createCubit()..load(),
      child: _HomeDashboardView(
        userName: userName.trim().isEmpty ? HomeStrings.defaultUserName : userName.trim(),
      ),
    );
  }
}

class _HomeDashboardView extends StatelessWidget {
  const _HomeDashboardView({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: HomeStrings.appTitle,
        headline: _greeting(DateTime.now(), userName),
        actions: [
          IconButton(
            tooltip: HomeStrings.refreshTooltip,
            onPressed: context.read<HomeDashboardCubit>().load,
            icon: const HomeAssetIcon(assetPath: 'assets/icons/cached.svg'),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<HomeDashboardCubit, ResultState<HomeDashboard>>(
          builder: (context, state) => switch (state) {
            Data<HomeDashboard>(:final data) => HomeDashboardContent(dashboard: data),
            ResultError<HomeDashboard>(:final error) => HomeDashboardError(message: error.message),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }

  String _greeting(DateTime dateTime, String name) {
    // Las franjas evitan saludos de madrugada como "Buenos dias" y mantienen
    // una regla determinista: mañana 05-11, tarde 12-19 y noche 20-04.
    final greeting = switch (dateTime.hour) {
      >= 5 && < 12 => HomeStrings.goodMorning,
      >= 12 && < 20 => HomeStrings.goodAfternoon,
      _ => HomeStrings.goodEvening,
    };
    return '$greeting, $name';
  }
}
