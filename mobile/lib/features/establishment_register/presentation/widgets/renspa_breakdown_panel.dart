import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/features/establishment_register/presentation/strings/establishment_register_strings.dart';

/// Desglose visual del número de RENSPA (provincia/depto/actividad/titular/UP).
class RenspaBreakdownPanel extends StatelessWidget {
  /// Crea el panel de desglose para el [nroRenspa] indicado.
  const RenspaBreakdownPanel({required this.nroRenspa, super.key});

  /// Número de RENSPA a desglosar, con formato `NN.NNN.N.NNNNN/NN`.
  final String nroRenspa;

  @override
  Widget build(BuildContext context) {
    final parts = _RenspaParts.parse(nroRenspa);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _RenspaPart(
                value: parts.provincia,
                label: EstablishmentRegisterStrings.renspaProvinciaLabel,
              ),
              _RenspaPart(
                value: parts.departamento,
                label: EstablishmentRegisterStrings.renspaDepartamentoLabel,
              ),
              _RenspaPart(
                value: parts.actividad,
                label: EstablishmentRegisterStrings.renspaActividadLabel,
              ),
              _RenspaPart(
                value: parts.titular,
                label: EstablishmentRegisterStrings.renspaTitularLabel,
              ),
              _RenspaPart(
                value: parts.unidadProductiva,
                label: EstablishmentRegisterStrings.renspaUnidadProductivaLabel,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            EstablishmentRegisterStrings.stepTwoRenspaCaption,
            style: AppTypography.formFieldHelper,
          ),
        ],
      ),
    );
  }
}

class _RenspaPart extends StatelessWidget {
  const _RenspaPart({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.monoValueEmphasis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: AppTypography.formFieldHelper,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Segmentos que componen un número de RENSPA.
///
/// El parseo es puramente visual: no valida el formato (eso lo hace la Etapa
/// 2), solo separa el texto en partes para mostrarlo desglosado.
class _RenspaParts {
  const _RenspaParts({
    required this.provincia,
    required this.departamento,
    required this.actividad,
    required this.titular,
    required this.unidadProductiva,
  });

  factory _RenspaParts.parse(String renspa) {
    final segments = renspa.split('.');
    final resto = segments.length > 3 ? segments[3] : '';
    final restoPartes = resto.split('/');

    return _RenspaParts(
      provincia: segments.isNotEmpty ? segments[0] : '',
      departamento: segments.length > 1 ? segments[1] : '',
      actividad: segments.length > 2 ? segments[2] : '',
      titular: restoPartes.isNotEmpty ? restoPartes[0] : '',
      unidadProductiva: restoPartes.length > 1 ? restoPartes[1] : '',
    );
  }

  final String provincia;
  final String departamento;
  final String actividad;
  final String titular;
  final String unidadProductiva;
}
