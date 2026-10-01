import 'package:flutter/widgets.dart';

class LazySliverList extends StatelessWidget {
  const LazySliverList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(itemCount: itemCount, itemBuilder: itemBuilder);
  }
}
