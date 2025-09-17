import 'package:pessoas/domain/models/pessoa.dart';

abstract class IPessoasRepository {
  Future<Iterable<Pessoa>> recuperarPessoas();

  Future<Pessoa?> recuperarPessoa(int id);

  Future<Pessoa?> recuperarPessoaPeloDocumento(String documento);

  Future<Pessoa> salvarPessoa(Pessoa pessoa);
}
