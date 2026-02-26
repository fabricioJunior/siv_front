import 'package:pessoas/domain/data/repositories/i_enderecos_repository.dart';

class ExcluirEndereco {
  final IEnderecosRepository _enderecosRepository;

  ExcluirEndereco({required IEnderecosRepository enderecosRepository})
      : _enderecosRepository = enderecosRepository;

  Future<void> call({required int idPessoa, required int idEndereco}) {
    return _enderecosRepository.excluirEndereco(
      idPessoa: idPessoa,
      idEndereco: idEndereco,
    );
  }
}
