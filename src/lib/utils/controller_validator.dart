import 'package:flutter/material.dart';

bool controller_validate(Map controller, {List except = const []}) {
  for (TextEditingController val in controller.values) {
    if (val.text.isEmpty && !except.contains(val)) { return false; }
  }
  return true;
}