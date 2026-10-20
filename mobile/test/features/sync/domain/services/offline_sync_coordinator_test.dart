import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
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
