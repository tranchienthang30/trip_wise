import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:trip_wise/demo/demo_main.dart';

void main() {
  testWidgets('Demo app shows Demo Items title', (WidgetTester tester) async {
    await tester.pumpWidget(const DemoApp());
    await tester.pumpAndSettle();

    expect(find.text('Demo Items'), findsOneWidget);
  });
}
