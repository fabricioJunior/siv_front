part of 'configuracao_stmp_bloc.dart';

class ConfiguracaoSTMPState extends Equatable {
  final int? id;
  final String? servidor;
  final int? porta;
  final String? usuario;
  final String? senha;
  final String? assuntoRedefinicaoSenha;
  final String? corpoRedefinicaoSenha;
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
        step = step ?? ConfiguracaoSTMPStep.carregado;

  ConfiguracaoSTMPState copyWith({
    int? id,
    String? servidor,
    int? porta,
    String? usuario,
    String? senha,
    String? assuntoRedefinicaoSenha,
    String? corpoRedefinicaoSenha,
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
