import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/constants/health_registration_strings.dart';
import 'package:frontend_mayoral/core/formatters/date_display_formatter.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_catalog.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_event.dart';
import 'package:frontend_mayoral/features/health/presentation/cubit/health_registration_cubit.dart';
import 'package:frontend_mayoral/features/health/presentation/health_rejection_prompt.dart';
import 'package:frontend_mayoral/features/health/presentation/widgets/health_manga_capture.dart';
import 'package:go_router/go_router.dart';

/// Formulario compartido de registro sanitario.
class HealthRegistrationPage extends StatelessWidget {
  /// Abre un registro nuevo o una corrección de la selección.
  const HealthRegistrationPage({
    required this.createCubit,
    this.establishmentId,
    this.animalIds = const [],
    this.rejected,
    this.refreshCatalog,
    this.capture = false,
    super.key,
  });

  /// Crea un cubit con dependencias inyectadas.
  final HealthRegistrationCubit Function() createCubit;

  /// Campo que fija el punto de entrada.
  final String? establishmentId;

  /// Animales que inicia la ficha o el lote.
  final List<String> animalIds;

  /// Carga rechazada del usuario actual.
  final HealthCorrection? rejected;

  /// Solicita una nueva descarga al coordinador de la sesión.
  final Future<void> Function(String establishmentId)? refreshCatalog;

  /// Inicia y mantiene una sesión de lectura sucesiva.
  final bool capture;

  @override
  Widget build(BuildContext context) {
    final draft = rejected?.registration;
    return BlocProvider(
      create: (_) => createCubit()
        ..prepare(
          draft?.establishmentId ?? establishmentId,
          animalIds: draft?.recipients.map((recipient) => recipient.animalId).toList() ?? animalIds,
          draft: draft?.recipients,
        ),
      child: _RegistrationForm(
        initialEstablishmentId: establishmentId,
        rejected: rejected,
        refreshCatalog: refreshCatalog,
        capture: capture,
      ),
    );
  }
}

class _RegistrationForm extends StatefulWidget {
  const _RegistrationForm({required this.capture, this.initialEstablishmentId, this.rejected, this.refreshCatalog});

  final String? initialEstablishmentId;
  final HealthCorrection? rejected;
  final Future<void> Function(String establishmentId)? refreshCatalog;
  final bool capture;

  @override
  State<_RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<_RegistrationForm> {
  final _responsible = TextEditingController();
  final _notes = TextEditingController();
  final _dose = TextEditingController();
  final _unit = TextEditingController();
  final _route = TextEditingController();
  final _batch = TextEditingController();
  final _description = TextEditingController();
  final _sampleType = TextEditingController();
  DateTime _date = DateTime.now();
  DateTime? _expiration;
  String? _practiceId;
  String? _productId;
  bool _refreshing = false;

  bool get _fixedEstablishment => widget.initialEstablishmentId != null || widget.rejected != null;

  String? get _rejectionPrompt {
    final draft = widget.rejected;
    final rejection = draft?.rejection;
    if (draft == null || rejection == null) return null;
    final recipient = draft.registration.recipients
        .where((animal) => animal.animalId == rejection.animalId)
        .firstOrNull;
    return healthRejectionPrompt(animalLabel: recipient?.label, field: rejection.field);
  }

  @override
  void initState() {
    super.initState();
    final draft = widget.rejected?.registration;
    if (draft == null) return;
    _date = draft.occurredAt.toLocal();
    _responsible.text = draft.responsible;
    _notes.text = draft.notes ?? '';
    _practiceId = draft.practice.id;
    switch (draft.details) {
      case final HealthApplication application:
        _productId = application.productId;
        _dose.text = application.dose;
        _unit.text = application.unit;
        _route.text = application.route;
        _batch.text = application.batch ?? '';
        _expiration = application.expirationDate;
      case final HealthObservation observation:
        _description.text = observation.description;
        _sampleType.text = observation.sampleType ?? '';
    }
  }

  @override
  void dispose() {
    for (final controller in [_responsible, _notes, _dose, _unit, _route, _batch, _description, _sampleType]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HealthRegistrationCubit, HealthRegistrationState>(
      listenWhen: (previous, current) => previous.submission != current.submission,
      listener: (context, state) {
        if (state.submission is Data<void>) context.pop(true);
      },
      builder: (context, state) {
        final catalog = state.catalog;
        final establishmentId = state.establishmentId;
        final preparing = state.preparation is Loading<void>;
        final practice = preparing || state.preparation is ResultError<void>
            ? null
            : catalog?.practices.where((item) => item.id == _practiceId).firstOrNull;
        final saving = state.submission is Loading<void>;
        final header = <Widget>[
          if (_rejectionPrompt case final prompt?) Text(prompt),
          if (!_fixedEstablishment && state.establishments.length > 1)
            _select(
              HealthRegistrationStrings.establishment,
              state.establishments.map((item) => (item.id, item.name)),
              state.establishmentId,
              saving ? null : _changeEstablishment,
            ),
          if (preparing)
            const Center(child: CircularProgressIndicator())
          else if (state.preparation case ResultError<void>(:final error))
            Text(error.message)
          else if (establishmentId == null && state.establishments.isEmpty)
            const Text(HealthRegistrationStrings.unauthorized)
          else if (establishmentId != null && catalog == null) ...[
            const Text(HealthRegistrationStrings.catalogUnavailable),
            if (widget.refreshCatalog != null)
              TextButton(
                onPressed: _refreshing ? null : () => _refresh(establishmentId),
                child: const Text(HealthRegistrationStrings.refresh),
              ),
          ] else if (catalog != null) ...[
            _select(
              HealthRegistrationStrings.practice,
              catalog.practices.map((item) => (item.id, item.name)),
              practice?.id,
              saving
                  ? null
                  : (value) => setState(() {
                      _practiceId = value;
                      _productId = null;
                    }),
            ),
            if (practice != null) ...[
              _entry(HealthRegistrationStrings.responsible, _responsible, enabled: !saving),
              _dateButton(HealthRegistrationStrings.date, _date, saving ? null : _pickDate),
              if (practice.kind == HealthPracticeKind.application)
                ..._application(catalog, practice, enabled: !saving)
              else ...[
                _entry(
                  practice.kind == HealthPracticeKind.sampling
                      ? HealthRegistrationStrings.reason
                      : HealthRegistrationStrings.description,
                  _description,
                  enabled: !saving,
                ),
                if (practice.kind == HealthPracticeKind.sampling)
                  _entry(HealthRegistrationStrings.sampleType, _sampleType, enabled: !saving),
              ],
              _entry(HealthRegistrationStrings.notes, _notes, enabled: !saving),
              const SizedBox(height: AppSpacing.xs),
              if (widget.capture)
                HealthMangaCapture(
                  key: ValueKey((state.establishmentId, practice.id)),
                  enabled: !saving,
                  onTag: context.read<HealthRegistrationCubit>().addReading,
                ),
              Text(HealthRegistrationStrings.selected(state.recipients.length), style: AppTypography.pageBodyTitle),
              if (state.selectionMessage case final message?) Text(message),
              if (state.recipients.isEmpty) const Text(HealthRegistrationStrings.noAnimals),
            ],
          ],
        ];
        final recipients = practice == null ? const <HealthRecipient>[] : state.recipients;
        final recipientIndices = {
          for (final (index, recipient) in recipients.indexed) recipient.animalId: header.length + index,
        };
        final footer = <Widget>[
          if (catalog != null && practice != null) ...[
            if (state.submission case ResultError<void>(:final error)) Text(error.message),
            AppFilledButton(
              label: HealthRegistrationStrings.confirm,
              onPressed: saving || state.recipients.isEmpty || state.pendingReadings > 0
                  ? null
                  : () => _submit(state, catalog, practice),
            ),
          ],
        ];
        final recipientEnd = header.length + recipients.length;
        return PopScope(
          canPop: !saving,
          child: Scaffold(
            appBar: AppBar(title: const Text(HealthRegistrationStrings.register)),
            body: SafeArea(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.lg),
                itemCount: recipientEnd + footer.length,
                findChildIndexCallback: (key) => key is ValueKey<String> ? recipientIndices[key.value] : null,
                itemBuilder: (context, index) {
                  if (index < header.length || index >= recipientEnd) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: index < header.length ? header[index] : footer[index - recipientEnd],
                    );
                  }
                  return _recipient(context, recipients[index - header.length], practice!.kind, enabled: !saving);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _recipient(BuildContext context, HealthRecipient recipient, HealthPracticeKind kind, {required bool enabled}) {
    final cubit = context.read<HealthRegistrationCubit>();
    return Card(
      key: ValueKey(recipient.animalId),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        title: Text(recipient.label),
        subtitle: kind == HealthPracticeKind.sampling
            ? Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xxs, bottom: AppSpacing.sm),
                child: TextFormField(
                  initialValue: recipient.sampleReference,
                  enabled: enabled,
                  decoration: const InputDecoration(labelText: HealthRegistrationStrings.sampleReference),
                  onChanged: (value) => cubit.updateSampleReference(recipient.animalId, value),
                ),
              )
            : null,
        trailing: IconButton(
          tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
          onPressed: enabled ? () => cubit.remove(recipient.animalId) : null,
          icon: const Icon(Icons.close),
        ),
      ),
    );
  }

  List<Widget> _application(HealthCatalog catalog, HealthPractice practice, {required bool enabled}) {
    final products = catalog.products.where((item) => practice.productIds.contains(item.id));
    return [
      const Padding(
        padding: EdgeInsets.only(top: AppSpacing.xs),
        child: Text(HealthRegistrationStrings.applicationDetails, style: AppTypography.pageBodyTitle),
      ),
      _select(
        HealthRegistrationStrings.product,
        products.map((item) => (item.id, item.name)),
        products.any((item) => item.id == _productId) ? _productId : null,
        enabled ? (value) => setState(() => _productId = value) : null,
      ),
      Row(
        children: [
          Expanded(child: _entry(HealthRegistrationStrings.dose, _dose, enabled: enabled, decimal: true)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: _entry(HealthRegistrationStrings.unit, _unit, enabled: enabled)),
        ],
      ),
      _entry(HealthRegistrationStrings.route, _route, enabled: enabled),
      _entry(HealthRegistrationStrings.batch, _batch, enabled: enabled),
      _dateButton(
        HealthRegistrationStrings.expiration,
        _expiration,
        enabled ? () => _pickDate(expiration: true) : null,
      ),
    ];
  }

  Widget _select(
    String label,
    Iterable<(String, String)> options,
    String? current,
    ValueChanged<String?>? onChanged,
  ) => AppDropdownFormField<String>(
    title: label,
    hintText: HealthRegistrationStrings.selectOption,
    options: [for (final (id, name) in options) AppDropdownOption(value: id, label: name)],
    initialValue: current,
    enabled: onChanged != null,
    onChanged: onChanged,
    animateMenu: true,
  );

  Widget _entry(String label, TextEditingController controller, {required bool enabled, bool decimal = false}) =>
      TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: decimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        decoration: InputDecoration(labelText: label),
      );

  Widget _dateButton(String label, DateTime? value, VoidCallback? onPressed) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: const Icon(Icons.calendar_today_outlined, size: 18),
    label: Text(value == null ? label : '$label · ${DateDisplayFormatter.shortDate(value)}'),
    style: OutlinedButton.styleFrom(alignment: AlignmentDirectional.centerStart, minimumSize: const Size(0, 48)),
  );

  Future<void> _pickDate({bool expiration = false}) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: expiration ? _expiration ?? now : _date,
      firstDate: DateTime(1900),
      lastDate: expiration ? DateTime(now.year + 20) : now,
    );
    if (date == null || !mounted) return;
    setState(() {
      if (expiration) {
        _expiration = date;
      } else {
        _date = DateTime(date.year, date.month, date.day, _date.hour, _date.minute);
      }
    });
  }

  void _changeEstablishment(String? id) {
    setState(() {
      _practiceId = null;
      _productId = null;
    });
    context.read<HealthRegistrationCubit>().prepare(id);
  }

  Future<void> _refresh(String establishmentId) async {
    setState(() => _refreshing = true);
    try {
      await widget.refreshCatalog?.call(establishmentId);
      if (!mounted) return;
      await context.read<HealthRegistrationCubit>().reloadCatalog();
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  void _submit(HealthRegistrationState state, HealthCatalog catalog, HealthPractice practice) {
    final productId = _productId;
    final product = catalog.products.where((item) => item.id == productId).firstOrNull;
    if (practice.kind == HealthPracticeKind.application && product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(HealthRegistrationStrings.unavailablePractice)),
      );
      return;
    }
    final details = practice.kind == HealthPracticeKind.application
        ? HealthApplication(
            productId: product!.id,
            productName: product.name,
            dose: _dose.text.trim(),
            unit: _unit.text.trim(),
            route: _route.text.trim(),
            batch: _optional(_batch.text),
            expirationDate: _expiration,
          )
        : HealthObservation(
            description: _description.text.trim(),
            sampleType: practice.kind == HealthPracticeKind.sampling ? _sampleType.text.trim() : null,
          );
    context.read<HealthRegistrationCubit>().submit(
      HealthRegistration(
        establishmentId: catalog.establishmentId,
        occurredAt: _date,
        practice: practice,
        details: details,
        responsible: _responsible.text.trim(),
        recipients: [
          for (final item in state.recipients)
            if (practice.kind == HealthPracticeKind.sampling) item else item.copyWith(sampleReference: null),
        ],
        notes: _optional(_notes.text),
      ),
      replacingOperationId: widget.rejected?.id,
    );
  }

  static String? _optional(String text) => text.trim().isEmpty ? null : text.trim();
}
