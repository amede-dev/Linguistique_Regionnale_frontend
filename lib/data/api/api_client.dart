import 'package:dio/dio.dart';

class ApiClient {
  ApiClient({String? baseUrl}) : _dio = Dio(BaseOptions(
    baseUrl: baseUrl ?? const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8080/api'),
    connectTimeout: const Duration(seconds: 8), receiveTimeout: const Duration(seconds: 12),
    headers: {'Content-Type': 'application/json'},
  ));
  final Dio _dio;
  void setToken(String? token) { if (token == null || token.isEmpty) { _dio.options.headers.remove('Authorization'); } else { _dio.options.headers['Authorization'] = 'Bearer $token'; } }
  Future<Map<String,dynamic>> login(String email, String password) async => (await _dio.post<Map<String,dynamic>>('/auth/login', data: {'email': email, 'password': password})).data!;
  Future<Map<String,dynamic>> register(String name, String email, String password, {String? region}) async => (await _dio.post<Map<String,dynamic>>('/auth/register', data: {'name': name, 'email': email, 'password': password, 'region': region})).data!;
  Future<List<dynamic>> regions() async => (await _dio.get<List<dynamic>>('/regions')).data!;
  Future<List<dynamic>> words({String query = '', String? region, String? type}) async => (await _dio.get<List<dynamic>>('/words', queryParameters: {'q': query, if (region != null) 'region': region, if (type != null) 'type': type})).data!;
  Future<List<dynamic>> favorites() async => (await _dio.get<List<dynamic>>('/favorites')).data!;
  Future<void> addFavorite(String id) async { await _dio.put('/favorites/$id'); }
  Future<void> removeFavorite(String id) async { await _dio.delete('/favorites/$id'); }
  Future<List<dynamic>> myContributions() async => (await _dio.get<List<dynamic>>('/contributions/mine')).data!;
  Future<Map<String,dynamic>> createContribution(Map<String,dynamic> data) async => (await _dio.post<Map<String,dynamic>>('/contributions', data: data)).data!;
}

final apiClient = ApiClient();
