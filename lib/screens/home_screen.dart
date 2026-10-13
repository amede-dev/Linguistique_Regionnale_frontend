import 'package:flutter/material.dart' hide Text;
import '../core/app_state.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import '../core/i18n.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
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
              GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: appState.regions.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.08,
                  ),
                  itemBuilder: (_, i) {
                    final r = appState.regions[i];
                    return GestureDetector(
                      onTap: () => appState.openSearch(region: r.name),
                      child: Container(
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
                              Text(
                                  r.words > 0
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
            ]),
      ),
    ]);
  }
}
