import 'package:pessoas/domain/data/repositories/i_pessoas_repository.dart';
import 'package:pessoas/models.dart';

class RecuperarPessoa {
  final IPessoasRepository _pessoasRepository;

  RecuperarPessoa({required IPessoasRepository pessoasRepository})
      : _pessoasRepository = pessoasRepository;
  Future<Pessoa?> call({
    required int idPessoa,
  }) async {
    return _pessoasRepository.recuperarPessoa(idPessoa);
  }
}
