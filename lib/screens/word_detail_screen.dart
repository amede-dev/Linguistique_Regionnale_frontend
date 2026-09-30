import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import '../core/app_state.dart';
import '../core/nav.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';
import '../data/models.dart';
import '../widgets/common.dart';
import 'contribute_screen.dart';
import '../core/i18n.dart';

class WordDetailScreen extends StatefulWidget {
  final Word word;
  const WordDetailScreen({super.key, required this.word});
  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  int? _variant; // null = toutes

  String _short(Variant v) => v.area.split('• ').last.split(' ').first;

  Widget _variantCard(Variant v) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: CardBox(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(v.area.toUpperCase(),
                style: ts(10, w7, color: C.tertiary, ls: .8)),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(
                  child: Text(v.forms, style: ts(17, w7, color: C.primary))),
              const Icon(Icons.volume_up, color: C.primary),
            ]),
            const SizedBox(height: 4),
            Text(v.text, style: ts(13, w4, color: C.onSurface)),
            const SizedBox(height: 8),
            Row(children: [
              Flexible(
                  child: Pill('Nuance : ${v.nuance}',
                      bg: C.tertiaryFixed, fg: C.tertiary)),
              const Spacer(),
              const Icon(Icons.check_circle, size: 14, color: C.secondary),
              const SizedBox(width: 4),
              Text('${v.consensus}% consensus',
                  style: ts(11, w6, color: C.secondary)),
            ]),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final w = widget.word;
    final vs = _variant == null ? w.variants : [w.variants[_variant!]];
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: C.onSurface),
        title: Text('Détail Mot', style: ts(16, w6)),
        centerTitle: true,
      ),
      body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
          children: [
            Container(
              height: 130,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                    colors: [C.primaryFixed, C.secondaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
              ),
              child: Stack(children: [
                Align(
                    alignment: Alignment.centerRight,
                    child: Icon(regionIcon(w.region),
                        size: 80, color: a(C.primaryContainer, .35))),
                Align(
                    alignment: Alignment.topLeft,
                    child: Wrap(spacing: 8, children: [
                      Pill('${w.region} (${w.dialect})',
                          bg: C.lowest,
                          fg: C.onSecondaryContainer,
                          icon: Icons.landscape),
                      const Pill('Vérifié',
                          bg: C.secondary,
                          fg: Colors.white,
                          icon: Icons.verified),
                    ])),
              ]),
            ),
            const SizedBox(height: 14),
            ListenableBuilder(
              listenable: appState,
              builder: (context, _) => Row(children: [
                Expanded(
                    child: Text('${w.category} • Interjection'.toUpperCase(),
                        style: ts(11, w7, color: C.tertiary, ls: 1))),
                IconButton(
                  onPressed: () => appState.toggleFav(w.id),
                  icon: Icon(
                      appState.isFav(w.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: appState.isFav(w.id)
                          ? C.primaryContainer
                          : C.outline),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: w.term));
                    toast(context, '« ${w.term} » copié');
                  },
                  icon: const Icon(Icons.content_copy,
                      color: C.outline, size: 20),
                ),
              ]),
            ),
            if (w.phonetic.isNotEmpty)
              Text(w.phonetic, style: ts(13, w5, color: C.outline, ls: .4)),
            Text(w.term.toUpperCase(),
                style: ts(34, w7, color: C.primary, ls: -.5, height: 1.15)),
            const SizedBox(height: 8),
            Text(w.meaning, style: ts(15, w4)),
            const SizedBox(height: 14),
            CardBox(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.record_voice_over,
                          size: 16, color: C.secondary),
                      const SizedBox(width: 6),
                      Expanded(
                          child: Text('Voix native • ${w.region}',
                              style: ts(12, w7, color: C.secondary))),
                    ]),
                    Text(w.note, style: ts(12, w4, color: C.onVariant)),
                    const SizedBox(height: 10),
                    AudioBar(id: w.id, seconds: w.seconds),
                    const SizedBox(height: 10),
                    Row(children: [
                      const Icon(Icons.location_on, size: 16, color: C.primary),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text('${w.dialect} • Berceau de l\'expression',
                              style: ts(12, w5, color: C.onVariant))),
                    ]),
                  ]),
            ),
            if (w.example != null) ...[
              const SizedBox(height: 14),
              UsageExample(w.example!, w.exampleFr),
            ],
            if (w.variants.isNotEmpty) ...[
              const SizedBox(height: 22),
              Row(children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Variantes Régionales', style: ts(18, w6)),
                        Text(
                            '${w.variants.length} aires linguistiques majeures',
                            style: ts(12, w4, color: C.onVariant)),
                      ]),
                ),
                Text('ATLAS VIVANT',
                    style: ts(10, w7, color: C.tertiary, ls: 1)),
              ]),
              const SizedBox(height: 10),
              ChipsRow(
                items: [
                  'Toutes (${w.variants.length})',
                  ...w.variants.map(_short)
                ],
                selected: _variant == null
                    ? 'Toutes (${w.variants.length})'
                    : _short(w.variants[_variant!]),
                onSelect: (s) => setState(() => _variant =
                    s.startsWith('Toutes')
                        ? null
                        : w.variants.indexWhere((v) => _short(v) == s)),
              ),
              const SizedBox(height: 12),
              for (final v in vs) _variantCard(v),
            ],
            if (w.etymology != null) ...[
              const SizedBox(height: 12),
              CardBox(
                color: C.container,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.menu_book, color: C.primary),
                        const SizedBox(width: 8),
                        Text('Analyse Linguistique', style: ts(16, w7)),
                      ]),
                      const SizedBox(height: 10),
                      Text('Étymologie austronésienne',
                          style: ts(13, w7, color: C.secondary)),
                      Text(w.etymology!, style: ts(13, w4)),
                      const SizedBox(height: 10),
                      Text('Niveau de langue',
                          style: ts(13, w7, color: C.secondary)),
                      Text('Polyvalent (courant & soutenu)', style: ts(13, w4)),
                    ]),
              ),
            ],
            const SizedBox(height: 18),
            PBtn('Proposer une variante pour ma région',
                icon: Icons.add_circle_outline,
                onTap: () => push(context, const ContributeScreen())),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: () =>
                    toast(context, 'Merci ! Signalement enregistré'),
                icon: const Icon(Icons.flag_outlined,
                    size: 18, color: C.onVariant),
                label: Text('Signaler une inexactitude phonétique',
                    style: ts(12, w6, color: C.onVariant)),
              ),
            ),
          ]),
    );
  }
}
