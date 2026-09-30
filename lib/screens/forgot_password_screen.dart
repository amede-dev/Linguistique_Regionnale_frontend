import 'package:flutter/material.dart' hide Text;
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
  final _ctrl = TextEditingController();
  bool _email = true;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _tab(String t, IconData i, bool sel, VoidCallback f) => Expanded(
        child: GestureDetector(
          onTap: f,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 44,
            decoration: BoxDecoration(
              color: sel ? C.lowest : Colors.transparent,
              borderRadius: BorderRadius.circular(99),
              boxShadow: sel
                  ? const [BoxShadow(color: Color(0x14000000), blurRadius: 6)]
                  : null,
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(i, size: 18, color: sel ? C.primary : C.onVariant),
              const SizedBox(width: 6),
              Text(t, style: ts(12, w7, color: sel ? C.primary : C.onVariant)),
            ]),
          ),
        ),
      );

  void _send() {
    if (!_key.currentState!.validate()) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.mark_email_read_outlined,
            color: C.secondary, size: 36),
        title: Text('Demande envoyée', style: ts(18, w7)),
        content: Text(
            _email
                ? 'Un lien de réinitialisation a été envoyé à ${_ctrl.text.trim()}.'
                : 'Un code de réinitialisation a été envoyé au +261 ${_ctrl.text.trim()}.',
            style: ts(13, w4, color: C.onVariant)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text('Retour à la connexion',
                style: ts(13, w7, color: C.primary)),
          ),
        ],
      ),
    );
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
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: const BoxDecoration(
                      color: C.primaryFixed, shape: BoxShape.circle),
                  child:
                      const Icon(Icons.lock_reset, size: 42, color: C.primary),
                ),
              ),
              const SizedBox(height: 20),
              Text('Mot de passe oublié ?', style: ts(24, w7)),
              const SizedBox(height: 6),
              Text(
                  "Ne vous inquiétez pas ! Saisissez l'adresse e-mail associée à votre compte et un code sécurisé pour réinitialiser votre accès.",
                  style: ts(13, w4, color: C.onVariant)),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: C.container,
                    borderRadius: BorderRadius.circular(99)),
                child: Row(children: [
                  _tab(
                      'Adresse e-mail',
                      Icons.mail_outline,
                      _email,
                      () => setState(() {
                            _email = true;
                            _ctrl.clear();
                          })),
                  _tab(
                      'SMS (Madagascar)',
                      Icons.sms_outlined,
                      !_email,
                      () => setState(() {
                            _email = false;
                            _ctrl.clear();
                          })),
                ]),
              ),
              FieldLabel(_email
                  ? 'Adresse e-mail'
                  : 'Numéro local (Telma, Orange, Airtel)'),
              TextFormField(
                controller: _ctrl,
                keyboardType:
                    _email ? TextInputType.emailAddress : TextInputType.phone,
                decoration: _email
                    ? fieldDec('votre.email@domaine.mg',
                        icon: Icons.mail_outline)
                    : fieldDec('034 00 000 00', icon: Icons.phone_iphone)
                        .copyWith(prefixText: '+261  '),
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (_email)
                    return emailRe.hasMatch(t)
                        ? null
                        : 'Adresse e-mail invalide';
                  return t.replaceAll(' ', '').length >= 9
                      ? null
                      : 'Numéro invalide';
                },
              ),
              const SizedBox(height: 18),
              PBtn('Envoyer le lien de réinitialisation',
                  icon: Icons.send, onTap: _send),
              const SizedBox(height: 20),
              Row(children: [
                const Icon(Icons.verified_user, size: 16, color: C.secondary),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(
                        'Données linguistiques protégées • Vos contributions audio et dialectes restent saufs',
                        style: ts(11, w5, color: C.secondary))),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
