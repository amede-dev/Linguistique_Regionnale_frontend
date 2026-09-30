import 'package:flutter_test/flutter_test.dart';
import 'package:linguistique_regionnale/core/app_state.dart';

void main() {
  test('un nouvel état ne contient aucun favori fictif', () {
    final s = AppState();
    expect(s.favorites, isEmpty);
    expect(s.userEmail, isEmpty);
    expect(s.words, isEmpty);
    expect(s.regions, isEmpty);
  });

  test('openSearch bascule sur l’onglet Recherche avec la région', () {
    final s = AppState();
    s.openSearch(region: 'Toliara');
    expect(s.tab, 1);
    expect(s.searchRegion, 'Toliara');
  });
}
