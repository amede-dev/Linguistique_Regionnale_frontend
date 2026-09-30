import 'package:flutter/material.dart' hide Text;
import 'package:flutter/material.dart' as m show Text;

/// Langue courante de l'interface : 'Français' ou 'Malagasy'.
/// Modifiée par AppState.setLanguage().
final ValueNotifier<String> languageNotifier =
    ValueNotifier<String>('Français');

/// Traduit le texte de l'interface selon la langue choisie.
///
/// Règle : TOUS les libellés écrits dans le code sont en FRANÇAIS.
/// - Langue 'Français' : le texte est affiché tel quel (aucune traduction),
///   seuls quelques noms de langue sont adaptés (ex. 'Malagasy' -> 'Malgache').
/// - Langue 'Malagasy' : français -> malagasy grâce au dictionnaire [_mg].
/// Si aucune traduction n'existe, le texte d'origine est conservé.
/// Les noms de lieux, de régions, de dialectes et les mots malgaches du
/// dictionnaire (contenu) ne sont donc jamais modifiés.
String tr(String s) {
  final toMalagasy = languageNotifier.value == 'Malagasy';
  final core = s.trim();
  if (core.isEmpty) return s;
  final start = s.indexOf(core);
  final lead = s.substring(0, start);
  final trail = s.substring(start + core.length);
  final out = toMalagasy ? _toMalagasy(core) : _fr[core];
  return out == null ? s : '$lead$out$trail';
}

String? _toMalagasy(String core) {
  final direct = _mg[core];
  if (direct != null) return direct;

  // Texte affiché en MAJUSCULES (ex. après .toUpperCase()) : on cherche sans
  // tenir compte de la casse, puis on remet le résultat en majuscules.
  final isUpper = core == core.toUpperCase() && core != core.toLowerCase();
  if (isUpper) {
    final lc = _mgLower[core.toLowerCase()];
    if (lc != null) return lc.toUpperCase();
  }

  for (final rule in _rules) {
    final match = rule.$1.firstMatch(core);
    if (match != null) {
      final r = rule.$2(match);
      return isUpper ? r.toUpperCase() : r;
    }
  }
  return null;
}

/// Remplace le widget Text de Flutter : traduit automatiquement son contenu
/// et se met à jour dès que la langue change.
class Text extends StatelessWidget {
  final String? data;
  final InlineSpan? textSpan;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool? softWrap;

  const Text(
    String this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
  }) : textSpan = null;

  const Text.rich(
    InlineSpan this.textSpan, {
    super.key,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
  }) : data = null;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String>(
        valueListenable: languageNotifier,
        builder: (_, __, ___) {
          if (textSpan != null) {
            return m.Text.rich(
              _trSpan(textSpan!),
              style: style,
              textAlign: textAlign,
              overflow: overflow,
              maxLines: maxLines,
              softWrap: softWrap,
            );
          }
          return m.Text(
            tr(data!),
            style: style,
            textAlign: textAlign,
            overflow: overflow,
            maxLines: maxLines,
            softWrap: softWrap,
          );
        },
      );
}

InlineSpan _trSpan(InlineSpan s) {
  if (s is TextSpan) {
    return TextSpan(
      text: s.text == null ? null : tr(s.text!),
      children: s.children?.map(_trSpan).toList(),
      style: s.style,
      recognizer: s.recognizer,
      semanticsLabel: s.semanticsLabel,
    );
  }
  return s;
}

// ---------------------------------------------------------------------------
// Textes avec des nombres ou des variables
// ---------------------------------------------------------------------------
final List<(RegExp, String Function(Match))> _rules = [
  (RegExp(r'^Tous \((\d+)\)$'), (m) => 'Rehetra (${m[1]})'),
  (RegExp(r'^Toutes \((\d+)\)$'), (m) => 'Rehetra (${m[1]})'),
  (
    RegExp(r'^(\d+) favoris sauvegardés$'),
    (m) => '${m[1]} ankafizina voatahiry'
  ),
  (
    RegExp(r'^(\d+) mots synchronisés en local$'),
    (m) => "teny ${m[1]} voatahiry ao amin'ny finday"
  ),
  (
    RegExp(r'^Rechercher parmi vos (\d+) expressions\.\.\.$'),
    (m) => 'Karohy anatin\'ny fitenenana ${m[1]} ankafizinao...'
  ),
  (RegExp(r'^(\d+) dialectes$'), (m) => 'fitenim-paritra ${m[1]}'),
  (RegExp(r'^(\d+) mots$'), (m) => 'teny ${m[1]}'),
  (RegExp(r'^(\d+)% consensus$'), (m) => 'fifanarahana ${m[1]}%'),
  (
    RegExp(r'^(\d+) aires linguistiques majeures$'),
    (m) => 'faritra ara-piteny lehibe ${m[1]}'
  ),
  (RegExp(r'^Nuance : (.*)$'), (m) => 'Fahasamihafana : ${m[1]}'),
  (RegExp(r'^Force : (.*)$'), (m) => 'Hery : ${tr(m[1]!)}'),
  (RegExp(r'^Voix native • (.*)$'), (m) => 'Feo teraka • ${m[1]}'),
  (RegExp(r'^Salutation (.*) : (.*)$'), (m) => 'Fiarahabana ${m[1]} : ${m[2]}'),
  (
    RegExp(r'^(.*) • Écoute comparative$'),
    (m) => '${tr(m[1]!)} • Fihainoana fampitahana'
  ),
  (RegExp(r'^(\d+) voix$'), (m) => 'feo ${m[1]}'),
  (
    RegExp(r'^(.*) • Interjection$', caseSensitive: false),
    (m) => '${tr(m[1]!)} • Teny fiantsoana'
  ),
  (
    RegExp(r"^(.*) • Berceau de l'expression$"),
    (m) => "${tr(m[1]!)} • Fototry ny fitenenana"
  ),
  (RegExp(r'^« (.*) » copié$'), (m) => '« ${m[1]} » voadika'),
  (
    RegExp(r'^« (.*) » retiré des favoris$'),
    (m) => "« ${m[1]} » nesorina tamin'ny ankafizina"
  ),
  (
    RegExp(
        r'^« (.*) » sera revu par nos linguistes sous 48h\. Vous gagnerez 25 points de réputation culturelle\.$'),
    (m) =>
        "« ${m[1]} » dia hojerena amin'ny mpahay teny anay anatin'ny 48 ora. Handray isa 25 amin'ny lazanao ara-kolontsaina ianao."
  ),
  (
    RegExp(r'^Un lien de réinitialisation a été envoyé à (.*)\.$'),
    (m) => "Nalefa tany amin'i ${m[1]} ny rohy famerenana."
  ),
  (
    RegExp(r'^Un code de réinitialisation a été envoyé au (.*)\.$'),
    (m) => "Nalefa tany amin'ny ${m[1]} ny kaody famerenana."
  ),
  (
    RegExp(r'^Champs manquants : (.*)$'),
    (m) => 'Tsy feno : ${m[1]!.split(', ').map(tr).join(', ')}'
  ),
  // "Antsiranana • Antakarana (Nord)" -> traduit la zone entre parenthèses
  (RegExp(r'^(.+ • .+) \((.+)\)$'), (m) => '${m[1]} (${tr(m[2]!)})'),
  (
    RegExp(
        r'^Participez à la sauvegarde et la transmission vivante des (\d+) dialectes de Madagascar\.$'),
    (m) => "Miara-miaro sy mampita ny fitenim-paritra ${m[1]} eto Madagasikara."
  ),
];

// ---------------------------------------------------------------------------
// Dictionnaire Français -> Malagasy
// (à faire relire par un locuteur natif pour ajuster les tournures)
// ---------------------------------------------------------------------------
const Map<String, String> _mg = {
  // Navigation
  'Accueil': 'Fandraisana',
  'Recherche': 'Fikarohana',
  'Rechercher': 'Fikarohana',
  'Régions': 'Faritra',
  'Favoris': 'Ankafizina',
  'Mes Favoris': 'Ny ankafiziko',
  'Profil': 'Mombamomba',
  'Détail Mot': 'Antsipiriany ny teny',
  'Contribuer': 'Handray anjara',
  'Annuler': 'Foana',
  'Terminer': 'Vita',
  'Passer': 'Handingana',
  'Optionnel': 'Tsy voatery',
  '* Obligatoire': '* Tsy maintsy fenoina',
  'Champ requis': 'Tsy maintsy fenoina',

  // Profil
  "Paramètres de l'application": "Fandrindrana ny application",
  "Langue de l'interface": 'Fiteny ampiasaina',
  'Notifications quotidiennes': "Fampilazana isan'andro",
  'Mots du jour & validation des propositions':
      'Teny androany sy fanamarinana ny tolo-kevitra',
  'Se déconnecter': 'Hiala',
  'Voulez-vous vraiment vous déconnecter de votre compte ?':
      "Tena te hiala amin'ny kaontinao ve ianao?",
  'Choisir depuis la galerie': "Misafidy avy amin'ny galeria",
  'Prendre une photo': 'Maka sary',
  'Supprimer la photo': 'Fafana ny sary',
  "Impossible d'accéder à la photo": "Tsy afaka miditra amin'ny sary",
  'Langue malgache • Version 1.2.0': 'Linguistique Régionale • Andiany 1.2.0',
  'Aucune nouvelle notification': 'Tsy misy fampilazana vaovao',

  // Connexion / inscription
  'Se connecter': 'Hiditra',
  "S'inscrire": 'Hisoratra anarana',
  "S'inscrire avec Google": "Hisoratra anarana amin'ny Google",
  "S'inscrire avec Apple": "Hisoratra anarana amin'ny Apple",
  'Continuer avec Google': "Hanohy amin'ny Google",
  'Continuer avec Apple': "Hanohy amin'ny Apple",
  'Mot de passe': 'Teny miafina',
  'Mot de passe oublié ?': 'Adino ny teny miafina?',
  'Adresse e-mail': 'Adiresy mailaka',
  'Adresse e-mail valide': 'Adiresy mailaka manan-kery',
  'Adresse e-mail invalide': 'Adiresy mailaka diso',
  'Confirmation du mot de passe': 'Fanamarinana ny teny miafina',
  'Les mots de passe ne correspondent pas': 'Tsy mitovy ny teny miafina',
  '8 caractères min. • 1 chiffre': 'Tarehintsoratra 8 farafahakeliny • isa 1',
  'Faible': 'Malemy',
  'Moyenne': 'Antonony',
  'Robuste': 'Matanjaka',
  'Nom complet ou pseudonyme': "Anarana feno na solon'anarana",
  'Public': 'Hita ampahibemaso',
  'Se souvenir de moi': 'Tsarovy aho',
  'Déjà membre ?': 'Efa mpikambana?',
  'Pas encore de compte ?': 'Mbola tsy manana kaonty?',
  'Créer mon compte explorateur': 'Hamorona ny kaontiko',
  'Créer un compte gratuitement': 'Hamorona kaonty maimaim-poana',
  "J'ai déjà un compte / Connexion": 'Efa manana kaonty aho / Hiditra',
  'ou avec vos coordonnées': "na amin'ny mombamomba anao",
  'ou avec votre adresse e-mail': "na amin'ny adiresy mailakao",
  'Rejoignez la communauté': "Miaraha amin'ny fiarahamonina",
  "J'accepte la": 'Manaiky ny',
  'Charte de préservation linguistique': 'Fitsipika fiarovana ny fiteny',
  'et les': 'sy ny',
  "Conditions d'utilisation": 'Fepetra fampiasana',
  'de Linguistique Régionale.': "an'i Linguistique Régionale.",
  "Veuillez accepter la charte et les conditions d'utilisation":
      'Ekeo azafady ny fitsipika sy ny fepetra fampiasana',
  "Région ou dialecte d'attache": 'Faritra na fitenim-paritra tiana',
  'Personnalise votre flux': 'Manamboatra ny votoatinao',
  'Sélectionnez un dialecte de prédilection...':
      'Fidio ny fitenim-paritra tianao...',
  'Privilège de Bienvenue': "Tombony ho an'ny vaovao",
  'Débloquez immédiatement le mode hors-ligne et 5 dialectes audio en cache.':
      "Vohay avy hatrany ny fomba tsy misy internet sy fitenim-paritra 5 misy feo voatahiry.",
  'Aide phonétique • Confidentialité • Académie Malgache':
      "Fanampiana amin'ny feo • Tsiambaratelo • Akademia Malagasy",
  'Connectez-vous pour retrouver vos favoris, synchroniser vos audios et participer à la communauté.':
      "Midira mba hahitana ny ankafizinao, hampifanaraka ny feo ary handray anjara amin'ny fiarahamonina.",
  'Astuce de connexion': "Toro-hevitra momba ny fidirana",
  "Si vous avez utilisé Google pour vous inscrire sur Linguistique Régionale, connectez-vous directement via le bouton Google sans mot de passe.":
      "Raha Google no nampiasainao tamin'ny fisoratana anarana, midira mivantana amin'ny bokotra Google tsy misy teny miafina.",
  'Retour à la connexion': "Miverina amin'ny fidirana",
  'Retour à la page de connexion': "Miverina any amin'ny pejy fidirana",
  'Envoyer le lien de réinitialisation': 'Alefaso ny rohy famerenana',
  'Réinitialiser': 'Hamerina',
  'Demande envoyée': 'Nalefa ny fangatahana',
  'Sécurité Linguistique Régionale': 'Filaminana Linguistique Régionale',
  "Ne vous inquiétez pas ! Saisissez l'adresse e-mail associée à votre compte Linguistique Régionale. Nous vous enverrons un lien magique ou un code sécurisé pour réinitialiser votre accès.":
      "Aza manahy! Ampidiro ny adiresy mailaka mifandray amin'ny kaontinao Linguistique Régionale. Handefa rohy na kaody azo antoka izahay hamerenana ny fidiranao.",
  'Sécurisé par Supabase Auth • Chiffrement de bout en bout':
      "Voaaro amin'ny Supabase Auth • Fanafenana tanteraka",
  'Support communautaire : aide@linguistique-regionnale.app':
      "Fanampiana avy amin'ny fiarahamonina : aide@linguistique-regionnale.app",

  // Présentation
  "Commencer l'exploration": "Atombohy ny fikarohana",
  'BIENVENUE SUR LINGUISTIQUE_RÉGIONALE':
      "TONGASOA ETO AMIN'NY LINGUISTIQUE_RÉGIONALE",
  'Un pays, plusieurs façons de parler.': 'Firenena iray, fomba fiteny maro.',
  "Écoutez des prononciations authentiques, découvrez les nuances régionales et participez à la sauvegarde de notre patrimoine oral.":
      "Henoy ny feo tena izy, jereo ny fahasamihafan'ny faritra ary miaraha miaro ny lovantsofinay.",
  "Chaque mot, intonation ou variante locale est vérifié par nos linguistes et modérateurs communautaires avant d'intégrer l'encyclopédie sonore.":
      "Ny teny, ny feo na ny fitenim-paritra rehetra dia hamarinin'ny mpahay teny sy ny mpandamina ao amin'ny fiarahamonina aloha vao tafiditra ao amin'ny rakibolana ara-peo.",
  'Validation communautaire garantie':
      "Fanamarinana avy amin'ny fiarahamonina voaro",
  'Données linguistiques protégées • Vos contributions audio et dialectes restent saufs':
      "Voaaro ny angona ara-piteny • Azo antoka ny fandraisanao anjara",

  // Accueil
  'Explorez les trésors dialectaux de Madagascar':
      'Hizaha ny harena ara-fitenim-paritra eto Madagasikara',
  'Mots Tendance': 'Teny malaza',
  'Tout voir': 'Hijery rehetra',
  'PERLE DU JOUR': 'TENY TSARA ANDROANY',
  'MOT DU JOUR': 'TENY ANDROANY',
  'Mis à jour à 06:00': "Nohavaozina tamin'ny 06:00",
  'Participez au patrimoine': "Miaraha miaro ny lova",
  "Connaissez-vous une variante ? Enregistrez la voix d'un aîné ou soumettez une expression typique de votre région pour enrichir l'encyclopédie sonore.":
      "Mahalala fitenim-paritra hafa ve ianao? Alaharo ny feon'ny anti-panahy na ateraho ny fitenenana mahazatra any amin'ny faritrao hanan-karena ny rakibolana ara-peo.",
  'Participer': 'Handray anjara',
  'Explorer': 'Hizaha',
  'Découvrir': 'Hijery',
  'Voir fiche': "Hijery ny antsipiriany",
  'Cette semaine': 'Ity herinandro ity',
  'Richesse lexicale': "Haren'ny teny",
  "Vue d'ensemble": 'Topimaso ankapobeny',

  // Recherche
  'Que recherchez-vous ?': 'Inona no tadiavinao?',
  'Rechercher un mot, une expression ou une signification...':
      'Mitadiava teny, fitenenana na dikany...',
  'Rechercher un mot, proverbe, région…': 'Mitadiava teny, ohabolana, faritra…',
  'Recherche phonétique, régionale ou par concept IA':
      "Fikarohana amin'ny feo, faritra na hevitra IA",
  'Tous types': 'Karazana rehetra',
  'Tous': 'Rehetra',
  'Toutes': 'Rehetra',
  'Toutes les régions': 'Faritra rehetra',
  'Pertinence IA': 'Fifanarahana IA',
  'Popularité': "Lazan'ny olona",
  'Tri :': 'Filaharana :',
  'Aucun résultat pour cette recherche':
      "Tsy misy valiny ho an'ity fikarohana ity",
  'Essayez un autre mot ou une autre région.':
      'Andramo teny hafa na faritra hafa.',
  'résultats trouvés': 'valiny hita',
  'Recherche par sens active': "Mandeha ny fikarohana araka ny hevitra",
  'Recherche vocale : bientôt disponible':
      "Fikarohana amin'ny feo : tsy ho ela",
  'Hauts-Plateaux': 'Tendrombohitra Afovoany',
  'Côte Est': 'Morontsiraka Atsinanana',
  'Côte Ouest': 'Morontsiraka Andrefana',
  'Grand Sud': 'Atsimo Lehibe',
  'Grand Nord': 'Avaratra Lehibe',

  // Favoris
  'Aucun favori ici': 'Tsy misy ankafizina eto',
  "Touchez le cœur d'un mot pour le retrouver ici.":
      "Tsindrio ny fon'ny teny iray mba hahitana azy eto.",
  'Retirer': 'Esory',
  'MAJ': 'VAOVAO',
  'Mots et expressions sauvegardés pour vos voyages':
      "Teny sy fitenenana voatahiry ho an'ny dia",
  'Synchronisation terminée': 'Vita ny fampifanarahana',
  'Mode hors-ligne actif': 'Mandeha tsy misy internet',
  'Créer une liste': 'Hamorona lisitra',
  'Listes personnalisées : bientôt disponible': 'Lisitra manokana : tsy ho ela',
  'Enrichissez la carte sonore': "Ampitomboy ny sarintanin'ny feo",
  'Prononcez une variante locale de vos favoris.':
      "Vakio amin'ny fitenim-paritra any aminao ny ankafizinao.",
  'Exporter (.pdf)': 'Alefa (.pdf)',
  'Export PDF : bientôt disponible': 'Fanondranana PDF : tsy ho ela',

  // Régions
  'Régions Linguistiques': "Faritry ny fiteny",
  'Régions linguistiques': "Faritry ny fiteny",
  'ATLAS VIVANT': 'ATLASY VELONA',
  'Carte Linguistique': "Sarintanin'ny fiteny",
  'Région (Nord à Sud)': 'Faritra (Avaratra mankany Atsimo)',
  'Par région': 'Isaky ny faritra',
  'Parcourez les 6 provinces et leurs parlers':
      "Jereo ny faritany 6 sy ny fitenin'izy ireo",
  'Découvrez la richesse des 6 grandes provinces et dialectes de la Grande Île.':
      "Jereo ny haren'ny faritany lehibe 6 sy ny fitenim-paritra eto amin'ny Nosy Lehibe.",
  "Votre parler manque à l'appel ?": 'Tsy hita ve ny fitenin-dry zareo?',
  'Aidez-nous à sauvegarder les variantes locales oubliées.':
      'Ampio izahay hiaro ny fitenim-paritra hadino.',
  'Proposer une variante pour ma région':
      "Hanolotra fitenim-paritra ho an'ny faritro",
  'Votre dialecte manque ?': 'Tsy hita ve ny fitenim-paritra?',
  'Ajouter un dialecte': 'Hanampy fitenim-paritra',
  '18 Régions': 'Faritra 18',
  '18 voix': 'Feo 18',
  'Expressions': 'Fitenenana',
  'Dialecte principal': 'Fitenim-paritra lehibe',
  'Salutations': 'Fiarahabana',
  'Vérifié': 'Voamarina',
  'Actif': 'Mavitrika',
  'En cours': 'Mbola mandeha',
  'Communautaire': "Avy amin'ny fiarahamonina",

  // Détail d'un mot
  'Analyse Linguistique': 'Famakafakana ny fiteny',
  'Variantes Régionales': 'Fitenim-paritra samihafa',
  'Aperçu': 'Topimaso',
  'Étymologie austronésienne': 'Fototeny aostronezianina',
  "EXEMPLE D'USAGE": 'OHATRA FAMPIASANA',
  'Signaler une inexactitude phonétique': "Hitatitra fahadisoana amin'ny feo",
  'Merci ! Signalement enregistré': 'Misaotra! Voarakitra ny tatitra',
  'Validé par 42 locuteurs': "Nohamarinin'ny mpandahateny 42",
  'Tradition orale': 'Lovantsofina',
  'Lecture…': 'Mamaky…',
  'Arrêter': 'Ajanony',
  'Appuyez pour arrêter': 'Tsindrio hijanonana',

  // Contribution
  'Contribuer au patrimoine': "Handray anjara amin'ny lova",
  'Contribuez en enregistrant un mot de votre région.':
      "Handray anjara amin'ny fandraketana teny avy any amin'ny faritrao.",
  'Proposer un mot de votre région': "Hanolotra teny avy any amin'ny faritrao",
  'Votre voix préserve notre culture': 'Ny feonao dia miaro ny kolontsaintsika',
  '1. Terme & Contexte': '1. Teny sy zava-misy',
  '2. Studio Vocal': '2. Studio feo',
  'Étape 1/2': 'Dingana 1/2',
  'Étape 2/2': 'Dingana 2/2',
  'Mot ou expression en dialecte': "Teny na fitenenana amin'ny fitenim-paritra",
  'Catégorie thématique': 'Sokajy',
  'Niveau de langue': "Haavon'ny fiteny",
  'Signification & traduction en français / malagasy standard':
      "Dikany sy fandikan-teny amin'ny frantsay / malagasy ofisialy",
  "Exemple d'utilisation dans une phrase":
      'Ohatra fampiasana ao anaty fehezanteny',
  'Votre ville / terroir d\'accentuation':
      'Ny tanànanao / faritra misy ny anjaranao',
  'Sélectionnez votre terroir': 'Fidio ny faritrao',
  'Sélectionnez une région linguistique': 'Fidio ny faritra ara-piteny',
  'Décrivez le sens du mot...': 'Farito ny dikan\'ny teny...',
  'Enregistrer comme brouillon': 'Tehirizo ho volavolan-dahatsoratra',
  'Brouillon enregistré sur cet appareil':
      "Voatahiry ao amin'ity finday ity ny volavolan-dahatsoratra",
  'Soumettre pour validation': 'Alefa ho fanamarinana',
  'Revue linguistique sous 48h. Vous gagnerez 25 points de réputation culturelle.':
      "Hojerena amin'ny mpahay teny anatin'ny 48 ora. Handray isa 25 amin'ny lazanao ara-kolontsaina ianao.",
  'Merci pour votre contribution !': 'Misaotra ny anjara birakao!',
  'Micro prêt': 'Vonona ny mikrô',
  'Appuyez pour enregistrer votre prononciation native':
      'Tsindrio hitehirizana ny fanononanao',
  'Enregistrement…': 'Mandraikitra…',
  'Enregistrement prêt ✓': 'Vonona ny rakitra ✓',
  'Enregistrer': 'Tehirizo',
  "Enregistrez d'abord votre prononciation": 'Alaharo aloha ny fanononanao',
  'Prononcez clairement le mot 2 fois à voix haute dans un environnement calme.':
      "Vakio tsara indroa amin'ny feo avo ny teny ao amin'ny toerana mangina.",
  'Qualité : 48 kHz HD • Réduction de bruit active':
      'Kalitao : 48 kHz HD • Mandeha ny fampihenana tabataba',
  '👋 Salutation': '👋 Fiarahabana',
  '🌊 Nature & Mer': '🌊 Natiora sy Ranomasina',
  '🏡 Vie quotidienne': "🏡 Fiainana andavan'andro",
  '❤️ Émotion & Sagesse': '❤️ Fihetseham-po sy Fahendrena',
  '📜 Proverbe (Ohabolana)': '📜 Ohabolana',
  'Famille & Respect': 'Fianakaviana sy Fanajana',
  'Mots isolés': 'Teny tokana',
  'Proverbes (Ohabolana)': 'Ohabolana',
  'Polyvalent (courant & soutenu)': 'Mahazatra sy ambony',
  'Numéro local (Telma, Orange, Airtel)':
      'Laharana eto an-toerana (Telma, Orange, Airtel)',

  // Libellés autrefois écrits en malagasy dans le code (désormais en français)
  'Bonjour 👋': 'Manao ahoana 👋',
  'Bienvenue !': 'Tongasoa eto !',
  'Patrimoine vivant': 'Lova Velona',
  'Patrimoine intellectuel de Madagascar': "Tahirin-tsain'ny Nosy Madagasikara",
  'LANGUE MALGACHE': 'LINGUISTIQUE RÉGIONALE',
  'Recherche de mots': 'Fikarohana Teny',
  'PATRIMOINE NATIONAL VIVANT': 'HAREM-PIRENENA VELONA',
  '6 provinces': '6 Faritany',
  'RECHERCHE AVANCÉE': 'FIKAROHANA MAROLAFY',
  'BELLES PAROLES': 'TENY SOA',
  '« Le lien fraternel est comme un fil fin : rompu, il peut se renouer. »':
      '« Ny fihavanana toy ny kofehy manify, tapaka azo tohizana. »',
  '« Les mots sont comme la canne à sucre : plus on les partage, plus ils sont doux. »':
      '« Ny teny toy ny fary lava tohana : vao mainka mifamaly vao mamy. »',
  'Malgache': 'Malagasy',

  // Ajouts : libellés supplémentaires et données de démonstration
  "Français": "Frantsay",
  "Choisissez la langue de l'application":
      "Fidio ny fiteny ampiasain'ny application",
  "Aucun mot tendance dans cette catégorie.":
      "Tsy misy teny malaza ao amin'ity sokajy ity.",
  "Numéro invalide": "Laharana diso",
  "Besoin d'aide ? Contacter le support communautaire":
      "Mila fanampiana? Mifandraisa amin'ny fanohanana",
  "6 caractères minimum": "Tarehintsoratra 6 farafahakeliny",
  "Explorer Madagascar": "Hizaha an'i Madagasikara",
  "Enrichissez le dictionnaire vivant des 18 dialectes malgaches.":
      "Ampitomboy ny rakibolana velona ny fitenim-paritra malagasy 18.",
  "Capturez l'intonation authentique": "Alaharo ny feo tena izy",
  "le mot": "ny teny",
  "le dialecte": "ny fitenim-paritra",
  "la signification": "ny dikany",
  "l'enregistrement": "ny fandraketana",
  "Tapez par ex. « Comment dit-on merci dans le Nord ? » ou décrivez une situation vécue.":
      "Soraty ohatra hoe « Ahoana no filazana hoe misaotra any Avaratra? » na lazao ny toe-javatra niainanao.",
  "Ex: Mbarakaly, Salama, Akory...": "Ohatra: Mbarakaly, Salama, Akory...",
  "Ex: [m-ba-ra-ka-li]": "Ohatra: [m-ba-ra-ka-li]",
  "Ex: Mbarakaly, akory tsara aby anareo ?":
      "Ohatra: Mbarakaly, akory tsara aby anareo ?",
  "Traduction de l'exemple (ex: Bonjour, comment allez-vous tous ?)":
      "Fandikana ny ohatra (ohatra: Arahaba, manao ahoana ianareo rehetra ?)",
  "Indication phonétique approximative": "Toromarika ara-peo tombana",
  "ex: Haingo Razafindrakoto": "ohatra: Haingo Razafindrakoto",
  "SMS (Madagascar)": "SMS (Madagasikara)",
  "Lien de partage copié": "Voadika ny rohy fizarana",
  "Nord": "Avaratra",
  "Ouest": "Andrefana",
  "Est": "Atsinanana",
  "Centre-Nord": "Afovoany Avaratra",
  "Sud-Hauts-Plateaux": "Atsimon'ny Tendrombohitra",
  "Littoral Sud-Ouest": "Morontsiraka Atsimo Andrefana",
  "Plateaux du Sud": "Tendrombohitra Atsimo",
  "Sud-Est": "Atsimo Atsinanana",
  "HARENA IOMBONANA • TRÉSOR PARTAGÉ": "HARENA IOMBONANA",
  "FIARAHA-MONINA • COMMUNAUTÉ": "FIARAHA-MONINA",
  "Les mots sont comme la canne à sucre : plus on les partage, plus ils sont doux.":
      "« Ny teny toy ny fary lava tohana : vao mainka mifamaly vao mamy. »",
  "Très bien, magnifique !": "Tsara dia tsara, mahafinaritra!",
  "Variante côtière orientale de l'expression commune « Tsara be », exprimant l'admiration joyeuse et cordiale.":
      "Fitenim-paritra amoron-tsiraka atsinanana ny fitenenana mahazatra hoe « Tsara be », maneho fahafinaretana sy fitiavana.",
  "Très bien, magnifique ! Variante côtière orientale de l'expression commune « Tsara be », exprimant l'admiration joyeuse et cordiale.":
      "Tsara dia tsara, mahafinaritra! Fitenim-paritra amoron-tsiraka atsinanana ny fitenenana mahazatra hoe « Tsara be », maneho fahafinaretana sy fitiavana.",
  "(La vie est si douce et magnifique ici au bord de la mer !)":
      "(Tsara sy mamy be ny fiainana eto amoron-dranomasina!)",
  "Enregistré à Tamatave": "Voarakitra tany Toamasina",
  "Bonjour, formule cordiale de salutation pour souhaiter la paix et le bien-être continu.":
      "Arahaba, fiarahabana mahafinaritra maniry fiadanana sy fahasalamana maharitra.",
  "Merina / Hauts Plateaux": "Merina / Tendrombohitra Afovoany",
  "Locuteur natif certifié": "Mpandahateny teratany voamarina",
  "Comment allez-vous tous ?": "Manao ahoana ianareo rehetra?",
  "Nord & Sakalava": "Avaratra sy Sakalava",
  "Locuteur vérifié • Majunga": "Mpandahateny voamarina • Mahajanga",
  "Comment allez-vous tous ? Salutation collective chaleureuse et fraternelle des régions côtières.":
      "Manao ahoana ianareo rehetra? Fiarahabana iombonana mafana sy mirindra avy any amin'ny faritra amoron-tsiraka.",
  "Côte Est (Betsimisaraka)": "Morontsiraka Atsinanana (Betsimisaraka)",
  "Vérifié par l'Académie Malgache": "Nohamarinin'ny Akademia Malagasy",
  "Concept philosophique fondamental de solidarité, fraternité et lien communautaire sacré unissant le peuple.":
      "Foto-kevitra ara-pilosofia lehibe momba ny firaisankina, ny fifankatiavana ary ny fatoram-piarahamonina masina mampiray ny vahoaka.",
  "Pannational": "Ho an'ny firenena manontolo",
  "Trésor immatériel": "Harena tsy hita maso",
  "Formule chaleureuse pour signifier « grand merci à vous » dans le septentrion malgache. Équivalent cordial de politesse communautaire.":
      "Fomba fiteny mafana milaza hoe « misaotra tompoko » any avaratr'i Madagasikara. Mitovy amin'ny politesy mahafinaritra eo amin'ny fiarahamonina.",
  "Locuteur vérifié • Diego-Suarez": "Mpandahateny voamarina • Antsiranana",
  "Salutation chaleureuse et marque de gratitude spontanée lorsqu'on reçoit un voyageur ou un bienfait au bord du canal de Mozambique.":
      "Fiarahabana mafana sy fisaorana tsy nokasaina rehefa mandray vahiny na soa any amoron'ny lalan-driaka Mozambika.",
  "3 variantes régionales • Mahafaly, Vezo":
      "Fitenim-paritra 3 • Mahafaly, Vezo",
  "Remerciement profond intégrant la générosité de la côte Est luxuriante. Signifie littéralement « grandement reconnaissant ».":
      "Fisaorana lalina maneho ny fahalalahan-tanana any amin'ny morontsiraka atsinanana be voly. Midika mivantana hoe « tena misaotra ».",
  "« Merci infiniment pour l'accueil hospitalier accordé au village. »":
      "« Misaotra tokoa ny fandraisana am-pitiavana natao tao an-tanàna. »",
  "Pédagogique • accent côtier": "Fampianarana • anjombona amoron-tsiraka",
  "Le lien fraternel est comme un fil fin : rompu, il peut se renouer.":
      "Ny fihavanana dia toy ny kofehy manify : raha tapaka dia azo tohizana.",
  "Teny Soa • sagesse ancestrale": "Teny Soa • fahendren'ny razana",
  "Formule chaleureuse et solennelle signifiant littéralement « Soyez vivant / Portez-vous bien », utilisée lors de la séparation ou comme vœu de prospérité durable.":
      "Fomba fiteny mafana sy manetriketrika midika mivantana hoe « Velomy / Ho salama anie », ampiasaina rehefa misaraka na ho faniriana fanambinana maharitra.",
  "« Au revoir monsieur/madame, que la grâce divine veille sur chacun de nous ! »":
      "« Veloma tompoko, enga anie ka hiaro antsika rehetra ny fahasoavan'Andriamanitra! »",
  "Fleuryssa R. (Locutrice Betsileo)": "Fleuryssa R. (Mpandahateny Betsileo)",
  "Racine proto-malayo-polynésienne *ma-hudip (« être vivant »). Cognat du tagalog mabuhay et de l'indonésien hidup. L'accent porte sur l'avant-dernière syllabe : vé-lo-ma.":
      "Fototeny proto-malayo-polynezianina *ma-hudip (« ho velona »). Mitovy amin'ny mabuhay amin'ny tagalog sy hidup amin'ny indoneziana. Ny lantom-peo dia eo amin'ny tovana faharoa farany : vé-lo-ma.",
  "Hauts-Plateaux • Merina": "Tendrombohitra Afovoany • Merina",
  "Forme standardisée très courante en milieu urbain et administratif signifiant « Jusqu'à notre prochaine rencontre ».":
      "Endrika ofisialy mahazatra be any an-tanàn-dehibe sy amin'ny fitantanana midika hoe « Ambara-pihaonantsika indray ».",
  "Formel • Urbain": "Ofisialy • An-tanàn-dehibe",
  "Côte Est • Betsimisaraka": "Morontsiraka Atsinanana • Betsimisaraka",
  "Accentué sur la dernière syllabe étirée avec intonation chantante. « Tsara mandeha » insiste sur la bénédiction du voyageur en mer ou le long du canal des Pangalanes.":
      "Lantom-peo eo amin'ny tovana farany ampitomboina amin'ny feo mihira. « Tsara mandeha » dia manasongadina ny fitahiana ho an'ny mpandeha an-dranomasina na eo amoron'ny Lakandranon'i Pangalana.",
  "Chaleureux • Périple": "Mafana • Dia",
  "Nord-Ouest • Sakalava du Boeny": "Avaratra Andrefana • Sakalava Boeny",
  "« Aza marary » (« Ne tombe point malade ») témoigne du rôle tutélaire de la communauté. Intonation vive, souvent accompagnée d'un claquement de mains discret.":
      "« Aza marary » (« Aza aretina ») dia mampiseho ny andraikitry ny fiarahamonina ho mpiaro. Feo mavitrika, matetika miaraka amin'ny tehaka malefaka.",
  "Protecteur • Familier": "Mpiaro • Fianakaviana",
  "Sud-Ouest • Vezo & Tandroy": "Atsimo Andrefana • Vezo sy Tandroy",
  "Marque le respect des aînés dans les terres arides du Grand Sud.":
      "Manondro ny fanajana ny zokiolona any amin'ny tany maina any Atsimo.",
  "Traditionnel • Respectueux": "Nentim-paharazana • Manaja",
  "Merina & Hauts-Plateaux": "Merina sy Tendrombohitra Afovoany",
  "Betsimisaraka & Est": "Betsimisaraka sy Atsinanana",
  "Sakalava du Boina": "Sakalava Boina",
  "Merina • Hautes Terres centrales": "Merina • Tany Avo Afovoany",
  "Betsimisaraka • Grand port maritime":
      "Betsimisaraka • Seranan-tsambo lehibe",
  "Betsileo • Pays des terrasses rizicoles":
      "Betsileo • Tanin'ny tanimbary an-tsaharana",
  "Sakalava • Cité des fleurs et du Boeny":
      "Sakalava • Tanànan'ny voninkazo sy ny Boeny",
  "Vezo / Tandroy / Mahafaly • Terres arides":
      "Vezo / Tandroy / Mahafaly • Tany maina",
  "Antakarana / Tsimihety • Baie de Diego":
      "Antakarana / Tsimihety • Helodrano Antsiranana",
  "Hauts-Plateaux (Merina / Betsileo)":
      "Tendrombohitra Afovoany (Merina / Betsileo)",
  "Côte Est (Betsimisaraka / Bezanozano)":
      "Morontsiraka Atsinanana (Betsimisaraka / Bezanozano)",
  "Nord (Antakarana / Tsimihety)": "Avaratra (Antakarana / Tsimihety)",
  "Sud (Tandroy / Mahafaly / Bara)": "Atsimo (Tandroy / Mahafaly / Bara)",
  "Ouest (Sakalava / Vezo)": "Andrefana (Sakalava / Vezo)",
  "Sud-Est (Antemoro / Antefasy / Tanala)":
      "Atsimo Atsinanana (Antemoro / Antefasy / Tanala)",
  "Diaspora • Apprentissage universel": "Diaspora • Fianarana ho an'ny rehetra",
};

// ---------------------------------------------------------------------------
// Affichage en français : le code source est déjà en français, on adapte
// seulement le nom des langues proposées dans le sélecteur.
// ---------------------------------------------------------------------------
const Map<String, String> _fr = {
  'Malagasy': 'Malgache',
};

// Version en minuscules du dictionnaire (pour les textes en MAJUSCULES)
final Map<String, String> _mgLower = {
  for (final e in _mg.entries) e.key.toLowerCase(): e.value
};
