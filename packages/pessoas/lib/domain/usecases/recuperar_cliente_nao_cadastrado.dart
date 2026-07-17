import 'package:pessoas/domain/data/repositories/i_pessoas_repository.dart';
import 'package:pessoas/models.dart';

class RecuperarClienteNaoCadastrado {
  final IPessoasRepository _pessoasRepository;

  RecuperarClienteNaoCadastrado({required IPessoasRepository pessoasRepository})
      : _pessoasRepository = pessoasRepository;

  Future<Pessoa> call() async {
    return _pessoasRepository.recuperarClienteNaoCadastrado();
  }
}
