import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_saved_draft.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_draft_repository.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/delete_livestock_sale_draft_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/load_livestock_sale_draft_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/save_livestock_sale_draft_use_case.dart';

/// Dependencias en memoria para probar el BLoC sin acceder al storage seguro.
class LivestockSaleDraftTestDependencies {
  /// Crea las tres operaciones sobre un mismo repositorio en memoria.
  LivestockSaleDraftTestDependencies({LivestockSaleSavedDraft? draft})
    : repository = LivestockSaleDraftTestRepository(draft: draft) {
    load = LoadLivestockSaleDraftUseCase(repository);
    save = SaveLivestockSaleDraftUseCase(repository);
    delete = DeleteLivestockSaleDraftUseCase(repository);
  }

  /// Repositorio observable por las aserciones.
  final LivestockSaleDraftTestRepository repository;

  /// Recuperación del borrador.
  late final LoadLivestockSaleDraftUseCase load;

  /// Autoguardado del borrador.
  late final SaveLivestockSaleDraftUseCase save;

  /// Eliminación del borrador.
  late final DeleteLivestockSaleDraftUseCase delete;
}

/// Implementación determinista que conserva un único borrador en memoria.
class LivestockSaleDraftTestRepository implements LivestockSaleDraftRepository {
  /// Crea el repositorio con un borrador inicial opcional.
  LivestockSaleDraftTestRepository({this.draft});

  /// Último borrador almacenado.
  LivestockSaleSavedDraft? draft;

  /// Cantidad de eliminaciones solicitadas.
  var deleteCalls = 0;

  @override
  Future<Result<LivestockSaleSavedDraft?>> load({
    required String userId,
    required String establishmentId,
  }) async => Result.success(draft);

  @override
  Future<Result<void>> save({
    required String userId,
    required LivestockSaleSavedDraft draft,
  }) async {
    this.draft = draft;
    return const Result.success(null);
  }

  @override
  Future<Result<void>> delete({
    required String userId,
    required String establishmentId,
  }) async {
    deleteCalls++;
    draft = null;
    return const Result.success(null);
  }
}
