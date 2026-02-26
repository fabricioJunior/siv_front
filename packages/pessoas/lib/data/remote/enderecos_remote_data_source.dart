import 'package:core/remote_data_sourcers.dart';
import 'package:pessoas/data/remote/dtos/endereco_dto.dart';
import 'package:pessoas/domain/data/data_sourcers/remote/i_enderecos_remote_data_source.dart';
import 'package:pessoas/models.dart';

class EnderecosRemoteDataSource extends RemoteDataSourceBase
    implements IEnderecosRemoteDataSource {
  EnderecosRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/pessoas/{pessoaId}/enderecos/{id}';

  @override
  Future<Endereco> atualizarEndereco({
    required int idPessoa,
    required Endereco endereco,
  }) async {
    final enderecoId = endereco.id;
    if (enderecoId == null) {
      throw Exception('Endereço sem ID para atualização.');
    }

    final response = await put(
      pathParameters: {'pessoaId': idPessoa, 'id': enderecoId},
      body: endereco.toDto().toJson(),
    );

    return EnderecoDto.fromJson(response.body);
  }

  @override
  Future<Endereco> criarEndereco({
    required int idPessoa,
    required Endereco endereco,
  }) async {
    final response = await post(
      pathParameters: {'pessoaId': idPessoa},
      body: endereco.toDto().toJson(),
    );

    return EnderecoDto.fromJson(response.body);
  }

  @override
  Future<void> excluirEndereco({
    required int idPessoa,
    required int idEndereco,
  }) async {
    final response = await delete(
      pathParameters: {'pessoaId': idPessoa, 'id': idEndereco},
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao excluir endereço');
    }
  }

  @override
  Future<List<Endereco>> getEnderecos({required int idPessoa}) async {
    final response = await get(pathParameters: {'pessoaId': idPessoa});

    return (response.body as List<dynamic>)
        .map((json) => EnderecoDto.fromJson(json))
        .toList();
  }
}
