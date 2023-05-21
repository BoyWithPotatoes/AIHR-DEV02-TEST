import 'package:flutter/material.dart';

class DialogScaffold extends StatelessWidget {
  final Widget body;
  final Widget? appBar;
  final double height;
  const DialogScaffold({
    super.key,
    this.appBar,
    this.body = const SizedBox(),
    this.height = 700 - 58,
  });

  @override
  Widget build(BuildContext context) {
    double width = 500;
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            width: width,
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey.shade200,
            height: 58.0,
            child: appBar,
          ),
          SizedBox(
            width: width,
            height: height,
            child: body
          ),
        ],
      ),
    );
  }
}