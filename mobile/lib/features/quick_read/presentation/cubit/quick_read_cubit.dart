import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/quick_read/domain/entities/quick_read_item.dart';
import 'package:frontend_mayoral/features/quick_read/domain/use_cases/quick_read_use_cases.dart';
import 'package:meta/meta.dart';

/// Sesión del lector de caravanas.
@immutable
class QuickReadState {
  /// Crea el estado.
  const QuickReadState({
    this.establishments = const [],
    this.establishmentId,
    this.items = const [],
    this.message,
    this.isManualEntry = false,
    this.isListExpanded = false,
  });

  /// Establecimientos del usuario.
  final List<EstablishmentMembership> establishments;

  /// Campo de la sesión (lo fija el primer animal registrado).
  final String? establishmentId;

  /// Caravanas leídas, la última primero.
  final List<QuickReadItem> items;

  /// Error de la última lectura.
  final String? message;

  /// Si se muestra el campo para escribir la caravana.
  final bool isManualEntry;

  /// Si la lista completa está abierta (varias caravanas).
  final bool isListExpanded;

  /// Animales registrados de la sesión.
  List<RegisteredRead> get registeredItems => items.whereType<RegisteredRead>().toList();

  /// Caravanas sin registrar de la sesión.
  List<UnregisteredRead> get unregisteredItems => items.whereType<UnregisteredRead>().toList();

  /// Nombre del campo de la sesión.
  String get establishmentName =>
      establishments.where((item) => item.id == establishmentId).map((item) => item.name).firstOrNull ?? '';

  QuickReadState _copy({
    List<EstablishmentMembership>? establishments,
    Object? establishmentId = _keep,
    List<QuickReadItem>? items,
    Object? message = _keep,
    bool? isManualEntry,
    bool? isListExpanded,
  }) => QuickReadState(
    establishments: establishments ?? this.establishments,
    establishmentId: identical(establishmentId, _keep) ? this.establishmentId : establishmentId as String?,
    items: items ?? this.items,
    message: identical(message, _keep) ? this.message : message as String?,
    isManualEntry: isManualEntry ?? this.isManualEntry,
    isListExpanded: isListExpanded ?? this.isListExpanded,
  );

  static const _keep = Object();
}

/// Arma la sesión de lectura y la mantiene al día después de cada acción.
class QuickReadCubit extends Cubit<QuickReadState> {
  /// Crea el cubit.
  QuickReadCubit({
    required ResolveQuickReadTagUseCase resolveTag,
    required RefreshQuickReadUseCase refresh,
    required GetQuickReadEstablishmentsUseCase getEstablishments,
  }) : _resolveTag = resolveTag,
       _refresh = refresh,
       _getEstablishments = getEstablishments,
       super(const QuickReadState());

  final ResolveQuickReadTagUseCase _resolveTag;
  final RefreshQuickReadUseCase _refresh;
  final GetQuickReadEstablishmentsUseCase _getEstablishments;

  /// Carga los establecimientos; con uno solo, queda como campo de la sesión.
  Future<void> start() async {
    final result = await _getEstablishments();
    if (isClosed || result is! Success<List<EstablishmentMembership>>) return;
    final establishments = result.data;
    emit(
      state._copy(
        establishments: establishments,
        establishmentId: state.establishmentId ?? (establishments.length == 1 ? establishments.single.id : null),
      ),
    );
  }

  /// Suma la caravana [tag]; devuelve si se agregó.
  Future<bool> addTag(String tag) async {
    final result = await _resolveTag(tag: tag, establishmentId: state.establishmentId, items: state.items);
    if (isClosed) return false;
    switch (result) {
      case Success<QuickReadItem>(:final data):
        emit(
          state._copy(
            items: [data, ...state.items],
            message: null,
            establishmentId:
                state.establishmentId ?? (data is RegisteredRead ? data.animal.animal.establishmentId : null),
          ),
        );
        return true;
      case Failure<QuickReadItem>(:final error):
        emit(state._copy(message: error.message));
        return false;
    }
    return false;
  }

  /// Saca [item] de la lista.
  void remove(QuickReadItem item) {
    final items = [
      for (final current in state.items)
        if (current != item) current,
    ];
    emit(state._copy(items: items, message: null, isListExpanded: items.length > 1 && state.isListExpanded));
  }

  /// Vacía la sesión (no borra nada registrado).
  void discard() => emit(state._copy(items: const [], message: null, isListExpanded: false));

  /// Fija el campo de la sesión (antes de un alta sin ningún animal leído).
  void selectEstablishment(String establishmentId) => emit(state._copy(establishmentId: establishmentId));

  /// Muestra u oculta el campo para escribir la caravana.
  void toggleManualEntry() => emit(state._copy(isManualEntry: !state.isManualEntry));

  /// Abre o cierra la lista completa.
  void toggleList() => emit(state._copy(isListExpanded: !state.isListExpanded));

  /// Relee la sesión después de mover, pesar o dar de alta.
  Future<void> refresh() async {
    final result = await _refresh(state.items);
    if (isClosed) return;
    if (result is Success<List<QuickReadItem>>) {
      emit(state._copy(items: result.data));
    }
  }
}
