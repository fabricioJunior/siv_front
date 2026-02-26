import 'package:pessoas/domain/data/repositories/i_enderecos_repository.dart';
import 'package:pessoas/models.dart';

class RecuperarEnderecosDaPessoa {
  final IEnderecosRepository _enderecosRepository;

  RecuperarEnderecosDaPessoa(
      {required IEnderecosRepository enderecosRepository})
      : _enderecosRepository = enderecosRepository;

  Future<List<Endereco>> call({required int idPessoa}) {
    return _enderecosRepository.recuperarEnderecos(idPessoa: idPessoa);
  }
}
