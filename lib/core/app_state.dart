import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../data/api/api_client.dart';
import '../data/models.dart';
import 'i18n.dart' show languageNotifier;

class AppState extends ChangeNotifier {
  bool loggedIn = false, loading = true;
  String? error;
  String userName = '', userEmail = '', userPhone = '', userRegion = '';
  int tab = 0;
  String searchRegion = 'Toutes les régions',
      searchType = 'Tous types';
  final Set<String> favorites = {};
  bool notifications = true, offline = false;
  String language = 'Français';
  List<Word> words = const [];
  List<Region> regions = const [];
  String get allRegionsLabel => 'Toutes les régions';

  Future<void> loadCatalog() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final result =
          await Future.wait([apiClient.regions(), apiClient.words()]);
      regions = result[0]
          .whereType<Map>()
          .map((e) => Region.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      words = result[1]
          .whereType<Map>()
          .map((e) => Word.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      error = 'Impossible de charger les données du serveur.';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final r = await apiClient.login(email.trim(), password);
    apiClient.setToken(r['token'] as String?);
    userEmail = '${r['email'] ?? email}';
    userName = '${r['name'] ?? ''}';
    loggedIn = true;
    await loadProfile();
    await loadCatalog();
    await loadFavorites();
  }

  Future<void> loginWithGoogle({String? region}) async {
    final r = await apiClient.googleLogin(region: region);
    apiClient.setToken(r['token'] as String?);
    userEmail = r['email'] ?? '';
    userName = r['name'] ?? '';
    userRegion = region ?? '';
    loggedIn = true;
    await loadProfile();
    await loadCatalog();
    await loadFavorites();
  }

  Future<void> register(String name, String email, String phone, String password,
      {String? region}) async {
    final r = await apiClient.register(name.trim(), email.trim(), phone.trim(), password,
        region: region);
    apiClient.setToken(r['token'] as String?);
    userName = name.trim();
    userEmail = '${r['email'] ?? email}';
    userPhone = phone.trim();
    userRegion = region ?? '';
    loggedIn = true;
    await loadProfile();
    await loadCatalog();
    notifyListeners();
  }

  Future<void> loadFavorites() async {
    final data = await apiClient.favorites();
    favorites
      ..clear()
      ..addAll(data.whereType<Map>().map((e) => '${e['id']}'));
    notifyListeners();
  }

  Word? wordById(String id) {
    for (final w in words) {
      if (w.id == id) return w;
    }
    return words.isEmpty ? null : words.first;
  }

  int regionOrder(String name) => regions
      .firstWhere((r) => r.name == name,
          orElse: () => Region(
              code: '',
              name: '',
              dialects: '',
              zone: '',
              badge: '',
              subtitle: '',
              quote: '',
              icon: Icons.language,
              words: 0,
              expressions: 0,
              contributors: 0,
              dialectCount: 0,
              order: 0))
      .order;
  IconData regionIcon(String name) => Icons.language;

  void setTab(int i) {
    tab = i;
    notifyListeners();
  }

  void openSearch({String region = 'Toutes les régions'}) {
    searchRegion = region;
    tab = 1;
    notifyListeners();
  }

  void setSearchRegion(String v) {
    searchRegion = v;
    notifyListeners();
  }

  void setSearchType(String v) {
    searchType = v;
    notifyListeners();
  }

  bool isFav(String id) => favorites.contains(id);
  Future<void> toggleFav(String id) async {
    if (!loggedIn) throw StateError('Connectez-vous pour utiliser les favoris.');
    final wasFavorite = favorites.contains(id);
    if (wasFavorite) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }
    notifyListeners();
    try {
      if (wasFavorite) {
        await apiClient.removeFavorite(id);
      } else {
        await apiClient.addFavorite(id);
      }
    } catch (e) {
      if (wasFavorite) {
        favorites.add(id);
      } else {
        favorites.remove(id);
      }
      notifyListeners();
      rethrow;
    }
  }

  void setNotifications(bool v) {
    notifications = v;
    notifyListeners();
  }

  void setLanguage(String v) {
    language = v;
    languageNotifier.value = v;
    notifyListeners();
  }

  void logout() {
    loggedIn = false;
    apiClient.setToken(null);
    userName = '';
    userEmail = '';
    userPhone = '';
    userRegion = '';
    favorites.clear();
    tab = 0;
    notifyListeners();
  }

  String? profilePhoto;

  Future<void> loadProfile() async {
    try {
      final p = await apiClient.profile();
      userName = '${p['name'] ?? userName}';
      userEmail = '${p['email'] ?? userEmail}';
      userPhone = '${p['phone'] ?? userPhone}';
      userRegion = '${p['region'] ?? ''}';
      final photo = '${p['photo_url'] ?? ''}';
      profilePhoto = photo.isEmpty ? null : photo;
      notifyListeners();
    } catch (_) {
      // Le profil reste utilisable même si l'URL de photo est indisponible.
    }
  }

  Future<void> setProfilePhoto(String path) async {
    final p = await apiClient.uploadProfilePhoto(path);
    final photo = '${p['photo_url'] ?? ''}';
    profilePhoto = photo.isEmpty ? null : photo;
    notifyListeners();
  }

  Future<void> deleteProfilePhoto() async {
    await apiClient.deleteProfilePhoto();
    profilePhoto = null;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await apiClient.deleteAccount();
    try {
      const id = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
      if (id.isNotEmpty) {
        await GoogleSignIn(
                serverClientId: id, scopes: const ['email', 'profile'])
            .signOut();
      }
    } catch (_) {
      // La suppression côté serveur est déjà effectuée.
    }
    logout();
  }

  Future<void> changePassword(String currentPassword, String newPassword) =>
      apiClient.changePassword(currentPassword, newPassword);

  Future<Map<String, dynamic>> requestPasswordReset(String email) =>
      apiClient.requestPasswordReset(email, language: language);

  Future<Map<String, dynamic>> requestPasswordResetSms(String phone) =>
      apiClient.requestPasswordResetSms(phone, language: language);

  Future<Map<String, dynamic>> resetPassword(
          String email, String code, String newPassword) =>
      apiClient.resetPassword(email, code, newPassword);

  Future<Map<String, dynamic>> resetPasswordSms(
          String phone, String code, String newPassword) =>
      apiClient.resetPasswordSms(phone, code, newPassword);

  Future<void> updatePhone(String phone) async {
    final p = await apiClient.updatePhone(phone);
    userPhone = '${p['phone'] ?? phone}';
    notifyListeners();
  }

  Future<Map<String, dynamic>> askAi(String question,
          {String? region, String? dialect, String? language}) =>
      apiClient.askAi(question,
          region: region, dialect: dialect, language: language ?? this.language);
}

final appState = AppState();
