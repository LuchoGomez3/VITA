import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/livestock/domain/entities/livestock_establishment.dart';
import 'package:frontend_mayoral/features/livestock/domain/use_cases/get_livestock_establishments_use_case.dart';

/// Coordina la carga del alcance offline antes de abrir el lector RFID.
class LivestockReaderCubit extends Cubit<ResultState<List<LivestockEstablishment>>> {
  /// Crea el Cubit con el caso de uso de Hacienda.
  LivestockReaderCubit(this._getEstablishmentsUseCase) : super(const ResultState.initial());

  final GetLivestockEstablishmentsUseCase _getEstablishmentsUseCase;

  /// Carga los establecimientos habilitados para identificar animales.
  Future<void> load() async {
    emit(const ResultState.loading());
    final result = await _getEstablishmentsUseCase();
    switch (result) {
      case Success<List<LivestockEstablishment>>(:final data):
        emit(ResultState.data(data));
      case Failure<List<LivestockEstablishment>>(:final error):
        emit(ResultState.error(error));
    }
  }
}
