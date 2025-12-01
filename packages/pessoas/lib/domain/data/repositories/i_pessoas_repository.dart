import 'package:pessoas/domain/models/pessoa.dart';

abstract class IPessoasRepository {
  Future<Iterable<Pessoa>> recuperarPessoas({
    int pagina,
    String? busca,
  });

  Future<Pessoa?> recuperarPessoa(int id);

  Future<Pessoa?> recuperarPessoaPeloDocumento(String documento);

  Future<Pessoa> salvarPessoa(Pessoa pessoa);

  Future<Pessoa> novaPessoa({
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
  });
}
