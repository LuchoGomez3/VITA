import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/post_authentication_summary.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/errors/domain_exception.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/team/data/datasources/team_remote_data_source.dart';
import 'package:frontend_mayoral/features/team/data/repositories/team_repository_impl.dart';
import 'package:frontend_mayoral/features/team/domain/entities/team.dart';
import 'package:frontend_mayoral/features/team/domain/errors/team_error.dart';
import 'package:frontend_mayoral/features/team/domain/use_cases/team_use_cases.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/join_establishment_cubit.dart';
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

Map<String, Object?> _accepted() => {
  'id': _campo,
  'owner_id': 'u-1',
  'nombre': 'La Sirena',
  'rol': 'employee',
  'created_at': '2026-10-01T00:00:00Z',
  'updated_at': '2026-10-01T00:00:00Z',
};

void main() {
  late MemoryStorage storage;
  late List<http.Request> requests;
  late DateTime now;

  TeamRepositoryImpl repository(
    http.Response Function(http.Request request) handler, {
    TeamOperationQueue? operations,
  }) {
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
      operations: operations,
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
    final cached = (await offline.readCached(_campo) as Success<TeamSnapshot?>).data;

    expect((refreshed as Failure).error.code, DomainErrorCode.offline);
    expect(cached!.members.single.email, 'ceci@example.com');
    expect(cached.invitations.single.isExpired, isTrue);
    expect(cached.fetchedAt, DateTime.utc(2026, 10, 17, 12));
  });

  test('la cache de un campo no pisa la de otro y una cache rota no rompe', () async {
    storage.values[SecureStorageKeys.teamSnapshot] = 'no es json';
    final repo = repository((request) => _ok(request.url.path.endsWith('/usuarios') ? [_member()] : <Object>[]));

    expect(await repo.readCached(_campo), isA<Failure<TeamSnapshot?>>());
    await repo.refresh(_campo);
    await repo.refresh('campo-2');

    final cache = jsonDecode(storage.values[SecureStorageKeys.teamSnapshot]!) as Map<String, dynamic>;
    expect(cache.keys, unorderedEquals([_campo, 'campo-2']));
  });

  test('invita con el email normalizado y el rol del backend', () async {
    final repo = repository((_) => _ok({..._invitation(), 'codigo': '7K4-P2M'}, status: 201));

    final result = await repo.invite(_campo, email: '  Vet@Example.com ', role: UserRole.veterinarian);

    expect((result as Success<TeamMutation<CreatedInvitation>>).data.value.code, '7K4-P2M');
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
      final result = await repository((_) => response).preview('7K4P2M');
      final error = (result as Failure).error;
      expect(error.code, code);
      expect((error.reason! as TeamFailure).reason, reason);
    }
  });

  test('informa cuántos intentos le quedan a quien canjea', () async {
    final response = http.Response.bytes(
      utf8.encode(
        jsonEncode({
          'success': false,
          'errors': [
            {
              'code': 'codigo_invalido',
              'message': 'x',
              'details': {'intentos_restantes': 4},
            },
          ],
        }),
      ),
      422,
    );

    final result = await repository((_) => response).accept('7K4P2N');

    final failure = (result as Failure).error.reason! as TeamFailure;
    expect(failure.reason, TeamErrorReason.invalidCode);
    expect(failure.remainingAttempts, 4);
  });

  test('reenviar, cancelar y quitar usan la ruta de cada recurso', () async {
    final repo = repository(
      (request) => request.method == 'DELETE' ? http.Response('', 204) : _ok({..._invitation(), 'codigo': 'Q8R-T3W'}),
    );

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

    final result = await repo.accept('7K4-P2M');

    final membership = (result as Success<TeamAcceptance>).data.membership;
    expect(membership.role, UserRole.veterinarian);
    expect(jsonDecode(requests.single.body), {'codigo': '7K4-P2M'});
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
        'establecimiento_renspa': '07.123.0.00456/01',
        'establecimiento_localidad': 'Coronel Moldes',
        'establecimiento_provincia': 'Córdoba',
        'rol': 'employee',
        'email': 'peon@example.com',
        'invitado_por': 'Cecilia Lazarte',
        'invitado_por_rol': 'owner',
        'expira_en': '2026-10-24T00:00:00Z',
      }),
    );

    final result = await repo.preview('7K4P2M');

    final preview = (result as Success<InvitationPreview>).data;
    expect(preview.establishmentName, 'La Sirena');
    expect(preview.role, UserRole.employee);
    expect(preview.renspa, '07.123.0.00456/01');
    expect(preview.locality, 'Coronel Moldes');
    expect(preview.invitedByRole, UserRole.owner);
    expect(preview.email, 'peon@example.com');
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
  for (final failure in [TimeoutException('storage timeout'), PlatformException(code: 'storage-unavailable')]) {
    test('lectura esperable de storage termina en Result: ${failure.runtimeType}', () async {
      final repo = repository(
        (request) => request.url.path.endsWith('/usuarios') ? _ok([_member()]) : _ok([_invitation()]),
      );
      storage.readFailure = failure;
      expect(await repo.findEstablishment(_campo), isA<Failure<EstablishmentMembership?>>());
      expect(await repo.readCached(_campo), isA<Failure<TeamSnapshot?>>());
      expect(await repo.refresh(_campo), isA<Failure<TeamSnapshot>>());
    });

    test('escritura esperable de storage termina en Result: ${failure.runtimeType}', () async {
      final repo = repository(
        (request) => request.url.path.endsWith('/usuarios') ? _ok([_member()]) : _ok([_invitation()]),
      );
      storage.writeFailure = failure;
      final result = await repo.refresh(_campo);
      expect((result as Failure<TeamSnapshot>).error.reason, (
        reason: TeamErrorReason.storageUnavailable,
        remainingAttempts: null,
      ));
    });

    test('canje confirmado conserva membresía si storage falla: ${failure.runtimeType}', () async {
      final repo = repository((_) => _ok(_accepted()));
      storage.writeFailure = failure;
      final accepted = (await repo.accept('7K4-P2M') as Success<TeamAcceptance>).data;
      expect(accepted.membership.id, _campo);
      expect(accepted.persistenceError, isNotNull);
      expect(requests.where((r) => r.method == 'POST'), hasLength(1));
      expect(storage.values.containsKey(SecureStorageKeys.establishmentCatalog), isFalse);
      // El contrato de recuperación es la sync de catálogo, sin repetir POST.
      storage.writeFailure = null;
      final catalog = EstablishmentCatalog(secureStorage: storage);
      await catalog.upsert(accepted.membership);
      expect((await catalog.getById(_campo))!.role, UserRole.employee);
      expect(requests, hasLength(1));
    });
  }

  test('invitar, reenviar, cancelar y quitar sobreviven a GET fallido y reapertura offline', () async {
    for (final action in ['invite', 'resend', 'cancel', 'remove']) {
      var offline = false;
      final repo = repository((request) {
        if (offline) throw http.ClientException('offline');
        if (request.method == 'DELETE') return http.Response('', 204);
        if (request.method == 'POST') {
          return _ok({
            ..._invitation(),
            'id': action == 'invite' ? 'inv-new' : 'inv-1',
            'expira_en': '2026-11-01T00:00:00Z',
            'codigo': 'SECRET-CODE',
          });
        }
        return request.url.path.endsWith('/usuarios')
            ? _ok([_member(), _member(id: 'u-2', rol: 'employee', titular: false)])
            : _ok([_invitation()]);
      });
      await repo.refresh(_campo);
      await repo.refresh('otro-campo');
      final before = jsonDecode(storage.values[SecureStorageKeys.teamSnapshot]!) as Map<String, dynamic>;
      TeamSnapshot confirmed;
      switch (action) {
        case 'invite':
          confirmed =
              (await repo.invite(_campo, email: 'vet@example.com', role: UserRole.employee)
                      as Success<TeamMutation<CreatedInvitation>>)
                  .data
                  .snapshot;
        case 'resend':
          confirmed = (await repo.resend(_campo, 'inv-1') as Success<TeamMutation<CreatedInvitation>>).data.snapshot;
        case 'cancel':
          confirmed = (await repo.cancel(_campo, 'inv-1') as Success<TeamMutation<void>>).data.snapshot;
        case 'remove':
          confirmed = (await repo.removeMember(_campo, 'u-2') as Success<TeamMutation<void>>).data.snapshot;
        default:
          throw StateError('Unknown action');
      }
      offline = true;
      expect(await repo.refresh(_campo), isA<Failure<TeamSnapshot>>());
      final reopened = repository((_) => throw http.ClientException('offline'));
      final cached = (await reopened.readCached(_campo) as Success<TeamSnapshot?>).data!;
      expect(cached, confirmed);
      if (action == 'invite') expect(cached.invitations.map((i) => i.id), ['inv-1', 'inv-new']);
      if (action == 'resend') expect(cached.invitations.single.expiresAt, DateTime.utc(2026, 11));
      if (action == 'cancel') expect(cached.invitations, isEmpty);
      if (action == 'remove') expect(cached.members.map((m) => m.userId), ['u-1']);
      final after = jsonDecode(storage.values[SecureStorageKeys.teamSnapshot]!) as Map<String, dynamic>;
      expect(after['otro-campo'], before['otro-campo']);
      expect(storage.values[SecureStorageKeys.teamSnapshot], isNot(contains('SECRET-CODE')));
      expect(storage.values[SecureStorageKeys.teamSnapshot], isNot(contains('codigo')));
    }
  });

  test('mutación confirmada informa falla local sin perder el snapshot conocido', () async {
    final repo = repository((request) {
      if (request.method == 'DELETE') return http.Response('', 204);
      return request.url.path.endsWith('/usuarios') ? _ok([_member()]) : _ok([_invitation()]);
    });
    await repo.refresh(_campo);
    storage.writeFailure = PlatformException(code: 'write-failed');
    final result = (await repo.cancel(_campo, 'inv-1') as Success<TeamMutation<void>>).data;
    expect(result.snapshot.invitations, isEmpty);
    expect(result.persistenceError, isNotNull);
    expect(requests.where((r) => r.method == 'DELETE'), hasLength(1));
  });

  test('dos repositorios con mutaciones superpuestas no pierden snapshots', () async {
    final operations = TeamOperationQueue();
    final started = Completer<void>();
    final release = Completer<http.Response>();
    final first = TeamRepositoryImpl(
      remote: TeamRemoteDataSource(
        baseUrl: 'https://api.example.com',
        tokenProvider: _Token(),
        client: MockClient((request) {
          started.complete();
          return release.future;
        }),
      ),
      secureStorage: storage,
      establishmentCatalog: EstablishmentCatalog(secureStorage: storage),
      clock: () => now,
      operations: operations,
    );
    final second = repository(
      (_) => _ok({..._invitation(), 'id': 'inv-2', 'codigo': 'Q8R-T3W'}),
      operations: operations,
    );
    final inviting = first.invite(_campo, email: 'one@example.com', role: UserRole.employee);
    await started.future;
    final another = second.invite('campo-2', email: 'two@example.com', role: UserRole.employee);
    final same = second.invite(_campo, email: 'two@example.com', role: UserRole.employee);
    release.complete(_ok({..._invitation(), 'codigo': '7K4-P2M'}));
    await Future.wait([inviting, another, same]);
    final cached = (await first.readCached(_campo) as Success<TeamSnapshot?>).data!;
    expect(cached.invitations.map((i) => i.id), ['inv-1', 'inv-2']);
    expect((await first.readCached('campo-2') as Success<TeamSnapshot?>).data!.invitations.single.id, 'inv-2');
  });

  test('respuesta de aceptación confirmada pero incompatible requiere recuperación', () async {
    final repo = repository((_) => _ok({'id': _campo}));
    final failure = (await repo.accept('7K4P2M') as Failure<TeamAcceptance>).error;
    expect(failure.reason, (reason: TeamErrorReason.acceptanceNeedsRecovery, remainingAttempts: null));
  });

  test('error de transporte al canjear no recomienda consumir de nuevo el código', () async {
    final repo = repository((_) => throw http.ClientException('connection lost'));
    final failure = (await repo.accept('7K4P2M') as Failure<TeamAcceptance>).error;
    expect(failure.reason, (reason: TeamErrorReason.acceptanceNeedsRecovery, remainingAttempts: null));
  });
  test('recuperar lectura antes de escribir conserva las otras filas del equipo', () async {
    final repo = repository((request) {
      if (request.method == 'DELETE') {
        storage.readFailure = null;
        return http.Response('', 204);
      }
      return request.url.path.endsWith('/usuarios') ? _ok([_member()]) : _ok([_invitation()]);
    });
    await repo.refresh(_campo);
    storage.readFailure = PlatformException(code: 'read-unavailable');
    final mutation = (await repo.cancel(_campo, 'inv-1') as Success<TeamMutation<void>>).data;
    expect(mutation.persistenceError, isNull);
    expect(mutation.snapshot.members.single.userId, 'u-1');
    final reopened = (await repo.readCached(_campo) as Success<TeamSnapshot?>).data!;
    expect(reopened.members.single.userId, 'u-1');
    expect(reopened.invitations, isEmpty);
  });

  test('lectura caída no pisa la cache y la UI conserva los datos que ya conocía', () async {
    final repo = repository((request) {
      if (request.method == 'DELETE') return http.Response('', 204);
      return request.url.path.endsWith('/usuarios') ? _ok([_member()]) : _ok([_invitation()]);
    });
    final original = (await repo.refresh(_campo) as Success<TeamSnapshot>).data;
    final encoded = storage.values[SecureStorageKeys.teamSnapshot];
    storage.readFailure = PlatformException(code: 'read-unavailable');
    final mutation = (await repo.cancel(_campo, 'inv-1') as Success<TeamMutation<void>>).data;
    expect(mutation.persistenceError, isNotNull);
    expect(storage.values[SecureStorageKeys.teamSnapshot], encoded);
    final visible = mutation.reconcile(original);
    expect(visible.members, original.members);
    expect(visible.invitations, isEmpty);
  });
  test('respuesta perdida después del efecto remoto se recupera y persiste sin duplicar', () async {
    var acceptedRemotely = false;
    var membershipCount = 0;
    var notifications = 0;
    var acceptanceRequests = 0;
    final repo = repository((request) {
      if (request.url.path.endsWith('/validaciones')) {
        return _ok({
          'establecimiento_id': _campo,
          'establecimiento_nombre': 'La Sirena',
          'rol': 'veterinarian',
          'expira_en': '2026-10-27T00:00:00Z',
        });
      }
      acceptanceRequests++;
      if (!acceptedRemotely) {
        acceptedRemotely = true;
        membershipCount++;
        notifications++;
        throw http.ClientException('response lost after remote commit');
      }
      return _ok({
        'id': _campo,
        'owner_id': 'owner',
        'nombre': 'La Sirena',
        'rol': 'veterinarian',
        'created_at': '2026-10-17T00:00:00Z',
        'updated_at': '2026-10-20T00:00:00Z',
      });
    });
    final flow = JoinEstablishmentCubit(
      JoinEstablishmentUseCase(repo, prepareData: () async => const Result.failure(offlineError)),
    )..edit('7K4P2M');
    addTearDown(flow.close);
    await flow.check();
    await flow.confirm();
    expect(acceptedRemotely, isTrue);
    expect(flow.state.step, JoinStep.recovery);
    expect(await EstablishmentCatalog(secureStorage: storage).getById(_campo), isNull);
    await flow.recover();
    expect(flow.state.step, JoinStep.joined);
    expect(flow.state.dataSync, JoinDataSync.failed);
    expect((await EstablishmentCatalog(secureStorage: storage).getById(_campo))?.name, 'La Sirena');
    expect(acceptanceRequests, 2);
    expect(membershipCount, 1);
    expect(notifications, 1);
  });

  test('una respuesta de otra sesión no escribe el catálogo ni el equipo', () async {
    var current = true;
    final pending = Completer<http.Response>();
    final started = Completer<void>();
    final repo = TeamRepositoryImpl(
      remote: TeamRemoteDataSource(
        baseUrl: 'https://api.example.com',
        tokenProvider: _Token(),
        client: MockClient((_) {
          started.complete();
          return pending.future;
        }),
      ),
      secureStorage: storage,
      establishmentCatalog: EstablishmentCatalog(secureStorage: storage),
      isSessionCurrent: () => current,
    );
    final accepting = repo.accept('7K4P2M');
    await started.future;
    current = false;
    pending.complete(
      _ok({
        'id': _campo,
        'owner_id': 'owner',
        'nombre': 'La Sirena',
        'rol': 'veterinarian',
        'created_at': '2026-10-17T00:00:00Z',
        'updated_at': '2026-10-20T00:00:00Z',
      }),
    );
    expect((await accepting as Failure<TeamAcceptance>).error.code, DomainErrorCode.unauthorized);
    expect(storage.values, isEmpty);
  });
  test('recuperar exige confirmación remota aunque la cache tenga la membresía', () async {
    storage.values[SecureStorageKeys.establishmentCatalog] = jsonEncode([
      {'id': _campo, 'name': 'Cache anterior', 'role': 'owner'},
    ]);
    var requestsCount = 0;
    var syncCalls = 0;
    final repo = repository((request) {
      if (request.url.path.endsWith('/validaciones')) {
        return _ok({
          'establecimiento_id': _campo,
          'establecimiento_nombre': 'La Sirena',
          'rol': 'veterinarian',
          'expira_en': '2026-10-27T00:00:00Z',
        });
      }
      requestsCount++;
      if (requestsCount == 1) throw http.ClientException('response lost');
      return _error(409, 'codigo_usado');
    });
    final flow = JoinEstablishmentCubit(
      JoinEstablishmentUseCase(
        repo,
        prepareData: () async {
          syncCalls++;
          return Result.success(PostAuthenticationSummary(establishmentIds: [_campo]));
        },
      ),
    )..edit('7K4P2M');
    addTearDown(flow.close);
    await flow.check();
    await flow.confirm();
    expect(flow.state.step, JoinStep.recovery);
    await flow.recover();
    expect(flow.state.joined, isNull);
    expect(flow.state.error?.code, DomainErrorCode.conflict);
    expect(syncCalls, 0);
    expect((await EstablishmentCatalog(secureStorage: storage).getById(_campo))?.name, 'Cache anterior');
  });
}
