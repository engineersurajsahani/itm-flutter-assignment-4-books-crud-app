import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('BooksCrudApp launches with title and add book button', (WidgetTester tester) async {
    await tester.pumpWidget(const BooksCrudApp());

    // Verify app bar title
    expect(find.text('Books Management'), findsOneWidget);

    // Verify Add Book button exists
    expect(find.text('Add Book'), findsOneWidget);
  });
}
