part of 'configuracao_fiscal_bloc.dart';

class ConfiguracaoFiscalState extends Equatable {
  final List<String> providers;
  final EmpresaIntegracaoFiscal? config;
  final String? erro;
  final ConfiguracaoFiscalStep step;
  final bool enviandoCertificado;
  final bool excluindoCertificado;
  final String? certificadoSucesso;
  final String? certificadoErro;

  const ConfiguracaoFiscalState({
    required this.providers,
    this.config,
    this.erro,
    required this.step,
    this.enviandoCertificado = false,
    this.excluindoCertificado = false,
    this.certificadoSucesso,
    this.certificadoErro,
  });

  const ConfiguracaoFiscalState.initial()
      : providers = const [],
        config = null,
        erro = null,
        step = ConfiguracaoFiscalStep.inicial,
        enviandoCertificado = false,
        excluindoCertificado = false,
        certificadoSucesso = null,
        certificadoErro = null;

  ConfiguracaoFiscalState copyWith({
    List<String>? providers,
    EmpresaIntegracaoFiscal? config,
    String? erro,
    ConfiguracaoFiscalStep? step,
    bool? enviandoCertificado,
    bool? excluindoCertificado,
    String? certificadoSucesso,
    String? certificadoErro,
  }) {
    return ConfiguracaoFiscalState(
      providers: providers ?? this.providers,
      config: config ?? this.config,
      erro: erro,
      step: step ?? this.step,
      enviandoCertificado: enviandoCertificado ?? this.enviandoCertificado,
      excluindoCertificado: excluindoCertificado ?? this.excluindoCertificado,
      certificadoSucesso: certificadoSucesso,
      certificadoErro: certificadoErro,
    );
  }

  @override
  List<Object?> get props => [
        providers,
        config,
        erro,
        step,
        enviandoCertificado,
        excluindoCertificado,
        certificadoSucesso,
        certificadoErro,
      ];
}

enum ConfiguracaoFiscalStep { inicial, carregando, sucesso, salvando, salvo, falha }
