import 'dart:async';
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import 'i18n.dart' show languageNotifier;

/// État global simple (ChangeNotifier). À remplacer par Supabase / Riverpod
/// lorsque le backend sera branché.
class AppState extends ChangeNotifier {
  bool loggedIn = false;
  String userName = 'Haingo Razafindrakoto';
  String userEmail = 'haingo.razafy@example.mg';
  String userRegion = '';

  int tab = 0;
  String searchRegion = allRegionsLabel;
  String searchType = 'Tous types';
  String sort = 'Pertinence';

  final Set<String> favorites = {
    'salama_tsara',
    'akory_aby_anareo',
    'tsara_bia',
    'fihavanana'
  };

  bool notifications = true;
  bool offline = true;
  String language = 'Français';

  // ---- Compteur de voix en temps réel ----
  // Chaque mot du dictionnaire possède un enregistrement vocal ;
  // on y ajoute les voix contribuées pendant la session.
  int contributedVoices = 0;

  int get voiceCount => words.length + contributedVoices;

  void addVoice() {
    contributedVoices++;
    notifyListeners();
  }

  /// Chemin de la photo de profil (null = afficher les initiales).
  String? profilePhoto;

  void setProfilePhoto(String? path) {
    profilePhoto = path;
    notifyListeners();
  }

  // ---- Navigation par onglets ----
  void setTab(int i) {
    tab = i;
    notifyListeners();
  }

  void openSearch({String region = allRegionsLabel}) {
    searchRegion = region;
    tab = 1;
    notifyListeners();
  }

  void setSearchRegion(String r) {
    searchRegion = r;
    notifyListeners();
  }

  void setSearchType(String t) {
    searchType = t;
    notifyListeners();
  }

  void setSort(String s) {
    sort = s;
    notifyListeners();
  }

  // ---- Favoris ----
  bool isFav(String id) => favorites.contains(id);

  void toggleFav(String id) {
    if (!favorites.remove(id)) favorites.add(id);
    notifyListeners();
  }

  // ---- Paramètres ----
  void setNotifications(bool v) {
    notifications = v;
    notifyListeners();
  }

  void setLanguage(String v) {
    language = v;
    languageNotifier.value = v; // met à jour tous les textes
    notifyListeners();
  }

  void logout() {
    loggedIn = false;
    stop();
    tab = 0;
    notifyListeners();
    profilePhoto = null;
  }

  // ---- Lecteur audio simulé (aucun fichier audio dans le prototype) ----
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
      progress += 100 * speed / (seconds * 1000);
      if (progress >= 1) {
        stop();
      } else {
        notifyListeners();
      }
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
