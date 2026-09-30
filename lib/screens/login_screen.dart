import 'package:flutter/material.dart' hide Text;
import '../core/app_state.dart';
import '../core/nav.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
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
  Future<void> _googleLogin() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await appState.loginWithGoogle();
      if (mounted) goHome(context);
    } on DioException catch (e) {
      if (mounted)
        setState(() => _error = 'Connexion Google impossible (' +
            (e.response?.statusCode ?? 'réseau').toString() +
            ').');
    } catch (e) {
      if (mounted && !e.toString().contains('annulée'))
        setState(() => _error = 'Connexion Google impossible.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    if (!_key.currentState!.validate() || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await appState.login(_email.text, _pwd.text);
      if (mounted) goHome(context);
    } on DioException catch (e) {
      if (mounted)
        setState(() => _error = e.response?.statusCode == 401
            ? 'E-mail ou mot de passe incorrect.'
            : 'Serveur indisponible.');
    } catch (_) {
      if (mounted) setState(() => _error = 'Connexion impossible.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: C.onSurface),
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          const LogoMark(size: 28),
          const SizedBox(width: 6),
          Text('LANGUE MALGACHE', style: ts(13, w7, color: C.primary, ls: .4)),
        ]),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Form(
            key: _key,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 12),
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
                  _googleLogin),
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
              ]),
              const SizedBox(height: 8),
              if (_error != null)
                Text(_error!, style: ts(12, w6, color: C.error)),
              PBtn(_busy ? 'Connexion...' : 'Se connecter',
                  icon: Icons.arrow_forward, onTap: _submit),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.verified_user, size: 14, color: C.secondary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text('Authentification sécurisée par le serveur',
                      style: ts(11, w5, color: C.secondary)),
                ),
              ]),
              const SizedBox(height: 12),
              Center(
                child: Text('Pas encore de compte ?',
                    style: ts(13, w4, color: C.onVariant)),
              ),
              TextButton(
                onPressed: () => replace(context, const SignupScreen()),
                child: Text('Créer un compte gratuitement',
                    style: ts(13, w7, color: C.primary)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
