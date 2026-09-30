import 'dart:async';
import 'package:flutter/material.dart' hide Text;
import '../core/app_state.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import '../core/i18n.dart';

enum _Rec { idle, recording, recorded }

class ContributeScreen extends StatefulWidget {
  const ContributeScreen({super.key});
  @override
  State<ContributeScreen> createState() => _ContributeScreenState();
}

class _ContributeScreenState extends State<ContributeScreen> {
  static const _dialects = [
    'Antsiranana • Antakarana (Nord)',
    'Majunga / Menabe • Sakalava (Ouest)',
    'Toamasina • Betsimisaraka (Est)',
    'Mandritsara • Tsimihety (Centre-Nord)',
    'Analamanga • Merina (Hauts-Plateaux)',
    'Fianarantsoa • Betsileo (Sud-Hauts-Plateaux)',
    'Ambovombe • Tandroy (Grand Sud)',
    'Toliara • Vezo (Littoral Sud-Ouest)',
    'Ihosy • Bara (Plateaux du Sud)',
    'Tolagnaro • Tañosy (Sud-Est)',
  ];
  static const _places = [
    'Diego-Suarez (Antsiranana)',
    'Nosy Be Hell-Ville',
    'Majunga (Mahajanga)',
    'SAVA (Sambava / Antalaha)',
    'Tamatave (Toamasina)',
    'Île Sainte-Marie (Nosy Boraha)',
    'Antananarivo Renivohitra',
    'Ambositra (Zafimaniry)',
    'Fianarantsoa',
    'Manakara / Farafangana',
    'Tuléar (Toliara)',
    'Fort-Dauphin (Tolagnaro)',
  ];
  static const _cats = [
    '👋 Salutation',
    '📜 Proverbe (Ohabolana)',
    '🏡 Vie quotidienne',
    '🌊 Nature & Mer',
    '❤️ Émotion & Sagesse'
  ];
  static const _maxSec = 15;

  final _term = TextEditingController();
  final _phon = TextEditingController();
  final _meaning = TextEditingController();
  final _example = TextEditingController();
  final _exampleFr = TextEditingController();
  String? _dialect, _place;
  String _cat = _cats.first;
  _Rec _rec = _Rec.idle;
  int _sec = 0;
  bool _previewing = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in [_term, _phon, _meaning, _example, _exampleFr]) {
      c.dispose();
    }
    super.dispose();
  }

  String _fmt(int s) => '00:${s.toString().padLeft(2, '0')} / 00:$_maxSec';

  void _toggleRecord() {
    if (_rec == _Rec.recording) {
      _timer?.cancel();
      setState(() => _rec = _Rec.recorded);
      return;
    }
    setState(() {
      _rec = _Rec.recording;
      _sec = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _sec++);
      if (_sec >= _maxSec) {
        t.cancel();
        setState(() => _rec = _Rec.recorded);
      }
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _rec = _Rec.idle;
      _sec = 0;
      _previewing = false;
    });
  }

  void _preview() {
    if (_rec != _Rec.recorded) {
      toast(context, "Enregistrez d'abord votre prononciation");
      return;
    }
    setState(() => _previewing = true);
    Timer(Duration(seconds: _sec.clamp(1, 4).toInt()), () {
      if (mounted) setState(() => _previewing = false);
    });
  }

  void _submit() {
    final missing = <String>[
      if (_term.text.trim().isEmpty) 'le mot',
      if (_dialect == null) 'le dialecte',
      if (_meaning.text.trim().isEmpty) 'la signification',
      if (_rec != _Rec.recorded) "l'enregistrement",
    ];
    if (missing.isNotEmpty) {
      toast(context, 'Champs manquants : ${missing.join(', ')}');
      return;
    }
    appState.addVoice(); // +1 voix en temps réel
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.verified, color: C.secondary, size: 40),
        title: Text('Démo de contribution terminée',
            textAlign: TextAlign.center, style: ts(18, w7)),
        content: Text(
            '« ${_term.text.trim()} » a été validé localement pour cette démonstration. L\'envoi aux linguistes sera activé avec le backend.',
            textAlign: TextAlign.center,
            style: ts(13, w4, color: C.onVariant)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text('Terminer', style: ts(13, w7, color: C.primary)),
          ),
        ],
      ),
    );
  }

  Widget _step(String t, String s) => Row(children: [
        Expanded(child: Text(t, style: ts(17, w7))),
        Pill(s, bg: C.primaryFixed, fg: C.primary),
      ]);

  @override
  Widget build(BuildContext context) {
    final recording = _rec == _Rec.recording;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: C.onSurface),
        title: Text('Contribuer', style: ts(16, w6)),
        centerTitle: true,
      ),
      body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
          children: [
            Text('HARENA IOMBONANA • TRÉSOR PARTAGÉ',
                style: ts(11, w7, color: C.tertiary, ls: 1)),
            const SizedBox(height: 4),
            Text('Contribuer au patrimoine', style: ts(24, w7, ls: -.2)),
            Text(
                'Enrichissez le dictionnaire vivant des 18 dialectes malgaches.',
                style: ts(13, w4, color: C.onVariant)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                    colors: [C.primaryContainer, C.primary]),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.record_voice_over,
                          color: C.onPrimaryContainer),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text('Votre voix préserve notre culture',
                              style: ts(15, w7, color: Colors.white))),
                    ]),
                    const SizedBox(height: 6),
                    Text(
                        "Chaque mot, intonation ou variante locale est vérifié par nos linguistes et modérateurs communautaires avant d'intégrer l'encyclopédie sonore.",
                        style: ts(12, w4, color: C.onPrimaryContainer)),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, children: const [
                      Pill('Tradition orale',
                          bg: Color(0x33FFFFFF), fg: Colors.white),
                      Pill('Richesse lexicale',
                          bg: Color(0x33FFFFFF), fg: Colors.white),
                      Pill('18 Régions',
                          bg: Color(0x33FFFFFF), fg: Colors.white),
                    ]),
                  ]),
            ),
            const SizedBox(height: 20),
            _step('1. Terme & Contexte', 'Étape 1/2'),
            const FieldLabel('Mot ou expression en dialecte',
                trailing: '* Obligatoire'),
            TextField(
                controller: _term,
                decoration: fieldDec('Ex: Mbarakaly, Salama, Akory...',
                    icon: Icons.translate)),
            const FieldLabel('Indication phonétique approximative',
                trailing: 'Optionnel'),
            TextField(
                controller: _phon,
                decoration:
                    fieldDec('Ex: [m-ba-ra-ka-li]', icon: Icons.hearing)),
            const FieldLabel('Dialecte principal', trailing: '*'),
            DropdownButtonFormField<String>(
              initialValue: _dialect,
              isExpanded: true,
              decoration: fieldDec('Sélectionnez une région linguistique'),
              items: [
                for (final d in _dialects)
                  DropdownMenuItem(
                      value: d,
                      child: Text(d,
                          overflow: TextOverflow.ellipsis, style: ts(13, w5)))
              ],
              onChanged: (v) => setState(() => _dialect = v),
            ),
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
                  onSelected: (_) => setState(() => _cat = c),
                ),
            ]),
            const FieldLabel(
                'Signification & traduction en français / malagasy standard',
                trailing: '* '),
            TextField(
              controller: _meaning,
              maxLines: 3,
              maxLength: 240,
              onChanged: (_) => setState(() {}),
              decoration: fieldDec('Décrivez le sens du mot...'),
            ),
            const FieldLabel("Exemple d'utilisation dans une phrase"),
            TextField(
                controller: _example,
                decoration:
                    fieldDec('Ex: Mbarakaly, akory tsara aby anareo ?')),
            const SizedBox(height: 8),
            TextField(
                controller: _exampleFr,
                decoration: fieldDec(
                    "Traduction de l'exemple (ex: Bonjour, comment allez-vous tous ?)")),
            const SizedBox(height: 22),
            _step('2. Studio Vocal', 'Étape 2/2'),
            const SizedBox(height: 4),
            Text('Capturez l\'intonation authentique',
                style: ts(13, w6, color: C.secondary)),
            Text(
                'Prononcez clairement le mot 2 fois à voix haute dans un environnement calme.',
                style: ts(12, w4, color: C.onVariant)),
            const SizedBox(height: 12),
            CardBox(
              child: Column(children: [
                Row(children: [
                  Pill(recording ? 'Enregistrement…' : 'Micro prêt',
                      bg: recording ? C.errorContainer : C.secondaryContainer,
                      fg: recording ? C.error : C.onSecondaryContainer,
                      icon: Icons.mic),
                  const Spacer(),
                  Text(_fmt(_sec), style: ts(12, w6, color: C.onVariant)),
                ]),
                const SizedBox(height: 4),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        'Qualité : 48 kHz HD • Réduction de bruit active',
                        style: ts(11, w4, color: C.outline))),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: _toggleRecord,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: recording ? 96 : 84,
                    height: recording ? 96 : 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: recording ? C.error : C.primaryContainer,
                      boxShadow: [
                        BoxShadow(
                            color: a(
                                recording ? C.error : C.primaryContainer, .35),
                            blurRadius: recording ? 24 : 12,
                            spreadRadius: recording ? 6 : 0)
                      ],
                    ),
                    child: Icon(recording ? Icons.stop : Icons.mic,
                        color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                    recording
                        ? 'Appuyez pour arrêter'
                        : (_rec == _Rec.recorded
                            ? 'Enregistrement prêt ✓'
                            : 'Appuyez pour enregistrer votre prononciation native'),
                    textAlign: TextAlign.center,
                    style: ts(12, w5, color: C.onVariant)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: PBtn(recording ? 'Arrêter' : 'Enregistrer',
                          icon: recording ? Icons.stop : Icons.mic,
                          onTap: _toggleRecord)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: PBtn(_previewing ? 'Lecture…' : 'Aperçu',
                          icon: Icons.play_arrow,
                          outlined: true,
                          onTap: _preview)),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                      onPressed: _reset, icon: const Icon(Icons.restart_alt)),
                ]),
              ]),
            ),
            const FieldLabel("Votre ville / terroir d'accentuation"),
            DropdownButtonFormField<String>(
              initialValue: _place,
              isExpanded: true,
              decoration: fieldDec('Sélectionnez votre terroir',
                  icon: Icons.location_on_outlined),
              items: [
                for (final d in _places)
                  DropdownMenuItem(
                      value: d,
                      child: Text(d,
                          overflow: TextOverflow.ellipsis, style: ts(13, w5)))
              ],
              onChanged: (v) => setState(() => _place = v),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: a(C.secondaryContainer, .7),
                  borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                const Icon(Icons.verified, color: C.secondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Validation communautaire garantie',
                            style: ts(13, w7, color: C.onSecondaryContainer)),
                        Text(
                            'Validation locale uniquement dans cette version de démonstration.',
                            style: ts(12, w4, color: C.onSecondaryContainer)),
                      ]),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            PBtn('Test local de la proposition', icon: Icons.send, onTap: _submit),
            const SizedBox(height: 8),
            Center(
              child: Text(
                  '« Les mots sont comme la canne à sucre : plus on les partage, plus ils sont doux. »',
                  textAlign: TextAlign.center,
                  style: ts(13, w6, color: C.tertiary)
                      .copyWith(fontStyle: FontStyle.italic)),
            ),
            const SizedBox(height: 4),
            Center(
                child: Text(
                    'Les mots sont comme la canne à sucre : plus on les partage, plus ils sont doux.',
                    textAlign: TextAlign.center,
                    style: ts(11, w4, color: C.onVariant))),
          ]),
    );
  }
}
