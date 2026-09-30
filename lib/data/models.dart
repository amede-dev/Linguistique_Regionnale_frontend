import 'package:flutter/material.dart';

class Variant {
  final String area, forms, text, nuance;
  final int consensus;
  const Variant(this.area, this.forms, this.text, this.nuance, this.consensus);
}

class Word {
  final String id, term, phonetic, meaning, region, dialect, type, category, note;
  final String? example, exampleFr, etymology;
  final int seconds, popularity;
  final bool trending;
  final List<Variant> variants;

  const Word({
    required this.id,
    required this.term,
    this.phonetic = '',
    required this.meaning,
    required this.region,
    required this.dialect,
    this.type = 'Expressions',
    this.category = 'Salutations',
    this.note = 'Validé par la communauté',
    this.example,
    this.exampleFr,
    this.etymology,
    this.seconds = 3,
    this.popularity = 50,
    this.trending = false,
    this.variants = const [],
  });

  factory Word.fromJson(Map<String, dynamic> j) => Word(
    id: '${j['id'] ?? j['slug'] ?? ''}', term: '${j['term'] ?? ''}',
    phonetic: '${j['phonetic'] ?? ''}', meaning: '${j['meaning'] ?? ''}',
    region: '${j['region_name'] ?? j['region'] ?? ''}', dialect: '${j['dialect'] ?? ''}',
    type: '${j['type'] ?? 'Expressions'}', category: '${j['category'] ?? 'Salutations'}',
    note: '${j['note'] ?? ''}', example: j['example'] as String?, exampleFr: j['example_fr'] as String?,
    etymology: j['etymology'] as String?, seconds: (j['seconds'] as num?)?.toInt() ?? 0,
    popularity: (j['popularity'] as num?)?.toInt() ?? 0, trending: j['trending'] == true,
  );
}

class Region {
  final String code, name, dialects, zone, badge, subtitle, quote;
  final IconData icon;
  final int words, expressions, contributors, dialectCount, order;

  const Region({
    required this.code,
    required this.name,
    required this.dialects,
    required this.zone,
    required this.badge,
    required this.subtitle,
    required this.quote,
    required this.icon,
    required this.words,
    required this.expressions,
    required this.contributors,
    required this.dialectCount,
    required this.order,
  });

  factory Region.fromJson(Map<String, dynamic> j) => Region(
    code: '${j['code'] ?? ''}', name: '${j['name'] ?? ''}', dialects: '${j['dialects'] ?? ''}',
    zone: '${j['zone'] ?? ''}', badge: '${j['badge'] ?? ''}', subtitle: '${j['subtitle'] ?? ''}',
    quote: '${j['quote'] ?? ''}', icon: Icons.language,
    words: (j['words'] as num?)?.toInt() ?? 0, expressions: (j['expressions'] as num?)?.toInt() ?? 0,
    contributors: (j['contributors'] as num?)?.toInt() ?? 0, dialectCount: (j['dialect_count'] as num?)?.toInt() ?? 0,
    order: (j['sort_order'] as num?)?.toInt() ?? 0,
  );
}
