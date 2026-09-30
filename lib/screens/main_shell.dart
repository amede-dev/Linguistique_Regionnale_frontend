import 'package:flutter/material.dart' hide Text;
import '../core/app_state.dart';
import '../core/i18n.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'regions_screen.dart';
import 'search_screen.dart';

/// Coquille de l'application avec barre de navigation à 5 onglets.
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) => Scaffold(
        body: SafeArea(
          bottom: false,
          child: IndexedStack(index: appState.tab, children: const [
            HomeScreen(),
            SearchScreen(),
            RegionsScreen(),
            FavoritesScreen(),
            ProfileScreen(),
          ]),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: appState.tab,
          onDestinationSelected: appState.setTab,
          destinations: [
            NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: tr('Accueil')),
            NavigationDestination(
                icon: const Icon(Icons.search), label: tr('Recherche')),
            NavigationDestination(
                icon: const Icon(Icons.explore_outlined),
                selectedIcon: const Icon(Icons.explore),
                label: tr('Régions')),
            NavigationDestination(
                icon: const Icon(Icons.favorite_border),
                selectedIcon: const Icon(Icons.favorite),
                label: tr('Favoris')),
            NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: tr('Profil')),
          ],
        ),
      ),
    );
  }
}
