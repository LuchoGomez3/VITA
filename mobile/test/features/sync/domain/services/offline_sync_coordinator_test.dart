import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/sync/domain/repositories/initial_data_sync_repository.dart';
import 'package:frontend_mayoral/features/sync/domain/services/offline_sync_coordinator.dart';
import 'package:frontend_mayoral/features/sync/domain/use_cases/prepare_initial_data_sync_use_case.dart';

void main() {
  test('shares a concurrent sync and publishes its result once', () async {
    final repository = _DeferredSyncRepository();
    final coordinator = OfflineSyncCoordinator(
      prepareInitialDataSyncUseCase: PrepareInitialDataSyncUseCase(repository),
    );
    addTearDown(coordinator.dispose);
    final publishedResults = <Result<PostAuthenticationSummary>>[];
    final subscription = coordinator.results.listen(publishedResults.add);
    addTearDown(subscription.cancel);

    final first = coordinator.synchronize();
    final second = coordinator.synchronize();

    expect(identical(first, second), isTrue);
    expect(repository.calls, 1);

    final result = Result<PostAuthenticationSummary>.success(
      PostAuthenticationSummary(establishmentIds: ['establishment-id']),
    );
    repository.completer.complete(result);

    expect(await first, result);
    expect(await second, result);
    await Future<void>.delayed(Duration.zero);
    expect(publishedResults, [result]);
  });
  test('a membership mutation waits for the previous cycle and starts a fresh pull', () async {
    final repository = _DeferredSyncRepository();
    final coordinator = OfflineSyncCoordinator(
      prepareInitialDataSyncUseCase: PrepareInitialDataSyncUseCase(repository),
    );
    addTearDown(coordinator.dispose);
    final previous = coordinator.synchronize();
    final afterMutation = coordinator.synchronizeAfterCurrent();
    expect(repository.calls, 1);
    repository.completer.complete(Result.success(PostAuthenticationSummary(establishmentIds: ['old'])));
    await previous;
    await afterMutation;
    expect(repository.calls, 2);
  });
  test('cambiar de sesión descarta un resultado viejo y permite un ciclo nuevo', () async {
    final repository = _DeferredSyncRepository();
    var identity = 1;
    final coordinator = OfflineSyncCoordinator(
      prepareInitialDataSyncUseCase: PrepareInitialDataSyncUseCase(repository),
      sessionIdentity: () => identity,
    );
    addTearDown(coordinator.dispose);
    final results = <Result<PostAuthenticationSummary>>[];
    final subscription = coordinator.results.listen(results.add);
    addTearDown(subscription.cancel);
    final previous = coordinator.synchronize();
    identity++;
    final current = coordinator.synchronize();
    expect(repository.calls, 2);
    repository.completer.complete(Result.success(PostAuthenticationSummary(establishmentIds: [])));
    await Future.wait([previous, current]);
    await Future<void>.delayed(Duration.zero);
    expect(results, hasLength(1));
  });

  test('cancelar la sesión mientras espera el catálogo impide la escritura', () async {
    final repository = _DeferredSyncRepository();
    var identity = 1;
    final coordinator = OfflineSyncCoordinator(
      prepareInitialDataSyncUseCase: PrepareInitialDataSyncUseCase(repository),
      sessionIdentity: () => identity,
    );
    addTearDown(coordinator.dispose);
    final active = coordinator.synchronize();
    var writes = 0;
    final update = coordinator.updateCatalog(() async {
      writes++;
      return PostAuthenticationSummary(establishmentIds: ['new']);
    });
    final rejected = expectLater(update, throwsA(isA<DomainException>()));
    identity++;
    repository.completer.complete(Result.success(PostAuthenticationSummary(establishmentIds: [])));
    await active;
    await rejected;
    expect(writes, 0);
  });
}

class _DeferredSyncRepository implements InitialDataSyncRepository {
  final completer = Completer<Result<PostAuthenticationSummary>>();
  int calls = 0;

  @override
  Future<Result<PostAuthenticationSummary>> sync() {
    calls += 1;
    return completer.future;
  }
}
