import 'package:core/remote_data_sourcers.dart';
import 'package:precos/data/remote/dtos/tabela_de_preco_dto.dart';
import 'package:precos/domain/data/remote/i_tabelas_de_preco_remote_data_source.dart';
import 'package:precos/domain/models/tabela_de_preco.dart';

class TabelaDePrecoRemoteDataSource extends RemoteDataSourceBase
    implements ITabelasDePrecoRemoteDataSource {
  TabelaDePrecoRemoteDataSource({required super.informacoesParaRequest});

  @override
  Future<TabelaDePreco> atualizarTabelaDePreco({
    required int id,
    required String nome,
    double? terminador,
  }) {
    var pathParamenters = {'id': id.toString()};
    var body = {'nome': nome, 'terminador': terminador};
    var response = put(pathParameters: pathParamenters, body: body);
    return response.then((res) => TabelaDePrecoDto.fromJson(res.body));
  }

  @override
  Future<TabelaDePreco> createTabelaDePreco({
    required String nome,
    double? terminador,
  }) {
    final body = <String, dynamic>{'nome': nome};
    if (terminador != null) {
      body['terminador'] = terminador;
    }
    var response = post(body: body);
    return response.then((res) => TabelaDePrecoDto.fromJson(res.body));
  }

  @override
  Future<void> desativarTabelaDePreco(int id) {
    // TODO: implement desativarTabelaDePreco
    throw UnimplementedError();
  }

  @override
  Future<TabelaDePreco?> fetchTabelaDePreco(int id) {
    var pathParamenters = {'id': id.toString()};
    var response = get(pathParameters: pathParamenters);
    return response.then((res) => TabelaDePrecoDto.fromJson(res.body));
  }

  @override
  Future<List<TabelaDePreco>> fetchTabelasDePreco({
    String? nome,
    bool? inativa,
  }) async {
    var queryParameters = {
      if (nome != null && nome.isNotEmpty) 'nome': nome,
      if (inativa != null) 'inativa': inativa.toString(),
    };
    var response = await get(queryParameters: queryParameters);
    return (response.body as List)
        .map((json) => TabelaDePrecoDto.fromJson(json))
        .toList();
  }

  @override
  String get path => '/v1/tabelas-de-precos/{id}';
}
