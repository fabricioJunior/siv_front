part of 'creditos_devolucao_bloc.dart';

enum CreditosDevolucaoStatus { carregando, pronto, erro }

class CreditosDevolucaoState extends Equatable {
  final CreditosDevolucaoStatus status;
  final List<CreditoDevolucao> creditos;
  final ResumoCreditoDevolucao resumo;
  final List<CreditoDevolucaoMovimentacao> extrato;
  final ConfigCreditoDevolucao? config;
  final List<Empresa> empresas;
  final int? empresaIdSessao;
  final String? erro;
  final bool executando;
  final String? erroAcao;

  /// Saldo devolvido pela última ação; a tela mostra no snackbar quando
  /// [acoesConcluidas] muda.
  final double? saldoAposAcao;
  final int acoesConcluidas;

  const CreditosDevolucaoState({
    this.status = CreditosDevolucaoStatus.carregando,
    this.creditos = const [],
    this.resumo = const ResumoCreditoDevolucao(),
    this.extrato = const [],
    this.config,
    this.empresas = const [],
    this.empresaIdSessao,
    this.erro,
    this.executando = false,
    this.erroAcao,
    this.saldoAposAcao,
    this.acoesConcluidas = 0,
  });

  /// Dias de aviso de vencimento (padrão 7 se a config não carregou).
  int get avisoDias => config?.avisoDiasAntes ?? 7;

  CreditosDevolucaoState copyWith({
    CreditosDevolucaoStatus? status,
    List<CreditoDevolucao>? creditos,
    ResumoCreditoDevolucao? resumo,
    List<CreditoDevolucaoMovimentacao>? extrato,
    ConfigCreditoDevolucao? config,
    List<Empresa>? empresas,
    int? empresaIdSessao,
    String? erro,
    bool? executando,
    String? erroAcao,
    bool limparErroAcao = false,
    double? saldoAposAcao,
    int? acoesConcluidas,
  }) {
    return CreditosDevolucaoState(
      status: status ?? this.status,
      creditos: creditos ?? this.creditos,
      resumo: resumo ?? this.resumo,
      extrato: extrato ?? this.extrato,
      config: config ?? this.config,
      empresas: empresas ?? this.empresas,
      empresaIdSessao: empresaIdSessao ?? this.empresaIdSessao,
      erro: erro,
      executando: executando ?? this.executando,
      erroAcao: limparErroAcao ? null : (erroAcao ?? this.erroAcao),
      saldoAposAcao: saldoAposAcao ?? this.saldoAposAcao,
      acoesConcluidas: acoesConcluidas ?? this.acoesConcluidas,
    );
  }

  @override
  List<Object?> get props => [
        status,
        creditos,
        resumo,
        extrato,
        config,
        empresas,
        empresaIdSessao,
        erro,
        executando,
        erroAcao,
        saldoAposAcao,
        acoesConcluidas,
      ];
}
