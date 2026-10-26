import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/auth/backend_access_token_provider.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/core/authentication/establishment_membership.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/storage/storage.dart';
import 'package:frontend_mayoral/features/team/data/datasources/team_remote_data_source.dart';
import 'package:frontend_mayoral/features/team/data/repositories/team_repository_impl.dart';
import 'package:frontend_mayoral/features/team/domain/entities/team.dart';
import 'package:frontend_mayoral/features/team/domain/use_cases/team_use_cases.dart';
import 'package:frontend_mayoral/features/team/presentation/cubit/team_cubit.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../team_fakes.dart';

void main() {
  for (final action in ['cancel', 'remove', 'resend']) {
    for (final manualRefresh in [false, true]) {
      test('$action limpia el aviso solo tras persistir el refresco (manual: $manualRefresh)', () async {
        final storage = _RecoverableStorage();
        final catalog = EstablishmentCatalog(secureStorage: storage);
        await catalog.upsert(
          const EstablishmentMembership(id: 'campo-1', name: 'Campo sintético', role: UserRole.owner),
        );
        var confirmed = false;
        var offline = false;
        var mutations = 0;
        final client = MockClient((request) async {
          if (request.method != 'GET') {
            confirmed = true;
            mutations++;
            offline = manualRefresh;
            if (action == 'resend') return _ok({..._invitation(), 'codigo': 'NEW-CODE'});
            return http.Response('', 204);
          }
          if (offline) throw http.ClientException('Offline');
          if (request.url.path.endsWith('/usuarios')) {
            return _ok([
              if (!confirmed || action != 'remove')
                {
                  'usuario_id': worker.userId,
                  'nombre': worker.firstName,
                  'apellido': worker.lastName,
                  'email': worker.email,
                  'rol': worker.role.backendValue,
                  'es_titular': false,
                  'miembro_desde': worker.memberSince.toIso8601String(),
                },
            ]);
          }
          return _ok([if (!confirmed || action != 'cancel') _invitation()]);
        });
        addTearDown(client.close);
        TeamRepositoryImpl repository() => TeamRepositoryImpl(
          remote: TeamRemoteDataSource(baseUrl: 'https://api.example.com', tokenProvider: _Token(), client: client),
          secureStorage: storage,
          establishmentCatalog: catalog,
          clock: () => DateTime.utc(2026, 10, 22),
        );
        final repo = repository();
        final cubit = TeamCubit(
          establishmentId: 'campo-1',
          getMembership: GetTeamMembershipUseCase(repo),
          readCached: ReadCachedTeamUseCase(repo),
          refreshTeam: RefreshTeamUseCase(repo),
          manageTeam: ManageTeamUseCase(repo),
        );
        addTearDown(cubit.close);
        await cubit.load();
        final observed = <TeamState>[];
        final subscription = cubit.stream.listen(observed.add);
        addTearDown(subscription.cancel);
        storage.failNextSnapshot = true;

        switch (action) {
          case 'cancel':
            await cubit.cancel(pendingVet);
          case 'remove':
            await cubit.remove(worker);
          case 'resend':
            await cubit.resend(pendingVet);
        }
        if (manualRefresh) {
          expect(cubit.state.persistenceError, isNotNull, reason: 'Un GET fallido no acredita persistencia');
          offline = false;
          await cubit.refresh();
        }

        expect(observed.any((state) => state.persistenceError != null), isTrue);
        expect(cubit.state.persistenceError, isNull);
        expect(cubit.state.notice, switch (action) {
          'cancel' => TeamNotice.cancelled,
          'remove' => TeamNotice.removed,
          _ => TeamNotice.resent,
        });
        if (action == 'resend') expect(cubit.state.created?.code, 'NEW-CODE');
        final cached = await repository().readCached('campo-1');
        expect((cached as Success<TeamSnapshot?>).data, cubit.state.snapshot);
        expect(storage.values[SecureStorageKeys.teamSnapshot], isNot(contains('NEW-CODE')));
        expect(mutations, 1);
      });
    }
  }
}

Map<String, Object?> _invitation() => {
  'id': pendingVet.id,
  'email': pendingVet.email,
  'rol': pendingVet.role.backendValue,
  'expira_en': DateTime.utc(2030).toIso8601String(),
  'vencida': false,
  'email_enviado': true,
  'created_at': pendingVet.createdAt.toIso8601String(),
};

http.Response _ok(Object data) => http.Response.bytes(
  utf8.encode(jsonEncode({'success': true, 'data': data})),
  200,
  headers: {'content-type': 'application/json'},
);

class _RecoverableStorage extends MemoryStorage {
  bool failNextSnapshot = false;
  @override
  Future<void> write({required String key, required String value}) async {
    if (key == SecureStorageKeys.teamSnapshot && failNextSnapshot) {
      failNextSnapshot = false;
      throw PlatformException(code: 'storage-unavailable');
    }
    await super.write(key: key, value: value);
  }
}

class _Token implements BackendAccessTokenProvider {
  @override
  Future<String?> getAccessToken() async => 'synthetic-token';
}
