import 'package:dajare_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the home actions', (WidgetTester tester) async {
    await tester.pumpWidget(const DajareApp());

    expect(find.text('ダジャレアプリ'), findsOneWidget);
    expect(find.text('ダジャレを入力する'), findsOneWidget);
    expect(find.text('今日のお題'), findsOneWidget);
    expect(find.text('ダジャレ図鑑'), findsOneWidget);
  });

  testWidgets('shows a friendly message for an upcoming action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DajareApp());

    await tester.tap(find.text('ダジャレを入力する'));
    await tester.pump();

    expect(find.text('じゅんび中だよ！'), findsOneWidget);
  });
}
