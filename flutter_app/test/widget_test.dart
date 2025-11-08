// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/main.dart';

void main() {
  testWidgets('Muestra textos en español en AppBar', (tester) async {
    await tester.pumpWidget(const AppBarApp());

    // Verifica que el título en español esté presente
    expect(find.text('Demostración de AppBar'), findsOneWidget);

    // Verifica que exista el botón para color de sombra
    expect(find.text('color de sombra'), findsOneWidget);

    // Verifica que el mensaje inicial esté visible
    expect(find.textContaining('Desplázate'), findsOneWidget);
  });
}
