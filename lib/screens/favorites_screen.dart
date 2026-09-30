import 'package:flutter/material.dart' hide Text;
import '../core/app_state.dart';
import '../core/nav.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';
import '../widgets/common.dart';
import '../widgets/word_card.dart';
import 'contribute_screen.dart';
import '../core/i18n.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _ctrl = TextEditingController();
  String _filter = 'Tous';
  static const _filters = [
    'Tous',
    'Salutations',
    'Proverbes (Ohabolana)',
    'Par région'
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final q = _ctrl.text.trim().toLowerCase();
        var favs = words.where((w) => appState.isFav(w.id)).where((w) {
          if (q.isNotEmpty &&
              !(w.term.toLowerCase().contains(q) ||
                  w.meaning.toLowerCase().contains(q))) return false;
          if (_filter == 'Salutations' || _filter == 'Proverbes (Ohabolana)')
            return w.category == _filter;
          return true;
        }).toList();
        if (_filter == 'Par région')
          favs.sort((a, b) => a.region.compareTo(b.region));
        return Column(children: [
          const TabHeader(title: 'Favoris'),
          Expanded(
            child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Row(children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mes Favoris', style: ts(24, w7, ls: -.2)),
                            Text(
                                'Mots et expressions sauvegardés pour vos voyages',
                                style: ts(13, w4, color: C.onVariant)),
                          ]),
                    ),
                    const Icon(Icons.bookmark,
                        color: C.tertiaryContainer, size: 28),
                  ]),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ctrl,
                    onChanged: (_) => setState(() {}),
                    decoration: fieldDec(
                        'Rechercher parmi vos ${appState.favorites.length} expressions...',
                        icon: Icons.search).copyWith(border: pillBorder, enabledBorder: pillBorder),
                  ),
                  const SizedBox(height: 10),
                  ChipsRow(
                    items: [
                      'Tous (${appState.favorites.length})',
                      ..._filters.skip(1)
                    ],
                    selected: _filter == 'Tous'
                        ? 'Tous (${appState.favorites.length})'
                        : _filter,
                    onSelect: (s) => setState(
                        () => _filter = s.startsWith('Tous') ? 'Tous' : s),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: C.secondaryContainer,
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      const Icon(Icons.cloud_done,
                          color: C.onSecondaryContainer),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mode hors-ligne actif',
                                  style: ts(13, w7,
                                      color: C.onSecondaryContainer)),
                              Text(
                                  '${appState.favorites.length} mots synchronisés en local',
                                  style: ts(12, w4,
                                      color: C.onSecondaryContainer)),
                            ]),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            toast(context, 'Synchronisation terminée'),
                        icon: const Icon(Icons.sync,
                            size: 16, color: C.onSecondaryContainer),
                        label: Text('MAJ',
                            style: ts(12, w7, color: C.onSecondaryContainer)),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  CardBox(
                    color: a(C.tertiaryFixed, .5),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BELLES PAROLES',
                              style: ts(10, w7, color: C.tertiary, ls: 1)),
                          const SizedBox(height: 4),
                          Text(
                              '« Le lien fraternel est comme un fil fin : rompu, il peut se renouer. »',
                              style: ts(14, w6)
                                  .copyWith(fontStyle: FontStyle.italic)),
                        ]),
                  ),
                  const SizedBox(height: 12),
                  if (favs.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(children: [
                        const Icon(Icons.favorite_border,
                            size: 44, color: C.outline),
                        const SizedBox(height: 8),
                        Text('Aucun favori ici', style: ts(14, w6)),
                        Text("Touchez le cœur d'un mot pour le retrouver ici.",
                            style: ts(12, w4, color: C.onVariant)),
                      ]),
                    ),
                  for (final w in favs)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: WordCard(w, removable: true)),
                  CtaCard(
                    icon: Icons.mic,
                    title: 'Enrichissez la carte sonore',
                    subtitle: 'Prononcez une variante locale de vos favoris.',
                    button: 'Participer',
                    onTap: () => push(context, const ContributeScreen()),
                  ),
                ]),
          ),
        ]);
      },
    );
  }
}
