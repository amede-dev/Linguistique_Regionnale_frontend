import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../data/api/api_client.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'package:dio/dio.dart';

class ContributeScreen extends StatefulWidget {
  const ContributeScreen({super.key});
  @override
  State<ContributeScreen> createState() => _ContributeScreenState();
}

class _ContributeScreenState extends State<ContributeScreen> {
  static const _cats = [
    '👋 Salutation',
    '📜 Proverbe (Ohabolana)',
    '🏡 Vie quotidienne',
    '🌊 Nature & Mer',
    '❤️ Émotion & Sagesse'
  ];
  final _term = TextEditingController(),
      _phon = TextEditingController(),
      _meaning = TextEditingController(),
      _example = TextEditingController(),
      _exampleFr = TextEditingController();
  String? _dialect, _place;
  String _cat = _cats.first;
  @override
  void dispose() {
    for (final c in [_term, _phon, _meaning, _example, _exampleFr]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final missing = <String>[
      if (_term.text.trim().isEmpty) 'le mot',
      if (_dialect == null) 'la région',
      if (_meaning.text.trim().isEmpty) 'la signification'
    ];
    if (missing.isNotEmpty) {
      toast(context, 'Champs manquants : ${missing.join(', ')}');
      return;
    }
    try {
      await apiClient.createContribution({
        'term': _term.text.trim(),
        'phonetic': _phon.text.trim(),
        'meaning': _meaning.text.trim(),
        'example': _example.text.trim(),
        'exampleFr': _exampleFr.text.trim(),
        'region': _place ?? _dialect,
        'dialect': _dialect,
        'category': _cat
      });
      if (mounted) {
        toast(context, 'Proposition envoyée aux linguistes.');
        Navigator.of(context).pop();
      }
    } on DioException {
      if (mounted)
        toast(context, 'Envoi impossible. Vérifiez votre connexion.');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          leading: const BackButton(color: C.onSurface),
          title: Text('Contribuer', style: ts(16, w6)),
          centerTitle: true),
      body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
          children: [
            Text('HARENA IOMBONANA • TRÉSOR PARTAGÉ',
                style: ts(11, w7, color: C.tertiary, ls: 1)),
            const SizedBox(height: 4),
            Text('Proposer un mot', style: ts(24, w7, ls: -.2)),
            Text(
                'Aidez à enrichir le dictionnaire régional avec des données textuelles validées.',
                style: ts(13, w4, color: C.onVariant)),
            const SizedBox(height: 18),
            _field('Mot ou expression', 'Ex. Mbarakaly, Salama, Akory...',
                _term, Icons.translate),
            _field('Indication phonétique approximative', 'Optionnel', _phon,
                Icons.hearing),
            const FieldLabel('Région linguistique', trailing: '*'),
            DropdownButtonFormField<String>(
                initialValue: _dialect,
                isExpanded: true,
                decoration: fieldDec('Sélectionnez une région'),
                items: [
                  for (final r in appState.regions)
                    DropdownMenuItem(
                        value: r.name,
                        child: Text(r.name,
                            overflow: TextOverflow.ellipsis, style: ts(13, w5)))
                ],
                onChanged: (v) => setState(() => _dialect = v)),
            const FieldLabel('Catégorie thématique'),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final c in _cats)
                ChoiceChip(
                    label: Text(c,
                        style: ts(12, w6,
                            color: _cat == c ? Colors.white : C.onVariant)),
                    selected: _cat == c,
                    showCheckmark: false,
                    selectedColor: C.primaryContainer,
                    backgroundColor: C.lowest,
                    side: const BorderSide(color: C.outlineVariant),
                    shape: const StadiumBorder(),
                    onSelected: (_) => setState(() => _cat = c))
            ]),
            const FieldLabel('Signification et traduction', trailing: '*'),
            TextField(
                controller: _meaning,
                maxLines: 3,
                maxLength: 240,
                decoration: fieldDec('Décrivez le sens du mot...')),
            const FieldLabel("Exemple d'utilisation"),
            TextField(
                controller: _example,
                decoration: fieldDec('Exemple dans une phrase')),
            const SizedBox(height: 8),
            TextField(
                controller: _exampleFr,
                decoration: fieldDec('Traduction de l’exemple')),
            const FieldLabel("Ville ou terroir d'attache",
                trailing: 'Optionnel'),
            DropdownButtonFormField<String>(
                initialValue: _place,
                isExpanded: true,
                decoration: fieldDec('Sélectionnez un terroir',
                    icon: Icons.location_on_outlined),
                items: [
                  for (final r in appState.regions)
                    DropdownMenuItem(
                        value: r.name,
                        child: Text(r.name,
                            overflow: TextOverflow.ellipsis, style: ts(13, w5)))
                ],
                onChanged: (v) => setState(() => _place = v)),
            const SizedBox(height: 18),
            Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: a(C.secondaryContainer, .7),
                    borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  const Icon(Icons.verified, color: C.secondary),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(
                          'La proposition textuelle sera vérifiée par les linguistes avant publication.',
                          style: ts(12, w4, color: C.onSecondaryContainer)))
                ])),
            const SizedBox(height: 16),
            PBtn('Envoyer la proposition', icon: Icons.send, onTap: _submit),
          ]));

  Widget _field(
          String label, String hint, TextEditingController c, IconData icon) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FieldLabel(label,
            trailing:
                label == 'Mot ou expression' ? '* Obligatoire' : 'Optionnel'),
        TextField(controller: c, decoration: fieldDec(hint, icon: icon))
      ]);
}
