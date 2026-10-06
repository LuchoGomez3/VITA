import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/livestock_sale_history_use_cases.dart';

part 'livestock_sale_history_cubit.freezed.dart';

/// Mantiene separados la consulta del listado y el registro del cobro.
@freezed
sealed class LivestockSaleHistoryState with _$LivestockSaleHistoryState {
  /// Conserva el listado mientras se procesa una confirmación de pago.
  const factory LivestockSaleHistoryState({
    @Default(ResultState<List<LivestockSale>>.initial()) ResultState<List<LivestockSale>> history,
    @Default(ResultState<LivestockSale>.initial()) ResultState<LivestockSale> payment,
  }) = _LivestockSaleHistoryState;
}

/// Coordina el historial y la confirmación de cobros mediante casos de uso.
class LivestockSaleHistoryCubit extends Cubit<LivestockSaleHistoryState> {
  /// Crea el estado para un único establecimiento autorizado por el router.
  LivestockSaleHistoryCubit({
    required String establishmentId,
    required GetLivestockSaleHistoryUseCase getHistory,
    required CollectUnpaidLivestockSaleUseCase collectSale,
  }) : _establishmentId = establishmentId,
       _getHistory = getHistory,
       _collectSale = collectSale,
       super(const LivestockSaleHistoryState());

  final String _establishmentId;
  final GetLivestockSaleHistoryUseCase _getHistory;
  final CollectUnpaidLivestockSaleUseCase _collectSale;

  /// Lee las ventas locales y permite reintentar ante errores de almacenamiento.
  Future<void> load() async {
    emit(state.copyWith(history: const ResultState.loading()));
    final result = await _getHistory(_establishmentId);
    if (isClosed) return;
    emit(
      state.copyWith(
        history: switch (result) {
          Success(:final data) => ResultState.data(data),
          Failure(:final error) => ResultState.error(error),
          _ => throw StateError('Unknown result'),
        },
      ),
    );
  }

  /// Confirma el total pactado y refresca el listado después de persistirlo.
  Future<void> collect(LivestockSale sale, LivestockSalePaymentMethod method) async {
    if (state.payment is Loading<LivestockSale>) return;
    emit(state.copyWith(payment: const ResultState.loading()));
    final result = await _collectSale(sale: sale, amountCents: sale.totalAmountCents, method: method);
    if (isClosed) return;
    emit(
      state.copyWith(
        payment: switch (result) {
          Success(:final data) => ResultState.data(data),
          Failure(:final error) => ResultState.error(error),
          _ => throw StateError('Unknown result'),
        },
      ),
    );
    if (result is Success<LivestockSale>) await load();
  }
}
