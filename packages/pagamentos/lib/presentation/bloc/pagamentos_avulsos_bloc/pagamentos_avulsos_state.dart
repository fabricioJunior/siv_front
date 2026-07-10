part of 'pagamentos_avulsos_bloc.dart';

class PagamentosAvulsosState extends Equatable {
  final List<PagamentoAvulso> pagamentos;
  final List<String> providers;
  final String orderBy;
  final String orderDir;
  final String? descricao;
  final String? provider;
  final String? erro;
  final PagamentosAvulsosStep step;

  const PagamentosAvulsosState({
    this.pagamentos = const [],
    this.providers = const [],
    this.orderBy = 'criadoEm',
    this.orderDir = 'DESC',
    this.descricao,
    this.provider,
    this.erro,
    required this.step,
  });

  PagamentosAvulsosState copyWith({
    List<PagamentoAvulso>? pagamentos,
    List<String>? providers,
    String? orderBy,
    String? orderDir,
    String? descricao,
    String? provider,
    String? erro,
    PagamentosAvulsosStep? step,
  }) {
    return PagamentosAvulsosState(
      pagamentos: pagamentos ?? this.pagamentos,
      providers: providers ?? this.providers,
      orderBy: orderBy ?? this.orderBy,
      orderDir: orderDir ?? this.orderDir,
      descricao: descricao ?? this.descricao,
      provider: provider ?? this.provider,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [
        pagamentos,
        providers,
        orderBy,
        orderDir,
        descricao,
        provider,
        erro,
        step,
      ];
}

enum PagamentosAvulsosStep {
  inicial,
  carregando,
  carregado,
  falha,
}
