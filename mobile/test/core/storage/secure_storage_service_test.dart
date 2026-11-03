import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('reintentar tras timeout espera el delete nativo que todavía puede escribir', () async {
    final pending = Completer<void>();
    var calls = 0;
    const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'delete');
        calls++;
        if (calls == 1) await pending.future;
        return null;
      });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    const storage = FlutterSecureStorageService(operationTimeout: Duration(milliseconds: 5));
    await expectLater(storage.delete('synthetic-session'), throwsA(isA<TimeoutException>()));
    await expectLater(storage.delete('synthetic-session'), throwsA(isA<TimeoutException>()));
    expect(calls, 1);

    final retry = storage.delete('synthetic-session');
    pending.complete();
    await retry;
    expect(calls, 3);
    await storage.delete('synthetic-session');
    expect(calls, 4);
  });
}
