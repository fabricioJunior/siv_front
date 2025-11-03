import 'package:pessoas/domain/models/pessoa.dart';

abstract class IPessoasRemoteDataSource {
  Future<List<Pessoa>> getPessoas();

  Future<Pessoa?> getPessoa(int id);

  Future<Pessoa?> recuperarPessoaPorDocumento(String documento);

  Future<Pessoa> atualizarPessoa(Pessoa pessoa);

  Future<Pessoa> criarPessoa({
    required bool bloqueado,
    required String contato,
    required String documento,
    required bool eCliente,
    required bool eFornecedor,
    required bool eFuncionario,
    required String email,
    String? inscricaoEstadual,
    required String nome,
    required TipoContato tipoContato,
    required TipoPessoa tipoPessoa,
    required String uf,
  });
}
