import 'package:dio/dio.dart';

import '../models/post.dart';

/// Error propio de la app con un mensaje listo para mostrar al usuario.
class ApiException implements Exception {
  final String mensaje;
  const ApiException(this.mensaje);

  @override
  String toString() => mensaje;
}

/// Cliente de la API REST usando `dio`.
class ApiService {
  ApiService()
      : _dio = Dio(
          BaseOptions(
            // API pública de pruebas (soporta HTTPS y CORS).
            baseUrl: 'https://jsonplaceholder.typicode.com',
            connectTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 8),
          ),
        );

  final Dio _dio;

  /// GET /posts -> lista de publicaciones.
  Future<List<Post>> obtenerPosts({int limite = 20}) async {
    try {
      final respuesta = await _dio.get<List<dynamic>>(
        '/posts',
        queryParameters: {'_limit': limite},
      );

      final datos = respuesta.data ?? [];
      return datos
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(_mensajeDeError(e));
    }
  }

  /// Traduce los errores técnicos de dio a mensajes entendibles.
  String _mensajeDeError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'La conexión tardó demasiado. Intenta de nuevo.';
      case DioExceptionType.connectionError:
        // Aquí cae el caso "sin internet" o "acceso a red bloqueado".
        // En Web también aparece cuando el navegador bloquea por CORS.
        return 'No se pudo conectar con el servidor. '
            'Revisa tu conexión o el acceso a red de la app.';
      case DioExceptionType.badResponse:
        return 'El servidor respondió con error (${e.response?.statusCode}).';
      case DioExceptionType.cancel:
        return 'La petición fue cancelada.';
      default:
        return 'Ocurrió un error inesperado de red.';
    }
  }
}