import 'package:flutter/material.dart';
import 'package:dajare_app/screens/home_screen.dart';
import 'package:dajare_app/screens/collection_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens the collection from Home', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tester.ensureVisible(find.text('ダジャレ図鑑'));
    await tester.tap(find.text('ダジャレ図鑑'));
    await tester.pumpAndSettle();

    expect(find.byType(CollectionScreen), findsOneWidget);
    expect(find.text('ダジャレ図鑑'), findsOneWidget);
  });
}
