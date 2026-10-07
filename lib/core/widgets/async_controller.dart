import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/cached.dart';
import '../utils/failure.dart';

/// Contrôleur générique : charge, expose données / erreur / "fromCache".
class AsyncController<T> extends ChangeNotifier {
  AsyncController(this._loader);
  final Future<Cached<T>> Function() _loader;

  T? data;
  bool loading = false;
  bool fromCache = false;
  String? error;
  FailureType? errorType;

  Future<void> load() async {
    loading = true;
    error = null;
    errorType = null;
    notifyListeners();
    try {
      final r = await _loader();
      data = r.data;
      fromCache = r.fromCache;
    } catch (e) {
      final f = Failure.from(e);
      error = f.message;
      errorType = f.type;
    }
    loading = false;
    notifyListeners();
  }
}

IconData _iconFor(FailureType? t) => switch (t) {
      FailureType.network => Icons.wifi_off,
      FailureType.server => Icons.dns_outlined,
      FailureType.unauthorized || FailureType.forbidden => Icons.lock_outline,
      FailureType.notFound => Icons.search_off,
      _ => Icons.error_outline,
    };

/// Affiche loader / erreur + bouton réessayer / bandeau hors-ligne / contenu.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({super.key, required this.builder});
  final Widget Function(BuildContext context, T data) builder;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AsyncController<T>>();

    if (c.data == null && c.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (c.data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(_iconFor(c.errorType), size: 48),
            const SizedBox(height: 12),
            Text(c.error ?? 'Erreur', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: c.load, child: const Text('Réessayer')),
          ]),
        ),
      );
    }
    return Column(children: [
      if (c.fromCache)
        MaterialBanner(
          content: const Text('Mode hors-ligne : données enregistrées sur l’appareil.'),
          leading: const Icon(Icons.wifi_off),
          actions: [TextButton(onPressed: c.load, child: const Text('Actualiser'))],
        ),
      if (c.error != null && !c.fromCache)
        Container(
          width: double.infinity,
          color: Theme.of(context).colorScheme.errorContainer,
          padding: const EdgeInsets.all(8),
          child: Text(c.error!),
        ),
      Expanded(
        child: RefreshIndicator(onRefresh: c.load, child: builder(context, c.data as T)),
      ),
    ]);
  }
}
