import 'package:flutter/material.dart';

class ClickableText extends StatefulWidget {
  final String text;
  final Color textColor;
  final double textSize;
  final VoidCallback onClick;
  const ClickableText({
    super.key,
    this.text = "",
    this.textColor = Colors.black,
    this.textSize = 18,
    required this.onClick,
  });

  @override
  State<ClickableText> createState() => _ClickableTextState();
}

class _ClickableTextState extends State<ClickableText> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: widget.onClick,
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Text(
        widget.text,
        style: TextStyle(
          fontSize: widget.textSize,
          color: widget.textColor,
          decoration: _hover ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
    ),
  );
}