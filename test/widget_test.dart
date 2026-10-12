import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_dz_27092026/hw2/main.dart';

void main() {
  testWidgets('HW2 запускается', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MyApp), findsOneWidget);
  });
}