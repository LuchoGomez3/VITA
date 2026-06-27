import 'package:flutter/services.dart';

/// Text formatter that keeps only numeric RFID characters.
class RfidInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp('[^0-9]'), '');

    return newValue.copyWith(
      text: digitsOnly,
      selection: TextSelection.collapsed(offset: digitsOnly.length),
    );
  }
}
