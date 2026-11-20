import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/constants/health_registration_strings.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/core/widgets/widgets.dart';
import 'package:frontend_mayoral/features/health/domain/entities/health_event.dart';
import 'package:frontend_mayoral/features/health/presentation/cubit/health_result_cubit.dart';
import 'package:go_router/go_router.dart';

/// Permite informar el resultado pendiente de un estudio existente.
class HealthResultPage extends StatefulWidget {
  /// Abre el resultado desde el historial animal.
  const HealthResultPage({required this.event, required this.createCubit, super.key});

  /// Estudio que se actualiza.
  final HealthEvent event;

  /// Crea el caso de uso con dependencias inyectadas.
  final HealthResultCubit Function() createCubit;

  @override
  State<HealthResultPage> createState() => _HealthResultPageState();
}

class _HealthResultPageState extends State<HealthResultPage> {
  late final _text = TextEditingController(text: widget.event.result?.value);
  late DateTime _date = widget.event.result?.reportedAt.toLocal() ?? DateTime.now();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => widget.createCubit(),
    child: BlocConsumer<HealthResultCubit, ResultState<void>>(
      listener: (context, state) {
        if (state is Data<void>) context.pop(true);
      },
      builder: (context, state) {
        final saving = state is Loading<void>;
        return PopScope(
          canPop: !saving,
          child: Scaffold(
            appBar: AppBar(title: const Text(HealthRegistrationStrings.addResult)),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(widget.event.practice.name),
                  Text(widget.event.recipient.label),
                  TextField(
                    controller: _text,
                    enabled: !saving,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: HealthRegistrationStrings.result),
                  ),
                  OutlinedButton(
                    onPressed: saving ? null : _pickDate,
                    child: Text(
                      '${HealthRegistrationStrings.resultDate} · ${MaterialLocalizations.of(context).formatCompactDate(_date)}',
                    ),
                  ),
                  if (state case ResultError<void>(:final error)) Text(error.message),
                  AppFilledButton(
                    label: HealthRegistrationStrings.saveResult,
                    onPressed: saving
                        ? null
                        : () => context.read<HealthResultCubit>().save(widget.event, _text.text, _date),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(now) ? now : _date,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (date != null && mounted) setState(() => _date = date);
  }
}
