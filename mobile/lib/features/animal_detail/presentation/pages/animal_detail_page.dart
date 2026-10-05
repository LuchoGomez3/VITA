import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_detail.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/cubit/animal_detail_cubit.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_detail_actions.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_detail_data_grid.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_detail_header.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_detail_photo.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_detail_sync_footer.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_event_history.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/weight_gain_chart.dart';
import 'package:go_router/go_router.dart';

/// Factory usada por composition root/router para construir el Cubit.
typedef AnimalDetailCubitFactory = AnimalDetailCubit Function();

/// Pagina que muestra la ficha de trazabilidad de un animal.
class AnimalDetailPage extends StatelessWidget {
  /// Crea la página de detalle para [animalId].
  const AnimalDetailPage({
    required this.animalId,
    required this.createCubit,
    super.key,
  });

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
      // Permite que la imagen cubra el fondo de las esquinas del header.
      extendBodyBehindAppBar: true,
      appBar: AppHeader(
        title: AnimalDetailStrings.pageTitle,
        onBackPressed: () => _close(context),
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

/// Coordina el diseño de la ficha con el resultado real de cargar la imagen.
class _AnimalDetailContent extends StatelessWidget {
  const _AnimalDetailContent({required this.animalDetail});

  final AnimalDetail animalDetail;

  @override
  Widget build(BuildContext context) {
    return AnimalDetailPhoto(
      animalDetail: animalDetail,
      contentBuilder: (photo) => _AnimalDetailLayout(animalDetail: animalDetail, photo: photo),
    );
  }
}

class _AnimalDetailLayout extends StatelessWidget {
  const _AnimalDetailLayout({
    required this.animalDetail,
    required this.photo,
  });

  final AnimalDetail animalDetail;
  final Widget? photo;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final headerHeight =
              MediaQuery.viewPaddingOf(context).top +
              const AppHeader(title: AnimalDetailStrings.pageTitle).preferredSize.height;
          final photoTop = headerHeight - AppRadius.lg;
          // La foto 4:3 queda detrás; los últimos 40 px reciben la ficha.
          // Sin foto, se conservan los márgenes y el círculo del diseño original.
          final contentTop = photo == null
              ? headerHeight + AppSpacing.lg
              : photoTop + constraints.maxWidth * 3 / 4 - (AppSpacing.lg + AppSpacing.md);
          return Stack(
            children: [
              if (photo != null) Positioned(top: photoTop, left: 0, right: 0, child: photo!),
              Padding(
                padding: EdgeInsets.fromLTRB(AppSpacing.sm, contentTop, AppSpacing.sm, AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppSurfaceCard(
                      elevation: 4,
                      shadowColor: AppColors.textPrimary,
                      color: AppColors.surface,
                      child: Column(
                        children: [
                          AnimalDetailHeader(animalDetail: animalDetail, showAvatar: photo == null),
                          const SizedBox(height: AppSpacing.lg),
                          AnimalDetailDataGrid(animalDetail: animalDetail),
                          const SizedBox(height: AppSpacing.md),
                          const Divider(color: AppColors.border),
                          const SizedBox(height: AppSpacing.sm),
                          AnimalDetailActions(sex: animalDetail.sex),
                        ],
                      ),
                    ),
                    // Separa las secciones con el mismo ritmo visual de las tarjetas del home.
                    const SizedBox(height: AppSpacing.md),
                    AppSurfaceCard(
                      elevation: 4,
                      shadowColor: AppColors.textPrimary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AnimalDetailStrings.observationsLabel,
                            style: AppTypography.smallEmphasis.copyWith(color: AppColors.textHint),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            animalDetail.observations ?? AnimalDetailStrings.noDataValue,
                            style: AppTypography.mediumEmphasis,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          const Align(
                            alignment: Alignment.centerRight,
                            child: AnimalObservationEntryButton(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    WeightGainChart(weightHistory: animalDetail.weightHistory),
                    const SizedBox(height: AppSpacing.md),
                    AppSurfaceCard(
                      elevation: 4,
                      shadowColor: AppColors.textPrimary,
                      child: AnimalEventHistory(animalDetail: animalDetail),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AnimalDetailSyncFooter(animalDetail: animalDetail),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
