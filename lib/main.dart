import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme.dart';
import 'core/app_state.dart';
import 'screens/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: C.surface,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  appState.loadCatalog();
  runApp(const LinguistiqueRegionnaleApp());
}

class LinguistiqueRegionnaleApp extends StatelessWidget {
  const LinguistiqueRegionnaleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Linguistique Régionale',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const OnboardingScreen(),
    );
  }
}
