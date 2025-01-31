import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:split_pane/split_pane.dart';

void main() {
  testWidgets('Fraction is correctly laid out', (widgetTester) async {
    final controller = SplitController(vsync: widgetTester);

    final primaryKey = ValueKey(1);
    final secondaryKey = ValueKey(2);

    await widgetTester.pumpWidget(
      SplitPane(
        controller: controller,
        primary: SizedBox.expand(key: primaryKey),
        secondary: SizedBox.expand(key: secondaryKey),
      ),
    );

    final splitPaneSize = widgetTester.getSize(find.byType(SplitPane));

    var primarySize = widgetTester.getSize(find.byKey(primaryKey));
    var secondarySize = widgetTester.getSize(find.byKey(secondaryKey));

    expect(primarySize, secondarySize);

    controller.setToFraction(0.25);

    await widgetTester.pump();

    primarySize = widgetTester.getSize(find.byKey(primaryKey));
    secondarySize = widgetTester.getSize(find.byKey(secondaryKey));

    final remainingSize =
        splitPaneSize.width - primarySize.width - secondarySize.width;

    expect(remainingSize, lessThanOrEqualTo(24.0));
    expect(primarySize, isNot(secondarySize));
    expect(secondarySize.width, lessThan(primarySize.width));
  });
}
