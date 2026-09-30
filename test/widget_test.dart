import 'package:flutter_test/flutter_test.dart';
import 'package:linguistique_regionnale/main.dart';

void main() {
  testWidgets('L’application démarre correctement', (tester) async {
    await tester.pumpWidget(const LinguistiqueRegionnaleApp());

    expect(find.byType(LinguistiqueRegionnaleApp), findsOneWidget);
  });
}
