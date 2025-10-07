import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:path_provider/path_provider.dart';

class DioClient {
  static late Dio _dio;
  static late CacheStore _cacheStore;
  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.mangadex.org', // Your base URL
        connectTimeout: Duration(seconds: 5),
        receiveTimeout: Duration(seconds: 3),
        headers: {'Accept': 'application/json'},
      ),
    );
    _dio.interceptors.add(LogInterceptor(responseBody: true));
  }
  static Future<Dio> initialize() async {
    final Directory appDocDir = await getTemporaryDirectory();

    _cacheStore = HiveCacheStore(appDocDir.path, hiveBoxName: 'dio_cache');

    final options = CacheOptions(
      store: _cacheStore,
      policy: CachePolicy.request,
      maxStale: const Duration(days: 7),
    );

    _dio = Dio()..interceptors.add(DioCacheInterceptor(options: options));

    return _dio;
  }

  static Dio get dio => _dio;
  static Future<void> close() async {
    await _cacheStore.clean();
    await _cacheStore.close();
  }
}
