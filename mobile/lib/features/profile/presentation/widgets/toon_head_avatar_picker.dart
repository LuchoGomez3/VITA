import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dicebear_core/dicebear_core.dart';
import 'package:dicebear_styles/toon_head.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/profile/presentation/strings/profile_strings.dart';

/// Avatares ilustrados del estilo "Toon Head" de DiceBear.
///
/// Se generan en el celular a partir de una semilla, sin pedir nada a
/// internet: el selector funciona igual en el campo sin señal.
abstract final class ToonHeadAvatars {
  /// Cuántos avatares muestra cada tanda.
  static const batchSize = 12;

  /// Fondos pastel: el avatar viene recortado sobre transparente y sin fondo
  /// se vería sobre blanco al guardarlo en JPEG.
  static const _backgrounds = ['b6e3f4', 'c0aede', 'd1d4f9', 'ffd5dc', 'ffdfbf', 'c1e7c8'];

  static final Style _style = Style.parse(toonHead);

  /// SVG del avatar de [seed].
  static String svg(String seed) => Avatar(_style, {'seed': seed, 'backgroundColor': _backgrounds}).svg;

  /// Una tanda de semillas nuevas.
  static List<String> seeds(Random random) => [
    for (var i = 0; i < batchSize; i++) random.nextInt(1 << 32).toRadixString(36),
  ];

  /// Dibuja [svg] como PNG cuadrado de [size] px para subirlo como foto.
  static Future<Uint8List> toPng(String svg, {int size = 512}) async {
    final info = await vg.loadPicture(SvgStringLoader(svg), null);
    try {
      final recorder = ui.PictureRecorder();
      Canvas(recorder)
        ..scale(size / info.size.width, size / info.size.height)
        ..drawPicture(info.picture);
      final image = await recorder.endRecording().toImage(size, size);
      try {
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        return bytes!.buffer.asUint8List();
      } finally {
        image.dispose();
      }
    } finally {
      info.picture.dispose();
    }
  }
}

/// Abre la grilla de avatares; devuelve la semilla elegida o `null`.
Future<String?> showToonHeadAvatarPicker(BuildContext context, {Random? random}) {
  return showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (context) => ToonHeadAvatarPicker(random: random ?? Random()),
  );
}

/// Grilla con una tanda de avatares y la opción de ver otros.
class ToonHeadAvatarPicker extends StatefulWidget {
  /// Crea el selector.
  const ToonHeadAvatarPicker({required this.random, super.key});

  /// Origen de las semillas (los tests lo fijan).
  final Random random;

  @override
  State<ToonHeadAvatarPicker> createState() => _ToonHeadAvatarPickerState();
}

class _ToonHeadAvatarPickerState extends State<ToonHeadAvatarPicker> {
  late List<String> _seeds = ToonHeadAvatars.seeds(widget.random);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(ProfileStrings.avatarPickerTitle, style: AppTypography.pageTitle),
            const SizedBox(height: AppSpacing.sm),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              children: [
                for (final (index, seed) in _seeds.indexed)
                  Semantics(
                    button: true,
                    label: ProfileStrings.avatarOption(index),
                    child: InkResponse(
                      onTap: () => Navigator.of(context).pop(seed),
                      child: ClipOval(child: SvgPicture.string(ToonHeadAvatars.svg(seed))),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () => setState(() => _seeds = ToonHeadAvatars.seeds(widget.random)),
              icon: const Icon(Icons.refresh),
              label: const Text(ProfileStrings.moreAvatars),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              ProfileStrings.avatarAttribution,
              textAlign: TextAlign.center,
              style: AppTypography.formFieldHelper,
            ),
          ],
        ),
      ),
    );
  }
}
