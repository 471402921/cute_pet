import 'package:cute_pet/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home page shows greeting', (tester) async {
    await tester.pumpWidget(const CutePetApp());
    await tester.pumpAndSettle();
    expect(find.text('Hello, cute pet!'), findsOneWidget);
    expect(find.text('Cheer'), findsOneWidget);
    expect(find.text('Meet the pet'), findsOneWidget);
  });
}
