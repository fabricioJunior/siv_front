import 'package:pessoas/domain/data/repositories/i_pessoas_repository.dart';
import 'package:pessoas/domain/models/pessoa.dart';

class CriarPessoa {
  final IPessoasRepository _pessoasRepository;

  CriarPessoa({required IPessoasRepository pessoasRepository})
      : _pessoasRepository = pessoasRepository;

  Future<Pessoa> call({
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
    return await _pessoasRepository.novaPessoa(
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
      dataDeNascimento: dataDeNascimento,
    );
  }
}
