import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/profile/presentation/strings/profile_strings.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/profile_header.dart';
import 'package:frontend_mayoral/features/profile/presentation/widgets/profile_sliver_header.dart';

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets('conserva la identidad al comprimir y expandir con escala $scale', (tester) async {
      // Arrange: pantalla angosta, nombre largo y contenido suficiente para scroll.
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: Scaffold(
              body: CustomScrollView(
                controller: controller,
                slivers: const [
                  ProfileSliverHeader(firstName: 'María Alejandra', lastName: 'Fernández González'),
                  SliverToBoxAdapter(child: SizedBox(height: 1600)),
                ],
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final header = find.descendant(
        of: find.byType(SliverPersistentHeader),
        matching: find.byType(ClipRRect),
      );
      final expandedHeight = tester.getSize(header).height;
      final avatarTop = tester.getTopLeft(find.byType(CircleAvatar)).dy;
      final title = find.text(ProfileStrings.title).hitTestable();
      final titleTop = tester.getTopLeft(title).dy;
      // El degradado no se desplaza ni se reescala al comprimir la cabecera.
      final background = find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).gradient != null,
      );
      expect(background, findsOneWidget);
      final backgroundRect = tester.getRect(background);

      // El primer tramo desplaza la identidad y conserva la elipse completa.
      controller.jumpTo(40);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.getTopLeft(find.byType(CircleAvatar)).dy, closeTo(avatarTop - 40, 0.01));
      expect(
        tester.getBottomLeft(find.byType(ProfileHeader)).dy,
        closeTo(tester.getBottomLeft(header).dy, 0.01),
      );
      final identityOpacity = tester.widget<Opacity>(
        find.ancestor(of: find.byType(ProfileHeader), matching: find.byType(Opacity)),
      );
      expect(identityOpacity.opacity, 1);
      expect(tester.getRect(background), backgroundRect);
      expect(tester.getTopLeft(title).dy, titleTop);

      // Comprimir no cambia el color: la segunda transición empieza después.
      final delegate = tester.widget<SliverPersistentHeader>(find.byType(SliverPersistentHeader)).delegate;
      final collapseDistance = delegate.maxExtent - delegate.minExtent;
      controller.jumpTo(collapseDistance);
      await tester.pumpAndSettle();
      expect(_backgroundColors(tester, background), [AppColors.primary, AppColors.passwordStrengthVeryStrong]);
      expect(tester.widget<Text>(title).style?.color, AppColors.onPrimary);

      controller.jumpTo(collapseDistance + 48);
      await tester.pumpAndSettle();
      expect(_backgroundColors(tester, background).first, isNot(AppColors.primary));
      expect(_backgroundColors(tester, background).first, isNot(AppColors.backgroundTertiary));

      // Act: el encabezado queda fijado cuando el contenido pasa por debajo.
      controller.jumpTo(collapseDistance + 120);
      await tester.pumpAndSettle();

      // Assert: sigue visible la identidad y ocupa menos altura, sin desbordes.
      expect(tester.takeException(), isNull);
      expect(tester.getSize(header).height, lessThan(expandedHeight));
      expect(find.text(ProfileStrings.title).hitTestable(), findsOneWidget);
      expect(find.text('María Alejandra Fernández González').hitTestable(), findsOneWidget);
      expect(tester.getTopLeft(header).dy, 0);
      expect(tester.getRect(background), backgroundRect);
      expect(tester.getTopLeft(title).dy, titleTop);
      expect(_backgroundColors(tester, background), [AppColors.backgroundTertiary, AppColors.backgroundTertiary]);
      expect(tester.widget<Text>(title).style?.color, AppColors.textPrimary);
      expect(
        tester.widget<ClipRRect>(header).borderRadius,
        const BorderRadius.vertical(bottom: Radius.circular(AppRadius.lg)),
      );

      controller.jumpTo(0);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.getSize(header).height, expandedHeight);
      expect(find.byType(CircleAvatar).hitTestable(), findsOneWidget);
      expect(_backgroundColors(tester, background), [AppColors.primary, AppColors.passwordStrengthVeryStrong]);
    });
  }
}

/// Obtiene los colores visibles para comprobar las etapas de la transición.
List<Color> _backgroundColors(WidgetTester tester, Finder background) {
  final decoration = tester.widget<DecoratedBox>(background).decoration as BoxDecoration;
  return decoration.gradient!.colors;
}
