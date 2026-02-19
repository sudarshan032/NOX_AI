// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

import 'package:nox_ai/app.dart';

void main() {
  testWidgets('Splash screen 1 renders', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Hello!'), findsOneWidget);
    expect(find.text('Your AI is booting up...'), findsOneWidget);

    final richTextFinder = find.byWidgetPredicate((widget) {
      if (widget is! RichText) return false;
      final text = widget.text.toPlainText();
      return text.contains('NOX') && text.contains('AI');
    });
    expect(richTextFinder, findsOneWidget);
  });
}
