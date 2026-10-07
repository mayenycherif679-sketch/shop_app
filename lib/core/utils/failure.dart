import 'package:dio/dio.dart';

/// Catégories d'erreurs : l'UI peut adapter icône / message / action.
enum FailureType { network, unauthorized, forbidden, notFound, validation, server, unknown }

/// Erreur "propre" destinée à l'UI : un message lisible + un type.
class Failure implements Exception {
  const Failure(this.message, {this.type = FailureType.unknown});
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
          return const Failure(
            'Pas de connexion internet. Vérifie ton réseau et réessaie.',
            type: FailureType.network,
          );
        default:
          break;
      }
      final code = e.response?.statusCode;
      if (code == 401) {
        return const Failure('Session expirée ou identifiants invalides.',
            type: FailureType.unauthorized);
      }
      if (code == 403) {
        return const Failure('Tu n’as pas le droit d’accéder à cette ressource.',
            type: FailureType.forbidden);
      }
      if (code == 404) {
        return const Failure('Ressource introuvable.', type: FailureType.notFound);
      }
      if (code == 400 || code == 422) {
        return const Failure(
            'Requête invalide (données incorrectes ou email déjà utilisé).',
            type: FailureType.validation);
      }
      if (code != null && code >= 500) {
        return const Failure('Le serveur est indisponible. Réessaie plus tard.',
            type: FailureType.server);
      }
      return Failure('Erreur réseau${code != null ? ' ($code)' : ''}.');
    }
    return const Failure('Une erreur inattendue est survenue.');
  }

  @override
  String toString() => message;
}
