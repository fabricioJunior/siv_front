part of 'configuracao_frete_bloc.dart';

class ConfiguracaoFreteState extends Equatable {
  final ConfiguracaoFrete? config;
  final List<String> transportadoras;
  final String? erro;
  final String? urlAutorizacao;
  final ConfiguracaoFreteStep step;

  const ConfiguracaoFreteState({
    this.config,
    this.transportadoras = const [],
    this.erro,
    this.urlAutorizacao,
    required this.step,
  });

  const ConfiguracaoFreteState.initial()
      : config = null,
        transportadoras = const [],
        erro = null,
        urlAutorizacao = null,
        step = ConfiguracaoFreteStep.inicial;

  ConfiguracaoFreteState copyWith({
    ConfiguracaoFrete? config,
    List<String>? transportadoras,
    String? erro,
    String? urlAutorizacao,
    ConfiguracaoFreteStep? step,
  }) {
    return ConfiguracaoFreteState(
      config: config ?? this.config,
      transportadoras: transportadoras ?? this.transportadoras,
      erro: erro,
      urlAutorizacao: urlAutorizacao ?? this.urlAutorizacao,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [config, transportadoras, erro, urlAutorizacao, step];
}

enum ConfiguracaoFreteStep { inicial, carregando, sucesso, salvando, salvo, autorizando, urlPronta, falha }
