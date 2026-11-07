import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uts_pam/screens/login_screen.dart';
import 'package:uts_pam/services/app_state.dart';

void main() {
  testWidgets('login memvalidasi input dan menerima akun demo', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final AppState appState = AppState();
    await appState.init();

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      AppStateScope(
        state: appState,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    // Validasi field kosong.
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pump();
    expect(find.text('Username wajib diisi.'), findsOneWidget);
    expect(find.text('Password wajib diisi.'), findsOneWidget);

    // Password salah harus menampilkan pesan error.
    await tester.enterText(find.byKey(const Key('usernameField')), 'admin');
    await tester.enterText(find.byKey(const Key('passwordField')), 'salah');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pump();
    expect(
      find.text('Username atau password salah. Silakan coba lagi.'),
      findsOneWidget,
    );

    // Akun demo harus berhasil masuk ke dashboard.
    await tester.enterText(find.byKey(const Key('passwordField')), '123456');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Selamat datang,'), findsOneWidget);
    expect(appState.isLoggedIn, isTrue);
  });
}
