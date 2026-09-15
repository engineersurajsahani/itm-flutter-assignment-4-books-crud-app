import 'package:flutter_test/flutter_test.dart';
import 'package:book_crud_app/main.dart';

void main() {
  testWidgets('BooksApp builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BooksApp());
    expect(find.byType(BooksApp), findsOneWidget);
  });
}
