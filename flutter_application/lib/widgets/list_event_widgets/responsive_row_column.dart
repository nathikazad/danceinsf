import 'package:flutter/material.dart';

class ResponsiveRowColumn extends StatelessWidget {
  final Widget firstChild;
  final Widget secondChild;
  final BoxConstraints constraints;

  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final EdgeInsets padding;

  const ResponsiveRowColumn({
    super.key,
    required this.firstChild,
    required this.secondChild,
    required this.constraints,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPhoneScreen = constraints.maxWidth < 600;
    print("the size of screen is phone ${isPhoneScreen}");

    return Padding(
      padding: padding,
      child: isPhoneScreen
          ? Column(
              mainAxisAlignment: mainAxisAlignment,
              crossAxisAlignment: crossAxisAlignment,
              mainAxisSize: mainAxisSize,
              children: [firstChild, secondChild],
            )
          : Row(
              mainAxisAlignment: mainAxisAlignment,
              crossAxisAlignment: crossAxisAlignment,
              mainAxisSize: mainAxisSize,
              children: [firstChild, secondChild],
            ),
    );
  }
}
