import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/profile/domain/entities/establishment_details.dart';
import 'package:frontend_mayoral/features/profile/domain/use_cases/get_profile_establishments_use_case.dart';

/// Coordina la carga de establecimientos para Perfil.
class ProfileCubit extends Cubit<ResultState<List<EstablishmentDetails>>> {
  /// Crea el Cubit con el caso de uso correspondiente.
  ProfileCubit(this._getEstablishmentsUseCase) : super(const ResultState.initial());

  final GetProfileEstablishmentsUseCase _getEstablishmentsUseCase;

  /// Carga el catálogo offline de la sesión actual.
  Future<void> load() async {
    emit(const ResultState.loading());
    final result = await _getEstablishmentsUseCase();
    switch (result) {
      case Success<List<EstablishmentDetails>>(:final data):
        emit(ResultState.data(data));
      case Failure<List<EstablishmentDetails>>(:final error):
        emit(ResultState.error(error));
    }
  }
}
