import 'package:flutter_test/flutter_test.dart';
import 'package:books_crud_application/main.dart';

void main() {
  testWidgets('App shows book app title', (tester) async {
    await tester.pumpWidget(const BooksApp());
    await tester.pumpAndSettle();

    expect(find.text('Books CRUD Application'), findsOneWidget);
  });
}
