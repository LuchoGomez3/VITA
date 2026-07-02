import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/bloc/animal_detail_cubit.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/bloc/animal_detail_state.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/strings/animal_detail_strings.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_detail_data_grid.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_detail_header.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_detail_sync_footer.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_event_history.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/weight_gain_chart.dart';
import 'package:go_router/go_router.dart';

/// Page that shows the traceability detail for an animal.
class AnimalDetailPage extends StatelessWidget {
  /// Creates the animal detail page for [animalId].
  const AnimalDetailPage({
    required this.animalId,
    super.key,
  });

  /// Animal identifier used by the detail flow.
  final String animalId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AnimalDetailCubit()..loadAnimalData(animalId),
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
      body: BlocBuilder<AnimalDetailCubit, AnimalDetailState>(
        builder: (context, state) {
          return switch (state) {
            AnimalDetailLoading() => const Center(child: CircularProgressIndicator()),
            AnimalDetailError(:final message) => Center(child: Text(message)),
            AnimalDetailLoaded() => _AnimalDetailContent(animalId: animalId),
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
    required this.animalId,
  });

  final String animalId;

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
                AnimalDetailHeader(animalId: animalId),
                const SizedBox(height: AppSpacing.lg),
                const AnimalDetailDataGrid(),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const WeightGainChart(),
          const SizedBox(height: AppSpacing.lg),
          const AppSurfaceCard(child: AnimalEventHistory()),
          const SizedBox(height: AppSpacing.lg),
          const AnimalDetailSyncFooter(),
        ],
      ),
    );
  }
}
