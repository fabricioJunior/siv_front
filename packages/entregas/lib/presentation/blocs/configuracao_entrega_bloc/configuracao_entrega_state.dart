part of 'configuracao_entrega_bloc.dart';

class ConfiguracaoEntregaState extends Equatable {
  final EmpresaIntegracaoEntrega? config;
  final String? erro;
  final ConfiguracaoEntregaStep step;

  const ConfiguracaoEntregaState({
    this.config,
    this.erro,
    required this.step,
  });

  const ConfiguracaoEntregaState.initial()
      : config = null,
        erro = null,
        step = ConfiguracaoEntregaStep.inicial;

  ConfiguracaoEntregaState copyWith({
    EmpresaIntegracaoEntrega? config,
    String? erro,
    ConfiguracaoEntregaStep? step,
  }) {
    return ConfiguracaoEntregaState(
      config: config ?? this.config,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [config, erro, step];
}

enum ConfiguracaoEntregaStep { inicial, carregando, sucesso, salvando, salvo, falha }
