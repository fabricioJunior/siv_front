import 'package:autenticacao/domain/data/repositories/i_empresas_repository.dart';
import 'package:autenticacao/domain/data/repositories/i_token_repository.dart';
import 'package:autenticacao/models.dart';

class CriarTokenDeAutenticacao {
  final ITokenRepository _repository;
  final IEmpresasRepository _empresasRepository;

  CriarTokenDeAutenticacao({
    required ITokenRepository repository,
    required IEmpresasRepository empresasRepository,
  })  : _repository = repository,
        _empresasRepository = empresasRepository;

  Future<Token?> call({
    required String usuario,
    required String senha,
    Empresa? empresa,
  }) async {
    var token = await _repository.recuperarTokenDoServidor(
      usuario,
      senha,
      empresa?.id,
    );
    if (empresa != null) {
      await _empresasRepository.salvarEmpresaDaSessao(empresa);
    }
    if (token != null) {
      await _repository.deleteToken(notificarTokenExcluido: false);
      await _repository.putToken(token);
    }

    return token;
  }
}
