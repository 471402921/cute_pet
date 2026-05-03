import 'package:cute_pixel/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home page renders English greeting and meet-the-pet button', (
    tester,
  ) async {
    await tester.pumpWidget(const CutePetApp());
    await tester.pumpAndSettle();

    expect(find.text('Cute Pet'), findsWidgets);
    expect(find.text('Hello, cute pet!'), findsOneWidget);
    expect(find.text('Meet the pet'), findsOneWidget);
  });
}
