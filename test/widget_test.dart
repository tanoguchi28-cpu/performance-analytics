import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:performance_analytics/app.dart';

void main() {
  testWidgets('アプリ起動時にオンボーディング画面が表示される', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: PerformanceAnalyticsApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('ようこそ'), findsOneWidget);
  });
}
