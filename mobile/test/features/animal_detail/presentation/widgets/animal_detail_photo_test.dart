import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_photo.dart';
import 'package:frontend_mayoral/features/animal_detail/presentation/widgets/animal_detail_photo.dart';

void main() {
  testWidgets('renders local bytes through a memory image', (tester) async {
    final photo = AnimalPhoto.fromBytes(base64Decode(_onePixelPng));

    await tester.pumpWidget(
      MaterialApp(
        home: AnimalDetailPhoto(
          photo: photo,
          contentBuilder: (photo) => photo ?? const SizedBox.shrink(),
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    final provider = image.image as ResizeImage;
    final memoryImage = provider.imageProvider as MemoryImage;
    expect(identical(memoryImage.bytes, photo.bytes), isTrue);
    expect(provider.width, tester.view.physicalSize.width.round());
  });

  testWidgets('keeps the fallback when no local photo exists', (tester) async {
    const fallbackKey = Key('photo-fallback');

    await tester.pumpWidget(
      MaterialApp(
        home: AnimalDetailPhoto(
          photo: null,
          contentBuilder: (photo) => photo ?? const SizedBox(key: fallbackKey),
        ),
      ),
    );

    expect(find.byKey(fallbackKey), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });
}

const _onePixelPng = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScL0WQAAAABJRU5ErkJggg==';
