import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/profile/presentation/strings/profile_strings.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/toon_head_avatar_picker.dart';

void main() {
  test('la misma semilla genera siempre el mismo avatar, sin red', () {
    expect(ToonHeadAvatars.svg('lucho'), ToonHeadAvatars.svg('lucho'));
    expect(ToonHeadAvatars.svg('lucho'), isNot(ToonHeadAvatars.svg('agustin')));
    expect(ToonHeadAvatars.svg('lucho'), startsWith('<svg'));
  });

  testWidgets('muestra una tanda, "Ver otros" la cambia y tocar uno lo devuelve', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    String? chosen;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => chosen = await showToonHeadAvatarPicker(context, random: Random(7)),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    final first = find.bySemanticsLabel(ProfileStrings.avatarOption(0));
    expect(find.bySemanticsLabel(RegExp('^Avatar ')), findsNWidgets(ToonHeadAvatars.batchSize));
    expect(find.text(ProfileStrings.avatarAttribution), findsOneWidget);

    final expectedSeeds = ToonHeadAvatars.seeds(Random(7));
    await tester.tap(find.text(ProfileStrings.moreAvatars));
    await tester.pumpAndSettle();
    await tester.tap(first);
    await tester.pumpAndSettle();

    expect(chosen, isNotNull);
    // Después de "Ver otros" el primero ya no es el de la tanda inicial.
    expect(chosen, isNot(expectedSeeds.first));
  });
}
