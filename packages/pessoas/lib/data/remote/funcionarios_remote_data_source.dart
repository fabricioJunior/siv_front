import 'package:core/remote_data_sourcers.dart';
import 'package:pessoas/domain/data/data_sourcers/remote/i_funcionarios_remote_data_source.dart';
import 'package:pessoas/models.dart';

class FuncionariosRemoteDataSource extends RemoteDataSourceBase
    implements IFuncionariosRemoteDataSource {
  FuncionariosRemoteDataSource({required super.informacoesParaRequest});

  // ponytail: rota de vínculos tem profundidade diferente do CRUD de
  // funcionário ('/funcionarios/{id}/empresas/...'). RemoteDataSourceBase só
  // permite um template de path por classe, então usamos este override
  // temporário (setado e limpo dentro do mesmo método, sem await entre as
  // duas pontas) em vez de duplicar toda a validação/parsing de erro da
  // classe base numa segunda implementação.
  String? _pathOverride;

  @override
  String get path => _pathOverride ?? '/v1/funcionarios/{id}';

  @override
  Future<Funcionario?> getFuncionario({required int idFuncionario}) async {
    final response = await get(
      pathParameters: {'id': idFuncionario.toString()},
    );

    if (response.body == null) {
      return null;
    }

    return Funcionario.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<List<Funcionario>> getFuncionarios({int? pessoaId}) async {
    final response = await get(
      queryParameters: pessoaId != null
          ? {'pessoaId': pessoaId.toString()}
          : null,
    );

    return (response.body as List<dynamic>)
        .map((json) => Funcionario.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Funcionario> atualizarFuncionario({
    required Funcionario funcionario,
  }) async {
    final response = await put(
      pathParameters: {'id': funcionario.id.toString()},
      body: funcionario.toJson(),
    );

    return Funcionario.fromJson(response.body);
  }

  @override
  Future<Funcionario> criarFuncionario({
    required Funcionario funcionario,
    required int empresaId,
  }) async {
    final response = await post(
      body: {...funcionario.toJson(), 'empresaId': empresaId},
    );
    return Funcionario.fromJson(response.body);
  }

  @override
  Future<void> excluirFuncionario({required int idFuncionario}) async {
    final response = await delete(
      pathParameters: {'id': idFuncionario.toString()},
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao excluir funcionário');
    }
  }

  @override
  Future<List<FuncionarioEmpresaVinculo>> getVinculosDoFuncionario({
    required int idFuncionario,
  }) async {
    _pathOverride = '/v1/funcionarios/{id}/empresas';
    try {
      final response = await get(
        pathParameters: {'id': idFuncionario.toString()},
      );
      return (response.body as List<dynamic>)
          .map((json) =>
              FuncionarioEmpresaVinculo.fromJson(json as Map<String, dynamic>))
          .toList();
    } finally {
      _pathOverride = null;
    }
  }

  @override
  Future<FuncionarioEmpresaVinculo> vincularEmpresa({
    required int idFuncionario,
    required int idEmpresa,
  }) async {
    _pathOverride = '/v1/funcionarios/{id}/empresas';
    try {
      final response = await post(
        pathParameters: {'id': idFuncionario.toString()},
        body: {'empresaId': idEmpresa},
      );
      return FuncionarioEmpresaVinculo.fromJson(
        response.body as Map<String, dynamic>,
      );
    } finally {
      _pathOverride = null;
    }
  }

  @override
  Future<void> desativarVinculo({
    required int idFuncionario,
    required int idEmpresa,
  }) async {
    _pathOverride = '/v1/funcionarios/{id}/empresas/{empresaId}/desativar';
    try {
      await put(
        pathParameters: {
          'id': idFuncionario.toString(),
          'empresaId': idEmpresa.toString(),
        },
        body: const {},
      );
    } finally {
      _pathOverride = null;
    }
  }

  @override
  Future<void> reativarVinculo({
    required int idFuncionario,
    required int idEmpresa,
  }) async {
    _pathOverride = '/v1/funcionarios/{id}/empresas/{empresaId}/reativar';
    try {
      await put(
        pathParameters: {
          'id': idFuncionario.toString(),
          'empresaId': idEmpresa.toString(),
        },
        body: const {},
      );
    } finally {
      _pathOverride = null;
    }
  }
}
