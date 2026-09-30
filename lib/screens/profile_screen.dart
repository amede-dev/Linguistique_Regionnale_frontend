import 'package:flutter/material.dart' hide Text;
import 'package:image_picker/image_picker.dart';
import '../core/app_state.dart';
import '../core/i18n.dart';
import '../core/nav.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

final ImagePicker _picker = ImagePicker();

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 10),
        child: Text(t, style: ts(16, w7)),
      );

  Widget _tile(IconData i, String title, String sub,
          {Widget? trailing, VoidCallback? onTap}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: CardBox(
          onTap: onTap,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: C.primaryFixed,
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(i, color: C.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: ts(14, w6)),
                    Text(sub, style: ts(11, w4, color: C.onVariant)),
                  ]),
            ),
            trailing ?? const Icon(Icons.chevron_right, color: C.outline),
          ]),
        ),
      );

  // ---------- Photo de profil ----------
  Future<void> _pickPhoto(BuildContext context, ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (file != null) {
        await appState.setProfilePhoto(file.path);
        if (context.mounted) toast(context, 'Photo enregistrée sur le serveur');
      }
    } catch (_) {
      if (context.mounted) toast(context, "Impossible d'accéder à la photo");
    }
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: C.lowest,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.photo_library, color: C.primary),
            title: Text('Choisir depuis la galerie', style: ts(14, w6)),
            onTap: () {
              Navigator.pop(sheetCtx);
              _pickPhoto(context, ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera, color: C.primary),
            title: Text('Prendre une photo', style: ts(14, w6)),
            onTap: () {
              Navigator.pop(sheetCtx);
              _pickPhoto(context, ImageSource.camera);
            },
          ),
          if (appState.profilePhoto != null)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: C.error),
              title:
                  Text('Supprimer la photo', style: ts(14, w6, color: C.error)),
              onTap: () {
                Navigator.pop(sheetCtx);
                appState.deleteProfilePhoto();
              },
            ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  // ---------- Déconnexion avec confirmation ----------
  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.lowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Se déconnecter', style: ts(18, w7)),
        content: Text('Voulez-vous vraiment vous déconnecter de votre compte ?',
            style: ts(14, w4, color: C.onVariant)),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Annuler', style: ts(14, w6, color: C.onVariant)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: C.error,
              shape: const StadiumBorder(),
            ),
            child:
                Text('Se déconnecter', style: ts(14, w7, color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) goOnboarding(context);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Column(children: [
          const TabHeader(
            title: 'Profil',
            showBrand: false,
            showNotification: false,
          ),
          Expanded(
            child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  Center(
                    child: Stack(children: [
                      const UserAvatar(radius: 46),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: () => _showPhotoOptions(context),
                          child: const CircleAvatar(
                            radius: 15,
                            backgroundColor: C.primary,
                            child: Icon(Icons.photo_camera,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 10),
                  Center(child: Text(appState.userName, style: ts(22, w7))),
                  Center(
                      child: Text(appState.userEmail,
                          style: ts(13, w4, color: C.onVariant))),
                  // Région / dialecte choisi à l'inscription
                  if (appState.userRegion.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Center(
                      child: Pill(appState.userRegion,
                          bg: C.secondaryContainer,
                          fg: C.onSecondaryContainer,
                          icon: Icons.location_on),
                    ),
                  ],
                  _section("Paramètres de l'application"),
                  _tile(
                    Icons.translate,
                    "Langue de l'interface",
                    "Choisissez la langue de l'application",
                    trailing: PopupMenuButton<String>(
                      onSelected: appState.setLanguage,
                      color: C.lowest,
                      itemBuilder: (_) => [
                        for (final l in ['Français', 'Malagasy'])
                          PopupMenuItem(
                              value: l, child: Text(l, style: ts(13, w5)))
                      ],
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(appState.language,
                            style: ts(12, w7, color: C.primary)),
                        const Icon(Icons.expand_more,
                            color: C.primary, size: 18),
                      ]),
                    ),
                  ),
                  _tile(
                      Icons.notifications_active,
                      'Notifications quotidiennes',
                      'Mots du jour & validation des propositions',
                      trailing: Switch(
                          value: appState.notifications,
                          activeColor: C.primaryContainer,
                          onChanged: appState.setNotifications)),
                  const SizedBox(height: 20),
                  // Bouton ajusté à la taille de son texte, centré
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmLogout(context),
                      style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                        side: const BorderSide(color: C.error),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 12),
                      ),
                      icon: const Icon(Icons.logout, color: C.error, size: 18),
                      label: Text('Se déconnecter',
                          style: ts(14, w7, color: C.error)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                      child: Text("Langue malgache • Version 1.2.0",
                          style: ts(11, w4, color: C.outline))),
                  Center(
                      child: Text('Patrimoine intellectuel de Madagascar',
                          style: ts(11, w5, color: C.tertiary))),
                ]),
          ),
        ]);
      },
    );
  }
}
