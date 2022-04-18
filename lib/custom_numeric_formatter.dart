import 'package:flutter/services.dart';

class CustomNumericFormatter extends TextInputFormatter {
  CustomNumericFormatter(this.min, this.max);

  final int min;
  final int max;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty || newValue.text == '') {
      return newValue;
    } else if (int.parse(newValue.text) > max) {
      return const TextEditingValue()
          .copyWith(text: max.toString(), selection: TextSelection.fromPosition(TextPosition(offset: max.toString().length)));
    } else {
      return newValue;
    }
  }
}
