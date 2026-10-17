import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/profile/presentation/strings/profile_strings.dart';

/// Qué eligió el usuario en la hoja de edición.
sealed class ProfileAppearanceChoice {
  const ProfileAppearanceChoice();
}

/// Sacar una foto nueva con la cámara.
final class TakePhotoChoice extends ProfileAppearanceChoice {
  /// Crea la elección.
  const TakePhotoChoice();
}

/// Elegir una foto de la galería.
final class PickPhotoChoice extends ProfileAppearanceChoice {
  /// Crea la elección.
  const PickPhotoChoice();
}

/// Elegir un avatar ilustrado (Toon Head).
final class ChooseAvatarChoice extends ProfileAppearanceChoice {
  /// Crea la elección.
  const ChooseAvatarChoice();
}

/// Quitar la foto actual.
final class RemovePhotoChoice extends ProfileAppearanceChoice {
  /// Crea la elección.
  const RemovePhotoChoice();
}

/// Aplicar un color de fondo (`null` es el verde original).
final class HeaderColorChoice extends ProfileAppearanceChoice {
  /// Crea la elección con [color] como `0xFFRRGGBB`.
  const HeaderColorChoice(this.color);

  /// Color elegido.
  final int? color;
}

/// Colores sugeridos: tonos sobrios que se leen bien con texto blanco.
const profileHeaderPresets = <int>[
  0xFF1B5E20,
  0xFF00695C,
  0xFF00838F,
  0xFF1565C0,
  0xFF283593,
  0xFF6A1B9A,
  0xFFAD1457,
  0xFFC62828,
  0xFFEF6C00,
  0xFF8D6E63,
  0xFF5D4037,
  0xFF455A64,
];

/// Abre la hoja para cambiar la foto o el color de la cabecera.
///
/// Devuelve lo elegido; `null` si el usuario la cerró sin elegir.
Future<ProfileAppearanceChoice?> showProfileAppearanceSheet(
  BuildContext context, {
  required int? currentColor,
  required bool hasPhoto,
}) {
  return showModalBottomSheet<ProfileAppearanceChoice>(
    context: context,
    // Por encima de la barra de navegación del shell, que si no tapa el botón.
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (context) => ProfileAppearanceSheet(currentColor: currentColor, hasPhoto: hasPhoto),
  );
}

/// Hoja con dos pestañas: la foto (cámara, galería, avatar o quitar) y el
/// color.
///
/// Cada pestaña ocupa solo lo que necesita: "Foto" es una lista corta y
/// "Color de fondo" lleva la rueda, así que la hoja cambia de alto al pasar
/// de una a otra.
class ProfileAppearanceSheet extends StatefulWidget {
  /// Crea la hoja.
  const ProfileAppearanceSheet({required this.currentColor, required this.hasPhoto, super.key});

  /// Color actual (`null` es el original).
  final int? currentColor;

  /// Si el usuario ya tiene foto (habilita "Quitar foto").
  final bool hasPhoto;

  @override
  State<ProfileAppearanceSheet> createState() => _ProfileAppearanceSheetState();
}

class _ProfileAppearanceSheetState extends State<ProfileAppearanceSheet> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this)
    ..addListener(() {
      if (!_tabs.indexIsChanging) {
        setState(() {});
      }
    });

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          dividerColor: AppColors.border,
          tabs: const [
            Tab(text: ProfileStrings.photoTab),
            Tab(text: ProfileStrings.colorTab),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _tabs.index == 0
              ? _PhotoTab(hasPhoto: widget.hasPhoto)
              : SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.75,
                  child: _ColorTab(initialColor: widget.currentColor),
                ),
        ),
      ],
    );
  }
}

class _PhotoTab extends StatelessWidget {
  const _PhotoTab({required this.hasPhoto});

  final bool hasPhoto;

  @override
  Widget build(BuildContext context) {
    void choose(ProfileAppearanceChoice choice) => Navigator.of(context).pop(choice);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: AppColors.primary),
              title: const Text(ProfileStrings.takePhoto, style: AppTypography.mediumEmphasis),
              onTap: () => choose(const TakePhotoChoice()),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: const Text(ProfileStrings.pickFromGallery, style: AppTypography.mediumEmphasis),
              onTap: () => choose(const PickPhotoChoice()),
            ),
            ListTile(
              leading: const Icon(Icons.face_outlined, color: AppColors.primary),
              title: const Text(ProfileStrings.chooseAvatar, style: AppTypography.mediumEmphasis),
              onTap: () => choose(const ChooseAvatarChoice()),
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: Text(
                  ProfileStrings.removePhoto,
                  style: AppTypography.mediumEmphasis.copyWith(color: AppColors.error),
                ),
                onTap: () => choose(const RemovePhotoChoice()),
              ),
            const Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.md, 0),
              child: Text(ProfileStrings.photoHint, style: AppTypography.formFieldHelper),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorTab extends StatefulWidget {
  const _ColorTab({required this.initialColor});

  final int? initialColor;

  @override
  State<_ColorTab> createState() => _ColorTabState();
}

class _ColorTabState extends State<_ColorTab> {
  /// `null` es el verde original.
  late int? _selected = widget.initialColor;

  final _red = TextEditingController();
  final _green = TextEditingController();
  final _blue = TextEditingController();

  Color get _preview => Color(_selected ?? AppColors.primary.toARGB32());

  @override
  void initState() {
    super.initState();
    _syncRgbFields();
  }

  @override
  void dispose() {
    _red.dispose();
    _green.dispose();
    _blue.dispose();
    super.dispose();
  }

  void _select(int? color, {bool updateFields = true}) {
    setState(() => _selected = color);
    if (updateFields) {
      _syncRgbFields();
    }
  }

  void _syncRgbFields() {
    final color = _preview.toARGB32();
    _red.text = '${(color >> 16) & 0xFF}';
    _green.text = '${(color >> 8) & 0xFF}';
    _blue.text = '${color & 0xFF}';
  }

  void _onRgbChanged(String _) {
    final channels = [_red.text, _green.text, _blue.text].map(int.tryParse).toList();
    if (channels.any((value) => value == null || value > 255)) {
      return;
    }
    final [red, green, blue] = channels.cast<int>();
    _select(0xFF000000 | (red << 16) | (green << 8) | blue, updateFields: false);
  }

  @override
  Widget build(BuildContext context) {
    final foreground = _preview.computeLuminance() > 0.45 ? AppColors.textPrimary : AppColors.onPrimary;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // Muestra cómo queda la cabecera con el color elegido.
              Container(
                height: 72,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_preview, _darker(_preview)],
                  ),
                ),
                child: Text(ProfileStrings.title, style: AppTypography.appBarTitle.copyWith(color: foreground)),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(ProfileStrings.savedColors, style: AppTypography.pageTitle),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _Swatch(
                    color: AppColors.primary,
                    tooltip: ProfileStrings.originalColor,
                    isSelected: _selected == null,
                    onTap: () => _select(null),
                  ),
                  for (final preset in profileHeaderPresets)
                    _Swatch(
                      color: Color(preset),
                      tooltip: _hex(preset),
                      isSelected: _selected == preset,
                      onTap: () => _select(preset),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(ProfileStrings.customColor, style: AppTypography.pageTitle),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: ColorPicker(
                  pickerColor: _preview,
                  onColorChanged: (color) => _select(color.toARGB32()),
                  paletteType: PaletteType.hueWheel,
                  enableAlpha: false,
                  labelTypes: const [],
                  colorPickerWidth: 240,
                  pickerAreaHeightPercent: 0.8,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(ProfileStrings.rgbLabel, style: AppTypography.formFieldHelper),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  for (final (label, controller) in [
                    (ProfileStrings.redLabel, _red),
                    (ProfileStrings.greenLabel, _green),
                    (ProfileStrings.blueLabel, _blue),
                  ]) ...[
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        decoration: InputDecoration(labelText: label, isDense: true),
                        onChanged: _onRgbChanged,
                      ),
                    ),
                    if (label != ProfileStrings.blueLabel) const SizedBox(width: AppSpacing.sm),
                  ],
                ],
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(HeaderColorChoice(_selected)),
                child: const Text(ProfileStrings.applyColor),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _hex(int color) => '#${(color & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  static Color _darker(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0)).toColor();
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.tooltip, required this.isSelected, required this.onTap});

  final Color color;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: isSelected ? AppColors.textPrimary : AppColors.border, width: isSelected ? 3 : 1),
          ),
          child: isSelected ? const Icon(Icons.check, color: AppColors.onPrimary, size: 20) : null,
        ),
      ),
    );
  }
}
