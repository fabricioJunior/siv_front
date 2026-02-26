import 'package:pessoas/domain/data/repositories/i_enderecos_repository.dart';
import 'package:pessoas/models.dart';

class CriarEndereco {
  final IEnderecosRepository _enderecosRepository;

  CriarEndereco({required IEnderecosRepository enderecosRepository})
      : _enderecosRepository = enderecosRepository;

  Future<Endereco> call({required int idPessoa, required Endereco endereco}) {
    return _enderecosRepository.novoEndereco(
      idPessoa: idPessoa,
      endereco: endereco,
    );
  }
}
