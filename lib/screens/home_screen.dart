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
    final pearl = appState.words.isEmpty ? null : appState.words.first;
    if (pearl == null) return const Center(child: Text('Aucun contenu disponible pour le moment.'));
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
              const SizedBox(height: 18),
              Row(children: [
                const Icon(Icons.auto_awesome, size: 14, color: C.primary),
                const SizedBox(width: 4),
                Text('PERLE DU JOUR',
                    style: ts(11, w7, color: C.primary, ls: 1)),
                const Spacer(),
                Text('Mis à jour à 06:00',
                    style: ts(11, w5, color: C.onVariant)),
              ]),
              const SizedBox(height: 8),
              CardBox(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Pill('MOT DU JOUR',
                            bg: C.primaryContainer, fg: Colors.white),
                        const Spacer(),
                        Flexible(
                            child: Pill('${pearl.region} (${pearl.dialect})',
                                bg: C.secondaryContainer,
                                fg: C.onSecondaryContainer,
                                icon: Icons.location_on)),
                      ]),
                      const SizedBox(height: 12),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Expanded(
                                child: Text(pearl.term.toUpperCase(),
                                    style:
                                        ts(24, w7, color: C.primary, ls: -.2))),
                            Text(pearl.phonetic,
                                style: ts(12, w5, color: C.outline)),
                          ]),
                      const SizedBox(height: 6),
                      Text.rich(TextSpan(style: ts(14, w4), children: [
                        TextSpan(
                            text: 'Très bien, magnifique ! ',
                            style: ts(14, w7, color: C.secondary)),
                        const TextSpan(
                            text:
                                "Variante côtière orientale de l'expression commune « Tsara be », exprimant l'admiration joyeuse et cordiale."),
                      ])),
                      const SizedBox(height: 12),
                      AudioBar(id: pearl.id, seconds: pearl.seconds),
                      const SizedBox(height: 12),
                      if (pearl.example != null) UsageExample(pearl.example!, pearl.exampleFr),
                      const SizedBox(height: 12),
                      Row(children: [
                        const Icon(Icons.verified,
                            size: 16, color: C.secondary),
                        const SizedBox(width: 4),
                        Expanded(
                            child: Text('Validé par 42 locuteurs',
                                style: ts(12, w6, color: C.secondary))),
                        TextButton(
                          onPressed: () =>
                              push(context, WordDetailScreen(word: pearl)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text('Découvrir',
                                style: ts(13, w7, color: C.primary)),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward,
                                size: 16, color: C.primary),
                          ]),
                        ),
                      ]),
                    ]),
              ),
              const SizedBox(height: 22),
              Row(children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Régions Linguistiques', style: ts(18, w6)),
                        Text('Parcourez les 6 provinces et leurs parlers',
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
                              Text(r.dialects,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: ts(11, w4, color: C.onVariant)),
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
                        GestureDetector(
                          onTap: () => appState.togglePlay(w.id, w.seconds),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                                color: appState.playingId == w.id
                                    ? C.primary
                                    : C.primaryFixed,
                                shape: BoxShape.circle),
                            child: Icon(
                                appState.playingId == w.id
                                    ? Icons.pause
                                    : Icons.volume_up,
                                color: appState.playingId == w.id
                                    ? Colors.white
                                    : C.primary,
                                size: 22),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                icon: Icons.record_voice_over,
                title: 'Participez au patrimoine',
                subtitle:
                    "Connaissez-vous une variante ? Enregistrez la voix d'un aîné ou soumettez une expression typique de votre région pour enrichir l'encyclopédie sonore.",
                button: 'Proposer un mot de votre région',
                onTap: () => push(context, const ContributeScreen()),
              ),
            ]),
      ),
    ]);
  }
}
