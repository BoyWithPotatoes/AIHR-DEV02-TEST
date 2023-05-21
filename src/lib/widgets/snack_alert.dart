import 'package:flutter/material.dart';

class SnackAlert extends StatefulWidget {
  final String text;
  final double? width;
  final bool show;
  final VoidCallback on_click;
  final Widget child;
  const SnackAlert({
    super.key,
    this.text = "",
    this.width,
    required this.show,
    required this.on_click,
    required this.child
  });

  @override
  State<SnackAlert> createState() => _SnackAlertState();
}

class _SnackAlertState extends State<SnackAlert> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      widget.child,
      if (widget.show) ... [
        Positioned(
          left: 16,
          bottom: 16,
          child: MouseRegion(
            onEnter: (event) => setState(() => _hover = true),
            onExit: (event) => setState(() => _hover = false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                setState(() => _hover = false);
                widget.on_click();
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.centerLeft,
                width: widget.width,
                color: _hover ? Colors.grey.shade800 : Colors.grey.shade900,
                child: Text(widget.text, style: const TextStyle(fontSize: 20, color: Colors.white)),
              ),
            ),
          ),
        ),
      ]
    ],
  );
}