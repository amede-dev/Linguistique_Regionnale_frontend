import 'package:flutter_test/flutter_test.dart';
import 'package:linguistique_regionnale/core/app_state.dart';
import 'package:linguistique_regionnale/data/mock_data.dart';

void main() {
  test('toggleFav ajoute puis retire un favori', () {
    final s = AppState();
    final before = s.favorites.length;
    s.toggleFav('veloma');
    expect(s.isFav('veloma'), true);
    expect(s.favorites.length, before + 1);
    s.toggleFav('veloma');
    expect(s.isFav('veloma'), false);
  });

  test('openSearch bascule sur l\'onglet Recherche avec la région', () {
    final s = AppState();
    s.openSearch(region: 'Toliara');
    expect(s.tab, 1);
    expect(s.searchRegion, 'Toliara');
  });

  test('les données de démonstration sont cohérentes', () {
    expect(regions.length, 6);
    expect(wordById('veloma').variants.length, 4);
    for (final w in words) {
      expect(regions.any((r) => r.name == w.region), true, reason: w.id);
    }
  });
}
