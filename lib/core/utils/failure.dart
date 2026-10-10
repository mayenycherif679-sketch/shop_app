import 'package:dio/dio.dart';

/// Catégories d'erreurs. L'UI choisit le message localisé via
/// `AppLocalizations.failureMessage(type)` : aucun texte utilisateur ici.
enum FailureType {
  network,
  invalidCredentials,
  unauthorized,
  forbidden,
  notFound,
  validation,
  server,
  unknown,
}

class Failure implements Exception {
  const Failure(this.message, {this.type = FailureType.unknown});

  /// Message technique (logs / debug), non destiné à l'utilisateur.
  final String message;
  final FailureType type;

  /// Seules les erreurs réseau autorisent le fallback sur le cache.
  bool get isNetwork => type == FailureType.network;

  /// Convertit n'importe quelle exception (surtout DioException) en Failure.
  factory Failure.from(Object e) {
    if (e is Failure) return e;
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionError:
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const Failure('Network unavailable', type: FailureType.network);
        default:
          break;
      }
      final code = e.response?.statusCode;
      if (code == 401) return const Failure('401', type: FailureType.unauthorized);
      if (code == 403) return const Failure('403', type: FailureType.forbidden);
      if (code == 404) return const Failure('404', type: FailureType.notFound);
      if (code == 400 || code == 422) {
        return Failure('$code', type: FailureType.validation);
      }
      if (code != null && code >= 500) {
        return Failure('$code', type: FailureType.server);
      }
      return Failure('HTTP ${code ?? '?'}');
    }
    return Failure('Unexpected: $e');
  }

  @override
  String toString() => 'Failure($type, $message)';
}
