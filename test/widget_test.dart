import 'package:flutter_test/flutter_test.dart';

import 'package:redes_exposicion/main.dart';

void main() {
  testWidgets('app loads the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const RedesApp());

    expect(find.text('Redes: API REST y conectividad'), findsOneWidget);
    expect(find.text('Cargar datos'), findsOneWidget);
  });
}
