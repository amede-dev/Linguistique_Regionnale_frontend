import 'package:flutter/material.dart' hide Text;
import '../core/app_state.dart';
import '../core/nav.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import '../core/i18n.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Widget _chip(String t, IconData i) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: C.lowest,
          borderRadius: BorderRadius.circular(99),
          boxShadow: const [
            BoxShadow(
                color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, 3))
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(i, size: 16, color: C.primary),
          const SizedBox(width: 6),
          Text(t, style: ts(12, w6)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(children: [
            Row(children: [
              const LogoMark(size: 40),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('LANGUE MALGACHE',
                    style: ts(16, w7,
                        color: const Color.fromARGB(255, 8, 8, 8),
                        ls: 1,
                        height: 1.1)),
                Text('Patrimoine vivant', style: ts(11, w5, color: C.tertiary)),
              ]),
              const Spacer(),
              TextButton(
                  onPressed: () => goHome(context),
                  child: Text('Passer', style: ts(14, w6, color: C.onVariant))),
            ]),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      gradient: const LinearGradient(colors: [
                        C.primaryFixed,
                        C.surface,
                        C.secondaryContainer
                      ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    ),
                    child: Stack(alignment: Alignment.center, children: [
                      ClipOval(
                        child: Image.asset('assets/images/logo_madagascar.jpg',
                            width: 170, height: 170, fit: BoxFit.cover),
                      ),
                      Positioned(
                          top: 26,
                          left: 16,
                          child: _chip('Tsimihety', Icons.graphic_eq)),
                      Positioned(
                          top: 70,
                          right: 14,
                          child: _chip('Betsimisaraka', Icons.spatial_audio)),
                      Positioned(
                          bottom: 90,
                          left: 12,
                          child: _chip('Antandroy', Icons.record_voice_over)),
                      Positioned(
                          bottom: 44,
                          right: 22,
                          child: _chip('Sakalava', Icons.spatial_audio)),
                      Positioned(
                        bottom: 14,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: C.primaryContainer,
                              borderRadius: BorderRadius.circular(99)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.volume_up,
                                size: 14, color: Colors.white),
                            const SizedBox(width: 6),
                            Image.asset('assets/images/logo_vocal.png',
                                width: 22, height: 22),
                            const SizedBox(width: 6),
                            ListenableBuilder(
                              listenable: appState,
                              builder: (context, _) =>
                                  TweenAnimationBuilder<int>(
                                tween: IntTween(
                                    begin: 0, end: appState.voiceCount),
                                duration: const Duration(milliseconds: 900),
                                curve: Curves.easeOut,
                                builder: (context, value, _) => Text(
                                  '$value voix',
                                  style: ts(12, w7, color: Colors.white),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                      color: C.primaryFixed,
                      borderRadius: BorderRadius.circular(99)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.spa, size: 14, color: C.primary),
                    const SizedBox(width: 6),
                    Text('BIENVENUE SUR LINGUISTIQUE_RÉGIONALE',
                        maxLines: 1,
                        softWrap: false,
                        style: ts(11, w7, color: C.primary, ls: .8)),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Écoutez des prononciations authentiques, découvrez les nuances régionales et participez à la sauvegarde de notre patrimoine oral.",
              textAlign: TextAlign.center,
              style: ts(13, w4, color: C.onVariant),
            ),
            const SizedBox(height: 20),
            PBtn("Commencer l'exploration",
                icon: Icons.arrow_forward,
                onTap: () => push(context, const SignupScreen())),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => push(context, const LoginScreen()),
              child: Text("J'ai déjà un compte / Connexion",
                  style: ts(13, w6, color: const Color.fromARGB(255, 8, 8, 8))),
            ),
          ]),
        ),
      ),
    );
  }
}
