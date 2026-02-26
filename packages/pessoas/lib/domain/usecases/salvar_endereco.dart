import 'package:pessoas/domain/data/repositories/i_enderecos_repository.dart';
import 'package:pessoas/models.dart';

class SalvarEndereco {
  final IEnderecosRepository _enderecosRepository;

  SalvarEndereco({required IEnderecosRepository enderecosRepository})
      : _enderecosRepository = enderecosRepository;

  Future<Endereco> call({required int idPessoa, required Endereco endereco}) {
    return _enderecosRepository.salvarEndereco(
      idPessoa: idPessoa,
      endereco: endereco,
    );
  }
}
