part of 'pagamentos_avulsos_bloc.dart';

class PagamentosAvulsosState extends Equatable {
  final List<PagamentoAvulso> pagamentos;
  final String? erro;
  final PagamentosAvulsosStep step;

  const PagamentosAvulsosState({
    this.pagamentos = const [],
    this.erro,
    required this.step,
  });

  PagamentosAvulsosState copyWith({
    List<PagamentoAvulso>? pagamentos,
    String? erro,
    PagamentosAvulsosStep? step,
  }) {
    return PagamentosAvulsosState(
      pagamentos: pagamentos ?? this.pagamentos,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [pagamentos, erro, step];
}

enum PagamentosAvulsosStep {
  inicial,
  carregando,
  carregado,
  falha,
}
