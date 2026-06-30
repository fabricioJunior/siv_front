part of 'configuracao_fiscal_bloc.dart';

class ConfiguracaoFiscalState extends Equatable {
  final List<String> providers;
  final EmpresaIntegracaoFiscal? config;
  final String? erro;
  final ConfiguracaoFiscalStep step;

  const ConfiguracaoFiscalState({
    required this.providers,
    this.config,
    this.erro,
    required this.step,
  });

  const ConfiguracaoFiscalState.initial()
      : providers = const [],
        config = null,
        erro = null,
        step = ConfiguracaoFiscalStep.inicial;

  ConfiguracaoFiscalState copyWith({
    List<String>? providers,
    EmpresaIntegracaoFiscal? config,
    String? erro,
    ConfiguracaoFiscalStep? step,
  }) {
    return ConfiguracaoFiscalState(
      providers: providers ?? this.providers,
      config: config ?? this.config,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [providers, config, erro, step];
}

enum ConfiguracaoFiscalStep { inicial, carregando, sucesso, salvando, salvo, falha }
