import 'package:pessoas/domain/data/repositories/i_pessoas_repository.dart';

import '../models/pessoa.dart';

class RecuperarPessoaPeloDocumento {
  final IPessoasRepository _pessoasRepository;

  RecuperarPessoaPeloDocumento({required IPessoasRepository pessoasRepository})
      : _pessoasRepository = pessoasRepository;

  Future<Pessoa?> call({required String documento}) async {
    return await _pessoasRepository.recuperarPessoaPeloDocumento(
      documento,
    );
  }
}
