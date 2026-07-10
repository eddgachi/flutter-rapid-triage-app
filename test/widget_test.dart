import 'package:flutter_rapid_triage/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const RapidTriageApp());
    expect(find.text('RapidTriage'), findsOneWidget);
  });
}
