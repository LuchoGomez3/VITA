import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Cómo se pinta el código.
enum CodeBoxesState {
  /// Escribiendo.
  idle,

  /// Código válido.
  valid,

  /// El servidor lo rechazó.
  invalid,
}

/// Código de invitación en cajitas `XXX-XXX` (`CodeBoxes` del diseño).
///
/// Debajo hay un campo de texto invisible que recibe el teclado (y lo pegado):
/// tocar cualquier cajita lo enfoca.
class CodeBoxes extends StatefulWidget {
  /// Crea las cajitas.
  const CodeBoxes({
    required this.code,
    required this.length,
    super.key,
    this.state = CodeBoxesState.idle,
    this.onChanged,
    this.onSubmitted,
    this.compact = false,
    this.autofocus = false,
  });

  /// Código normalizado a mostrar.
  final String code;

  /// Cantidad de caracteres.
  final int length;

  /// Color de las cajitas.
  final CodeBoxesState state;

  /// Texto escrito; `null` deja las cajitas de solo lectura.
  final ValueChanged<String>? onChanged;

  /// Se tocó "listo" en el teclado.
  final VoidCallback? onSubmitted;

  /// Cajitas más chicas (pantalla de confirmación).
  final bool compact;

  /// Abre el teclado al mostrarse.
  final bool autofocus;

  @override
  State<CodeBoxes> createState() => _CodeBoxesState();
}

class _CodeBoxesState extends State<CodeBoxes> {
  late final _controller = TextEditingController(text: widget.code);
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(CodeBoxes oldWidget) {
    super.didUpdateWidget(oldWidget);
    // El cubit manda (p. ej. "Borrar y escribir de nuevo" deja el código vacío).
    if (widget.code != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.code,
        selection: TextSelection.collapsed(offset: widget.code.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final half = widget.length ~/ 2;
    final editable = widget.onChanged != null;
    final boxes = [
      for (var i = 0; i < widget.length; i++) ...[
        if (i == half)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            child: Container(width: 8, height: 3, color: AppColors.border),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: _Box(
            char: i < widget.code.length ? widget.code[i] : null,
            focused: editable && _focus.hasFocus && i == widget.code.length,
            state: widget.state,
            compact: widget.compact,
          ),
        ),
      ],
    ];

    return Semantics(
      label: 'Código de invitación',
      value: widget.code,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: boxes),
          if (editable)
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  autofocus: widget.autofocus,
                  showCursor: false,
                  autocorrect: false,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.characters,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                    LengthLimitingTextInputFormatter(widget.length),
                  ],
                  onChanged: widget.onChanged,
                  onSubmitted: (_) => widget.onSubmitted?.call(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.char, required this.focused, required this.state, required this.compact});

  final String? char;
  final bool focused;
  final CodeBoxesState state;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final filled = char != null;
    final borderColor = focused
        ? AppColors.primary
        : !filled
        ? AppColors.border
        : switch (state) {
            CodeBoxesState.invalid => AppColors.error,
            CodeBoxesState.valid => AppColors.primary,
            CodeBoxesState.idle => AppColors.border,
          };
    return Container(
      width: compact ? 40 : 46,
      height: compact ? 52 : 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: state == CodeBoxesState.invalid ? AppColors.errorContainer : AppColors.surface,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: focused ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.18), spreadRadius: 3)] : null,
      ),
      child: Text(
        char ?? '',
        style: AppTypography.monoValueEmphasis.copyWith(
          fontSize: compact ? 22 : 26,
          color: state == CodeBoxesState.invalid ? AppColors.error : AppColors.textPrimary,
        ),
      ),
    );
  }
}
