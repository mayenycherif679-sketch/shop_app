import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_app/core/utils/failure.dart';
import 'package:shop_app/features/auth/data/auth_remote_data_source.dart';
import 'package:shop_app/features/auth/data/auth_repository_impl.dart';

import 'helpers.dart';

class MockAuthRemote extends Mock implements AuthRemoteDataSource {}

const _profile = {
  'id': 1,
  'name': 'John',
  'email': 'john@mail.com',
  'avatar': 'https://img.test/a.png',
  'role': 'customer',
};

void main() {
  late MockAuthRemote remote;
  late FakeTokens tokens;
  late FakeCache cache;
  late AuthRepositoryImpl repo;

  setUp(() {
    remote = MockAuthRemote();
    tokens = FakeTokens();
    cache = FakeCache();
    repo = AuthRepositoryImpl(remote, tokens, cache);
  });

  test('login : sauvegarde les tokens et renvoie le profil', () async {
    when(() => remote.login('john@mail.com', 'pw'))
        .thenAnswer((_) async => {'access_token': 'A', 'refresh_token': 'R'});
    when(() => remote.profile()).thenAnswer((_) async => _profile);

    final user = await repo.login('john@mail.com', 'pw');

    expect(user.name, 'John');
    expect(tokens.access, 'A');
    expect(tokens.refresh, 'R');
  });

  test('login 401 : Failure invalidCredentials', () async {
    when(() => remote.login(any(), any())).thenThrow(
        dioError(DioExceptionType.badResponse, status: 401, path: '/auth/login'));

    expect(
      repo.login('x@x.com', 'bad'),
      throwsA(isA<Failure>()
          .having((f) => f.type, 'type', FailureType.invalidCredentials)),
    );
    expect(tokens.access, isNull);
  });

  test('logout : efface tokens ET cache', () async {
    tokens.access = 'A';
    tokens.refresh = 'R';
    cache.store['profile'] = _profile;

    await repo.logout();

    expect(tokens.access, isNull);
    expect(tokens.refresh, isNull);
    expect(cache.store, isEmpty);
  });

  test('restoreSession hors-ligne : utilise le profil en cache', () async {
    tokens.access = 'A';
    cache.store['profile'] = _profile;
    when(() => remote.profile()).thenThrow(dioError(DioExceptionType.connectionError));

    final user = await repo.restoreSession();

    expect(user?.email, 'john@mail.com');
  });

  test('restoreSession sans token : null', () async {
    expect(await repo.restoreSession(), isNull);
    verifyNever(() => remote.profile());
  });
}
