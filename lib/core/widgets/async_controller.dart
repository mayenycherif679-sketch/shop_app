import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../utils/cached.dart';
import '../utils/failure.dart';

/// Contrôleur générique : charge, expose données / type d'erreur / "fromCache".
class AsyncController<T> extends ChangeNotifier {
  AsyncController(this._loader);
  final Future<Cached<T>> Function() _loader;

  T? data;
  bool loading = false;
  bool fromCache = false;
  FailureType? errorType;

  bool get hasError => errorType != null;

  Future<void> load() async {
    loading = true;
    errorType = null;
    notifyListeners();
    try {
      final result = await _loader();
      data = result.data;
      fromCache = result.fromCache;
    } catch (e) {
      errorType = Failure.from(e).type;
    }
    loading = false;
    notifyListeners();
  }
}

IconData _iconFor(FailureType? type) => switch (type) {
      FailureType.network => Icons.wifi_off,
      FailureType.server => Icons.dns_outlined,
      FailureType.unauthorized ||
      FailureType.invalidCredentials ||
      FailureType.forbidden =>
        Icons.lock_outline,
      FailureType.notFound => Icons.search_off,
      _ => Icons.error_outline,
    };

/// Loader / erreur + Réessayer / bandeau hors-ligne / contenu (+ pull-to-refresh).
class AsyncView<T> extends StatelessWidget {
  const AsyncView({super.key, required this.builder});
  final Widget Function(BuildContext context, T data) builder;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AsyncController<T>>();
    final l10n = AppLocalizations.of(context);
    final data = controller.data;

    if (data == null && controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(_iconFor(controller.errorType), size: 48),
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: Text(
                l10n.failureMessage(controller.errorType),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: controller.load, child: Text(l10n.retry)),
          ]),
        ),
      );
    }
    return Column(children: [
      if (controller.fromCache)
        MaterialBanner(
          content: Text(l10n.offlineBanner),
          leading: const Icon(Icons.wifi_off),
          actions: [
            TextButton(onPressed: controller.load, child: Text(l10n.refresh)),
          ],
        ),
      if (controller.hasError && !controller.fromCache)
        Container(
          width: double.infinity,
          color: Theme.of(context).colorScheme.errorContainer,
          padding: const EdgeInsets.all(8),
          child: Text(l10n.failureMessage(controller.errorType)),
        ),
      Expanded(
        child: RefreshIndicator(
          onRefresh: controller.load,
          child: builder(context, data),
        ),
      ),
    ]);
  }
}
