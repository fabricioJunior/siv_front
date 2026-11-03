import 'package:autenticacao/data/repositories/permissoes_do_usuario_repository.dart';
import 'package:autenticacao/domain/data/data_sourcers/local/i_permissoes_do_usuario_local_data_source.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_permissoes_do_usuario_remote_data_source.dart';
import 'package:autenticacao/models.dart';
import 'package:flutter_test/flutter_test.dart';

class _Perm extends PermissaoDoUsuario {
  _Perm(this.componenteId);
  @override
  final String componenteId;
  @override
  int get id => 1;
  @override
  int get empresaId => 1;
  @override
  int get grupoId => 1;
  @override
  String get grupoNome => 'g';
  @override
  String get componenteNome => 'n';
  @override
  int get descontinuado => 0;
}

class _Local implements IPermissoesDoUsuarioLocalDataSource<PermissaoDoUsuario> {
  final dados = <String, PermissaoDoUsuario>{'A': _Perm('A'), 'B': _Perm('B')};
  final vazioObservado = <String>[];
  final sequencia = <String>[];

  void _obs(String op) {
    sequencia.add(op);
    if (dados.isEmpty) vazioObservado.add(op);
  }

  @override
  Future<void> putAll(Iterable<PermissaoDoUsuario> e) async {
    for (final p in e) {
      dados[p.componenteId] = p;
    }
    _obs('putAll');
  }

  @override
  Future<void> removerExceto(Set<String> ids) async {
    dados.removeWhere((k, _) => !ids.contains(k));
    _obs('removerExceto');
  }

  @override
  Future<Iterable<PermissaoDoUsuario>> fetchAll() async => dados.values.toList();

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Remote implements IPermissoesDoUsuarioRemoteDataSource {
  List<PermissaoDoUsuario> resposta = [];
  @override
  Future<List<PermissaoDoUsuario>> getPermissoes(int idUsuario) async =>
      resposta;
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  test('(vii) sync troca permissoes sem nunca deixar o armazenamento vazio',
      () async {
    final local = _Local();
    final remote = _Remote()..resposta = [_Perm('B'), _Perm('C')];
    final repo = PermissoesDoUsuarioRepository(
      localDataSource: local,
      remoteDataSource: remote,
    );

    await repo.sincronizarPermissoes(1);

    expect(local.sequencia, ['putAll', 'removerExceto']);
    expect(local.vazioObservado, isEmpty);
    expect(local.dados.keys.toSet(), {'B', 'C'});
  });

  test('resposta vazia nao apaga o armazenamento', () async {
    final local = _Local();
    final repo = PermissoesDoUsuarioRepository(
      localDataSource: local,
      remoteDataSource: _Remote(),
    );
    await repo.sincronizarPermissoes(1);
    expect(local.dados.keys.toSet(), {'A', 'B'});
  });
}
