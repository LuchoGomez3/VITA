import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/home/domain/entities/home_dashboard.dart';
import 'package:frontend_mayoral/features/home/presentation/bloc/home_dashboard_cubit.dart';
import 'package:frontend_mayoral/features/home/presentation/strings/home_strings.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_dashboard_content.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_dashboard_error.dart';
import 'package:frontend_mayoral/features/home/presentation/widgets/home_expandable_header.dart';

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
      child: _HomeDashboardView(
        userName: userName.trim().isEmpty
            ? HomeStrings.defaultUserName
            : userName.trim(),
      ),
    );
  }
}

class _HomeDashboardView extends StatefulWidget {
  const _HomeDashboardView({required this.userName});

  final String userName;

  @override
  State<_HomeDashboardView> createState() => _HomeDashboardViewState();
}

class _HomeDashboardViewState extends State<_HomeDashboardView> {
  bool _isSelectorExpanded = false;
  String? _highlightedEstablishmentId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          HomeExpandableHeader(
            greeting: _greeting(DateTime.now(), widget.userName),
            isExpanded: _isSelectorExpanded,
            highlightedEstablishmentId: _highlightedEstablishmentId,
            onToggle: _toggleSelector,
            onSelected: _selectEstablishment,
          ),
          const Expanded(child: _HomeDashboardBody()),
        ],
      ),
    );
  }

  void _toggleSelector() {
    setState(() {
      _isSelectorExpanded = !_isSelectorExpanded;
      if (_isSelectorExpanded) {
        _highlightedEstablishmentId = context
            .read<HomeDashboardCubit>()
            .selectedEstablishmentId;
      }
    });
  }

  void _selectEstablishment(String? establishmentId) {
    setState(() {
      _highlightedEstablishmentId = establishmentId;
      _isSelectorExpanded = false;
    });
    unawaited(
      context
          .read<HomeDashboardCubit>()
          .selectEstablishment(establishmentId),
    );
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
  const _HomeDashboardBody();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: BlocBuilder<HomeDashboardCubit, ResultState<HomeDashboard>>(
        builder: (context, state) => switch (state) {
          Data<HomeDashboard>(:final data) =>
            HomeDashboardContent(dashboard: data),
          ResultError<HomeDashboard>(:final error) =>
            HomeDashboardError(message: error.message),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}
