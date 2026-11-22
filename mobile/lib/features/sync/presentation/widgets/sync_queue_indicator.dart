import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/sync/presentation/cubit/sync_queue_cubit.dart';
import 'package:frontend_mayoral/features/sync/presentation/strings/sync_status_strings.dart';

/// Ícono de nube con la cantidad de registros pendientes, en vivo.
///
/// Pensado para el header de otras pantallas: no conoce rutas, el que lo
/// usa decide qué pasa al tocarlo (normalmente abrir `SyncStatusPage`).
class SyncQueueIndicator extends StatelessWidget {
  /// Crea el indicador.
  const SyncQueueIndicator({required this.createCubit, required this.onPressed, super.key});

  /// Fábrica del cubit; el indicador lo cierra al desmontarse.
  final SyncQueueCubit Function() createCubit;

  /// Acción al tocar el indicador.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createCubit(),
      child: BlocBuilder<SyncQueueCubit, SyncQueueViewState>(
        buildWhen: (previous, current) =>
            previous.pendingCount != current.pendingCount || previous.isOnline != current.isOnline,
        builder: (context, state) {
          final pending = state.pendingCount;
          final offline = state.isOnline == false;
          final icon = switch ((pending, offline)) {
            (0, false) => Icons.cloud_done_outlined,
            (_, true) => Icons.cloud_off_outlined,
            (_, false) => Icons.cloud_upload_outlined,
          };
          return IconButton(
            tooltip: '${SyncStatusStrings.title} · ${SyncStatusStrings.pendingSubtitle(pending)}',
            onPressed: onPressed,
            icon: Badge(
              isLabelVisible: pending > 0,
              label: Text('$pending'),
              backgroundColor: AppColors.syncPending,
              child: Icon(icon),
            ),
          );
        },
      ),
    );
  }
}
