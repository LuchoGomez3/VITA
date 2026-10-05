import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/rfid_scan/data/datasources/hid_rfid_reading_source.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/bloc/rfid_scan_bloc.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/pages/rfid_capture_page.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/strings/rfid_scan_strings.dart';
import 'package:frontend_mayoral/features/rfid_scan/presentation/widgets/hid_rfid_keyboard_listener.dart';
import 'package:frontend_mayoral/features/rfid_scan/rfid_scan_composition.dart';

void main() {
  testWidgets('returns a valid HID reading without looking up an animal', (tester) async {
    final source = HidRfidReadingSource();
    String? captured;
    await tester.pumpWidget(
      MaterialApp(
        home: RfidCapturePage(
          createBloc: () => createRfidCaptureBloc(readingSource: source),
          onHidKeyEvent: source.handleKeyEvent,
          onCaptured: (rfid) => captured = rfid,
        ),
      ),
    );

    await tester.tap(find.text(RfidScanStrings.startReading));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pump();
    expect(source.isReading, isTrue);
    source
      ..addKeystroke('982000412991416')
      ..submitReading();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pump();

    final bloc = BlocProvider.of<RfidScanBloc>(tester.element(find.byType(HidRfidKeyboardListener)));
    expect(bloc.state, const RfidScanState.captured(rfid: '982000412991416'));

    expect(captured, '982000412991416');
  });
}
