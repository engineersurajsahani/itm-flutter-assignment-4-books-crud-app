import 'package:books_crud_application/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Books app shows title and loads list', (tester) async {
    await tester.pumpWidget(const BooksApp());
    await tester.pumpAndSettle();

    expect(find.text('Fairy Tale Library'), findsOneWidget);
  });
}
