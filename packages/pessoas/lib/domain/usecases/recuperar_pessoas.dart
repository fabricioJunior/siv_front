import 'package:pessoas/domain/data/repositories/i_pessoas_repository.dart';

import '../models/pessoa.dart';

class RecuperarPessoas {
  final IPessoasRepository _pessoasRepository;

  RecuperarPessoas({required IPessoasRepository pessoasRepository})
      : _pessoasRepository = pessoasRepository;

  Future<Iterable<Pessoa>> call() async {
    return await _pessoasRepository.recuperarPessoas();
  }
}
