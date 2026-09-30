import 'package:flutter/material.dart' hide Text;
import '../core/app_state.dart';
import '../core/nav.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';
import '../data/models.dart';
import '../widgets/common.dart';
import 'contribute_screen.dart';
import '../core/i18n.dart';

class RegionsScreen extends StatefulWidget {
  const RegionsScreen({super.key});
  @override
  State<RegionsScreen> createState() => _RegionsScreenState();
}

class _RegionsScreenState extends State<RegionsScreen> {
  String _zone = allRegionsLabel;
  String _mapSel = 'Antananarivo';

  Widget _stat(String n, String l) => Expanded(
        child: Column(children: [
          Text(n, style: ts(16, w7, color: C.primary)),
          Text(l, style: ts(11, w4, color: C.onVariant)),
        ]),
      );

  Widget _card(Region r) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: CardBox(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(
                  child: Pill(r.zone,
                      bg: C.secondaryContainer, fg: C.onSecondaryContainer)),
              const Spacer(),
              Icon(Icons.verified,
                  size: 14,
                  color: r.badge == 'En cours'
                      ? C.tertiaryContainer
                      : C.secondary),
              const SizedBox(width: 4),
              Text(r.badge,
                  style: ts(11, w6,
                      color: r.badge == 'En cours'
                          ? C.tertiaryContainer
                          : C.secondary)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.name, style: ts(20, w7)),
                      Text(r.subtitle, style: ts(12, w4, color: C.onVariant)),
                    ]),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                    color: C.primaryFixed, shape: BoxShape.circle),
                child: Icon(r.icon, color: C.primary),
              ),
            ]),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  color: C.low, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                _stat('${r.words}', 'mots'),
                _stat('${r.expressions}', 'expressions'),
                _stat('${r.contributors}', 'contributeurs')
              ]),
            ),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.record_voice_over, size: 16, color: C.tertiary),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(r.quote,
                      style: ts(13, w5, color: C.onVariant)
                          .copyWith(fontStyle: FontStyle.italic))),
            ]),
            const SizedBox(height: 10),
            PBtn('Explorer',
                icon: Icons.arrow_forward,
                outlined: true,
                onTap: () => appState.openSearch(region: r.name)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final list = regions
        .where((r) => _zone == allRegionsLabel || r.zone == _zone)
        .toList();
    final sel = regions.firstWhere((r) => r.name == _mapSel);
    return Column(children: [
      const TabHeader(title: 'Régions'),
      Expanded(
        child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Row(children: [
                Text('PATRIMOINE NATIONAL VIVANT',
                    style: ts(11, w7, color: C.tertiary, ls: 1)),
                const Spacer(),
                const Pill('6 provinces',
                    bg: C.secondaryContainer,
                    fg: C.onSecondaryContainer,
                    icon: Icons.verified),
              ]),
              const SizedBox(height: 4),
              Text('Explorer Madagascar', style: ts(24, w7, ls: -.2)),
              Text(
                  'Découvrez la richesse des 6 grandes provinces et dialectes de la Grande Île.',
                  style: ts(13, w4, color: C.onVariant)),
              const SizedBox(height: 14),
              CardBox(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.pin_drop, color: C.primary),
                        const SizedBox(width: 8),
                        Text('Carte Linguistique', style: ts(16, w7)),
                        const Spacer(),
                        Text("Vue d'ensemble",
                            style: ts(11, w5, color: C.onVariant)),
                      ]),
                      const SizedBox(height: 10),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final r in [
                          ...regions
                        ]..sort((a, b) => a.order.compareTo(b.order)))
                          GestureDetector(
                            onTap: () => setState(() => _mapSel = r.name),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: r.name == _mapSel
                                    ? C.primaryContainer
                                    : C.low,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.location_on,
                                        size: 14,
                                        color: r.name == _mapSel
                                            ? Colors.white
                                            : C.primary),
                                    const SizedBox(width: 4),
                                    Text(r.name,
                                        style: ts(12, w6,
                                            color: r.name == _mapSel
                                                ? Colors.white
                                                : C.onSurface)),
                                  ]),
                            ),
                          ),
                      ]),
                      const SizedBox(height: 12),
                      ListenableBuilder(
                        listenable: appState,
                        builder: (context, _) => Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: C.low,
                              borderRadius: BorderRadius.circular(14)),
                          child: Row(children: [
                            GestureDetector(
                              onTap: () =>
                                  appState.togglePlay('preview_${sel.code}', 3),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                    color: C.primary, shape: BoxShape.circle),
                                child: Icon(
                                    appState.playingId == 'preview_${sel.code}'
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Salutation ${sel.name} : ${sel.quote}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: ts(12, w6)),
                                    Text('${sel.zone} • Écoute comparative',
                                        style: ts(11, w4, color: C.onVariant)),
                                  ]),
                            ),
                            GestureDetector(
                              onTap: appState.cycleSpeed,
                              child: Text('${appState.speed}x',
                                  style: ts(11, w7, color: C.primary)),
                            ),
                          ]),
                        ),
                      ),
                    ]),
              ),
              const SizedBox(height: 14),
              ChipsRow(
                  items: zones,
                  selected: _zone,
                  onSelect: (z) => setState(() => _zone = z)),
              const SizedBox(height: 12),
              for (final r in list) _card(r),
              const SizedBox(height: 4),
              CtaCard(
                icon: Icons.mic,
                title: "Votre parler manque à l'appel ?",
                subtitle:
                    'Aidez-nous à sauvegarder les variantes locales oubliées.',
                button: 'Ajouter un dialecte',
                onTap: () => push(context, const ContributeScreen()),
              ),
            ]),
      ),
    ]);
  }
}
