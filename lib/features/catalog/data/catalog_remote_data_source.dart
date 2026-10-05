import 'package:dio/dio.dart';

class CatalogRemoteDataSource {
  CatalogRemoteDataSource(this._dio);
  final Dio _dio;

  Future<List<dynamic>> products() async {
    final r = await _dio.get('/products', queryParameters: {'offset': 0, 'limit': 30});
    return r.data as List<dynamic>;
  }

  Future<List<dynamic>> categories() async {
    final r = await _dio.get('/categories');
    return r.data as List<dynamic>;
  }
}
