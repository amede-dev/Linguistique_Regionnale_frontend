import 'package:flutter_test/flutter_test.dart';
import 'package:teny_gasy/main.dart';

void main() {
  testWidgets('L’application démarre correctement', (tester) async {
    await tester.pumpWidget(const TenyGasyApp());

    expect(find.byType(TenyGasyApp), findsOneWidget);
  });
}
