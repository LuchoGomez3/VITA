import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/use_cases/field_map_photo_actions.dart';
import 'package:frontend_mayoral/features/field/presentation/strings/field_strings.dart';
import 'package:frontend_mayoral/features/field/presentation/widgets/lot_overview_canvas.dart';
import 'package:logging/logging.dart';

/// Carga el fondo local o satelital para los mapas del listado y la ficha.
class FieldMapWithPhoto extends StatefulWidget {
  /// Crea un mapa con el fondo del establecimiento.
  const FieldMapWithPhoto({
    required this.establishmentId,
    required this.actions,
    required this.lots,
    required this.onLotSelected,
    this.expanded = false,
    this.onToggleFullscreen,
    this.allowPhotoSelection = false,
    super.key,
  });

  /// Establecimiento del que se lee el fondo.
  final String establishmentId;

  /// Lecturas locales y selector de foto, si están disponibles.
  final FieldMapPhotoActions? actions;

  /// Lotes dibujados sobre el fondo.
  final List<Lot> lots;

  /// Acción al tocar un lote.
  final ValueChanged<String> onLotSelected;

  /// Si el mapa ocupa toda la pantalla.
  final bool expanded;

  /// Acción para ampliar o contraer el mapa.
  final VoidCallback? onToggleFullscreen;

  /// Habilita el cambio de foto desde el mapa general.
  final bool allowPhotoSelection;

  @override
  State<FieldMapWithPhoto> createState() => _FieldMapWithPhotoState();
}

class _FieldMapWithPhotoState extends State<FieldMapWithPhoto> {
  late final Future<FieldMapLocation?>? _location = widget.actions?.locate(widget.establishmentId);
  late Future<Uint8List?>? _photo = widget.actions?.read(widget.establishmentId);
  bool _selecting = false;

  Future<void> _select() async {
    setState(() => _selecting = true);
    try {
      final bytes = await widget.actions?.select(widget.establishmentId);
      if (mounted && bytes != null) setState(() => _photo = Future.value(bytes));
    } on Exception catch (error, stackTrace) {
      Logger('FieldMapPhoto').warning('No se pudo guardar el fondo local.', error, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(FieldStrings.mapPhotoError)));
      }
    } finally {
      if (mounted) setState(() => _selecting = false);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<FieldMapLocation?>(
    future: _location,
    builder: (context, location) => FutureBuilder<Uint8List?>(
      future: _photo,
      builder: (context, photo) => LotOverviewCanvas(
        lots: widget.lots,
        onLotSelected: widget.onLotSelected,
        location: location.data,
        photo: photo.data,
        onSelectPhoto: !widget.allowPhotoSelection || widget.actions == null || _selecting ? null : _select,
        expanded: widget.expanded,
        onToggleFullscreen: widget.onToggleFullscreen,
      ),
    ),
  );
}
