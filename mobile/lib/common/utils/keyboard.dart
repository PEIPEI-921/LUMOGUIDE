import 'package:flutter/material.dart';

void showKeyboard(BuildContext context) {
  // 請求當前的 primary focus 節點重新獲得焦點即可喚起鍵盤，
  // 不要 new FocusNode（永不 dispose 且未掛載，requestFocus 無效）。
  final node = FocusScope.of(context);
  if (node.hasFocus) {
    node.requestFocus(node.focusedChild ?? node);
  } else {
    node.requestFocus(node);
  }
}

void hideKeyboard(BuildContext context) {
  FocusScope.of(context).unfocus();
  FocusManager.instance.primaryFocus?.unfocus();
}
