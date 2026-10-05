import 'package:dio/dio.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final r = await _dio.post('/auth/login', data: {'email': email, 'password': password});
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<void> register(String name, String email, String password) async {
    await _dio.post('/users/', data: {
      'name': name,
      'email': email,
      'password': password,
      'avatar': 'https://picsum.photos/800', // champ requis par l'API
    });
  }

  Future<Map<String, dynamic>> profile() async {
    final r = await _dio.get('/auth/profile');
    return Map<String, dynamic>.from(r.data as Map);
  }
}
