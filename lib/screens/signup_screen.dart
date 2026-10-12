import 'package:flutter/material.dart' hide Text;
import '../core/app_state.dart';
import '../data/api/api_client.dart';
import '../core/nav.dart';
import '../core/theme.dart';
import 'package:dio/dio.dart';
import '../widgets/common.dart';
import 'login_screen.dart';
import '../core/i18n.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pwd = TextEditingController();
  final _pwd2 = TextEditingController();
  String? _dialect;
  List<String> _regions = const [];
  bool _regionsLoading = true;
  bool _hide = true;

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  Future<void> _loadRegions() async {
    try {
      final data = await apiClient.regions();
      if (!mounted) return;
      setState(() {
        _regions = data
            .whereType<Map>()
            .map((e) => '${e['name'] ?? ''}')
            .where((name) => name.isNotEmpty)
            .toList();
        _regionsLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _regionsLoading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _pwd.dispose();
    _pwd2.dispose();
    super.dispose();
  }

  ({String label, Color color}) get _strength {
    final p = _pwd.text;
    if (p.length >= 8 && RegExp(r'\d').hasMatch(p)) {
      return (label: 'Robuste', color: C.secondary);
    }
    if (p.length >= 6) return (label: 'Moyenne', color: C.tertiaryContainer);
    return (label: 'Faible', color: C.error);
  }

  bool _busy = false;
  String? _error;
  Future<void> _googleSignup() async {
    if (_busy) return;
    if (_dialect == null) {
      setState(() =>
          _error = 'Sélectionnez votre région avant de continuer avec Google.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await appState.loginWithGoogle(region: _dialect);
      if (mounted) goHome(context);
    } on DioException catch (e) {
      if (mounted)
        setState(() => _error = 'Inscription Google impossible (' +
            (e.response?.statusCode ?? 'réseau').toString() +
            ').');
    } catch (e) {
      if (mounted && !e.toString().contains('annulée'))
        setState(() => _error = 'Inscription Google impossible.');
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
      await appState.register(_name.text, _email.text, _phone.text, _pwd.text,
          region: _dialect);
      if (mounted) goHome(context);
    } on DioException catch (e) {
      if (mounted)
        setState(() => _error = e.response?.statusCode == 409
            ? 'Cet e-mail est déjà utilisé.'
            : 'Inscription impossible.');
    } catch (_) {
      if (mounted) setState(() => _error = 'Inscription impossible.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _strength;
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
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: a(C.secondary, .15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Rejoignez la communauté',
                      textAlign: TextAlign.center,
                      style: ts(13, w6, color: C.secondary)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                  'Participez à la sauvegarde et à la transmission vivante du patrimoine linguistique de Madagascar.',
                  style: ts(13, w4, color: C.onVariant)),
              const SizedBox(height: 16),
              AuthTabs(
                  login: false,
                  onLogin: () => replace(context, const LoginScreen()),
                  onSignup: () {}),
              const SizedBox(height: 16),
              SocialBtn(
                  "S'inscrire avec Google",
                  Text('G', style: ts(18, w7, color: C.primaryContainer)),
                  _googleSignup),
              const OrDivider('ou avec votre adresse e-mail'),
              const FieldLabel('Nom complet ou pseudonyme', trailing: 'Public'),
              TextFormField(
                controller: _name,
                decoration: fieldDec('ex: Haingo Razafindrakoto',
                    icon: Icons.person_outline),
                validator: (v) =>
                    (v ?? '').trim().length >= 2 ? null : 'Champ requis',
              ),
              const FieldLabel('Adresse e-mail valide'),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: fieldDec('haingo.razafy@tanindrazana.mg',
                    icon: Icons.mail_outline),
                validator: (v) => emailRe.hasMatch((v ?? '').trim())
                    ? null
                    : 'Adresse e-mail invalide',
              ),
              const FieldLabel('Numéro de téléphone', trailing: 'Pour les codes SMS'),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: fieldDec('0382099195', icon: Icons.phone_outlined),
                validator: (v) => RegExp(r'^(?:0|\+261|261)3\d{8}$')
                        .hasMatch((v ?? '').replaceAll(RegExp(r'[\s()-]'), ''))
                    ? null
                    : 'Numéro malgache invalide',
              ),
              const FieldLabel("Région d'attache", trailing: '* Obligatoire'),
              DropdownButtonFormField<String>(
                value: _dialect,
                isExpanded: true,
                decoration: fieldDec(
                    _regionsLoading
                        ? 'Chargement des régions...'
                        : 'Sélectionnez votre région',
                    icon: Icons.explore_outlined),
                items: _regions
                    .map((region) => DropdownMenuItem<String>(
                          value: region,
                          child: Text(region, overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: _regionsLoading
                    ? null
                    : (value) => setState(() => _dialect = value),
                validator: (value) => value == null || value.isEmpty
                    ? 'Sélectionnez votre région'
                    : null,
              ),
              const FieldLabel('Mot de passe'),
              TextFormField(
                controller: _pwd,
                obscureText: _hide,
                onChanged: (_) => setState(() {}),
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
                    (v ?? '').length >= 8 && RegExp(r'\d').hasMatch(v!)
                        ? null
                        : '8 caractères min. • 1 chiffre',
              ),
              if (_pwd.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(children: [
                    Icon(Icons.check_circle, size: 14, color: s.color),
                    const SizedBox(width: 4),
                    Text('Force : ${s.label}',
                        style: ts(11, w6, color: s.color)),
                    const Spacer(),
                    Text('8 caractères min. • 1 chiffre',
                        style: ts(11, w4, color: C.outline)),
                  ]),
                ),
              const FieldLabel('Confirmation du mot de passe'),
              TextFormField(
                controller: _pwd2,
                obscureText: _hide,
                decoration: fieldDec('••••••••••••',
                    icon: Icons.verified_user_outlined),
                validator: (v) => v == _pwd.text
                    ? null
                    : 'Les mots de passe ne correspondent pas',
              ),
              const SizedBox(height: 16),
              PBtn('Créer mon compte explorateur',
                  icon: Icons.arrow_forward, onTap: _submit),
              const SizedBox(height: 14),
              Center(
                child: Text.rich(
                    TextSpan(style: ts(13, w4, color: C.onVariant), children: [
                  const TextSpan(text: 'Déjà membre ? '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: () => replace(context, const LoginScreen()),
                      child: Text('Se connecter',
                          style: ts(13, w7, color: C.primary)),
                    ),
                  ),
                ])),
              ),
              const SizedBox(height: 10),
              Center(
                  child: Text(
                      'Aide phonétique • Confidentialité • Académie Malgache',
                      style: ts(11, w4, color: C.outline))),
            ]),
          ),
        ),
      ),
    );
  }
}
