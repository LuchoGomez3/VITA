import 'package:flutter/material.dart';
import 'package:frontend_mayoral/features/operating_expenses/presentation/strings/operating_expense_strings.dart';

/// Diálogo que captura el nombre de una categoría personalizada.
///
/// Es propietario de su controlador para liberarlo solamente cuando Flutter
/// termina la animación de cierre y desmonta la ruta del diálogo.
class AddOperatingExpenseCategoryDialog extends StatefulWidget {
  /// Crea el diálogo para agregar una categoría.
  const AddOperatingExpenseCategoryDialog({super.key});

  @override
  State<AddOperatingExpenseCategoryDialog> createState() => _AddOperatingExpenseCategoryDialogState();
}

class _AddOperatingExpenseCategoryDialogState extends State<AddOperatingExpenseCategoryDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(OperatingExpenseStrings.addCategory),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: OperatingExpenseStrings.categoryName,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
