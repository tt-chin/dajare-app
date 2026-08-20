import 'package:dajare_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the app title', (WidgetTester tester) async {
    await tester.pumpWidget(const DajareApp());

    expect(find.text('ダジャレアプリ'), findsOneWidget);
  });
}
