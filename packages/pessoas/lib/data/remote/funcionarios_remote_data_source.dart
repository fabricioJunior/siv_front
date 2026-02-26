import 'package:core/remote_data_sourcers.dart';
import 'package:pessoas/domain/data/data_sourcers/remote/i_funcionarios_remote_data_source.dart';
import 'package:pessoas/models.dart';

class FuncionariosRemoteDataSource extends RemoteDataSourceBase
    implements IFuncionariosRemoteDataSource {
  FuncionariosRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/funcionarios/{id}';

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
  Future<List<Funcionario>> getFuncionarios() async {
    final response = await get();

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
  Future<Funcionario> criarFuncionario(
      {required Funcionario funcionario}) async {
    final response = await post(body: funcionario.toJson());
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
}
