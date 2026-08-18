part of 'configuracao_stmp_bloc.dart';

class ConfiguracaoSTMPState extends Equatable {
  final int? id;
  final String? servidor;
  final int? porta;
  final String? usuario;
  final String? senha;
  final String? assuntoRedefinicaoSenha;
  final String? corpoRedefinicaoSenha;
  final String? urlVerificacaoEmail;
  final String? assuntoVerificacaoEmail;
  final String? corpoVerificacaoEmail;
  final String? assuntoPedidoConfirmado;
  final String? corpoPedidoConfirmado;
  final String? assuntoPedidoEmbalado;
  final String? corpoPedidoEmbalado;
  final ConfiguracaoSTMP? configuracao;
  final ConfiguracaoSTMPStep step;

  const ConfiguracaoSTMPState({
    this.id,
    this.servidor,
    this.porta,
    this.usuario,
    this.senha,
    this.assuntoRedefinicaoSenha,
    this.corpoRedefinicaoSenha,
    this.urlVerificacaoEmail,
    this.assuntoVerificacaoEmail,
    this.corpoVerificacaoEmail,
    this.assuntoPedidoConfirmado,
    this.corpoPedidoConfirmado,
    this.assuntoPedidoEmbalado,
    this.corpoPedidoEmbalado,
    this.configuracao,
    required this.step,
  });

  ConfiguracaoSTMPState.fromModel(
    this.configuracao, {
    ConfiguracaoSTMPStep? step,
  })  : id = configuracao!.id,
        servidor = configuracao.servidor,
        porta = configuracao.porta,
        usuario = configuracao.usuario,
        senha = configuracao.senha,
        assuntoRedefinicaoSenha = configuracao.redefinirSenhaTemplate.assunto,
        corpoRedefinicaoSenha = configuracao.redefinirSenhaTemplate.corpo,
        urlVerificacaoEmail = configuracao.urlVerificacaoEmail,
        assuntoVerificacaoEmail =
            configuracao.verificacaoEmailTemplate?.assunto,
        corpoVerificacaoEmail = configuracao.verificacaoEmailTemplate?.corpo,
        assuntoPedidoConfirmado =
            configuracao.pedidoConfirmadoTemplate?.assunto,
        corpoPedidoConfirmado = configuracao.pedidoConfirmadoTemplate?.corpo,
        assuntoPedidoEmbalado = configuracao.pedidoEmbaladoTemplate?.assunto,
        corpoPedidoEmbalado = configuracao.pedidoEmbaladoTemplate?.corpo,
        step = step ?? ConfiguracaoSTMPStep.carregado;

  ConfiguracaoSTMPState copyWith({
    int? id,
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
    ConfiguracaoSTMP? configuracao,
    ConfiguracaoSTMPStep? step,
  }) {
    return ConfiguracaoSTMPState(
      id: id ?? this.id,
      servidor: servidor ?? this.servidor,
      porta: porta ?? this.porta,
      usuario: usuario ?? this.usuario,
      senha: senha ?? this.senha,
      assuntoRedefinicaoSenha:
          assuntoRedefinicaoSenha ?? this.assuntoRedefinicaoSenha,
      corpoRedefinicaoSenha:
          corpoRedefinicaoSenha ?? this.corpoRedefinicaoSenha,
      urlVerificacaoEmail: urlVerificacaoEmail ?? this.urlVerificacaoEmail,
      assuntoVerificacaoEmail:
          assuntoVerificacaoEmail ?? this.assuntoVerificacaoEmail,
      corpoVerificacaoEmail:
          corpoVerificacaoEmail ?? this.corpoVerificacaoEmail,
      assuntoPedidoConfirmado:
          assuntoPedidoConfirmado ?? this.assuntoPedidoConfirmado,
      corpoPedidoConfirmado:
          corpoPedidoConfirmado ?? this.corpoPedidoConfirmado,
      assuntoPedidoEmbalado:
          assuntoPedidoEmbalado ?? this.assuntoPedidoEmbalado,
      corpoPedidoEmbalado: corpoPedidoEmbalado ?? this.corpoPedidoEmbalado,
      configuracao: configuracao ?? this.configuracao,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [
        id,
        servidor,
        porta,
        usuario,
        senha,
        assuntoRedefinicaoSenha,
        corpoRedefinicaoSenha,
        urlVerificacaoEmail,
        assuntoVerificacaoEmail,
        corpoVerificacaoEmail,
        assuntoPedidoConfirmado,
        corpoPedidoConfirmado,
        assuntoPedidoEmbalado,
        corpoPedidoEmbalado,
        configuracao,
        step,
      ];
}

enum ConfiguracaoSTMPStep {
  inicial,
  carregando,
  carregado,
  editando,
  salvando,
  salva,
  configuracaoNaoSalva,
  verificandoConexao,
  conexaoValida,
  conexaoInvalida,
  falha,
}
