import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ApiClient {
  ApiClient({String? baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl ??
              const String.fromEnvironment('API_BASE_URL',
                  defaultValue: 'https://linguistique-regionnale-backend.onrender.com/api'),
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 12),
          headers: {'Content-Type': 'application/json'},
        ));
  final Dio _dio;
  void setToken(String? token) {
    if (token == null || token.isEmpty) {
      _dio.options.headers.remove('Authorization');
    } else {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async =>
      (await _dio.post<Map<String, dynamic>>('/auth/login',
              data: {'email': email, 'password': password}))
          .data!;
  Future<Map<String, dynamic>> register(
          String name, String email, String password, {String? region}) async =>
      (await _dio.post<Map<String, dynamic>>('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'region': region
      }))
          .data!;
  Future<Map<String, dynamic>> googleLogin() async {
    const id = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
    if (id.isEmpty) throw StateError('GOOGLE_SERVER_CLIENT_ID manquant');
    final account = await GoogleSignIn(
        serverClientId: id, scopes: const ['email', 'profile']).signIn();
    if (account == null) throw StateError('Connexion Google annulée');
    final token = (await account.authentication).idToken;
    if (token == null || token.isEmpty) throw StateError('Jeton Google absent');
    return (await _dio.post<Map<String, dynamic>>('/auth/google',
            data: {'idToken': token}))
        .data!;
  }

  Future<Map<String, dynamic>> profile() async =>
      (await _dio.get<Map<String, dynamic>>('/profile')).data!;

  Future<Map<String, dynamic>> uploadProfilePhoto(String path) async {
    final form = FormData.fromMap({'file': await MultipartFile.fromFile(path)});
    return (await _dio.put<Map<String, dynamic>>('/profile/photo', data: form)).data!;
  }

  Future<Map<String, dynamic>> deleteProfilePhoto() async =>
      (await _dio.delete<Map<String, dynamic>>('/profile/photo')).data!;

  Future<List<dynamic>> regions() async =>
      (await _dio.get<List<dynamic>>('/regions')).data!;
  Future<List<dynamic>> words(
          {String query = '', String? region, String? type}) async =>
      (await _dio.get<List<dynamic>>('/words', queryParameters: {
        'q': query,
        if (region != null) 'region': region,
        if (type != null) 'type': type
      }))
          .data!;
  Future<List<dynamic>> favorites() async =>
      (await _dio.get<List<dynamic>>('/favorites')).data!;
  Future<void> addFavorite(String id) async {
    await _dio.put('/favorites/$id');
  }

  Future<void> removeFavorite(String id) async {
    await _dio.delete('/favorites/$id');
  }

  Future<List<dynamic>> myContributions() async =>
      (await _dio.get<List<dynamic>>('/contributions/mine')).data!;
  Future<Map<String, dynamic>> createContribution(
          Map<String, dynamic> data) async =>
      (await _dio.post<Map<String, dynamic>>('/contributions', data: data))
          .data!;
}

final apiClient = ApiClient();
