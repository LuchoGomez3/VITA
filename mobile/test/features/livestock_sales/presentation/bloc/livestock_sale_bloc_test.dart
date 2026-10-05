import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_selection.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/errors/livestock_sale_error.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_animal_repository.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_repository.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/add_animal_to_livestock_sale_selection_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/confirm_livestock_sale_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/remove_animal_from_livestock_sale_selection_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/bloc/livestock_sale_bloc.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_strings.dart';

void main() {
  group('LivestockSaleBloc', () {
    late _AnimalRepository animalRepository;
    late _SaleRepository saleRepository;
    late LivestockSaleBloc bloc;

    setUp(() {
      animalRepository = _AnimalRepository();
      saleRepository = _SaleRepository();
      bloc = _createBloc(
        animalRepository: animalRepository,
        saleRepository: saleRepository,
      );
      addTearDown(bloc.close);
    });

    test('no avanza del primer paso sin animales', () async {
      bloc.add(const LivestockSaleEvent.nextStepRequested());

      await _waitUntil(bloc, (state) => state.stepError != null);

      expect(bloc.state.currentStep, LivestockSaleStep.animals);
      expect(bloc.state.stepError?.code.name, 'validation');
    });

    test('informa el primer campo obligatorio y repite el mismo error', () async {
      await _openOperationStep(bloc);
      final secondError = Completer<void>();
      var errorCount = 0;
      final subscription = bloc.stream.listen((state) {
        if (state.stepError == null) return;
        errorCount++;
        if (errorCount == 2) secondError.complete();
      });
      addTearDown(subscription.cancel);

      bloc.add(const LivestockSaleEvent.nextStepRequested());
      await _waitUntil(bloc, (state) => state.stepError != null);
      bloc.add(const LivestockSaleEvent.nextStepRequested());
      await secondError.future.timeout(const Duration(seconds: 2));

      expect(bloc.state.stepError?.message, LivestockSaleStrings.missingRequiredFields);
      expect(bloc.state.stepError?.reason, LivestockSaleFormField.buyerName);
      expect(errorCount, 2);
    });

    test('agrega y quita animales mediante los casos de uso', () async {
      bloc.add(const LivestockSaleEvent.animalAddRequested(_rfid));
      await _waitUntil(bloc, (state) => state.selection.animals.isNotEmpty);

      expect(bloc.state.selection.animals.single.id, 'animal-id');

      bloc.add(const LivestockSaleEvent.animalRemoveRequested('animal-id'));
      await _waitUntil(bloc, (state) => state.selection.animals.isEmpty);

      expect(bloc.state.animalSelectionResult, isA<Data<LivestockSaleSelection>>());
    });

    test('conserva todos los campos al avanzar y retroceder', () async {
      await _addAnimal(bloc);
      bloc.add(const LivestockSaleEvent.nextStepRequested());
      await _waitUntil(bloc, (state) => state.currentStep == LivestockSaleStep.operation);

      final form = _validBulkForm(bloc.state.form);
      bloc.add(LivestockSaleEvent.formChanged(form));
      await _waitUntil(bloc, (state) => state.form == form);

      bloc.add(const LivestockSaleEvent.nextStepRequested());
      await _waitUntil(bloc, (state) => state.currentStep == LivestockSaleStep.review);
      bloc.add(const LivestockSaleEvent.previousStepRequested());
      await _waitUntil(bloc, (state) => state.currentStep == LivestockSaleStep.operation);

      expect(bloc.state.form, form);
      expect(bloc.state.selection.animals.single.id, 'animal-id');
    });

    test('limpia solamente campos incompatibles al cambiar modalidad', () async {
      final bulk = bloc.state.form.copyWith(
        bulkTotalAmount: '10000',
        totalWeight: '10',
        pricePerKg: '1000',
        saleType: LivestockSaleType.perKilogram,
      );
      bloc.add(LivestockSaleEvent.formChanged(bulk));
      await _waitUntil(bloc, (state) => state.form.saleType == LivestockSaleType.perKilogram);

      expect(bloc.state.form.bulkTotalAmount, isEmpty);
      expect(bloc.state.form.totalWeight, '10');
      expect(bloc.state.form.pricePerKg, '1000');

      bloc.add(
        LivestockSaleEvent.formChanged(
          bloc.state.form.copyWith(
            saleType: LivestockSaleType.bulk,
            bulkTotalAmount: '5000',
          ),
        ),
      );
      await _waitUntil(bloc, (state) => state.form.saleType == LivestockSaleType.bulk);

      expect(bloc.state.form.bulkTotalAmount, '5000');
      expect(bloc.state.form.totalWeight, isEmpty);
      expect(bloc.state.form.pricePerKg, isEmpty);
    });

    test('confirma por kilo conservando precio y truncando el total', () async {
      await _openOperationStep(bloc);
      final form = _validBulkForm(bloc.state.form).copyWith(
        saleType: LivestockSaleType.perKilogram,
        bulkTotalAmount: '',
        totalWeight: '10.125',
        pricePerKg: '1000.123456',
        paymentCondition: LivestockSalePaymentCondition.pending,
      );
      bloc.add(LivestockSaleEvent.formChanged(form));
      await _waitUntil(bloc, (state) => state.form == form);
      bloc.add(const LivestockSaleEvent.nextStepRequested());
      await _waitUntil(bloc, (state) => state.currentStep == LivestockSaleStep.review);

      bloc.add(const LivestockSaleEvent.submitRequested());
      await _waitUntil(bloc, (state) => state.submitResult is Data<LivestockSale>);

      expect(saleRepository.created?.pricePerKgMicros, 1000123456);
      expect(saleRepository.created?.totalAmountCents, 1012624);
      expect(saleRepository.created?.initialPayment, isNull);
    });

    test('confirma cobro parcial con monto y medio seleccionados', () async {
      await _openOperationStep(bloc);
      final form = _validBulkForm(bloc.state.form).copyWith(
        paymentCondition: LivestockSalePaymentCondition.partial,
        paymentMethod: LivestockSalePaymentMethod.card,
        amountToCollect: '4000',
      );
      bloc.add(LivestockSaleEvent.formChanged(form));
      await _waitUntil(bloc, (state) => state.form == form);

      bloc.add(const LivestockSaleEvent.nextStepRequested());
      await _waitUntil(
        bloc,
        (state) => state.currentStep == LivestockSaleStep.review,
      );
      bloc.add(const LivestockSaleEvent.submitRequested());
      await _waitUntil(
        bloc,
        (state) => state.submitResult is Data<LivestockSale>,
      );

      expect(
        saleRepository.created?.paymentCondition,
        LivestockSalePaymentCondition.partial,
      );
      expect(saleRepository.created?.initialPayment?.amountCents, 400000);
      expect(
        saleRepository.created?.initialPayment?.method,
        LivestockSalePaymentMethod.card,
      );
    });

    test('cobro parcial sin monto informa error y conserva el formulario', () async {
      await _openOperationStep(bloc);
      final form = _validBulkForm(bloc.state.form).copyWith(
        paymentCondition: LivestockSalePaymentCondition.partial,
        amountToCollect: '',
      );
      bloc.add(LivestockSaleEvent.formChanged(form));
      await _waitUntil(bloc, (state) => state.form == form);

      bloc.add(const LivestockSaleEvent.nextStepRequested());
      await _waitUntil(bloc, (state) => state.stepError != null);

      expect(bloc.state.currentStep, LivestockSaleStep.operation);
      expect(bloc.state.form, form);
      expect(bloc.state.stepError?.message, LivestockSaleStrings.missingRequiredFields);
      expect(
        bloc.state.stepError?.reason,
        LivestockSaleFormField.amountToCollect,
      );
      expect(saleRepository.created, isNull);
    });

    test('distingue cobro parcial no positivo del que alcanza el total', () async {
      await _openOperationStep(bloc);
      final baseForm = _validBulkForm(bloc.state.form).copyWith(
        paymentCondition: LivestockSalePaymentCondition.partial,
        amountToCollect: '0',
      );
      bloc.add(LivestockSaleEvent.formChanged(baseForm));
      await _waitUntil(bloc, (state) => state.form == baseForm);

      bloc.add(const LivestockSaleEvent.nextStepRequested());
      await _waitUntil(bloc, (state) => state.stepError != null);
      expect(
        bloc.state.stepError?.reason,
        LivestockSaleError.nonPositiveInitialPaymentAmount,
      );
      expect(
        bloc.state.stepError?.message,
        LivestockSaleStrings.nonPositiveInitialPayment,
      );

      final equalTotalForm = baseForm.copyWith(amountToCollect: '10000');
      bloc.add(LivestockSaleEvent.formChanged(equalTotalForm));
      await _waitUntil(bloc, (state) => state.form == equalTotalForm);
      bloc.add(const LivestockSaleEvent.nextStepRequested());
      await _waitUntil(bloc, (state) => state.stepError != null);

      expect(
        bloc.state.stepError?.reason,
        LivestockSaleError.initialPaymentNotLessThanTotal,
      );
      expect(
        bloc.state.stepError?.message,
        LivestockSaleStrings.initialPaymentNotLessThanTotal,
      );
    });

    test('ignora una segunda confirmacion mientras la primera sigue cargando', () async {
      final pendingRepository = _SaleRepository(waitForCompletion: true);
      final pendingBloc = _createBloc(
        animalRepository: animalRepository,
        saleRepository: pendingRepository,
      );
      addTearDown(pendingBloc.close);
      await _openOperationStep(pendingBloc);
      final form = _validBulkForm(pendingBloc.state.form);
      pendingBloc.add(LivestockSaleEvent.formChanged(form));
      await _waitUntil(pendingBloc, (state) => state.form == form);
      pendingBloc.add(const LivestockSaleEvent.nextStepRequested());
      await _waitUntil(
        pendingBloc,
        (state) => state.currentStep == LivestockSaleStep.review,
      );

      pendingBloc
        ..add(const LivestockSaleEvent.submitRequested())
        ..add(const LivestockSaleEvent.submitRequested());
      await _waitUntil(
        pendingBloc,
        (state) => state.submitResult is Loading<LivestockSale>,
      );

      expect(pendingRepository.createCalls, 1);
      pendingRepository.complete();
      await _waitUntil(
        pendingBloc,
        (state) => state.submitResult is Data<LivestockSale>,
      );
      expect(pendingRepository.createCalls, 1);
    });
  });
}

const _rfid = '982000000001295';
final _today = DateTime(2026, 10, 3);

LivestockSaleBloc _createBloc({
  required _AnimalRepository animalRepository,
  required _SaleRepository saleRepository,
}) {
  return LivestockSaleBloc(
    establishmentId: 'establishment-id',
    addAnimal: AddAnimalToLivestockSaleSelectionUseCase(
      repository: animalRepository,
    ),
    removeAnimal: const RemoveAnimalFromLivestockSaleSelectionUseCase(),
    confirmSale: ConfirmLivestockSaleUseCase(
      repository: saleRepository,
      now: () => _today,
      createId: _SequentialIds().next,
    ),
    now: () => _today,
  );
}

LivestockSaleFormDraft _validBulkForm(LivestockSaleFormDraft form) {
  return form.copyWith(
    buyerName: 'Juan',
    buyerLastName: 'Perez',
    dteNumber: '001234567-9',
    bulkTotalAmount: '10000',
  );
}

Future<void> _addAnimal(LivestockSaleBloc bloc) async {
  bloc.add(const LivestockSaleEvent.animalAddRequested(_rfid));
  await _waitUntil(bloc, (state) => state.selection.animals.isNotEmpty);
}

Future<void> _openOperationStep(LivestockSaleBloc bloc) async {
  await _addAnimal(bloc);
  bloc.add(const LivestockSaleEvent.nextStepRequested());
  await _waitUntil(bloc, (state) => state.currentStep == LivestockSaleStep.operation);
}

Future<void> _waitUntil(
  LivestockSaleBloc bloc,
  bool Function(LivestockSaleState state) predicate,
) async {
  if (predicate(bloc.state)) return;
  await bloc.stream.firstWhere(predicate).timeout(const Duration(seconds: 2));
}

class _AnimalRepository implements LivestockSaleAnimalRepository {
  @override
  Future<Result<LivestockSaleAnimal?>> findLocalByRfidTagNumber(
    String rfidTagNumber,
  ) async {
    return const Result.success(
      LivestockSaleAnimal(
        id: 'animal-id',
        establishmentId: 'establishment-id',
        rfidTagNumber: _rfid,
        visualTag: '1295',
        categoryName: 'Novillo',
        lotName: 'Lote Norte',
        status: LivestockSaleAnimalStatus.active,
      ),
    );
  }
}

class _SaleRepository implements LivestockSaleRepository {
  _SaleRepository({this.waitForCompletion = false});

  final bool waitForCompletion;
  final Completer<void> _completer = Completer<void>();
  int createCalls = 0;
  LivestockSale? created;

  @override
  Future<Result<LivestockSale>> createSale(LivestockSale sale) async {
    createCalls += 1;
    created = sale;
    if (waitForCompletion) await _completer.future;
    return Result.success(sale);
  }

  void complete() {
    if (!_completer.isCompleted) _completer.complete();
  }
}

class _SequentialIds {
  int _value = 0;

  String next() {
    _value += 1;
    return 'id-$_value';
  }
}
