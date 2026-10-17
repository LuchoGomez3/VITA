import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/team/data/datasources/team_remote_data_source.dart';
import 'package:frontend_mayoral/features/team/data/repositories/team_repository_impl.dart';
import 'package:frontend_mayoral/features/team/domain/entities/team.dart';
import 'package:frontend_mayoral/features/team/domain/errors/team_error.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../team_fakes.dart';

const _campo = 'campo-1';

Map<String, Object?> _member({String id = 'u-1', String rol = 'owner', bool titular = true}) => {
  'usuario_id': id,
  'nombre': 'Cecilia',
  'apellido': 'Lazarte',
  'email': 'ceci@example.com',
  'rol': rol,
  'es_titular': titular,
  'color_cabecera': '#2E7D32',
  'miembro_desde': '2026-10-01T00:00:00Z',
};

Map<String, Object?> _invitation({String expira = '2026-10-24T00:00:00Z', bool vencida = false}) => {
  'id': 'inv-1',
  'establecimiento_id': _campo,
  'email': 'vet@example.com',
  'rol': 'veterinarian',
  'estado': 'pendiente',
  'expira_en': expira,
  'vencida': vencida,
  'email_enviado': true,
  'invitado_por_id': 'u-1',
  'created_at': '2026-10-17T00:00:00Z',
};

http.Response _ok(Object? data, {int status = 200}) => http.Response.bytes(
  utf8.encode(jsonEncode({'success': true, 'data': data, 'meta': null, 'errors': null})),
  status,
  headers: {'content-type': 'application/json'},
);

http.Response _error(int status, String code) => http.Response.bytes(
  utf8.encode(
    jsonEncode({
      'success': false,
      'data': null,
      'errors': [
        {'code': code, 'message': 'mensaje del servidor'},
      ],
    }),
  ),
  status,
);

class _Token implements BackendAccessTokenProvider {
  @override
  Future<String?> getAccessToken() async => 'token';
}

void main() {
  late MemoryStorage storage;
  late List<http.Request> requests;
  late DateTime now;

  TeamRepositoryImpl repository(http.Response Function(http.Request request) handler) {
    return TeamRepositoryImpl(
      remote: TeamRemoteDataSource(
        baseUrl: 'https://api.example.com/',
        tokenProvider: _Token(),
        client: MockClient((request) async {
          requests.add(request);
          return handler(request);
        }),
      ),
      secureStorage: storage,
      establishmentCatalog: EstablishmentCatalog(secureStorage: storage),
      clock: () => now,
    );
  }

  setUp(() {
    storage = MemoryStorage();
    requests = [];
    now = DateTime.utc(2026, 10, 17, 12);
  });

  test('trae el equipo, lo guarda en el celular y lo lee sin conexión', () async {
    final repo = repository(
      (request) => request.url.path.endsWith('/usuarios') ? _ok([_member()]) : _ok([_invitation()]),
    );

    final result = await repo.refresh(_campo);

    final snapshot = (result as Success<TeamSnapshot>).data;
    expect(snapshot.members.single.role, UserRole.owner);
    expect(snapshot.members.single.isHolder, isTrue);
    expect(snapshot.invitations.single.role, UserRole.veterinarian);
    expect(requests.map((r) => r.url.toString()), [
      'https://api.example.com/api/v1/establecimientos/campo-1/usuarios',
      'https://api.example.com/api/v1/establecimientos/campo-1/invitaciones',
    ]);
    expect(requests.first.headers['Authorization'], 'Bearer token');

    // Una semana después, sin red: lo guardado se lee y la invitación ya venció.
    now = DateTime.utc(2026, 10, 25);
    final offline = repository((_) => throw http.ClientException('sin red'));
    final refreshed = await offline.refresh(_campo);
    final cached = await offline.readCached(_campo);

    expect((refreshed as Failure).error.code, DomainErrorCode.offline);
    expect(cached!.members.single.email, 'ceci@example.com');
    expect(cached.invitations.single.isExpired, isTrue);
    expect(cached.fetchedAt, DateTime.utc(2026, 10, 17, 12));
  });

  test('la cache de un campo no pisa la de otro y una cache rota no rompe', () async {
    storage.values[SecureStorageKeys.teamSnapshot] = 'no es json';
    final repo = repository((request) => _ok(request.url.path.endsWith('/usuarios') ? [_member()] : <Object>[]));

    expect(await repo.readCached(_campo), isNull);
    await repo.refresh(_campo);
    await repo.refresh('campo-2');

    final cache = jsonDecode(storage.values[SecureStorageKeys.teamSnapshot]!) as Map<String, dynamic>;
    expect(cache.keys, unorderedEquals([_campo, 'campo-2']));
  });

  test('invita con el email normalizado y el rol del backend', () async {
    final repo = repository((_) => _ok(_invitation(), status: 201));

    final result = await repo.invite(_campo, email: '  Vet@Example.com ', role: UserRole.veterinarian);

    expect(result, isA<Success<TeamInvitation>>());
    final request = requests.single;
    expect(request.method, 'POST');
    expect(request.url.path, '/api/v1/establecimientos/campo-1/invitaciones');
    expect(jsonDecode(request.body), {'email': 'vet@example.com', 'rol': 'veterinarian'});
  });

  test('traduce los códigos de error del backend a motivos del equipo', () async {
    final cases = {
      _error(409, 'invitacion_pendiente_duplicada'): (DomainErrorCode.conflict, TeamErrorReason.duplicatedInvitation),
      _error(403, 'rol_no_asignable'): (DomainErrorCode.unknown, TeamErrorReason.roleNotAssignable),
      _error(422, 'codigo_vencido'): (DomainErrorCode.validation, TeamErrorReason.expiredCode),
      http.Response(jsonEncode({'error': 'Demasiados intentos.', 'status': 429}), 429): (
        DomainErrorCode.unknown,
        TeamErrorReason.tooManyAttempts,
      ),
    };

    for (final MapEntry(key: response, value: (code, reason)) in cases.entries) {
      final result = await repository((_) => response).preview('K7QM4XPD');
      final error = (result as Failure).error;
      expect(error.code, code);
      expect(error.reason, reason);
    }
  });

  test('reenviar, cancelar y quitar usan la ruta de cada recurso', () async {
    final repo = repository((request) => request.method == 'DELETE' ? http.Response('', 204) : _ok(_invitation()));

    await repo.resend(_campo, 'inv-1');
    await repo.cancel(_campo, 'inv-1');
    await repo.removeMember(_campo, 'u-2');

    expect(requests.map((r) => '${r.method} ${r.url.path}'), [
      'POST /api/v1/establecimientos/campo-1/invitaciones/inv-1/reenvios',
      'DELETE /api/v1/establecimientos/campo-1/invitaciones/inv-1',
      'DELETE /api/v1/establecimientos/campo-1/usuarios/u-2',
    ]);
  });

  test('canjear agrega el campo al catálogo con todos sus datos', () async {
    final repo = repository(
      (_) => _ok({
        'id': _campo,
        'owner_id': 'u-1',
        'nombre': 'La Sirena',
        'rol': 'veterinarian',
        'nro_renspa': '07.123.0.00456/01',
        'superficie_ha': '847.00',
        'poligono': null,
        'created_at': '2026-10-01T00:00:00Z',
        'updated_at': '2026-10-01T00:00:00Z',
      }, status: 201),
    );

    final result = await repo.accept('K7QM-4XPD');

    final membership = (result as Success<EstablishmentMembership>).data;
    expect(membership.role, UserRole.veterinarian);
    expect(jsonDecode(requests.single.body), {'codigo': 'K7QM-4XPD'});
    final catalog = jsonDecode(storage.values[SecureStorageKeys.establishmentCatalog]!) as List<dynamic>;
    final entry = catalog.single as Map<String, dynamic>;
    expect(entry['name'], 'La Sirena');
    expect(entry['role'], 'veterinarian');
    expect(entry['renspa_number'], '07.123.0.00456/01');
    expect(entry['area_hectares'], 847.0);
  });

  test('previsualiza el campo y el rol del código', () async {
    final repo = repository(
      (_) => _ok({
        'establecimiento_id': _campo,
        'establecimiento_nombre': 'La Sirena',
        'rol': 'employee',
        'invitado_por': 'Cecilia Lazarte',
        'expira_en': '2026-10-24T00:00:00Z',
      }),
    );

    final result = await repo.preview('K7QM4XPD');

    final preview = (result as Success<InvitationPreview>).data;
    expect(preview.establishmentName, 'La Sirena');
    expect(preview.role, UserRole.employee);
    expect(requests.single.url.path, '/api/v1/invitaciones/validaciones');
  });

  test('una respuesta sin datos se informa como error y no como crash', () async {
    final result = await repository(
      (_) => _ok([
        {'usuario_id': 1},
      ]),
    ).refresh(_campo);

    expect(result, isA<Failure<TeamSnapshot>>());
  });
}
