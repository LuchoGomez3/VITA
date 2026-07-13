import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/bloc/animal_detail_cubit.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_detail_data_grid.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_detail_header.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_detail_sync_footer.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_event_history.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/weight_gain_chart.dart';
import 'package:go_router/go_router.dart';

/// Factory usada por composition root/router para construir el Cubit.
typedef AnimalDetailCubitFactory = AnimalDetailCubit Function();

/// Page that shows the traceability detail for an animal.
class AnimalDetailPage extends StatelessWidget {
  /// Crea la página de detalle para [animalId].
  const AnimalDetailPage({
    required this.animalId,
    required this.createCubit,
    super.key,
  });

  /// Animal identifier used by the detail flow.
  /// Identificador usado para cargar el animal.
  final String animalId;

  /// Crea el Cubit con dependencias resueltas fuera de presentation.
  final AnimalDetailCubitFactory createCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createCubit()..loadAnimalData(animalId),
      child: _AnimalDetailView(animalId: animalId),
    );
  }
}

class _AnimalDetailView extends StatelessWidget {
  const _AnimalDetailView({
    required this.animalId,
  });

  final String animalId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _close(context),
        ),
        actions: const [SizedBox(width: 48)],
        title: const Text(AnimalDetailStrings.pageTitle),
      ),
      body: BlocBuilder<AnimalDetailCubit, ResultState<AnimalDetail>>(
        builder: (context, state) {
          return switch (state) {
            Loading<AnimalDetail>() => const Center(child: CircularProgressIndicator()),
            ResultError<AnimalDetail>(:final error) => Center(child: Text(error.message)),
            Data<AnimalDetail>(:final data) => _AnimalDetailContent(animalDetail: data),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.home);
  }
}

class _AnimalDetailContent extends StatelessWidget {
  const _AnimalDetailContent({
    required this.animalDetail,
  });

  final AnimalDetail animalDetail;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSurfaceCard(
            child: Column(
              children: [
                AnimalDetailHeader(animalDetail: animalDetail),
                const SizedBox(height: AppSpacing.lg),
                AnimalDetailDataGrid(animalDetail: animalDetail),
              ],
            ),
          ),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AnimalDetailStrings.observationsLabel,
                  style: AppTypography.smallEmphasis.copyWith(color: AppColors.textHint),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(animalDetail.observations ?? '-', style: AppTypography.mediumEmphasis),
              ],
            ),
          ),
          const WeightGainChart(),
          AppSurfaceCard(
            child: AnimalEventHistory(animalDetail: animalDetail),
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimalDetailSyncFooter(animalDetail: animalDetail),
        ],
      ),
    );
  }
}
