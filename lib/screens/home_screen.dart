import 'package:flutter/material.dart' hide Text;
import '../core/app_state.dart';
import '../core/nav.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'contribute_screen.dart';
import 'word_detail_screen.dart';
import '../core/i18n.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _cat = 'Tous';
  static const _cats = [
    'Tous',
    'Salutations',
    'Proverbes (Ohabolana)',
    'Famille & Respect'
  ];

  @override
  Widget build(BuildContext context) {
    final trending = appState.words
        .where((w) => w.trending && (_cat == 'Tous' || w.category == _cat))
        .toList();
    return Column(children: [
      const TabHeader(title: 'Accueil'),
      Expanded(
        child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Row(children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bonjour 👋', style: ts(24, w7, ls: -.2)),
                        Text('Explorez les trésors dialectaux de Madagascar',
                            style: ts(13, w4, color: C.onVariant)),
                      ]),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                      color: C.secondaryContainer, shape: BoxShape.circle),
                  child: const Icon(Icons.translate,
                      size: 20, color: C.onSecondaryContainer),
                ),
              ]),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => appState.openSearch(),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.only(left: 14, right: 8),
                  decoration: BoxDecoration(
                    color: C.lowest,
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x0F000000),
                          blurRadius: 8,
                          offset: Offset(0, 2))
                    ],
                  ),
                  child: Row(children: [
                    const Icon(Icons.search, color: C.outline),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text('Rechercher un mot, proverbe, région…',
                            overflow: TextOverflow.ellipsis,
                            style: ts(13, w4, color: C.outline))),
                  ]),
                ),
              ),
              const SizedBox(height: 22),
              Row(children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Régions Linguistiques', style: ts(18, w6)),
                        Text(
                            'Parcourez les 23 régions administratives et leurs parlers',
                            style: ts(12, w4, color: C.onVariant)),
                      ]),
                ),
                TextButton(
                  onPressed: () => appState.setTab(2),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Tout voir', style: ts(12, w7, color: C.primary)),
                    const Icon(Icons.chevron_right, size: 18, color: C.primary),
                  ]),
                ),
              ]),
              const SizedBox(height: 8),
              SizedBox(
                height: 148,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: appState.regions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final r = appState.regions[i];
                    return GestureDetector(
                      onTap: () => appState.openSearch(region: r.name),
                      child: Container(
                        width: 176,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: C.lowest,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0x0F000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2))
                            ]),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                CircleAvatar(
                                    radius: 18,
                                    backgroundColor: C.primaryFixed,
                                    child: Text(r.code,
                                        style: ts(12, w7, color: C.primary))),
                                const Spacer(),
                                Text('${r.words} mots',
                                    style: ts(11, w6, color: C.secondary)),
                                const SizedBox(width: 4),
                                const Icon(Icons.north_east,
                                    size: 14, color: C.outline),
                              ]),
                              const Spacer(),
                              Text(r.name, style: ts(15, w7)),
                              Text(r.words > 0
                                      ? (r.dialects.isEmpty
                                          ? 'Dialecte documenté'
                                          : r.dialects)
                                      : 'Données en cours de documentation',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: ts(11, w4,
                                      color: r.words > 0
                                          ? C.onVariant
                                          : C.tertiary)),
                              const SizedBox(height: 4),
                              Text('${r.dialectCount} dialectes',
                                  style: ts(11, w6, color: C.tertiary)),
                            ]),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 22),
              Row(children: [
                const Icon(Icons.trending_up, color: C.primary),
                const SizedBox(width: 8),
                Text('Mots Tendance', style: ts(18, w6)),
                const Spacer(),
                Text('Cette semaine', style: ts(11, w5, color: C.onVariant)),
              ]),
              const SizedBox(height: 10),
              ChipsRow(
                  items: _cats,
                  selected: _cat,
                  onSelect: (c) => setState(() => _cat = c)),
              const SizedBox(height: 10),
              if (trending.isEmpty)
                Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                        child: Text('Aucun mot tendance dans cette catégorie.',
                            style: ts(13, w4, color: C.onVariant)))),
              for (final w in trending)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ListenableBuilder(
                    listenable: appState,
                    builder: (context, _) => CardBox(
                      padding: const EdgeInsets.all(12),
                      onTap: () => push(context, WordDetailScreen(word: w)),
                      child: Row(children: [
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Flexible(
                                      flex: 3,
                                      child: Text(w.term,
                                          overflow: TextOverflow.ellipsis,
                                          style: ts(16, w7))),
                                  const SizedBox(width: 8),
                                  Flexible(
                                      flex: 2,
                                      child: Pill(w.dialect,
                                          bg: C.tertiaryFixed, fg: C.tertiary)),
                                ]),
                                Text(w.meaning,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: ts(12, w4, color: C.onVariant)),
                              ]),
                        ),
                        IconButton(
                          onPressed: () => appState.toggleFav(w.id),
                          icon: Icon(
                              appState.isFav(w.id)
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: appState.isFav(w.id)
                                  ? C.tertiaryContainer
                                  : C.outline),
                        ),
                      ]),
                    ),
                  ),
                ),
              const SizedBox(height: 14),
              CtaCard(
                icon: Icons.add_circle_outline,
                title: 'Participez au patrimoine',
                subtitle:
                    "Connaissez-vous un mot ou une expression de votre région ? Partagez-la avec la communauté.",
                button: 'Proposer un mot de votre région',
                onTap: () => push(context, const ContributeScreen()),
              ),
            ]),
      ),
    ]);
  }
}
