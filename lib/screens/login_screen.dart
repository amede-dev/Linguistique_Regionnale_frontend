import 'package:flutter/material.dart' hide Text;
import '../core/app_state.dart';
import '../core/nav.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';
import '../core/i18n.dart';
import 'package:dio/dio.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _key = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pwd = TextEditingController();
  bool _hide = true, _remember = true;

  @override
  void dispose() {
    _email.dispose();
    _pwd.dispose();
    super.dispose();
  }

  bool _busy = false;
  String? _error;
  Future<void> _submit() async {
    if (!_key.currentState!.validate() || _busy) return;
    setState(() { _busy = true; _error = null; });
    try { await appState.login(_email.text, _pwd.text); if (mounted) goHome(context); }
    on DioException catch (e) { if (mounted) setState(() => _error = e.response?.statusCode == 401 ? 'E-mail ou mot de passe incorrect.' : 'Serveur indisponible.'); }
    catch (_) { if (mounted) setState(() => _error = 'Connexion impossible.'); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: C.onSurface),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: a(C.secondary, .15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.travel_explore, size: 16, color: C.secondary),
            const SizedBox(width: 6),
            Text('Recherche de mots', style: ts(12, w6, color: C.secondary)),
          ]),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Form(
            key: _key,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(
                child: Column(children: [
                  const LogoMark(size: 64),
                  const SizedBox(height: 8),
                  Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('LANGUE MALGACHE',
                            style: ts(20, w7, color: C.primary, ls: 1.5)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: a(C.tertiary, .15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('Patrimoine vivant',
                              style: ts(11, w6, color: C.tertiary)),
                        ),
                      ]),
                ]),
              ),
              const SizedBox(height: 20),
              Text('Bienvenue !', style: ts(24, w7)),
              const SizedBox(height: 4),
              Text(
                  'Connectez-vous pour retrouver vos favoris, synchroniser vos audios et participer à la communauté.',
                  style: ts(13, w4, color: C.onVariant)),
              const SizedBox(height: 16),
              AuthTabs(
                  login: true,
                  onLogin: () {},
                  onSignup: () => replace(context, const SignupScreen())),
              const SizedBox(height: 16),
              SocialBtn(
                  'Continuer avec Google',
                  Text('G', style: ts(18, w7, color: C.primaryContainer)),
                  () => toast(context, 'Connexion sociale non configurée.')),
              const SizedBox(height: 10),
              SocialBtn(
                  'Continuer avec Apple',
                  const Icon(Icons.apple, color: C.onSurface),
                  () => toast(context, 'Connexion sociale non configurée.')),
              const OrDivider('ou avec votre adresse e-mail'),
              const FieldLabel('Adresse e-mail'),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration:
                    fieldDec('nom@exemple.mg', icon: Icons.alternate_email),
                validator: (v) => emailRe.hasMatch((v ?? '').trim())
                    ? null
                    : 'Adresse e-mail invalide',
              ),
              const FieldLabel('Mot de passe'),
              TextFormField(
                controller: _pwd,
                obscureText: _hide,
                decoration: fieldDec('••••••••••••',
                    icon: Icons.lock_outline,
                    suffix: IconButton(
                        onPressed: () => setState(() => _hide = !_hide),
                        icon: Icon(
                            _hide
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: C.outline))),
                validator: (v) =>
                    (v ?? '').length >= 6 ? null : '6 caractères minimum',
              ),
              const SizedBox(height: 6),
              Row(children: [
                Checkbox(
                    value: _remember,
                    activeColor: C.primaryContainer,
                    onChanged: (v) => setState(() => _remember = v ?? false)),
                Text('Se souvenir de moi', style: ts(12, w5)),
                const Spacer(),
                TextButton(
                    onPressed: () =>
                        push(context, const ForgotPasswordScreen()),
                    child: Text('Mot de passe oublié ?',
                        style: ts(12, w6, color: C.primary))),
              ]),
              const SizedBox(height: 8),
              if (_error != null) Text(_error!, style: ts(12, w6, color: C.error)),
              PBtn(_busy ? 'Connexion...' : 'Se connecter', icon: Icons.arrow_forward, onTap: _submit),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.verified_user, size: 14, color: C.secondary),
                const SizedBox(width: 6),
                Flexible(
                    child: Text(
                        'Sécurisé par Supabase Auth • Chiffrement de bout en bout',
                        style: ts(11, w5, color: C.secondary))),
              ]),
              const SizedBox(height: 12),
              Center(
                  child: Text('Pas encore de compte ?',
                      style: ts(13, w4, color: C.onVariant))),
              TextButton(
                  onPressed: () => replace(context, const SignupScreen()),
                  child: Text('Créer un compte gratuitement',
                      style: ts(13, w7, color: C.primary))),
            ]),
          ),
        ),
      ),
    );
  }
}
