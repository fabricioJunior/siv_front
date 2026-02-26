import 'package:pessoas/models.dart';

abstract class IEnderecosRepository {
  Future<List<Endereco>> recuperarEnderecos({
    required int idPessoa,
  });

  Future<Endereco> novoEndereco({
    required int idPessoa,
    required Endereco endereco,
  });

  Future<Endereco> salvarEndereco({
    required int idPessoa,
    required Endereco endereco,
  });

  Future<void> excluirEndereco({
    required int idPessoa,
    required int idEndereco,
  });
}
