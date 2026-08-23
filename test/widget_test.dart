import 'package:flutter_test/flutter_test.dart';
import 'package:flow_state_app/app.dart';

void main() {
  testWidgets('FlowStateApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FlowStateApp());

    // Verify FlowStateApp builds without crashing.
    expect(find.byType(FlowStateApp), findsOneWidget);
  });
}
