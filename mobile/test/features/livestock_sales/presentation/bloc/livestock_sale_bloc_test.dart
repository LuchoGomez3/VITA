import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/app/theme/app_theme.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_saved_draft.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_selection.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/errors/livestock_sale_error.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_animal_repository.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/repositories/livestock_sale_repository.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/add_animal_to_livestock_sale_selection_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/confirm_livestock_sale_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/remove_animal_from_livestock_sale_selection_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/search_livestock_sale_animals_by_rfid_prefix_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/bloc/livestock_sale_bloc.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/pages/livestock_sale_flow_page.dart';
import 'package:frontend_mayoral/features/livestock_sales/presentation/strings/livestock_sale_strings.dart';

import '../../support/livestock_sale_draft_test_support.dart';

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
      expect(bloc.state.hasDraftChanges, isFalse);
    });

    test('un agregado lento conserva las bajas y no habilita otro agregado', () async {
      await _addAnimal(bloc);
      bloc.add(const LivestockSaleEvent.animalAddRequested('982000000001296'));
      await _waitUntil(bloc, (state) => state.selection.animals.length == 2);
      final pendingAnimal = Completer<void>();
      addTearDown(() {
        if (!pendingAnimal.isCompleted) pendingAnimal.complete();
      });
      animalRepository.pendingLookup = pendingAnimal;
      bloc.add(const LivestockSaleEvent.animalAddRequested('982000000001297'));
      await _waitUntil(bloc, (state) => state.animalSelectionResult is Loading<LivestockSaleSelection>);

      bloc.add(const LivestockSaleEvent.animalRemoveRequested('animal-id'));
      await _waitUntil(bloc, (state) => state.selection.animals.length == 1);
      expect(bloc.state.animalSelectionResult, isA<Loading<LivestockSaleSelection>>());
      bloc.add(const LivestockSaleEvent.animalAddRequested('982000000001298'));
      // La cola de eventos procesa el intento extra mientras C sigue pendiente.
      await Future<void>.delayed(Duration.zero);
      expect(animalRepository.lookupCalls, 3);

      pendingAnimal.complete();
      await _waitUntil(bloc, (state) => state.animalSelectionResult is Data<LivestockSaleSelection>);
      expect(bloc.state.selection.animals.map((animal) => animal.rfidTagNumber), [
        '982000000001296',
        '982000000001297',
      ]);
    });

    test('elimina el borrador al quitar el ultimo animal sin otros datos', () async {
      final draftDependencies = LivestockSaleDraftTestDependencies();
      final draftBloc = _createBloc(
        animalRepository: animalRepository,
        saleRepository: saleRepository,
        draftDependencies: draftDependencies,
      );
      addTearDown(draftBloc.close);

      draftBloc.add(const LivestockSaleEvent.animalAddRequested(_rfid));
      await _waitUntil(
        draftBloc,
        (state) => state.selection.animals.isNotEmpty,
      );
      await _waitUntilDraft(
        draftDependencies,
        (draft) => draft.selectedRfidTagNumbers.contains(_rfid),
      );

      draftBloc.add(
        const LivestockSaleEvent.animalRemoveRequested('animal-id'),
      );
      await _waitUntil(
        draftBloc,
        (state) => state.selection.animals.isEmpty && !state.hasDraftChanges,
      );
      await _waitUntilDraftDeleted(draftDependencies);

      expect(draftDependencies.repository.draft, isNull);
    });

    test('autoguarda inmediatamente los animales seleccionados', () async {
      final draftDependencies = LivestockSaleDraftTestDependencies();
      final draftBloc = _createBloc(
        animalRepository: animalRepository,
        saleRepository: saleRepository,
        draftDependencies: draftDependencies,
      );
      addTearDown(draftBloc.close);
      await _waitUntil(
        draftBloc,
        (state) => state.draftRecoveryStatus == LivestockSaleDraftRecoveryStatus.ready,
      );

      draftBloc.add(const LivestockSaleEvent.animalAddRequested(_rfid));
      await _waitUntil(
        draftBloc,
        (state) => state.selection.animals.isNotEmpty,
      );
      await _waitUntilDraft(
        draftDependencies,
        (draft) => draft.selectedRfidTagNumbers.contains(_rfid),
      );

      expect(
        draftDependencies.repository.draft?.selectedRfidTagNumbers,
        [_rfid],
      );
    });

    test('ofrece y restaura un borrador validando sus animales', () async {
      final savedDraft = _savedDraft();
      final draftDependencies = LivestockSaleDraftTestDependencies(
        draft: savedDraft,
      );
      final draftBloc = _createBloc(
        animalRepository: animalRepository,
        saleRepository: saleRepository,
        draftDependencies: draftDependencies,
      );
      addTearDown(draftBloc.close);

      await _waitUntil(
        draftBloc,
        (state) => state.draftRecoveryStatus == LivestockSaleDraftRecoveryStatus.choiceRequired,
      );
      draftBloc.add(const LivestockSaleEvent.draftRestoreAccepted());
      await _waitUntil(
        draftBloc,
        (state) =>
            state.draftRecoveryStatus == LivestockSaleDraftRecoveryStatus.ready && state.selection.animals.isNotEmpty,
      );

      expect(draftBloc.state.form.buyerName, 'Juan');
      expect(draftBloc.state.currentStep, LivestockSaleStep.operation);
      expect(draftBloc.state.selection.animals.single.rfidTagNumber, _rfid);
    });

    test('oculta animales seleccionados, vendidos y muertos en sugerencias', () async {
      animalRepository.suggestions = const [
        LivestockSaleAnimal(
          id: 'animal-id',
          establishmentId: 'establishment-id',
          rfidTagNumber: _rfid,
          visualTag: '1295',
          categoryName: 'Novillo',
          lotName: 'Lote Norte',
          status: LivestockSaleAnimalStatus.active,
        ),
        LivestockSaleAnimal(
          id: 'available-animal',
          establishmentId: 'establishment-id',
          rfidTagNumber: '982000000001296',
          visualTag: '1296',
          categoryName: 'Novillo',
          lotName: 'Lote Norte',
          status: LivestockSaleAnimalStatus.active,
        ),
        LivestockSaleAnimal(
          id: 'sold-animal',
          establishmentId: 'establishment-id',
          rfidTagNumber: '982000000001297',
          visualTag: '1297',
          categoryName: 'Novillo',
          lotName: 'Lote Norte',
          status: LivestockSaleAnimalStatus.sold,
        ),
        LivestockSaleAnimal(
          id: 'dead-animal',
          establishmentId: 'establishment-id',
          rfidTagNumber: '982000000001298',
          visualTag: '1298',
          categoryName: 'Novillo',
          lotName: 'Lote Norte',
          status: LivestockSaleAnimalStatus.dead,
        ),
      ];
      await _addAnimal(bloc);

      bloc.add(const LivestockSaleEvent.rfidPrefixChanged('982'));
      await _waitUntil(
        bloc,
        (state) => state.rfidSuggestions is Data<List<LivestockSaleAnimal>>,
      );

      final suggestions = (bloc.state.rfidSuggestions as Data<List<LivestockSaleAnimal>>).data;
      expect(suggestions.map((animal) => animal.id), ['available-animal']);
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

    test('un rechazo del alta al confirmar conserva formulario, seleccion y borrador', () async {
      final dependencies = LivestockSaleDraftTestDependencies();
      final rejectingRepository = _SaleRepository(
        error: const DomainException(
          message: 'animalSyncRejected',
          code: DomainErrorCode.conflict,
          reason: LivestockSaleError.animalSyncRejected,
        ),
      );
      final saleBloc = _createBloc(
        animalRepository: animalRepository,
        saleRepository: rejectingRepository,
        draftDependencies: dependencies,
      );
      addTearDown(saleBloc.close);
      await _openOperationStep(saleBloc);
      final form = _validBulkForm(saleBloc.state.form);
      saleBloc.add(LivestockSaleEvent.formChanged(form));
      await _waitUntil(saleBloc, (state) => state.form == form);
      saleBloc.add(const LivestockSaleEvent.nextStepRequested());
      await _waitUntil(saleBloc, (state) => state.currentStep == LivestockSaleStep.review);
      await _waitUntilDraft(dependencies, (draft) => draft.currentStep == LivestockSaleDraftStep.review);
      final draftBeforeConfirm = dependencies.repository.draft;
      final selection = saleBloc.state.selection;

      saleBloc.add(const LivestockSaleEvent.submitRequested());
      await _waitUntil(saleBloc, (state) => state.submitResult is ResultError<LivestockSale>);

      final error = (saleBloc.state.submitResult as ResultError<LivestockSale>).error;
      expect(error.reason, LivestockSaleError.animalSyncRejected);
      expect(error.message, LivestockSaleStrings.rejectedAnimalRegistration);
      expect(saleBloc.state.form, form);
      expect(saleBloc.state.selection, selection);
      expect(saleBloc.state.currentStep, LivestockSaleStep.review);
      expect(dependencies.repository.draft, draftBeforeConfirm);
      expect(dependencies.repository.deleteCalls, 0);
    });

    for (final restore in [true, false]) {
      testWidgets('Atras conserva el borrador hasta elegir ${restore ? 'continuar' : 'descartar'}', (tester) async {
        final savedDraft = _savedDraft();
        final dependencies = LivestockSaleDraftTestDependencies(draft: savedDraft);
        late LivestockSaleBloc recoveryBloc;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: LivestockSaleFlowPage(
              userId: 'user-id',
              establishmentId: 'establishment-id',
              createBloc: ({required userId, required establishmentId}) => recoveryBloc = _createBloc(
                animalRepository: animalRepository,
                saleRepository: saleRepository,
                draftDependencies: dependencies,
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        expect(find.text(LivestockSaleStrings.savedDraftFoundTitle), findsOneWidget);

        await tester.binding.handlePopRoute();
        await tester.pump(const Duration(milliseconds: 350));

        expect(dependencies.repository.deleteCalls, 0);
        expect(dependencies.repository.draft, savedDraft);
        expect(recoveryBloc.state.draftRecoveryStatus, LivestockSaleDraftRecoveryStatus.choiceRequired);
        expect(find.text(LivestockSaleStrings.savedDraftFoundTitle), findsOneWidget);
        await tester.tap(
          find.text(restore ? LivestockSaleStrings.continueSavedDraft : LivestockSaleStrings.discardSavedDraft),
        );
        await tester.pumpAndSettle();
        expect(recoveryBloc.state.draftRecoveryStatus, LivestockSaleDraftRecoveryStatus.ready);
        if (restore) {
          expect(recoveryBloc.state.form.buyerName, savedDraft.buyerName);
          expect(recoveryBloc.state.selection.animals.single.rfidTagNumber, _rfid);
          expect(dependencies.repository.deleteCalls, 0);
        } else {
          expect(dependencies.repository.draft, isNull);
          expect(dependencies.repository.deleteCalls, 1);
        }
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }

    testWidgets('bloquea cierre, volver y retroceso del sistema durante la confirmacion', (tester) async {
      final pendingRepository = _SaleRepository(waitForCompletion: true);
      final pendingBloc = _createBloc(animalRepository: animalRepository, saleRepository: pendingRepository);
      await _openOperationStep(pendingBloc);
      final form = _validBulkForm(pendingBloc.state.form);
      pendingBloc.add(LivestockSaleEvent.formChanged(form));
      await _waitUntil(pendingBloc, (state) => state.form == form);
      pendingBloc.add(const LivestockSaleEvent.nextStepRequested());
      await _waitUntil(pendingBloc, (state) => state.currentStep == LivestockSaleStep.review);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: LivestockSaleFlowPage(
            userId: 'user-id',
            establishmentId: 'establishment-id',
            createBloc: ({required userId, required establishmentId}) => pendingBloc,
          ),
        ),
      );
      pendingBloc.add(const LivestockSaleEvent.submitRequested());
      await tester.pump();
      expect(pendingBloc.state.submitResult, isA<Loading<LivestockSale>>());
      expect(tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.close)).onPressed, isNull);
      expect(tester.widget<AppOutlinedButton>(find.byType(AppOutlinedButton)).onPressed, isNull);
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(pendingBloc.state.currentStep, LivestockSaleStep.review);
      expect(find.byType(AlertDialog), findsNothing);
      pendingRepository.complete();
      await tester.pumpAndSettle();
      expect(pendingBloc.state.submitResult, isA<Data<LivestockSale>>());
      await tester.pumpWidget(const SizedBox.shrink());
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
      final submittingState = pendingBloc.state;
      pendingBloc
        ..add(const LivestockSaleEvent.previousStepRequested())
        ..add(LivestockSaleEvent.formChanged(form.copyWith(buyerName: 'Otro')))
        ..add(const LivestockSaleEvent.animalRemoveRequested('animal-id'))
        ..add(const LivestockSaleEvent.animalAddRequested('982000000001296'))
        ..add(const LivestockSaleEvent.saveAndExitRequested())
        ..add(const LivestockSaleEvent.discardAndExitRequested());
      await Future<void>.delayed(Duration.zero);
      expect(pendingBloc.state, submittingState);
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
  LivestockSaleDraftTestDependencies? draftDependencies,
}) {
  final resolvedDraftDependencies = draftDependencies ?? LivestockSaleDraftTestDependencies();
  return LivestockSaleBloc(
    userId: 'user-id',
    establishmentId: 'establishment-id',
    addAnimal: AddAnimalToLivestockSaleSelectionUseCase(
      repository: animalRepository,
    ),
    searchAnimalsByRfidPrefix: SearchLivestockSaleAnimalsByRfidPrefixUseCase(
      repository: animalRepository,
    ),
    removeAnimal: const RemoveAnimalFromLivestockSaleSelectionUseCase(),
    confirmSale: ConfirmLivestockSaleUseCase(
      repository: saleRepository,
      now: () => _today,
      createId: _SequentialIds().next,
    ),
    loadDraft: resolvedDraftDependencies.load,
    saveDraft: resolvedDraftDependencies.save,
    deleteDraft: resolvedDraftDependencies.delete,
    now: () => _today,
  );
}

LivestockSaleSavedDraft _savedDraft() {
  return LivestockSaleSavedDraft(
    establishmentId: 'establishment-id',
    operationDate: _today,
    buyerType: LivestockSaleBuyerType.slaughterhouse,
    buyerName: 'Juan',
    isCompany: false,
    buyerLastName: 'Perez',
    dteNumber: '001234567-9',
    saleType: LivestockSaleType.bulk,
    bulkTotalAmount: '10000',
    totalWeight: '',
    pricePerKg: '',
    paymentCondition: LivestockSalePaymentCondition.total,
    paymentMethod: LivestockSalePaymentMethod.cash,
    amountToCollect: '',
    paymentDate: _today,
    observations: '',
    paymentObservations: '',
    selectedRfidTagNumbers: const [_rfid],
    currentStep: LivestockSaleDraftStep.operation,
    updatedAt: _today,
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

Future<void> _waitUntilDraft(
  LivestockSaleDraftTestDependencies dependencies,
  bool Function(LivestockSaleSavedDraft draft) predicate,
) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    final draft = dependencies.repository.draft;
    if (draft != null && predicate(draft)) return;
    await Future<void>.delayed(const Duration(milliseconds: 25));
  }
  fail('El borrador esperado no se guardó a tiempo.');
}

Future<void> _waitUntilDraftDeleted(
  LivestockSaleDraftTestDependencies dependencies,
) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    if (dependencies.repository.draft == null) return;
    await Future<void>.delayed(const Duration(milliseconds: 25));
  }
  fail('El borrador vacío no se eliminó a tiempo.');
}

class _AnimalRepository implements LivestockSaleAnimalRepository {
  List<LivestockSaleAnimal> suggestions = const [];
  Completer<void>? pendingLookup;
  int lookupCalls = 0;

  @override
  Future<Result<List<LivestockSaleAnimal>>> findLocalByRfidPrefix(
    String prefix,
  ) async => Result.success(suggestions);

  @override
  Future<Result<LivestockSaleAnimal?>> findLocalByRfidTagNumber(
    String rfidTagNumber,
  ) async {
    lookupCalls++;
    await pendingLookup?.future;
    return Result.success(
      LivestockSaleAnimal(
        id: rfidTagNumber == _rfid ? 'animal-id' : 'animal-$rfidTagNumber',
        establishmentId: 'establishment-id',
        rfidTagNumber: rfidTagNumber,
        visualTag: '1295',
        categoryName: 'Novillo',
        lotName: 'Lote Norte',
        status: LivestockSaleAnimalStatus.active,
      ),
    );
  }
}

class _SaleRepository implements LivestockSaleRepository {
  _SaleRepository({this.waitForCompletion = false, this.error});

  final bool waitForCompletion;
  final DomainException? error;
  final Completer<void> _completer = Completer<void>();
  int createCalls = 0;
  LivestockSale? created;

  @override
  Future<Result<LivestockSale>> createSale(LivestockSale sale) async {
    createCalls += 1;
    created = sale;
    if (waitForCompletion) await _completer.future;
    final error = this.error;
    if (error != null) return Result.failure(error);
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
