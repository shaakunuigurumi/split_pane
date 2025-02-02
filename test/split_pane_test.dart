import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:split_pane/split_pane.dart';

void main() {
  testWidgets('Panes are equal width on 50%', (widgetTester) async {
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

    var primarySize = widgetTester.getSize(find.byKey(primaryKey));
    var secondarySize = widgetTester.getSize(find.byKey(secondaryKey));

    expect(primarySize, secondarySize);
  });

  testWidgets('Panes are correctly laid out on 25%', (widgetTester) async {
    final controller = SplitController(vsync: widgetTester, position: .25);

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

    final remainingSize =
        splitPaneSize.width - primarySize.width - secondarySize.width;

    expect(remainingSize, lessThanOrEqualTo(24.0));
    expect(primarySize, isNot(secondarySize));
    expect(secondarySize.width, lessThan(primarySize.width));
  });
}
