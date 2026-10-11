import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide Text;
import '../core/app_state.dart';
import '../core/i18n.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _key = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _hideCurrent = true, _hideNext = true, _hideConfirm = true, _busy = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate() || _busy) return;
    setState(() => _busy = true);
    try {
      await appState.changePassword(_current.text, _next.text);
      if (mounted) {
        toast(context, 'Mot de passe modifié avec succès');
        Navigator.pop(context);
      }
    } on DioException catch (e) {
      if (mounted) {
        toast(context, e.response?.statusCode == 400
            ? 'Ancien mot de passe incorrect ou mot de passe invalide.'
            : 'Impossible de modifier le mot de passe.');
      }
    } catch (_) {
      if (mounted) toast(context, 'Impossible de modifier le mot de passe.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  InputDecoration _dec(String hint, IconData icon, bool hidden, VoidCallback toggle) =>
      fieldDec(hint,
          icon: icon,
          suffix: IconButton(
              onPressed: toggle,
              icon: Icon(hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined)));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: const BackButton(color: C.onSurface),
          title: Text('Modifier le mot de passe', style: ts(16, w7)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Form(
              key: _key,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Sécurisez votre compte', style: ts(24, w7)),
                const SizedBox(height: 6),
                Text('Utilisez au moins 8 caractères pour votre nouveau mot de passe.',
                    style: ts(13, w4, color: C.onVariant)),
                const SizedBox(height: 20),
                const FieldLabel('Mot de passe actuel'),
                TextFormField(
                  controller: _current,
                  obscureText: _hideCurrent,
                  decoration: _dec('••••••••', Icons.lock_outline, _hideCurrent,
                      () => setState(() => _hideCurrent = !_hideCurrent)),
                  validator: (v) => (v == null || v.isEmpty) ? 'Champ obligatoire' : null,
                ),
                const FieldLabel('Nouveau mot de passe'),
                TextFormField(
                  controller: _next,
                  obscureText: _hideNext,
                  decoration: _dec('8 caractères minimum', Icons.lock_reset, _hideNext,
                      () => setState(() => _hideNext = !_hideNext)),
                  validator: (v) => (v ?? '').length < 8 ? '8 caractères minimum' : null,
                ),
                const FieldLabel('Confirmation du mot de passe'),
                TextFormField(
                  controller: _confirm,
                  obscureText: _hideConfirm,
                  decoration: _dec('••••••••', Icons.verified_user_outlined, _hideConfirm,
                      () => setState(() => _hideConfirm = !_hideConfirm)),
                  validator: (v) => v != _next.text ? 'Les mots de passe ne correspondent pas' : null,
                ),
                const SizedBox(height: 24),
                PBtn('Enregistrer', icon: Icons.check, onTap: _busy ? null : _save),
              ]),
            ),
          ),
        ),
      );
}
