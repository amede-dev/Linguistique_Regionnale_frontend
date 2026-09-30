import 'dart:io';
import 'package:flutter/material.dart' hide Text;
import '../core/app_state.dart';
import '../core/i18n.dart';
import '../core/theme.dart';

void toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(msg, style: ts(13, w5, color: Colors.white)),
      behavior: SnackBarBehavior.floating,
      backgroundColor: C.inverseSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
}

class LogoMark extends StatelessWidget {
  final double size;
  const LogoMark({super.key, this.size = 36});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
            shape: BoxShape.circle, color: C.primaryContainer),
        child: Icon(Icons.record_voice_over,
            color: Colors.white, size: size * .55),
      );
}

class CardBox extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final VoidCallback? onTap;
  const CardBox(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(16),
      this.color = C.lowest,
      this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2))
            ],
          ),
          child: child,
        ),
      );
}

class Pill extends StatelessWidget {
  final String text;
  final Color bg, fg;
  final IconData? icon;
  const Pill(this.text,
      {super.key, this.bg = C.container, this.fg = C.onVariant, this.icon});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4)
          ],
          Flexible(
              child: Text(text,
                  overflow: TextOverflow.ellipsis,
                  style: ts(11, w6, color: fg))),
        ]),
      );
}

class PBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool outlined;
  const PBtn(this.label,
      {super.key, this.icon, this.onTap, this.outlined = false});
  @override
  Widget build(BuildContext context) {
    final fg = outlined ? C.primary : Colors.white;
    final child = Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Flexible(
          child: Text(label,
              textAlign: TextAlign.center, style: ts(14, w7, color: fg))),
      if (icon != null) ...[
        const SizedBox(width: 8),
        Icon(icon, size: 18, color: fg)
      ],
    ]);
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: outlined
          ? OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                  shape: const StadiumBorder(),
                  side:
                      const BorderSide(color: C.primaryContainer, width: 1.5)),
              child: child)
          : FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                  backgroundColor: C.primaryContainer,
                  shape: const StadiumBorder()),
              child: child),
    );
  }
}

class ChipsRow extends StatelessWidget {
  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelect;
  const ChipsRow(
      {super.key,
      required this.items,
      required this.selected,
      required this.onSelect});
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final s = items[i] == selected;
            return GestureDetector(
              onTap: () => onSelect(items[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: s ? C.primaryContainer : C.lowest,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                      color: s ? C.primaryContainer : C.outlineVariant),
                ),
                child: Text(items[i],
                    style: ts(13, w6, color: s ? Colors.white : C.onVariant)),
              ),
            );
          },
        ),
      );
}

OutlineInputBorder _b(Color c) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: c, width: c == C.primary ? 1.5 : 1));

InputDecoration fieldDec(String hint, {IconData? icon, Widget? suffix}) =>
    InputDecoration(
      hintText: tr(hint),
      hintStyle: ts(14, w4, color: C.outline),
      prefixIcon: icon != null ? Icon(icon, color: C.outline, size: 20) : null,
      suffixIcon: suffix,
      filled: true,
      fillColor: C.lowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: _b(C.outlineVariant),
      enabledBorder: _b(C.outlineVariant),
      focusedBorder: _b(C.primary),
      errorBorder: _b(C.error),
      focusedErrorBorder: _b(C.error),
    );

class FieldLabel extends StatelessWidget {
  final String text;
  final String? trailing;
  const FieldLabel(this.text, {super.key, this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 14),
        child: Row(children: [
          Expanded(child: Text(text, style: ts(13, w6))),
          if (trailing != null)
            Text(trailing!, style: ts(11, w5, color: C.outline)),
        ]),
      );
}

/// En-tête des écrans à onglets.
class TabHeader extends StatelessWidget {
  final String title;
  final bool showBrand; // texte "TENY GASY"
  final bool showNotification; // icône cloche

  const TabHeader({
    super.key,
    required this.title,
    this.showBrand = true,
    this.showNotification = true,
  });

  @override
  Widget build(BuildContext context) => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: a(C.surface, .95), boxShadow: const [
          BoxShadow(
              color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 1))
        ]),
        child: Row(children: [
          const LogoMark(size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showBrand)
                    Text('LANGUE MALGACHE',
                        style: ts(11, w5,
                            color: C.tertiary, ls: 1.2, height: 1.1)),
                  Text(title,
                      overflow: TextOverflow.ellipsis,
                      style: ts(18, w6, height: 1.2)),
                ]),
          ),
          if (showNotification)
            IconButton(
              onPressed: () => toast(context, 'Aucune nouvelle notification'),
              icon: const Icon(Icons.notifications_none, color: C.onVariant),
            ),
          GestureDetector(
            onTap: () => appState.setTab(4),
            child: const UserAvatar(radius: 16),
          ),
        ]),
      );
}

/// Avatar de l'utilisateur : photo de profil si elle existe, sinon les
/// initiales du nom. Utilisé partout (en-tête, profil...) pour rester
/// toujours synchronisé.
class UserAvatar extends StatelessWidget {
  final double radius;
  const UserAvatar({super.key, this.radius = 16});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final path = appState.profilePhoto;
          final initials = appState.userName
              .trim()
              .split(RegExp(r'\s+'))
              .where((e) => e.isNotEmpty)
              .take(2)
              .map((e) => e[0].toUpperCase())
              .join();
          return CircleAvatar(
            radius: radius,
            backgroundColor: C.primaryFixed,
            backgroundImage: path != null ? FileImage(File(path)) : null,
            child: path == null
                ? Text(initials, style: ts(radius * .7, w7, color: C.primary))
                : null,
          );
        },
      );
}

/// Lecteur audio simulé avec forme d'onde, durée et vitesse.
class AudioBar extends StatelessWidget {
  final String id;
  final int seconds;
  const AudioBar({super.key, required this.id, required this.seconds});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final playing = appState.playingId == id;
          final p = playing ? appState.progress : 0.0;
          final shown = playing ? (seconds * p).floor() : seconds;
          const n = 28;
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: C.low, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              GestureDetector(
                onTap: () => appState.togglePlay(id, seconds),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                      color: C.primary, shape: BoxShape.circle),
                  child: Icon(playing ? Icons.pause : Icons.play_arrow,
                      color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: Row(
                    children: List.generate(n, (i) {
                      final h = 6.0 + ((i * 7) % 5) * 5.0;
                      final active = i / n < p;
                      return Expanded(
                        child: Center(
                          child: Container(
                            width: 3,
                            height: h,
                            decoration: BoxDecoration(
                                color: active ? C.primary : a(C.primary, .3),
                                borderRadius: BorderRadius.circular(2)),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('0:${shown.toString().padLeft(2, '0')}',
                  style: ts(12, w6, color: C.onVariant)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: appState.cycleSpeed,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: C.container,
                      borderRadius: BorderRadius.circular(99)),
                  child: Text('${appState.speed}x',
                      style: ts(11, w7, color: C.primary)),
                ),
              ),
            ]),
          );
        },
      );
}

/// Carte d'appel à contribuer (Accueil, Recherche, Régions, Favoris).
class CtaCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle, button;
  final VoidCallback onTap;
  const CtaCard(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle,
      required this.button,
      required this.onTap});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
              colors: [C.primaryContainer, C.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: C.onPrimaryContainer, size: 28),
          const SizedBox(height: 10),
          Text(title, style: ts(18, w7, color: Colors.white)),
          const SizedBox(height: 4),
          Text(subtitle, style: ts(13, w4, color: C.onPrimaryContainer)),
          const SizedBox(height: 16),
          SizedBox(
            height: 46,
            child: FilledButton.icon(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: C.primary,
                  shape: const StadiumBorder()),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: Text(button, style: ts(13, w7, color: C.primary)),
            ),
          ),
        ]),
      );
}

class UsageExample extends StatelessWidget {
  final String text;
  final String? translation;
  const UsageExample(this.text, this.translation, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: a(C.tertiaryFixed, .45),
            borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.format_quote, size: 16, color: C.tertiary),
            const SizedBox(width: 4),
            Text("EXEMPLE D'USAGE",
                style: ts(10, w7, color: C.tertiary, ls: 1)),
          ]),
          const SizedBox(height: 6),
          Text(text, style: ts(14, w6, color: C.onSurface)),
          if (translation != null) ...[
            const SizedBox(height: 4),
            Text(translation!, style: ts(12, w4, color: C.onVariant)),
          ],
        ]),
      );
}

// ---------- Widgets d'authentification ----------
class AuthTabs extends StatelessWidget {
  final bool login;
  final VoidCallback onLogin, onSignup;
  const AuthTabs(
      {super.key,
      required this.login,
      required this.onLogin,
      required this.onSignup});
  Widget _tab(String t, bool sel, VoidCallback f) => Expanded(
        child: GestureDetector(
          onTap: f,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: sel ? C.lowest : Colors.transparent,
              borderRadius: BorderRadius.circular(99),
              boxShadow: sel
                  ? const [BoxShadow(color: Color(0x14000000), blurRadius: 6)]
                  : null,
            ),
            child: Text(t,
                style: ts(13, w7, color: sel ? C.primary : C.onVariant)),
          ),
        ),
      );
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: C.container, borderRadius: BorderRadius.circular(99)),
        child: Row(children: [
          _tab('Se connecter', login, onLogin),
          _tab("S'inscrire", !login, onSignup)
        ]),
      );
}

class SocialBtn extends StatelessWidget {
  final String label;
  final Widget leading;
  final VoidCallback onTap;
  const SocialBtn(this.label, this.leading, this.onTap, {super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 50,
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
              backgroundColor: C.lowest,
              shape: const StadiumBorder(),
              side: const BorderSide(color: C.outlineVariant)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            leading,
            const SizedBox(width: 10),
            Text(label, style: ts(14, w6)),
          ]),
        ),
      );
}

class OrDivider extends StatelessWidget {
  final String text;
  const OrDivider(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(children: [
          const Expanded(child: Divider(color: C.outlineVariant)),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(text, style: ts(12, w5, color: C.outline))),
          const Expanded(child: Divider(color: C.outlineVariant)),
        ]),
      );
}

final emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

final pillBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(99),
    borderSide: const BorderSide(color: C.outlineVariant));
