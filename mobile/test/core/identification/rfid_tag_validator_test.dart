import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/identification/rfid_tag_validator.dart';

void main() {
  const validator = RfidTagValidator();

  test('accepts exactly 15 numeric digits', () {
    expect(validator('982000412991416'), isTrue);
  });

  test('rejects invalid lengths and non-numeric characters', () {
    expect(validator('98200041299141'), isFalse);
    expect(validator('9820004129914160'), isFalse);
    expect(validator('98200041299A416'), isFalse);
  });
}
