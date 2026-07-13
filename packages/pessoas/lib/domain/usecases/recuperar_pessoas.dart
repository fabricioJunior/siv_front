import 'package:pessoas/domain/data/repositories/i_pessoas_repository.dart';

import '../models/pessoa.dart';

class RecuperarPessoas {
  final IPessoasRepository _pessoasRepository;

  RecuperarPessoas({required IPessoasRepository pessoasRepository})
      : _pessoasRepository = pessoasRepository;

  Future<Iterable<Pessoa>> call({
    int pagina = 1,
    String? busca,
    bool? eCliente,
    bool? eFornecedor,
    bool? eFuncionario,
    bool? clienteOuFuncionario,
  }) async {
    return await _pessoasRepository.recuperarPessoas(
      pagina: pagina,
      busca: busca,
      eCliente: eCliente,
      eFornecedor: eFornecedor,
      eFuncionario: eFuncionario,
      clienteOuFuncionario: clienteOuFuncionario,
    );
  }
}
