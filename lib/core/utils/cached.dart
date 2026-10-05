import '../storage/cache_store.dart';
import 'failure.dart';

/// Données + indicateur "viennent du cache" (pour afficher le bandeau hors-ligne).
class Cached<T> {
  const Cached(this.data, {this.fromCache = false});
  final T data;
  final bool fromCache;
}

/// Stratégie "network first, cache fallback" :
/// 1. appel réseau, mise à jour du cache ;
/// 2. si erreur RÉSEAU uniquement et cache dispo -> données du cache ;
/// 3. sinon -> Failure lisible.
Future<Cached<T>> cachedFetch<T>({
  required CacheStore cache,
  required String key,
  required Future<dynamic> Function() remote,
  required T Function(dynamic json) parse,
}) async {
  try {
    final raw = await remote();
    final parsed = parse(raw);
    await cache.write(key, raw);
    return Cached(parsed);
  } catch (e) {
    final failure = Failure.from(e);
    if (failure.isNetwork) {
      final stored = cache.read(key);
      if (stored != null) return Cached(parse(stored), fromCache: true);
    }
    throw failure;
  }
}
