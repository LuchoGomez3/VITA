import 'package:frontend_mayoral/brick/repository.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_register/data/repositories/animal_repository_impl.dart';
import 'package:frontend_mayoral/features/animal_register/domain/entities/animal.dart';
import 'package:frontend_mayoral/features/animal_register/domain/use_cases/registrar_animal_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'registrar_animal_cubit.freezed.dart';
// TODO(Agus): Seguramente haya que cambiar Cubit por Bloc para manejar el estado de esta feature.

class RegistrarAnimalCubit extends Cubit<RegistrarAnimalState> {
  RegistrarAnimalCubit({
    RegistrarAnimalUseCase? registrarAnimalUseCase,
  }) : _registrarAnimalUseCase =
           registrarAnimalUseCase ??
           RegistrarAnimalUseCase(
             AnimalRepositoryImpl(
               brickRepository: AppBrickRepository(),
             ),
           ),
       super(const RegistrarAnimalState());

  final RegistrarAnimalUseCase _registrarAnimalUseCase;

  Future<void> submit({
    required int nroCaravana,
    required String sexo,
    required String raza,
    required double peso,
    required DateTime fechaNac,
    required String categoria,
    required String pelaje,
    int? idLote,
    int? caravanaPadre,
    int? caravanaMadre,
    String? observaciones,
  }) async {
    emit(
      state.copyWith(
        status: RegistrarAnimalStatus.loading,
        error: null,
      ),
    );

    final result = await _registrarAnimalUseCase(
      Animal(
        nroCaravana: nroCaravana,
        sexo: sexo,
        raza: raza,
        peso: peso,
        fechaNac: fechaNac,
        categoria: categoria,
        pelaje: pelaje,
        idLote: idLote,
        caravanaPadre: caravanaPadre,
        caravanaMadre: caravanaMadre,
        observaciones: observaciones,
      ),
    );

    result.when(
      success: (_) {
        emit(
          state.copyWith(
            status: RegistrarAnimalStatus.success,
            error: null,
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            status: RegistrarAnimalStatus.failure,
            error: error,
          ),
        );
      },
    );
  }

  void resetFeedback() {
    emit(
      state.copyWith(
        status: RegistrarAnimalStatus.initial,
        error: null,
      ),
    );
  }
}

@freezed
abstract class RegistrarAnimalState with _$RegistrarAnimalState {
  const factory RegistrarAnimalState({
    @Default(RegistrarAnimalStatus.initial) RegistrarAnimalStatus status,
    DomainException? error,
  }) = _RegistrarAnimalState;
}

enum RegistrarAnimalStatus {
  initial,
  loading,
  success,
  failure,
}
