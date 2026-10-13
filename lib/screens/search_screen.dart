import 'package:flutter/material.dart' hide Text;
import 'package:flutter/material.dart' as m show Text;
import 'package:dio/dio.dart';
import '../core/app_state.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../widgets/common.dart';
import '../widgets/word_card.dart';
import '../core/i18n.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  bool _aiBusy = false;
  String? _aiAnswer;
  bool _aiCached = false;
  static const _types = [
    'Tous types',
    'Expressions',
    'Mots isolés',
    'Proverbes (Ohabolana)'
  ];
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _askAi() async {
    final question = _ctrl.text.trim();
    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saisissez une question pour l’IA.')));
      return;
    }
    setState(() => _aiBusy = true);
    try {
      final result = await appState.askAi(question,
          region: appState.searchRegion == appState.allRegionsLabel
              ? null
              : appState.searchRegion,
          language: appState.language);
      // L'IA peut maintenant créer automatiquement le mot et ses variantes.
      // Recharge le catalogue pour les rendre visibles sans redémarrer l'app.
      await appState.loadCatalog();
      if (mounted) {
        setState(() {
          _aiAnswer = '${result['answer'] ?? ''}';
          _aiCached = result['cached'] == true;
        });
      }
    } on DioException catch (e) {
      if (mounted) {
        final message = e.response?.data is Map
            ? '${(e.response!.data as Map)['message'] ?? 'Service IA indisponible'}'
            : 'Service IA indisponible';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _aiBusy = false);
    }
  }

  Future<void> _submitSearch() async {
    if (_ctrl.text.trim().isEmpty) {
      setState(() => _aiAnswer = null);
      return;
    }

    // Les résultats locaux sont prioritaires. L'IA intervient seulement
    // lorsque le dictionnaire ne contient aucun résultat correspondant.
    if (_results().isEmpty && !_aiBusy) {
      await _askAi();
    } else {
      setState(() {});
    }
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
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _submitSearch(),
                    onChanged: (_) => setState(() {
                      _aiAnswer = null;
                    }),
                    decoration: fieldDec(
                            'Rechercher un mot, une expression ou une signification...',
                            icon: Icons.search)
                        .copyWith(
                            border: pillBorder,
                            enabledBorder: pillBorder,
                            suffixIcon: _ctrl.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Effacer',
                                    onPressed: () {
                                      _ctrl.clear();
                                      setState(() {
                                        _aiAnswer = null;
                                        _aiCached = false;
                                      });
                                    },
                                    icon: const Icon(Icons.close))),
                  ),
                  if (_aiAnswer != null) ...[
                    const SizedBox(height: 10),
                    CardBox(
                      color: C.secondaryContainer,
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
                                Text(
                                    _aiCached
                                        ? 'Réponse mémorisée'
                                        : 'Réponse de l’IA',
                                    style: ts(13, w7,
                                        color: C.onSecondaryContainer)),
                                const SizedBox(height: 4),
                                m.Text(malagasyContent(_aiAnswer!),
                                    style: ts(13, w4,
                                        color: C.onSecondaryContainer)),
                                const SizedBox(height: 5),
                                Text('Réponse à vérifier avant publication.',
                                    style: ts(11, w5,
                                        color: C.onSecondaryContainer)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                                      'Appuyez sur Entrée pour rechercher. Si aucun résultat n’est trouvé, l’IA proposera une réponse.',
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
                        setState(() {
                          _aiAnswer = null;
                          _aiCached = false;
                        });
                        appState.setSearchRegion(appState.allRegionsLabel);
                        appState.setSearchType('Tous types');
                      },
                      child: Text('Réinitialiser',
                          style: ts(12, w6, color: C.primary)),
                    ),
                  ]),
                  ChipsRow(
                    items: [
                      appState.allRegionsLabel,
                      ...appState.regions.map((r) => r.name)
                    ],
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
                    if (_aiAnswer != null) ...[
                      Text('Réponse IA',
                          style: ts(13, w7, color: C.primary)),
                      if (res.isEmpty)
                        Text(' — aucun résultat local',
                            style: ts(13, w4, color: C.onVariant)),
                    ] else ...[
                      Text('${res.length}',
                          style: ts(14, w7, color: C.primary)),
                      Text(' résultats trouvés',
                          style: ts(13, w4, color: C.onVariant)),
                    ],
                  ]),
                  const SizedBox(height: 10),
                  if (res.isEmpty && _aiAnswer == null)
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
                ]),
          ),
        ]);
      },
    );
  }
}
