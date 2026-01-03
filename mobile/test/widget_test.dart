import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/app.dart';

void main() {
  testWidgets('App builds correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const TasklyApp());
    await tester.pumpAndSettle();
  });
}
