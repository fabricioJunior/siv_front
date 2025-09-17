import 'package:pessoas/domain/models/pessoa.dart';

abstract class IPessoasRemoteDataSource {
  Future<List<Pessoa>> getPessoas();

  Future<Pessoa?> getPessoa(int id);

  Future<Pessoa> atualizarPessoa(Pessoa pessoa);

  Future<Pessoa> criarPessoa(Pessoa pessoa);
}
