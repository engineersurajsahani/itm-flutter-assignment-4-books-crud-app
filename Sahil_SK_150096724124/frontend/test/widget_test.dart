import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  test('uses local backend port 5001 by default', () {
    expect(BooksApi().baseUrl, 'http://localhost:5001/api/books');
  });

  testWidgets('shows books screen', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Books'), findsOneWidget);
    expect(find.text('Add Book'), findsOneWidget);
  });
}
