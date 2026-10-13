import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide Text;
import '../core/app_state.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import '../core/i18n.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _key = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _code = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _sent = false, _busy = false, _hideNext = true, _hideConfirm = true;
  bool _sms = false;

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    _code.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_key.currentState!.validate() || _busy) return;
    setState(() => _busy = true);
    try {
      if (_sms) {
        await appState.requestPasswordResetSms(_phone.text);
      } else {
        await appState.requestPasswordReset(_email.text);
      }
      if (mounted) setState(() => _sent = true);
    } on DioException catch (e) {
      if (mounted) {
        final data = e.response?.data;
        final message = data is Map && data['message'] != null
            ? '${data['message']}'
            : (_sms ? 'Service SMS indisponible.' : 'Service d’e-mail indisponible.');
        toast(context, message);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reset() async {
    if (!_key.currentState!.validate() || _busy) return;
    setState(() => _busy = true);
    try {
      if (_sms) {
        await appState.resetPasswordSms(_phone.text, _code.text, _next.text);
      } else {
        await appState.resetPassword(_email.text, _code.text, _next.text);
      }
      if (mounted) {
        toast(context, 'Mot de passe réinitialisé avec succès.');
        Navigator.pop(context);
      }
    } on DioException catch (e) {
      if (mounted) {
        final data = e.response?.data;
        final message = data is Map && data['message'] != null
            ? '${data['message']}'
            : 'Code invalide ou expiré.';
        toast(context, message);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: C.onSurface),
        title: Text('Mot de passe oublié', style: ts(15, w6)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Form(
            key: _key,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: const BoxDecoration(
                      color: C.primaryFixed, shape: BoxShape.circle),
                  child: const Icon(Icons.lock_reset, size: 42, color: C.primary),
                ),
              ),
              const SizedBox(height: 20),
              Text(_sent ? 'Réinitialiser le mot de passe' : 'Mot de passe oublié ?',
                  style: ts(24, w7)),
              const SizedBox(height: 6),
              Text(
                  _sent
                      ? (_sms
                          ? 'Saisissez le code reçu par SMS et choisissez un nouveau mot de passe.'
                          : 'Saisissez le code reçu par e-mail et choisissez un nouveau mot de passe.')
                      : (_sms
                          ? 'Saisissez le numéro associé à votre compte pour recevoir un code sécurisé par SMS.'
                          : "Saisissez l'adresse e-mail associée à votre compte pour recevoir un code sécurisé."),
                  style: ts(13, w4, color: C.onVariant)),
              const SizedBox(height: 18),
              if (!_sent)
                OptionTabs(
                  first: 'E-mail',
                  second: 'SMS',
                  firstSelected: !_sms,
                  onFirst: () => setState(() => _sms = false),
                  onSecond: () => setState(() => _sms = true),
                ),
              FieldLabel(_sms ? 'Numéro de téléphone' : 'Adresse e-mail'),
              if (_sms)
                TextFormField(
                  controller: _phone,
                  readOnly: _sent,
                  keyboardType: TextInputType.phone,
                  decoration: fieldDec('03XXXXXXXX', icon: Icons.phone_outlined),
                  validator: (v) {
                    final phone = (v ?? '').replaceAll(RegExp(r'[\s()-]'), '');
                    return RegExp(r'^(?:0|\+261|261)3\d{8}$').hasMatch(phone)
                        ? null
                        : 'Numéro malgache invalide';
                  },
                )
              else
                TextFormField(
                  controller: _email,
                  readOnly: _sent,
                  keyboardType: TextInputType.emailAddress,
                  decoration: fieldDec(tr('votre.email@domaine.mg'), icon: Icons.mail_outline),
                  validator: (v) => emailRe.hasMatch((v ?? '').trim())
                      ? null
                      : 'Adresse e-mail invalide',
                ),
              if (_sent) ...[
                const FieldLabel('Code de réinitialisation'),
                TextFormField(
                  controller: _code,
                  keyboardType: TextInputType.number,
                  decoration: fieldDec('123456', icon: Icons.pin_outlined),
                  validator: (v) => (v ?? '').trim().length == 6
                      ? null
                      : 'Saisissez le code à 6 chiffres',
                ),
                const FieldLabel('Nouveau mot de passe'),
                TextFormField(
                  controller: _next,
                  obscureText: _hideNext,
                  decoration: fieldDec(tr('8 caractères minimum'),
                      icon: Icons.lock_reset,
                      suffix: IconButton(
                          onPressed: () => setState(() => _hideNext = !_hideNext),
                          icon: Icon(_hideNext
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined))),
                  validator: (v) => (v ?? '').length >= 8
                      ? null
                      : '8 caractères minimum',
                ),
                const FieldLabel('Confirmation du mot de passe'),
                TextFormField(
                  controller: _confirm,
                  obscureText: _hideConfirm,
                  decoration: fieldDec('••••••••', icon: Icons.verified_user_outlined,
                      suffix: IconButton(
                          onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
                          icon: Icon(_hideConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined))),
                  validator: (v) => v == _next.text
                      ? null
                      : 'Les mots de passe ne correspondent pas',
                ),
              ],
              const SizedBox(height: 18),
              PBtn(
                _busy
                    ? 'Envoi en cours...'
                    : (_sent ? 'Réinitialiser le mot de passe' : 'Envoyer le code'),
                icon: Icons.send,
                onTap: _busy ? null : (_sent ? _reset : _sendCode),
              ),
              if (_sent)
                Center(
                  child: TextButton(
                    onPressed: _busy ? null : () => setState(() => _sent = false),
                    child: Text('Renvoyer un code',
                        style: ts(12, w6, color: C.primary)),
                  ),
                ),
              const SizedBox(height: 20),
              Row(children: [
                const Icon(Icons.verified_user, size: 16, color: C.secondary),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(
                        'Données linguistiques protégées • Vos contributions restent sauvegardées',
                        style: ts(11, w5, color: C.secondary))),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
