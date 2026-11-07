import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/splash_screen.dart';
import 'services/app_state.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppState appState = AppState();
  await appState.init();

  runApp(StudentApp(appState: appState));
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      state: appState,
      child: MaterialApp(
        title: 'StudentApp',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: const Locale('id', 'ID'),
        supportedLocales: const <Locale>[
          Locale('id', 'ID'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const SplashScreen(),
      ),
    );
  }
}
