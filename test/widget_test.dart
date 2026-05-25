import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app smoke placeholder', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('Lao Beauty & Health'))));
    expect(find.text('Lao Beauty & Health'), findsOneWidget);
  });
}
