import 'package:frontend_mayoral/core/formatters/formatters.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/validators/validators.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:flutter/material.dart';

class RegistrarAnimalForm extends StatefulWidget {
  const RegistrarAnimalForm({
    required this.onSubmit,
    required this.isSubmitting,
    super.key,
  });

  final Future<void> Function({
    required int nroCaravana,
    required String sexo,
    required String raza,
    required double peso,
    required DateTime fechaNac,
    required String categoria,
    required String pelaje,
    int? idLote,
    int? caravanaPadre,
    int? caravanaMadre,
    String? observaciones,
  }) onSubmit;
  final bool isSubmitting;

  @override
  State<RegistrarAnimalForm> createState() => _RegistrarAnimalFormState();
}

class _RegistrarAnimalFormState extends State<RegistrarAnimalForm> {
  final _formKey = GlobalKey<FormState>();
  final _nroCaravanaController = TextEditingController();
  final _sexoController = TextEditingController();
  final _razaController = TextEditingController();
  final _pesoController = TextEditingController();
  final _fechaNacController = TextEditingController();
  final _idLoteController = TextEditingController();
  final _caravanaPadreController = TextEditingController();
  final _caravanaMadreController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _pelajeController = TextEditingController();
  final _observacionesController = TextEditingController();

  @override
  void dispose() {
    _nroCaravanaController.dispose();
    _sexoController.dispose();
    _razaController.dispose();
    _pesoController.dispose();
    _fechaNacController.dispose();
    _idLoteController.dispose();
    _caravanaPadreController.dispose();
    _caravanaMadreController.dispose();
    _categoriaController.dispose();
    _pelajeController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await widget.onSubmit(
      nroCaravana: int.parse(_nroCaravanaController.text.trim()),
      sexo: _sexoController.text.trim(),
      raza: _razaController.text.trim(),
      peso: double.parse(_pesoController.text.trim()),
      fechaNac: DateTime.parse(_fechaNacController.text.trim()),
      idLote: _parseOptionalInt(_idLoteController.text),
      caravanaPadre: _parseOptionalInt(_caravanaPadreController.text),
      caravanaMadre: _parseOptionalInt(_caravanaMadreController.text),
      categoria: _categoriaController.text.trim(),
      pelaje: _pelajeController.text.trim(),
      observaciones: _parseOptionalString(_observacionesController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          const AppSectionHeader(
            title: 'Alta manual de animal',
            subtitle:
                'Formulario base alineado con la tabla real de animal. Despues puede crecer con selects, date pickers y validaciones mas ricas.',
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _nroCaravanaController,
            decoration: const InputDecoration(
              labelText: 'Nro caravana',
              hintText: 'Ej. 1001',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [RfidInputFormatter()],
            validator: (value) => FormValidators.requiredField(value) ?? FormValidators.numeric(value),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _sexoController,
            decoration: const InputDecoration(
              labelText: 'Sexo',
              hintText: 'Ej. Hembra',
            ),
            validator: FormValidators.requiredField,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _razaController,
            decoration: const InputDecoration(
              labelText: 'Raza',
              hintText: 'Ej. Angus',
            ),
            validator: FormValidators.requiredField,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _pesoController,
            decoration: const InputDecoration(
              labelText: 'Peso',
              hintText: 'Ej. 350.5',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) => FormValidators.requiredField(value) ?? _doubleValidator(value),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _fechaNacController,
            decoration: const InputDecoration(
              labelText: 'Fecha nac',
              hintText: 'YYYY-MM-DD',
            ),
            validator: (value) => FormValidators.requiredField(value) ?? _dateValidator(value),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _idLoteController,
            decoration: const InputDecoration(
              labelText: 'ID lote',
              hintText: 'Opcional',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [RfidInputFormatter()],
            validator: FormValidators.numeric,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _caravanaPadreController,
            decoration: const InputDecoration(
              labelText: 'Caravana padre',
              hintText: 'Opcional',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [RfidInputFormatter()],
            validator: FormValidators.numeric,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _caravanaMadreController,
            decoration: const InputDecoration(
              labelText: 'Caravana madre',
              hintText: 'Opcional',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [RfidInputFormatter()],
            validator: FormValidators.numeric,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _categoriaController,
            decoration: const InputDecoration(
              labelText: 'Categoria',
              hintText: 'Ej. Vaquillona',
            ),
            validator: FormValidators.requiredField,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _pelajeController,
            decoration: const InputDecoration(
              labelText: 'Pelaje',
              hintText: 'Ej. Negro',
            ),
            validator: FormValidators.requiredField,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _observacionesController,
            decoration: const InputDecoration(
              labelText: 'Observaciones',
              hintText: 'Opcional',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Registrar animal',
            isLoading: widget.isSubmitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  int? _parseOptionalInt(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    return int.parse(trimmed);
  }

  String? _parseOptionalString(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _doubleValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return double.tryParse(value.trim()) == null
        ? 'Debe ser un número decimal válido.'
        : null;
  }

  String? _dateValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    try {
      DateTime.parse(value.trim());
      return null;
    } catch (_) {
      return 'Usá formato YYYY-MM-DD.';
    }
  }
}
