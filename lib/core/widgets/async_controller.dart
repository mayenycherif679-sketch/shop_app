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

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final r = await _loader();
      data = r.data;
      fromCache = r.fromCache;
    } catch (e) {
      error = Failure.from(e).message;
    }
    loading = false;
    notifyListeners();
  }
}

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
            const Icon(Icons.cloud_off, size: 48),
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
