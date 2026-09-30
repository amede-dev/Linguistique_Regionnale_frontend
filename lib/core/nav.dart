import 'package:flutter/material.dart';
import '../screens/main_shell.dart';
import '../screens/onboarding_screen.dart';
import 'app_state.dart';

Future<T?> push<T>(BuildContext c, Widget w) =>
    Navigator.of(c).push<T>(MaterialPageRoute(builder: (_) => w));

void replace(BuildContext c, Widget w) =>
    Navigator.of(c).pushReplacement(MaterialPageRoute(builder: (_) => w));

/// Ouvre l'application principale (barre d'onglets) et vide la pile.
void goHome(BuildContext c) {
  appState.loggedIn = true;
  appState.setTab(0);
  Navigator.of(c).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainShell()), (r) => false);
}

void goOnboarding(BuildContext c) {
  appState.logout();
  Navigator.of(c)
      .pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const OnboardingScreen()), (r) => false);
}
