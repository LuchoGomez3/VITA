import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/team/domain/use_cases/team_use_cases.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/join_establishment_cubit.dart';
import 'package:frontend_mayoral/features/team/presentation/pages/join_establishment_page.dart';
import 'package:frontend_mayoral/features/team/presentation/strings/team_strings.dart';
import 'package:frontend_mayoral/features/team/presentation/widgets/code_boxes.dart';

import '../team_fakes.dart';

void main() {
  for (final width in [320.0, 360.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('código legible y editable a $width px, escala $scale y teclado visible', (tester) async {
        tester.view
          ..physicalSize = Size(width, 740)
          ..devicePixelRatio = 1
          ..viewInsets = const FakeViewPadding(bottom: 280);
        addTearDown(tester.view.reset);
        final repository = FakeTeamRepository();
        final cubit = JoinEstablishmentCubit(
          JoinEstablishmentUseCase(
            repository,
            prepareData: () async => Result.success(PostAuthenticationSummary(establishmentIds: [])),
          ),
        );
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: JoinEstablishmentPage(createCubit: () => cubit),
          ),
        );
        await tester.pump();
        await tester.ensureVisible(find.byType(CodeBoxes));
        await tester.pump();
        await tester.tap(find.byType(TextField));
        await tester.enterText(find.byType(TextField), '7k4-p2m');
        await tester.pump();
        expect(cubit.state.code, '7K4P2M');
        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.focusNode!.hasFocus, isTrue);
        final bounds = tester.getRect(find.byType(CodeBoxes));
        expect(bounds.left, greaterThanOrEqualTo(0));
        expect(bounds.right, lessThanOrEqualTo(width));
        for (final char in ['7', 'K', '4', 'P', '2', 'M']) {
          final rect = tester.getRect(find.text(char));
          expect(bounds.contains(rect.center), isTrue);
          expect(rect.left, greaterThanOrEqualTo(bounds.left));
          expect(rect.right, lessThanOrEqualTo(bounds.right));
          expect(rect.width, greaterThan(10));
        }
        await tester.ensureVisible(find.byType(CodeBoxes));
        await tester.pumpAndSettle();
        final semantics = tester.ensureSemantics();
        await tester.pump();
        expect(
          tester.getSemantics(find.byType(EditableText)).getSemanticsData().hasAction(SemanticsAction.setText),
          isTrue,
        );
        semantics.dispose();
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(cubit.state.step, JoinStep.confirm);
        expect(repository.calls, ['preview:7K4P2M']);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('pegar desde el portapapeles conserva foco y normalización a 320 px', (tester) async {
    tester.view
      ..physicalSize = const Size(320, 740)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.getData') return {'text': '7k4-p2m'};
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    final cubit = JoinEstablishmentCubit(
      JoinEstablishmentUseCase(
        FakeTeamRepository(),
        prepareData: () async => Result.success(PostAuthenticationSummary(establishmentIds: [])),
      ),
    );
    await tester.pumpWidget(MaterialApp(home: JoinEstablishmentPage(createCubit: () => cubit)));
    await tester.pump();
    await tester.ensureVisible(find.text(TeamStrings.pasteCta));
    await tester.tap(find.text(TeamStrings.pasteCta));
    await tester.pump();
    expect(cubit.state.code, '7K4P2M');
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '7K4P2M');
    expect(tester.takeException(), isNull);
  });
}
