// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:myapp/main.dart';
import 'package:myapp/theme.dart';

void main() {
  testWidgets('Role selection smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: const FaceRecognitionApp(),
      ),
    );

    // Verify that our role selection screen is shown.
    expect(find.text('I am a Student'), findsOneWidget);
    expect(find.text('I am a Teacher'), findsOneWidget);
  });
}
