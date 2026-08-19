import 'package:flutter/material.dart';

void showKeyboard(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

void hideKeyboard(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
  FocusManager.instance.primaryFocus?.unfocus();
}
