import 'dart:math';

import 'package:flutter/material.dart';
import 'package:player/generated/l10n.dart';

class DaysLeftBadge extends StatelessWidget {
  const DaysLeftBadge({
    required this.showDate,
    Key? key,
  }) : super(key: key);

  final DateTime showDate;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        S.of(context).daysLeft(
              max(28 - DateTime.now().difference(showDate).inDays, 0),
            ),
      ),
      labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      backgroundColor: Colors.amberAccent,
      visualDensity: VisualDensity.compact,
    );
  }
}
