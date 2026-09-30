import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme.dart';
import 'screens/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: C.surface,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const TenyGasyApp());
}

class TenyGasyApp extends StatelessWidget {
  const TenyGasyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teny Gasy',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const OnboardingScreen(),
    );
  }
}
