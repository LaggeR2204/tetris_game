import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Widget? child;

  const CustomButton({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Center(child: child),
        decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
      ),
    );
  }
}
