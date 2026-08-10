import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/rfid_scan/domain/use_cases/validate_rfid_reading_use_case.dart';

void main() {
  group('ValidateRfidReadingUseCase', () {
    const validRfid = '982000412991416';
    late ValidateRfidReadingUseCase useCase;

    setUp(() {
      useCase = ValidateRfidReadingUseCase();
    });

    test('accepts exactly 15 numeric digits', () {
      expect(useCase(validRfid), isTrue);
    });

    test('rejects values with fewer or more than 15 digits', () {
      expect(useCase('98200041299141'), isFalse);
      expect(useCase('${validRfid}0'), isFalse);
    });

    test('rejects values containing non-numeric characters', () {
      expect(useCase('98200041299A416'), isFalse);
    });
  });
}
