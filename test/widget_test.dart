import 'package:flutter_test/flutter_test.dart';
import 'package:adssu_click_and_sulit/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AdssuClickAndSulitApp());
    expect(find.byType(AdssuClickAndSulitApp), findsOneWidget);
  });
}
