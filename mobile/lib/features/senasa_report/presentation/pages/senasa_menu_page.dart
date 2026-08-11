import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/app/router/routes.dart';
import 'package:frontend_mayoral/core/formatters/date_display_formatter.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/bloc/senasa_menu_cubit.dart';
import 'package:frontend_mayoral/features/senasa_report/presentation/strings/senasa_report_strings.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

const _historyButtonClearance = 80.0;
const _historyHeaderClearance = 184.0;

/// Factory que construye el Cubit del menú SENASA.
typedef SenasaMenuCubitFactory = SenasaMenuCubit Function();

/// Pantalla principal del historial remoto de declaraciones.
class SenasaMenuPage extends StatelessWidget {
  /// Crea la pantalla con la factory de su estado.
  const SenasaMenuPage({
    required this.createCubit,
    super.key,
  });

  /// Construye el Cubit cuyo ciclo de vida pertenece a esta página.
  final SenasaMenuCubitFactory createCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createCubit()..loadEstablishments(),
      child: const _SenasaMenuView(),
    );
  }
}

class _SenasaMenuView extends StatelessWidget {
  const _SenasaMenuView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SenasaMenuCubit, SenasaMenuState>(
      listenWhen: (previous, current) => previous.download != current.download,
      listener: _onDownloadChanged,
      child: Scaffold(
        appBar: const AppHeader(title: SenasaStrings.menuPageTitle),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.xl,
            ),
            child: Stack(
              children: [
                const Positioned.fill(child: _HistoryContent()),
                const Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  child: _RecentDocumentsHeader(),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  left: 0,
                  child: AppFilledButton(
                    label: SenasaStrings.generateNewFile,
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => context.push(AppRoutes.senasaReport),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onDownloadChanged(
    BuildContext context,
    SenasaMenuState state,
  ) async {
    switch (state.download) {
      case Data<GeneratedSenasaReport>(:final data):
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile.fromData(data.bytes, mimeType: data.mediaType, name: data.filename)],
            fileNameOverrides: [data.filename],
          ),
        );
      case ResultError<GeneratedSenasaReport>(:final error):
        if (context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(error.message)));
        }
      default:
        break;
    }
  }
}

class _RecentDocumentsHeader extends StatelessWidget {
  const _RecentDocumentsHeader();

  @override
  Widget build(BuildContext context) {
    return const AppSurfaceCard(
      padding: EdgeInsets.all(AppSpacing.md),
      elevation: 5,
      shadowColor: AppColors.cardShadow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            SenasaStrings.menuPageSubtitle,
            style: AppTypography.pageTitle,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            SenasaStrings.menuPageDescription,
            style: AppTypography.mediumEmphasis,
          ),
          SizedBox(height: AppSpacing.sm),
          _EstablishmentFilter(),
        ],
      ),
    );
  }
}

class _EstablishmentFilter extends StatelessWidget {
  const _EstablishmentFilter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SenasaMenuCubit, SenasaMenuState>(
      buildWhen: (previous, current) =>
          previous.establishments != current.establishments ||
          previous.selectedEstablishmentId != current.selectedEstablishmentId,
      builder: (context, state) => state.establishments.when(
        initial: () => const LinearProgressIndicator(),
        loading: () => const LinearProgressIndicator(),
        error: (error) => Text(error.message),
        data: (establishments) => DropdownButtonFormField<String>(
          initialValue: state.selectedEstablishmentId,
          // El historial puede incluir varios establecimientos. Limitamos la
          // altura del desplegable para que no cubra casi toda la pantalla y
          // respetamos la altura táctil mínima que exige Material.
          menuMaxHeight: 220,
          itemHeight: 48,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          decoration: const InputDecoration(labelText: SenasaStrings.establishmentSelectorLabel),
          items: establishments
              .map(
                (establishment) => DropdownMenuItem(
                  value: establishment.id,
                  child: Text(establishment.name),
                ),
              )
              .toList(growable: false),
          onChanged: (value) {
            if (value != null) {
              unawaited(context.read<SenasaMenuCubit>().selectEstablishment(value));
            }
          },
        ),
      ),
    );
  }
}

class _HistoryContent extends StatelessWidget {
  const _HistoryContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SenasaMenuCubit, SenasaMenuState>(
      builder: (context, state) => switch (state.history) {
        Data<List<SenasaExportHistoryItem>>(:final data) when data.isEmpty => const Center(
          child: Padding(
            padding: EdgeInsets.only(
              top: _historyHeaderClearance,
              bottom: _historyButtonClearance,
            ),
            child: Text(SenasaStrings.emptyGeneratedReports),
          ),
        ),
        Data<List<SenasaExportHistoryItem>>(:final data) => ListView.separated(
          padding: const EdgeInsets.only(
            top: _historyHeaderClearance,
            bottom: _historyButtonClearance,
          ),
          itemCount: data.length,
          // Las tarjetas forman un único historial visual, por eso usamos una
          // separación breve sin perder la distinción entre archivos.
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
          itemBuilder: (context, index) => _HistoryCard(item: data[index]),
        ),
        ResultError<List<SenasaExportHistoryItem>>(:final error) => Padding(
          padding: const EdgeInsets.only(
            top: _historyHeaderClearance,
            bottom: _historyButtonClearance,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(error.message, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.sm),
                AppOutlinedButton(
                  label: SenasaStrings.retry,
                  onPressed: () {
                    final id = state.selectedEstablishmentId;
                    if (id != null) {
                      unawaited(context.read<SenasaMenuCubit>().selectEstablishment(id));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        _ => const Padding(
          padding: EdgeInsets.only(
            top: _historyHeaderClearance,
            bottom: _historyButtonClearance,
          ),
          child: Center(child: CircularProgressIndicator()),
        ),
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item});

  final SenasaExportHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final date = item.generatedAt.toLocal();
    final formattedDate = DateDisplayFormatter.shortDate(date);
    return AppSurfaceCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      elevation: 5,
      shadowColor: AppColors.cardShadow,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: const Icon(Icons.description_outlined, color: AppColors.primary),
        title: Text(
          item.filename,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '$formattedDate · ${SenasaStrings.historyAnimalCount(item.animalCount)}',
        ),
        trailing: IconButton(
          tooltip: SenasaStrings.share,
          icon: const Icon(Icons.download_outlined),
          onPressed: () => unawaited(context.read<SenasaMenuCubit>().download(item.id)),
        ),
      ),
    );
  }
}
