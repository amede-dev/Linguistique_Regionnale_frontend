import 'package:flutter/material.dart';
import 'models.dart';

const allRegionsLabel = 'Toutes les régions';

const words = <Word>[
  Word(
    id: 'tsara_bia',
    term: 'Tsara bia',
    phonetic: '/tsa.ra bi.a/',
    meaning:
        "Très bien, magnifique ! Variante côtière orientale de l'expression commune « Tsara be », exprimant l'admiration joyeuse et cordiale.",
    region: 'Toamasina',
    dialect: 'Betsimisaraka',
    example: '« Tsara bia ny fiainana aty amoron-dranomasina ! »',
    exampleFr: '(La vie est si douce et magnifique ici au bord de la mer !)',
    note: 'Enregistré à Tamatave',
    seconds: 2,
    popularity: 95,
  ),
  Word(
    id: 'salama_tsara',
    term: 'Salama tsara',
    phonetic: '/sa.la.ma tsa.ra/',
    meaning:
        'Bonjour, formule cordiale de salutation pour souhaiter la paix et le bien-être continu.',
    region: 'Antananarivo',
    dialect: 'Merina / Hauts Plateaux',
    note: 'Locuteur natif certifié',
    seconds: 3,
    popularity: 90,
    trending: true,
  ),
  Word(
    id: 'akory_aby',
    term: 'Akory aby',
    phonetic: '/a.kuri a.bi/',
    meaning: 'Comment allez-vous tous ?',
    region: 'Mahajanga',
    dialect: 'Nord & Sakalava',
    note: 'Locuteur vérifié • Majunga',
    seconds: 4,
    popularity: 70,
    trending: true,
  ),
  Word(
    id: 'akory_aby_anareo',
    term: 'Akory aby anareo',
    phonetic: '/a.kuri a.bi a.na.reo/',
    meaning:
        'Comment allez-vous tous ? Salutation collective chaleureuse et fraternelle des régions côtières.',
    region: 'Toamasina',
    dialect: 'Côte Est (Betsimisaraka)',
    note: "Vérifié par l'Académie Malgache",
    seconds: 4,
    popularity: 60,
  ),
  Word(
    id: 'fihavanana',
    term: 'Fihavanana',
    phonetic: '/fi.ha.va.na.na/',
    meaning:
        'Concept philosophique fondamental de solidarité, fraternité et lien communautaire sacré unissant le peuple.',
    region: 'Antananarivo',
    dialect: 'Pannational',
    type: 'Mots isolés',
    category: 'Famille & Respect',
    note: 'Trésor immatériel',
    seconds: 5,
    popularity: 99,
    trending: true,
  ),
  Word(
    id: 'misaotra_anareo',
    term: 'Misaotra anareo',
    phonetic: '/miˈsawtʂə aˈnaɾew/',
    meaning:
        'Formule chaleureuse pour signifier « grand merci à vous » dans le septentrion malgache. Équivalent cordial de politesse communautaire.',
    region: 'Antsiranana',
    dialect: 'Antakarana',
    note: 'Locuteur vérifié • Diego-Suarez',
    seconds: 4,
    popularity: 80,
  ),
  Word(
    id: 'akory_heno',
    term: 'Akory heno',
    phonetic: '/aˈkuɾi ˈhenu/',
    meaning:
        "Salutation chaleureuse et marque de gratitude spontanée lorsqu'on reçoit un voyageur ou un bienfait au bord du canal de Mozambique.",
    region: 'Toliara',
    dialect: 'Tandroy / Vezo',
    note: '3 variantes régionales • Mahafaly, Vezo',
    seconds: 3,
    popularity: 65,
  ),
  Word(
    id: 'misaotra_betsaka',
    term: 'Misaotra betsaka',
    phonetic: '/miˈsotʂə ˈbetsakə/',
    meaning:
        'Remerciement profond intégrant la générosité de la côte Est luxuriante. Signifie littéralement « grandement reconnaissant ».',
    region: 'Toamasina',
    dialect: 'Betsimisaraka',
    example: "« Misaotra betsaka tamin'ny fandraisana vahiny tao an-tanàna. »",
    exampleFr:
        "« Merci infiniment pour l'accueil hospitalier accordé au village. »",
    note: 'Pédagogique • accent côtier',
    seconds: 5,
    popularity: 85,
  ),
  Word(
    id: 'ohabolana_fihavanana',
    term: 'Ny fihavanana toy ny kofehy manify',
    meaning:
        'Le lien fraternel est comme un fil fin : rompu, il peut se renouer.',
    region: 'Antananarivo',
    dialect: 'Merina',
    type: 'Proverbes (Ohabolana)',
    category: 'Proverbes (Ohabolana)',
    note: 'Teny Soa • sagesse ancestrale',
    seconds: 5,
    popularity: 75,
    trending: true,
  ),
  Word(
    id: 'veloma',
    term: 'Veloma',
    phonetic: '/ve.lu.ma/',
    meaning:
        'Formule chaleureuse et solennelle signifiant littéralement « Soyez vivant / Portez-vous bien », utilisée lors de la séparation ou comme vœu de prospérité durable.',
    region: 'Fianarantsoa',
    dialect: 'Betsileo',
    category: 'Salutations',
    example:
        "« Veloma tompoko ô, enga anie ka samy ho tahin'Andriamanitra isika rehetra ! »",
    exampleFr:
        "« Au revoir monsieur/madame, que la grâce divine veille sur chacun de nous ! »",
    note: 'Fleuryssa R. (Locutrice Betsileo)',
    seconds: 3,
    popularity: 88,
    etymology:
        "Racine proto-malayo-polynésienne *ma-hudip (« être vivant »). Cognat du tagalog mabuhay et de l'indonésien hidup. L'accent porte sur l'avant-dernière syllabe : vé-lo-ma.",
    variants: [
      Variant(
          'Hauts-Plateaux • Merina',
          'Mandra-pihaona',
          "Forme standardisée très courante en milieu urbain et administratif signifiant « Jusqu'à notre prochaine rencontre ».",
          'Formel • Urbain',
          98),
      Variant(
          'Côte Est • Betsimisaraka',
          'Veloma e ! / Tsara mandeha',
          "Accentué sur la dernière syllabe étirée avec intonation chantante. « Tsara mandeha » insiste sur la bénédiction du voyageur en mer ou le long du canal des Pangalanes.",
          'Chaleureux • Périple',
          94),
      Variant(
          'Nord-Ouest • Sakalava du Boeny',
          'Aza marary / Akory hely',
          "« Aza marary » (« Ne tombe point malade ») témoigne du rôle tutélaire de la communauté. Intonation vive, souvent accompagnée d'un claquement de mains discret.",
          'Protecteur • Familier',
          91),
      Variant(
          'Sud-Ouest • Vezo & Tandroy',
          'Soa mandeha / Veloma Baba',
          'Marque le respect des aînés dans les terres arides du Grand Sud.',
          'Traditionnel • Respectueux',
          96),
    ],
  ),
];

Word wordById(String id) => words.firstWhere((w) => w.id == id);

const regions = <Region>[
  Region(
      code: 'AN',
      name: 'Antananarivo',
      dialects: 'Merina & Hauts-Plateaux',
      zone: 'Hauts-Plateaux',
      badge: 'Vérifié',
      subtitle: 'Merina • Hautes Terres centrales',
      quote: '"Akory natao, manao ahoana?"',
      icon: Icons.account_balance,
      words: 1420,
      expressions: 215,
      contributors: 48,
      dialectCount: 3,
      order: 3),
  Region(
      code: 'TO',
      name: 'Toamasina',
      dialects: 'Betsimisaraka & Est',
      zone: 'Côte Est',
      badge: 'Actif',
      subtitle: 'Betsimisaraka • Grand port maritime',
      quote: '"Akory aby anareo..."',
      icon: Icons.water,
      words: 980,
      expressions: 140,
      contributors: 32,
      dialectCount: 4,
      order: 2),
  Region(
      code: 'FI',
      name: 'Fianarantsoa',
      dialects: 'Betsileo, Tanala',
      zone: 'Hauts-Plateaux',
      badge: 'Vérifié',
      subtitle: 'Betsileo • Pays des terrasses rizicoles',
      quote: '"Salama tsara e!"',
      icon: Icons.filter_hdr,
      words: 1150,
      expressions: 180,
      contributors: 39,
      dialectCount: 5,
      order: 4),
  Region(
      code: 'MJ',
      name: 'Mahajanga',
      dialects: 'Sakalava du Boina',
      zone: 'Côte Ouest',
      badge: 'En cours',
      subtitle: 'Sakalava • Cité des fleurs et du Boeny',
      quote: '"Akory kabaro!"',
      icon: Icons.wb_sunny,
      words: 870,
      expressions: 110,
      contributors: 25,
      dialectCount: 2,
      order: 1),
  Region(
      code: 'TL',
      name: 'Toliara',
      dialects: 'Antandroy, Mahafaly',
      zone: 'Grand Sud',
      badge: 'Actif',
      subtitle: 'Vezo / Tandroy / Mahafaly • Terres arides',
      quote: '"Manao akory ty anie..."',
      icon: Icons.sailing,
      words: 1040,
      expressions: 160,
      contributors: 31,
      dialectCount: 4,
      order: 5),
  Region(
      code: 'AS',
      name: 'Antsiranana',
      dialects: 'Antakarana, Tsimihety',
      zone: 'Grand Nord',
      badge: 'Communautaire',
      subtitle: 'Antakarana / Tsimihety • Baie de Diego',
      quote: '"Mbarakaly, akory tsara!"',
      icon: Icons.terrain,
      words: 760,
      expressions: 95,
      contributors: 22,
      dialectCount: 3,
      order: 0),
];

const zones = [
  allRegionsLabel,
  'Hauts-Plateaux',
  'Côte Est',
  'Côte Ouest',
  'Grand Sud',
  'Grand Nord'
];

IconData regionIcon(String name) =>
    regions.firstWhere((r) => r.name == name, orElse: () => regions.first).icon;

int regionOrder(String name) => regions
    .firstWhere((r) => r.name == name, orElse: () => regions.first)
    .order;

// Les 18 ethnies officiellement reconnues à Madagascar, listées
// individuellement pour n'en oublier aucune (+ Vezo, déjà cité ailleurs
// dans l'app, + une option Diaspora).
const dialectChoices = [
  'Antaifasy',
  'Antaimoro',
  'Antaisaka',
  'Antakarana',
  'Antambahoaka',
  'Antandroy',
  'Antanosy',
  'Bara',
  'Betsileo',
  'Betsimisaraka',
  'Bezanozano',
  'Mahafaly',
  'Makoa',
  'Merina',
  'Sakalava',
  'Sihanaka',
  'Tanala',
  'Tsimihety',
  'Vezo',
  'Diaspora • Apprentissage universel',
];

// Nombre d'ethnies proposées au choix (sans compter l'option Diaspora),
// à réutiliser partout où ce total doit s'afficher, pour ne plus jamais
// se désynchroniser de la vraie liste.
final ethnieCount = dialectChoices.length - 1;
