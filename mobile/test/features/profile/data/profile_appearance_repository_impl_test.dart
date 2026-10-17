import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/profile/data/datasources/profile_appearance_local_data_source.dart';
import 'package:frontend_mayoral/features/profile/data/datasources/profile_appearance_remote_data_source.dart';
import 'package:frontend_mayoral/features/profile/data/repositories/profile_appearance_repository_impl.dart';
import 'package:frontend_mayoral/features/profile/domain/entities/profile_appearance.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _userId = 'user-1';

void main() {
  late _MemoryStorage storage;
  late _MemoryFiles files;
  late _FakeBackend backend;
  late ProfileAppearanceRepositoryImpl repository;

  setUp(() {
    storage = _MemoryStorage();
    files = _MemoryFiles();
    backend = _FakeBackend();
    repository = ProfileAppearanceRepositoryImpl(
      local: ProfileAppearanceLocalDataSource(secureStorage: storage, files: files),
      remote: ProfileAppearanceRemoteDataSource(
        baseUrl: 'http://vita.test',
        tokenProvider: const _Token(),
        client: MockClient(backend.handle),
      ),
    );
  });

  test('el color se guarda en la cuenta con formato #RRGGBB', () async {
    final result = await repository.changeHeaderColor(_userId, 0xFF1565C0);

    expect(_data(result).headerColor, 0xFF1565C0);
    expect(_data(result).hasPendingChanges, isFalse);
    expect(backend.headerColor, '#1565C0');
  });

  test('sin señal el color queda en el celular y se sube después', () async {
    backend.online = false;

    final offline = await repository.changeHeaderColor(_userId, 0xFF1565C0);

    expect(_data(offline).headerColor, 0xFF1565C0);
    expect(_data(offline).hasPendingChanges, isTrue);
    expect(backend.headerColor, isNull);

    backend.online = true;
    final synced = await repository.sync(_userId);

    expect(_data(synced).hasPendingChanges, isFalse);
    expect(backend.headerColor, '#1565C0');
  });

  test('un cambio pendiente no se pisa con lo que trae la cuenta', () async {
    backend
      ..online = false
      ..headerColor = '#C62828';
    await repository.changeHeaderColor(_userId, 0xFF1565C0);

    backend.online = true;
    final synced = await repository.sync(_userId);

    expect(_data(synced).headerColor, 0xFF1565C0);
    expect(backend.headerColor, '#1565C0');
  });

  test('sube la foto y la reemplaza en vez de acumularlas', () async {
    await repository.changeAvatar(_userId, Uint8List.fromList([1, 2, 3]));
    final second = await repository.changeAvatar(_userId, Uint8List.fromList([4, 5, 6]));

    expect(backend.avatar, [4, 5, 6]);
    expect(backend.uploads, 2);
    expect(_data(second).avatarPath, isNotNull);
    expect(_data(second).hasPendingChanges, isFalse);
  });

  test('sin señal la foto se ve igual y se sube al volver la conexión', () async {
    backend.online = false;

    final offline = await repository.changeAvatar(_userId, Uint8List.fromList([7, 8]));

    expect(_data(offline).avatarPath, isNotNull);
    expect(_data(offline).hasPendingChanges, isTrue);
    expect(backend.avatar, isNull);

    backend.online = true;
    await repository.sync(_userId);

    expect(backend.avatar, [7, 8]);
  });

  test('una foto rechazada por el servidor se descarta y se avisa', () async {
    backend.rejectAvatar = true;

    final result = await repository.changeAvatar(_userId, Uint8List.fromList([9]));

    expect(result, isA<Failure<ProfileAppearance>>());
    expect((result as Failure<ProfileAppearance>).error.message, 'La foto tiene que ser JPEG, PNG o WebP.');
    final after = _data(await repository.load(_userId));
    expect(after.avatarPath, isNull);
    expect(after.hasPendingChanges, isFalse);
  });

  test('trae la foto subida desde otro celular', () async {
    backend
      ..avatar = [5, 5, 5]
      ..avatarUpdatedAt = DateTime.utc(2026, 10, 17, 12);

    final synced = await repository.sync(_userId);

    expect(_data(synced).avatarPath, isNotNull);
    expect(files.bytes[_userId], [5, 5, 5]);
  });

  test('quitar la foto la borra del celular y de la cuenta', () async {
    await repository.changeAvatar(_userId, Uint8List.fromList([1]));

    final removed = await repository.removeAvatar(_userId);

    expect(_data(removed).avatarPath, isNull);
    expect(backend.avatar, isNull);
  });

  test('no muestra la apariencia guardada de otro usuario', () async {
    await repository.changeHeaderColor('otro-usuario', 0xFF1565C0);

    final mine = await repository.load(_userId);

    expect(_data(mine).headerColor, isNull);
  });
}

ProfileAppearance _data(Result<ProfileAppearance> result) => (result as Success<ProfileAppearance>).data;

/// Backend en memoria con el contrato de `/api/v1/usuarios/me`.
class _FakeBackend {
  bool online = true;
  bool rejectAvatar = false;
  String? headerColor;
  List<int>? avatar;
  DateTime? avatarUpdatedAt;
  int uploads = 0;

  Future<http.Response> handle(http.Request request) async {
    if (!online) {
      throw http.ClientException('Sin conexión');
    }
    final path = request.url.path;
    if (path == '/api/auth/me' && request.method == 'GET') {
      return _profile();
    }
    if (path == '/api/v1/usuarios/me' && request.method == 'PATCH') {
      headerColor = (jsonDecode(request.body) as Map<String, dynamic>)['color_cabecera'] as String?;
      return _profile();
    }
    if (path == '/api/v1/usuarios/me/avatar') {
      switch (request.method) {
        case 'PUT':
          if (rejectAvatar) {
            return http.Response(
              jsonEncode({
                'success': false,
                'errors': [
                  {'code': 'avatar_formato_invalido', 'message': 'La foto tiene que ser JPEG, PNG o WebP.'},
                ],
              }),
              422,
            );
          }
          uploads++;
          avatar = _fileBytes(request);
          avatarUpdatedAt = DateTime.utc(2026, 10, 17, 10, uploads);
          return _profile();
        case 'GET':
          return avatar == null ? http.Response('', 404) : http.Response.bytes(avatar!, 200);
        case 'DELETE':
          avatar = null;
          avatarUpdatedAt = null;
          return _profile();
      }
    }
    return http.Response('', 404);
  }

  http.Response _profile() => http.Response(
    jsonEncode({
      'success': true,
      'data': {
        'id': _userId,
        'color_cabecera': headerColor,
        'avatar_actualizado_en': avatarUpdatedAt?.toIso8601String(),
      },
    }),
    200,
  );

  /// Extrae el contenido del campo `archivo` del multipart.
  List<int> _fileBytes(http.Request request) {
    final body = request.bodyBytes;
    final text = latin1.decode(body);
    final start = text.indexOf('\r\n\r\n', text.indexOf('name="archivo"')) + 4;
    final end = text.indexOf('\r\n--', start);
    return body.sublist(start, end);
  }
}

class _Token implements BackendAccessTokenProvider {
  const _Token();

  @override
  Future<String?> getAccessToken() async => 'token';
}

class _MemoryStorage implements SecureStorageService {
  final Map<String, String> values = {};

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }
}

class _MemoryFiles implements AvatarFileStore {
  final Map<String, Uint8List> bytes = {};

  @override
  Future<String?> path(String userId) async => bytes.containsKey(userId) ? '/fotos/$userId.jpg' : null;

  @override
  Future<Uint8List?> read(String userId) async => bytes[userId];

  @override
  Future<void> save(String userId, Uint8List data) async => bytes[userId] = data;

  @override
  Future<void> delete(String userId) async => bytes.remove(userId);
}
