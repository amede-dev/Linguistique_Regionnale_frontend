import 'dart:async';
import 'package:flutter/material.dart';
import '../data/api/api_client.dart';
import '../data/models.dart';
import 'i18n.dart' show languageNotifier;

class AppState extends ChangeNotifier {
  bool loggedIn = false, loading = true;
  String? error;
  String userName = '', userEmail = '', userRegion = '';
  int tab = 0;
  String searchRegion = 'Toutes les régions',
      searchType = 'Tous types',
      sort = 'Pertinence';
  final Set<String> favorites = {};
  bool notifications = true, offline = false;
  String language = 'Français';
  List<Word> words = const [];
  List<Region> regions = const [];
  int contributedVoices = 0;
  int get voiceCount => words.length + contributedVoices;
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

  Future<void> loginWithGoogle() async {
    final r = await apiClient.googleLogin();
    apiClient.setToken(r['token'] as String?);
    userEmail = r['email'] ?? '';
    userName = r['name'] ?? '';
    loggedIn = true;
    await loadProfile();
    await loadCatalog();
    await loadFavorites();
  }

  Future<void> register(String name, String email, String password,
      {String? region}) async {
    final r = await apiClient.register(name.trim(), email.trim(), password,
        region: region);
    apiClient.setToken(r['token'] as String?);
    userName = name.trim();
    userEmail = '${r['email'] ?? email}';
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
  void addVoice() {
    contributedVoices++;
    notifyListeners();
  }

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

  void setSort(String v) {
    sort = v;
    notifyListeners();
  }

  bool isFav(String id) => favorites.contains(id);
  Future<void> toggleFav(String id) async {
    if (favorites.contains(id)) {
      await apiClient.removeFavorite(id);
      favorites.remove(id);
    } else {
      await apiClient.addFavorite(id);
      favorites.add(id);
    }
    notifyListeners();
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

  String? playingId;
  double progress = 0;
  double speed = 1.0;
  Timer? _timer;
  void cycleSpeed() {
    const all = [1.0, 1.5, 0.75];
    speed = all[(all.indexOf(speed) + 1) % all.length];
    notifyListeners();
  }

  void togglePlay(String id, int seconds) {
    if (playingId == id) {
      stop();
      return;
    }
    _timer?.cancel();
    playingId = id;
    progress = 0;
    notifyListeners();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      progress += 100 * speed / (seconds.clamp(1, 999) * 1000);
      if (progress >= 1)
        stop();
      else
        notifyListeners();
    });
  }

  void stop() {
    _timer?.cancel();
    playingId = null;
    progress = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final appState = AppState();
