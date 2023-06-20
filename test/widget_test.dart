import 'package:corider/providers/user_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:corider/main.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Test', (WidgetTester tester) async {
    final userState = UserState(null, []);
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider<UserState>.value(
        value: userState,
        child: MyApp(
          userState: userState,
        ),
      ),
    );
    expect(find.text('LOGIN'), findsOneWidget);

    await tester.tap(find.text('LOGIN'));
    await tester.pump(const Duration(seconds: 2));
  });
}
