import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';

void main() {
  test('keeps establishment IDs immutable', () {
    final sourceIds = ['establishment-1'];
    final summary = PostAuthenticationSummary(establishmentIds: sourceIds);

    sourceIds.add('establishment-2');

    expect(summary.establishmentIds, ['establishment-1']);
    expect(
      () => summary.establishmentIds.add('establishment-3'),
      throwsUnsupportedError,
    );
  });
}
