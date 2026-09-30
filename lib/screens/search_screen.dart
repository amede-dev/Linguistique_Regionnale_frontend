import 'package:flutter/material.dart' hide Text;
import '../core/app_state.dart';
import '../core/nav.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../widgets/common.dart';
import '../widgets/word_card.dart';
import 'contribute_screen.dart';
import '../core/i18n.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  static const _types = [
    'Tous types',
    'Expressions',
    'Mots isolés',
    'Proverbes (Ohabolana)'
  ];
  static const _sorts = ['Pertinence', 'Région (Nord à Sud)', 'Popularité'];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<Word> _results() {
    final q = _ctrl.text.trim().toLowerCase();
    final list = appState.words.where((w) {
      final okRegion = appState.searchRegion == appState.allRegionsLabel ||
          w.region == appState.searchRegion;
      final okType =
          appState.searchType == 'Tous types' || w.type == appState.searchType;
      final okQ = q.isEmpty ||
          w.term.toLowerCase().contains(q) ||
          w.meaning.toLowerCase().contains(q) ||
          w.dialect.toLowerCase().contains(q) ||
          w.region.toLowerCase().contains(q);
      return okRegion && okType && okQ;
    }).toList();
    switch (appState.sort) {
      case 'Région (Nord à Sud)':
        list.sort(
            (a, b) => appState.regionOrder(a.region).compareTo(appState.regionOrder(b.region)));
        break;
      case 'Popularité':
        list.sort((a, b) => b.popularity.compareTo(a.popularity));
        break;
      default:
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final res = _results();
        return Column(children: [
          const TabHeader(title: 'Rechercher'),
          Expanded(
            child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Row(children: [
                    const Icon(Icons.auto_awesome, size: 14, color: C.primary),
                    const SizedBox(width: 4),
                    Text('RECHERCHE DU DICTIONNAIRE',
                        style: ts(11, w7, color: C.primary, ls: 1)),
                  ]),
                  const SizedBox(height: 4),
                  Text('Que recherchez-vous ?', style: ts(24, w7, ls: -.2)),
                  Text('Recherchez par mot, signification ou région',
                      style: ts(13, w4, color: C.onVariant)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ctrl,
                    onChanged: (_) => setState(() {}),
                    decoration: fieldDec(
                        'Rechercher un mot, une expression ou une signification...',
                        icon: Icons.search).copyWith(border: pillBorder, enabledBorder: pillBorder),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: C.secondaryContainer,
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.psychology,
                              color: C.onSecondaryContainer),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Recherche par signification active',
                                      style: ts(13, w7,
                                          color: C.onSecondaryContainer)),
                                  Text(
                                      'Tapez par ex. « Comment dit-on merci dans le Nord ? » ou décrivez une situation vécue.',
                                      style: ts(12, w4,
                                          color: C.onSecondaryContainer)),
                                ]),
                          ),
                        ]),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    Text('Régions linguistiques', style: ts(14, w7)),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        _ctrl.clear();
                        appState.setSearchRegion(appState.allRegionsLabel);
                        appState.setSearchType('Tous types');
                      },
                      child: Text('Réinitialiser',
                          style: ts(12, w6, color: C.primary)),
                    ),
                  ]),
                  ChipsRow(
                    items: [appState.allRegionsLabel, ...appState.regions.map((r) => r.name)],
                    selected: appState.searchRegion,
                    onSelect: appState.setSearchRegion,
                  ),
                  const SizedBox(height: 8),
                  ChipsRow(
                      items: _types,
                      selected: appState.searchType,
                      onSelect: appState.setSearchType),
                  const SizedBox(height: 12),
                  Row(children: [
                    Text('${res.length}', style: ts(14, w7, color: C.primary)),
                    Text(' résultats trouvés',
                        style: ts(13, w4, color: C.onVariant)),
                    const Spacer(),
                    PopupMenuButton<String>(
                      onSelected: appState.setSort,
                      color: C.lowest,
                      itemBuilder: (_) => [
                        for (final s in _sorts)
                          PopupMenuItem(
                              value: s, child: Text(s, style: ts(13, w5)))
                      ],
                      child: Row(children: [
                        Text('Tri : ', style: ts(12, w4, color: C.onVariant)),
                        Text(appState.sort,
                            style: ts(12, w7, color: C.primary)),
                        const Icon(Icons.expand_more,
                            size: 18, color: C.primary),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  if (res.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(children: [
                        const Icon(Icons.search_off,
                            size: 44, color: C.outline),
                        const SizedBox(height: 8),
                        Text('Aucun résultat pour cette recherche',
                            style: ts(14, w6)),
                        Text('Essayez un autre mot ou une autre région.',
                            style: ts(12, w4, color: C.onVariant)),
                      ]),
                    ),
                  for (final w in res)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: WordCard(w)),
                  const SizedBox(height: 8),
                  CardBox(
                    color: C.container,
                    child: Row(children: [
                      const Icon(Icons.mic_none, color: C.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Votre dialecte manque ?',
                                  style: ts(14, w7)),
                              Text(
                                  'Contribuez en enregistrant un mot de votre région.',
                                  style: ts(12, w4, color: C.onVariant)),
                            ]),
                      ),
                      FilledButton(
                        onPressed: () =>
                            push(context, const ContributeScreen()),
                        style: FilledButton.styleFrom(
                            backgroundColor: C.primaryContainer,
                            shape: const StadiumBorder()),
                        child: Text('Contribuer',
                            style: ts(12, w7, color: Colors.white)),
                      ),
                    ]),
                  ),
                ]),
          ),
        ]);
      },
    );
  }
}
