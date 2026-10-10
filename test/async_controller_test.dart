import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/utils/cached.dart';
import 'package:shop_app/core/utils/failure.dart';
import 'package:shop_app/core/widgets/async_controller.dart';

void main() {
  test('load : succès expose les données', () async {
    final c = AsyncController<int>(() async => const Cached(42));

    await c.load();

    expect(c.data, 42);
    expect(c.hasError, false);
    expect(c.fromCache, false);
    expect(c.loading, false);
  });

  test('load : erreur réseau expose errorType', () async {
    final c = AsyncController<int>(
      () async => throw const Failure('x', type: FailureType.network),
    );

    await c.load();

    expect(c.data, isNull);
    expect(c.errorType, FailureType.network);
  });

  test('load : conserve les anciennes données si le rafraîchissement échoue', () async {
    var calls = 0;
    final c = AsyncController<int>(() async {
      calls++;
      if (calls == 1) return const Cached(1);
      throw const Failure('x', type: FailureType.server);
    });

    await c.load();
    await c.load();

    expect(c.data, 1);
    expect(c.errorType, FailureType.server);
  });

  test('load : indique fromCache', () async {
    final c = AsyncController<int>(() async => const Cached(7, fromCache: true));

    await c.load();

    expect(c.fromCache, true);
  });
}
