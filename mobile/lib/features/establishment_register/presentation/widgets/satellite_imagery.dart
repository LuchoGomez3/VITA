import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/strings/establishment_register_strings.dart';

/// Imagen satelital de Esri (World Imagery). Ver ADR-0009 por términos de uso.
const _satelliteUrlTemplate =
    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

/// Último zoom con imagen real en zonas rurales de Córdoba. Más cerca, Esri
/// devuelve una placa gris ("Map data not yet available"), así que desde acá
/// se amplía la imagen de este nivel.
const _satelliteMaxNativeZoom = 17;

/// Zoom máximo de los mapas del alta (ampliando la imagen del nivel 17).
const satelliteMaxZoom = 19.0;

/// Capa de imagen satelital para los mapas del alta de establecimiento.
///
/// Sin conexión los tiles fallan y el mapa queda con su color de fondo:
/// [onError] permite avisarle al productor.
TileLayer satelliteTileLayer({VoidCallback? onError}) {
  return TileLayer(
    urlTemplate: _satelliteUrlTemplate,
    userAgentPackageName: 'com.example.frontend_mayoral',
    maxNativeZoom: _satelliteMaxNativeZoom,
    errorTileCallback: onError == null ? null : (_, _, _) => onError(),
  );
}

/// Atribución que exigen los términos de la imagen de Esri: chica, en una
/// esquina y sin desbordar en pantallas angostas.
class SatelliteAttribution extends StatelessWidget {
  /// Crea la atribución de la imagen satelital.
  const SatelliteAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
        color: AppColors.onPrimary.withValues(alpha: 0.75),
        child: Text(
          EstablishmentRegisterStrings.stepFourSatelliteAttribution,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.formFieldHelper.copyWith(fontSize: 10),
        ),
      ),
    );
  }
}
