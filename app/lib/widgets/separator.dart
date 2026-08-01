import 'package:flutter/material.dart';

class Separator extends StatelessWidget {
  const Separator({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.onSurface,
                width: 6,
              ),
            ),
          ),
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.displaySmall!,
            child: child,
          ),
        ),
      ],
    );
  }
}
