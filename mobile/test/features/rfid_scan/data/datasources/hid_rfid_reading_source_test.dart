import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/rfid_scan/data/datasources/hid_rfid_reading_source.dart';

void main() {
  group('HidRfidReadingSource', () {
    late HidRfidReadingSource source;

    setUp(() {
      source = HidRfidReadingSource();
    });

    tearDown(() async {
      await source.dispose();
    });

    test('publishes the accumulated reading when Enter is received', () async {
      await source.startReading();
      final expectation = expectLater(source.readings, emits('982000412991416'));

      for (final character in '982000412991416'.split('')) {
        source.addKeystroke(character);
      }
      source.submitReading();

      await expectation;
    });

    test('preserves non-numeric values for the use case to validate', () async {
      await source.startReading();
      final expectation = expectLater(source.readings, emits('98200041299A416'));

      for (final character in '98200041299A416'.split('')) {
        source.addKeystroke(character);
      }
      source.submitReading();

      await expectation;
    });

    test('converts HID key events into a reading completed by Enter', () async {
      await source.startReading();
      final expectation = expectLater(source.readings, emits('1'));

      source
        ..handleKeyEvent(
          const KeyDownEvent(
            physicalKey: PhysicalKeyboardKey.digit1,
            logicalKey: LogicalKeyboardKey.digit1,
            timeStamp: Duration.zero,
            character: '1',
          ),
        )
        ..handleKeyEvent(
          const KeyDownEvent(
            physicalKey: PhysicalKeyboardKey.enter,
            logicalKey: LogicalKeyboardKey.enter,
            timeStamp: Duration.zero,
          ),
        );

      await expectation;
    });

    test('ignores keystrokes while reading is stopped', () async {
      var receivedReadings = 0;
      final subscription = source.readings.listen((_) {
        receivedReadings++;
      });
      addTearDown(subscription.cancel);

      source
        ..addKeystroke('9')
        ..submitReading();

      await Future<void>.delayed(Duration.zero);

      expect(receivedReadings, isZero);
    });

    test('discards a partial reading when it is stopped', () async {
      await source.startReading();
      source.addKeystroke('982');
      await source.stopReading();
      await source.startReading();
      final expectation = expectLater(source.readings, emits('000412991416'));

      for (final character in '000412991416'.split('')) {
        source.addKeystroke(character);
      }
      source.submitReading();

      await expectation;
    });
  });
}
