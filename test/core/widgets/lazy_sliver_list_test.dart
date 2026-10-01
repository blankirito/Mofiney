import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mofiney/core/utils/lazy_sliver_list.dart';

void main() {
  testWidgets('builds only visible items from a large list', (tester) async {
    var builtItemCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: CustomScrollView(
          slivers: [
            LazySliverList(
              itemCount: 400,
              itemBuilder: (context, index) {
                builtItemCount++;

                return SizedBox(height: 72, child: Text('Transaction $index'));
              },
            ),
          ],
        ),
      ),
    );

    expect(builtItemCount, lessThan(400));
    expect(find.text('Transaction 0'), findsOneWidget);
    expect(find.text('Transaction 399'), findsNothing);
  });
}
