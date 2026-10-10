import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/core/utils/failure.dart';
import 'package:shop_app/features/auth/presentation/auth_controller.dart';
import 'package:shop_app/features/auth/presentation/login_page.dart';

import '../fakes.dart';
import '../pump_app.dart';

void main() {
  Future<void> pumpLogin(
    WidgetTester tester, {
    FakeAuthRepository? repository,
    Locale locale = const Locale('en'),
  }) {
    final auth = AuthController(repository ?? FakeAuthRepository());
    return pumpApp(
      tester,
      const LoginPage(),
      locale: locale,
      providers: [ChangeNotifierProvider<AuthController>.value(value: auth)],
    );
  }

  testWidgets('affiche les erreurs de validation (email + mot de passe)', (tester) async {
    await pumpLogin(tester);

    await tester.enterText(find.byKey(const Key('email')), 'not-an-email');
    await tester.tap(find.byKey(const Key('submit')));
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('At least 4 characters'), findsOneWidget);
  });

  testWidgets('bascule vers l\'inscription : champ Nom + nouveau titre', (tester) async {
    await pumpLogin(tester);
    expect(find.byType(TextFormField), findsNWidgets(2));

    await tester.tap(find.text('No account yet? Sign up'));
    await tester.pump();

    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.text('Create your account'), findsOneWidget);
  });

  testWidgets('identifiants refusés : message localisé affiché', (tester) async {
    await pumpLogin(
      tester,
      repository: FakeAuthRepository(
        loginError: const Failure('x', type: FailureType.invalidCredentials),
      ),
    );

    await tester.enterText(find.byKey(const Key('email')), 'john@mail.com');
    await tester.enterText(find.byKey(const Key('password')), 'wrong-pass');
    await tester.tap(find.byKey(const Key('submit')));
    await tester.pumpAndSettle();

    expect(find.text('Incorrect email or password.'), findsOneWidget);
  });

  testWidgets('le bouton œil affiche / masque le mot de passe', (tester) async {
    await pumpLogin(tester);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();

    expect(find.byTooltip('Hide password'), findsOneWidget);
  });
}
