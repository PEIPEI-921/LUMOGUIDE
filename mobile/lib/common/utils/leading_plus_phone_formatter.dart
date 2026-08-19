import 'package:flutter/services.dart';

/// 若首字符不是「+」则自动在开头插入「+」，用于国际区号电话输入框。
class LeadingPlusPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    if (text.startsWith('+')) return newValue;
    final result = '+$text';
    return TextEditingValue(
      text: result,
      selection: TextSelection(
        baseOffset: newValue.selection.baseOffset + 1,
        extentOffset: newValue.selection.extentOffset + 1,
      ),
    );
  }
}
