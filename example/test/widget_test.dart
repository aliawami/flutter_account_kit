import 'package:flutter/material.dart';
import 'package:flutter_account_kit/flutter_account_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:example/fake_backend.dart';
import 'package:example/main.dart';

Widget _app() {
  final auth = FakeAuthRepository();
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(auth),
      profileRepositoryProvider.overrideWithValue(FakeProfileRepository(auth)),
    ],
    child: const DemoApp(),
  );
}

void main() {
  testWidgets('signed-out users see the landing page', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Account Kit Demo'), findsOneWidget);
    expect(find.text('Continue with phone (OTP)'), findsOneWidget);
    expect(find.text('Continue with email'), findsOneWidget);
  });

  testWidgets('email sign-in reaches the home page', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue with email'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'me@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.byType(FilledButton));
    await tester.pump(); // start request
    await tester.pump(const Duration(seconds: 1)); // fake latency
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('me@example.com'), findsOneWidget);
  });
}
