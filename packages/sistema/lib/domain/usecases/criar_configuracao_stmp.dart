import 'package:sistema/domain/data/repositories/i_configuracao_stmp_repository.dart';
import 'package:sistema/models.dart';

class CriarConfiguracaoSTMP {
  final IConfiguracaoSTMPRepository _repository;

  CriarConfiguracaoSTMP({
    required IConfiguracaoSTMPRepository repository,
  }) : _repository = repository;

  Future<ConfiguracaoSTMP> call({
    required int id,
    required String servidor,
    required int porta,
    required String usuario,
    required String senha,
    required String assuntoRedefinicaoSenha,
    required String corpoRedefinicaoSenha,
    required String urlVerificacaoEmail,
    required String assuntoVerificacaoEmail,
    required String corpoVerificacaoEmail,
  }) {
    final configuracao = ConfiguracaoSTMP.create(
      id: id,
      servidor: servidor,
      porta: porta,
      usuario: usuario,
      senha: senha,
      redefinirSenhaTemplate: RedefinirSenhaTemplate.create(
        assunto: assuntoRedefinicaoSenha,
        corpo: corpoRedefinicaoSenha,
      ),
      urlVerificacaoEmail: urlVerificacaoEmail,
      verificacaoEmailTemplate: VerificacaoEmailTemplate.create(
        assunto: assuntoVerificacaoEmail,
        corpo: corpoVerificacaoEmail,
      ),
    );

    return _repository.criarConfiguracao(configuracao);
  }
}
