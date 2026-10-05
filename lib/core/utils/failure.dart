import 'package:dio/dio.dart';

/// Erreur "propre" destinée à l'UI : un message lisible + un flag réseau.
class Failure implements Exception {
  const Failure(this.message, {this.isNetwork = false});
  final String message;
  final bool isNetwork;

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
            isNetwork: true,
          );
        default:
          break;
      }
      final code = e.response?.statusCode;
      if (code == 401) {
        return const Failure('Session expirée ou identifiants invalides.');
      }
      if (code == 400) {
        return const Failure(
            'Requête invalide (données incorrectes ou email déjà utilisé).');
      }
      if (code == 404) return const Failure('Ressource introuvable.');
      if (code != null && code >= 500) {
        return const Failure('Le serveur est indisponible. Réessaie plus tard.');
      }
      return Failure('Erreur réseau${code != null ? ' ($code)' : ''}.');
    }
    return const Failure('Une erreur inattendue est survenue.');
  }

  @override
  String toString() => message;
}
