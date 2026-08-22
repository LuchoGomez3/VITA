import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/utils/uuid_v4.dart';

void main() {
  test('genera identificadores UUID v4 con variante RFC 4122', () {
    final id = generateUuidV4();

    expect(
      id,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
  });
}
