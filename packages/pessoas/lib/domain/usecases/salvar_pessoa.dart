import 'package:pessoas/domain/data/repositories/i_pessoas_repository.dart';
import 'package:pessoas/models.dart';

class SalvarPessoa {
  final IPessoasRepository _pessoasRepository;

  SalvarPessoa({required IPessoasRepository pessoasRepository})
      : _pessoasRepository = pessoasRepository;
  Future<Pessoa> call({
    required Pessoa pessoa,
    String? nome,
    TipoPessoa? tipoPessoa,
    String? documento,
    String? uf,
    String? inscricaoEstadual,
    DateTime? dataDeNascimento,
    String? email,
    TipoContato? tipoContato,
    String? contato,
    bool? eCliente,
    bool? eFornecedor,
    bool? eFuncionario,
    bool? bloqueado,
  }) async {
    var updatedPessoa = pessoa.copyWith(
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
      inscricaoEstadual: inscricaoEstadual,
      uf: uf,
    );

    return _pessoasRepository.salvarPessoa(updatedPessoa);
  }
}
