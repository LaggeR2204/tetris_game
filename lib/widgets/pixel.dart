import 'package:flutter/material.dart';

class Pixel extends StatelessWidget {
  final Color? color;
  final Widget? child;

  const Pixel({Key? key, this.color, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
        child: Container(
          color: color ?? Colors.black,
          child: Center(child: child),
        ),
      ),
    );
  }
}
