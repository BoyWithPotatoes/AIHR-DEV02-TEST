import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SimpleTextField extends StatelessWidget {
  final String title;
  final TextEditingController? controller;
  final bool only_number;
  final String hint_text;
  final String? Function(String? value)? validator;
  final bool read_only;
  final bool date;
  const SimpleTextField({
    super.key,
    this.title = "",
    this.controller,
    this.only_number = false,
    this.hint_text = "",
    this.validator,
    this.read_only = false,
    this.date = false,
  });

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
      const SizedBox(height: 8),
      TextFormField(
        readOnly: read_only,
        validator: validator,
        inputFormatters: <TextInputFormatter>[
          if (date) ... [
            FilteringTextInputFormatter.allow(RegExp(r'^\d{0,4}\-?\d{0,2}\-?\d{0,2}')),
          ]else if (only_number) ... [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,6}')),
          ]
        ],
        controller: controller,
        decoration: InputDecoration(
          hintText: hint_text,
          helperText: only_number ? "*Only Number" : null,
          border: InputBorder.none,
          filled: true,
          fillColor: read_only ? Colors.grey.shade300 : Colors.grey.shade200,
        ),
        style: TextStyle(
          fontSize: 16,
          color: read_only ? Colors.grey.shade600 : null,
        ),
      ),
      const SizedBox(height: 12),
    ],
  );
}