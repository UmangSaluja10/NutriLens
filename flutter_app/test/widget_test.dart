// Basic Flutter widget test for NutriLens.
// This test simply verifies the app launches without crashing.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Just verify the app builds without throwing
    await tester.pumpWidget(const NutriLensApp());
    expect(find.byType(NutriLensApp), findsOneWidget);
  });
}