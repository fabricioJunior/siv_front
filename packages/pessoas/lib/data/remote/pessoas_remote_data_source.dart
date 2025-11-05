import 'package:core/remote_data_sourcers.dart';
import 'package:pessoas/data/remote/dtos/pessoa_dto.dart';
import 'package:pessoas/data/remote/dtos/pessoas_dto.dart';
import 'package:pessoas/domain/data/data_sourcers/remote/i_pessoas_remote_data_source.dart';
import 'package:pessoas/domain/models/pessoa.dart';

int _pageSize = 10;

class PessoasRemoteDataSource extends RemoteDataSourceBase
    implements IPessoasRemoteDataSource {
  PessoasRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => 'v1/pessoas/{id}';

  @override
  Future<Pessoa> atualizarPessoa(Pessoa pessoa) async {
    var pathParameters = {
      'id': pessoa.id,
    };
    final response = await put(
      body: pessoa.toDto(),
      pathParameters: pathParameters,
    );
    return PessoaDto.fromJson(response.body);
  }

  @override
  Future<Pessoa?> getPessoa(int id) async {
    var pathParameters = {'id': id.toString()};
    final response = await get(pathParameters: pathParameters);

    return PessoaDto.fromJson(response.body);
  }

  @override
  Future<List<Pessoa>> getPessoas({
    int pagina = 1,
  }) async {
    var query = {
      'pagina': pagina.toString(),
      'itemsPorPagina': _pageSize.toString(),
    };
    final response = await get(
      queryParameters: query,
    );
    var lista =
        PessoasDto.fromJson(response.body as Map<String, dynamic>).items;
    return lista.toList();
  }

  @override
  Future<Pessoa?> recuperarPessoaPorDocumento(String documento) async {
    var pathParameters = {'id': '$documento/documento'};
    final response = await get(pathParameters: pathParameters);

    return PessoaDto.fromJson(response.body);
  }

  @override
  Future<Pessoa> criarPessoa({
    required bool bloqueado,
    required String contato,
    required String documento,
    required bool eCliente,
    required bool eFornecedor,
    required bool eFuncionario,
    required String? email,
    String? inscricaoEstadual,
    required String nome,
    required TipoContato tipoContato,
    required TipoPessoa tipoPessoa,
    required String? uf,
    required DateTime dataDeNascimento,
  }) async {
    var pessoa = PessoaDto(
      bloqueado: bloqueado,
      contato: contato,
      documento: documento,
      eCliente: eCliente,
      eFornecedor: eFornecedor,
      eFuncionario: eFuncionario,
      email: email,
      nome: nome,
      tipoContato: tipoContato,
      tipoPessoa: tipoPessoa,
      uf: uf,
      nascimento: dataDeNascimento,
    );

    var response = await post(body: pessoa.toJson());

    return PessoaDto.fromJson(response.body);
  }
}
