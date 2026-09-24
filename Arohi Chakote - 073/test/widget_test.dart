import 'package:flutter_test/flutter_test.dart';
import 'package:books_crud_app/main.dart';

void main() {
  testWidgets('Books app smoke test - verify initial screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // Verify that the title 'Books Library' is present.
    expect(find.text('Books Library'), findsOneWidget);
  });
}
