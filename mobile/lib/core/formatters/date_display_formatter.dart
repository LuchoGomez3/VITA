/// Formateos de fecha usados por la UI.
class DateDisplayFormatter {
  const DateDisplayFormatter._();

  /// Formatea una fecha como `dd/mm/yyyy`.
  static String shortDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  /// Formatea una fecha como `dd/mm` para espacios compactos como ejes.
  static String dayAndMonth(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month';
  }

  /// Formatea una fecha y hora como `dd/mm/yyyy hh:mm`.
  static String shortDateTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '${shortDate(date)} $hour:$minute';
  }
}
