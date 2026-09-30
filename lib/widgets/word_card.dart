import 'package:flutter/material.dart' hide Text;
import '../core/app_state.dart';
import '../core/nav.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../screens/word_detail_screen.dart';
import 'common.dart';
import '../core/i18n.dart';

/// Carte de mot utilisée par la Recherche et les Favoris.
class WordCard extends StatelessWidget {
  final Word word;
  final bool removable;
  const WordCard(this.word, {super.key, this.removable = false});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final fav = appState.isFav(word.id);
        return CardBox(
          onTap: () => push(context, WordDetailScreen(word: word)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Wrap(spacing: 6, runSpacing: 4, children: [
                  Pill('${word.region}',
                      bg: C.secondaryContainer,
                      fg: C.onSecondaryContainer,
                      icon: appState.regionIcon(word.region)),
                  Pill(word.dialect, bg: C.tertiaryFixed, fg: C.tertiary),
                ]),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => appState.toggleFav(word.id),
                icon: Icon(fav ? Icons.favorite : Icons.favorite_border,
                    color: fav ? C.primaryContainer : C.outline),
              ),
            ]),
            const SizedBox(height: 6),
            Text(word.term, style: ts(22, w7, color: C.primary, height: 1.2)),
            if (word.phonetic.isNotEmpty)
              Text(word.phonetic, style: ts(12, w5, color: C.outline, ls: .3)),
            const SizedBox(height: 8),
            Text(word.meaning, style: ts(14, w4, color: C.onSurface)),
            if (word.example != null) ...[
              const SizedBox(height: 10),
              UsageExample(word.example!, word.exampleFr),
            ],
            const SizedBox(height: 12),
            AudioBar(id: word.id, seconds: word.seconds),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.verified, size: 15, color: C.secondary),
              const SizedBox(width: 4),
              Expanded(
                  child: Text(word.note,
                      overflow: TextOverflow.ellipsis,
                      style: ts(11, w5, color: C.secondary))),
              if (removable)
                TextButton.icon(
                  onPressed: () {
                    appState.toggleFav(word.id);
                    toast(context, '« ${word.term} » retiré des favoris');
                  },
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: C.error),
                  label: Text('Retirer', style: ts(12, w6, color: C.error)),
                )
              else
                TextButton(
                  onPressed: () => push(context, WordDetailScreen(word: word)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Voir fiche', style: ts(12, w7, color: C.primary)),
                    const Icon(Icons.chevron_right, size: 18, color: C.primary),
                  ]),
                ),
            ]),
          ]),
        );
      },
    );
  }
}
