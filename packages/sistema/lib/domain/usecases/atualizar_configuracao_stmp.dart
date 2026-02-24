import 'package:sistema/domain/data/repositories/i_configuracao_stmp_repository.dart';
import 'package:sistema/models.dart';

class AtualizarConfiguracaoSTMP {
  final IConfiguracaoSTMPRepository _repository;

  AtualizarConfiguracaoSTMP({
    required IConfiguracaoSTMPRepository repository,
  }) : _repository = repository;

  Future<ConfiguracaoSTMP> call({
    required ConfiguracaoSTMP configuracao,
    String? servidor,
    int? porta,
    String? usuario,
    String? senha,
    String? assuntoRedefinicaoSenha,
    String? corpoRedefinicaoSenha,
  }) {
    final configuracaoAtualizada = configuracao.copyWith(
      servidor: servidor,
      porta: porta,
      usuario: usuario,
      senha: senha,
      redefinirSenhaTemplate: configuracao.redefinirSenhaTemplate.copyWith(
        assunto: assuntoRedefinicaoSenha,
        corpo: corpoRedefinicaoSenha,
      ),
    );

    return _repository.atualizarConfiguracao(configuracaoAtualizada);
  }
}
