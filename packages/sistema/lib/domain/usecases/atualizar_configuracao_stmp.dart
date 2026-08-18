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
    String? urlVerificacaoEmail,
    String? assuntoVerificacaoEmail,
    String? corpoVerificacaoEmail,
    String? assuntoPedidoConfirmado,
    String? corpoPedidoConfirmado,
    String? assuntoPedidoEmbalado,
    String? corpoPedidoEmbalado,
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
      urlVerificacaoEmail: urlVerificacaoEmail,
      verificacaoEmailTemplate: configuracao.verificacaoEmailTemplate
              ?.copyWith(
            assunto: assuntoVerificacaoEmail,
            corpo: corpoVerificacaoEmail,
          ) ??
          VerificacaoEmailTemplate.create(
            assunto: assuntoVerificacaoEmail ?? '',
            corpo: corpoVerificacaoEmail ?? '',
          ),
      pedidoConfirmadoTemplate: configuracao.pedidoConfirmadoTemplate
              ?.copyWith(
            assunto: assuntoPedidoConfirmado,
            corpo: corpoPedidoConfirmado,
          ) ??
          PedidoConfirmadoTemplate.create(
            assunto: assuntoPedidoConfirmado ?? '',
            corpo: corpoPedidoConfirmado ?? '',
          ),
      pedidoEmbaladoTemplate: configuracao.pedidoEmbaladoTemplate?.copyWith(
            assunto: assuntoPedidoEmbalado,
            corpo: corpoPedidoEmbalado,
          ) ??
          PedidoEmbaladoTemplate.create(
            assunto: assuntoPedidoEmbalado ?? '',
            corpo: corpoPedidoEmbalado ?? '',
          ),
    );

    return _repository.atualizarConfiguracao(configuracaoAtualizada);
  }
}
