import 'package:flutter_test/flutter_test.dart';
import 'package:books_crud_app/main.dart';

void main() {
  testWidgets('BooksCrudApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BooksCrudApp());

    // Verify that the title is present
    expect(find.text('Books Inventory'), findsOneWidget);
  });
}
