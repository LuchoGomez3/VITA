import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/livestock/domain/use_cases/get_livestock_sale_establishments_use_case.dart';

/// Carga los establecimientos habilitados para vender desde Hacienda.
class LivestockAccessCubit extends Cubit<ResultState<List<EstablishmentMembership>>> {
  /// Crea el cubit con la consulta offline de permisos comerciales.
  LivestockAccessCubit({
    required GetLivestockSaleEstablishmentsUseCase getSaleEstablishments,
  }) : _getSaleEstablishments = getSaleEstablishments,
       super(const ResultState.initial());

  final GetLivestockSaleEstablishmentsUseCase _getSaleEstablishments;

  /// Actualiza los accesos cada vez que se construye la pestaña Hacienda.
  Future<void> load() async {
    emit(const ResultState.loading());
    final result = await _getSaleEstablishments();
    switch (result) {
      case Success<List<EstablishmentMembership>>(:final data):
        emit(ResultState.data(data));
      case Failure<List<EstablishmentMembership>>(:final error):
        emit(ResultState.error(error));
    }
  }
}
