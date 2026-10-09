import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/presentation/bloc/home_dashboard_cubit.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_dashboard_content.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_dashboard_error.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_header.dart';
import 'package:go_router/go_router.dart';

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

  /// Construye una instancia de cubit cuyo ciclo de vida pertenece a la página.
  final HomeDashboardCubitFactory createCubit;

  /// Nombre visible de la persona autenticada.
  final String userName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeDashboardCubit>(
      create: (_) => createCubit()..load(),
      child: _HomeDashboardView(userName: _displayUserName),
    );
  }

  String get _displayUserName {
    final trimmedUserName = userName.trim();
    return trimmedUserName.isEmpty ? HomeStrings.defaultUserName : trimmedUserName;
  }
}

class _HomeDashboardView extends StatefulWidget {
  const _HomeDashboardView({required this.userName});

  final String userName;

  @override
  State<_HomeDashboardView> createState() => _HomeDashboardViewState();
}

class _HomeDashboardViewState extends State<_HomeDashboardView> {
  final _establishmentMenu = MenuController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          HomeHeader(
            greeting: _greeting(DateTime.now(), widget.userName),
            establishmentMenuController: _establishmentMenu,
            onSelected: _selectEstablishment,
            onCreateEstablishment: _createEstablishment,
            onIdentifyAnimal: _identifyAnimal,
          ),
          Expanded(
            child: _HomeDashboardBody(
              onEstablishmentSelectionRequested: _openSelector,
            ),
          ),
        ],
      ),
    );
  }

  void _identifyAnimal() {
    final establishmentId = context.read<HomeDashboardCubit>().state.selectedEstablishmentId;
    if (establishmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(HomeStrings.selectEstablishmentBeforeIdentification)),
      );
      return;
    }

    context.push(AppRoutes.rfidScanForEstablishment(establishmentId));
  }

  void _openSelector() => _establishmentMenu.open();

  void _selectEstablishment(String? establishmentId) {
    unawaited(
      context.read<HomeDashboardCubit>().selectEstablishment(establishmentId),
    );
  }

  /// Abre el wizard de alta y, al volver, recarga Inicio para que el
  /// establecimiento recién creado aparezca en el selector.
  Future<void> _createEstablishment() async {
    await context.push<void>(AppRoutes.establishmentRegisterStep1);
    if (mounted) {
      await context.read<HomeDashboardCubit>().load();
    }
  }

  String _greeting(DateTime dateTime, String name) {
    // Las franjas mantienen una regla determinista: mañana 05-11,
    // tarde 12-19 y noche 20-04.
    final greeting = switch (dateTime.hour) {
      >= 5 && < 12 => HomeStrings.goodMorning,
      >= 12 && < 20 => HomeStrings.goodAfternoon,
      _ => HomeStrings.goodEvening,
    };
    return '$greeting, $name';
  }
}

class _HomeDashboardBody extends StatelessWidget {
  const _HomeDashboardBody({
    required this.onEstablishmentSelectionRequested,
  });

  final VoidCallback onEstablishmentSelectionRequested;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: BlocBuilder<HomeDashboardCubit, HomeDashboardState>(
        builder: (context, state) {
          final dashboardState = state.dashboardState;
          final membership = state.establishments[state.selectedEstablishmentId];
          return switch (dashboardState) {
            Data<HomeDashboard>(:final data) => HomeDashboardContent(
              dashboard: data,
              onEstablishmentSelectionRequested: onEstablishmentSelectionRequested,
              canViewFinancialInformation: membership?.role.canViewFinancialInformation ?? false,
            ),
            ResultError<HomeDashboard>(:final error) => HomeDashboardError(message: error.message),
            _ => const Center(child: CircularProgressIndicator()),
          };
        },
      ),
    );
  }
}
