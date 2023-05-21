import 'package:exam/utils/global.dart';
import 'package:flutter/material.dart';

class SimpleButton extends StatefulWidget {
  final Color color;
  final Widget? child;
  final VoidCallback onClick;
  const SimpleButton({
    super.key,
    this.color = dexon_blue,
    this.child,
    required this.onClick,
  });

  @override
  State<SimpleButton> createState() => _SimpleButtonState();
}

class _SimpleButtonState extends State<SimpleButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: widget.onClick,
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        color: _hover ? widget.color.withOpacity(0.8) : widget.color,
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.center,
        child: widget.child,
      ),
    ),
  );
}