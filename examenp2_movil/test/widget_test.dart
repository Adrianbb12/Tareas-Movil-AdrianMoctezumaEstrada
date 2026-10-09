import 'package:flutter_test/flutter_test.dart';
import 'package:examenp2_movil/main.dart';

void main() {
  testWidgets('shows Supabase setup before credentials are configured',
      (tester) async {
    await tester.pumpWidget(const MisLugaresApp());
    expect(find.text('Conecta tu proyecto Supabase'), findsOneWidget);
  });
}
