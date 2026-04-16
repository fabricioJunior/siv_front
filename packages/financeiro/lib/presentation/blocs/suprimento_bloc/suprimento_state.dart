part of 'suprimento_bloc.dart';

class SuprimentoState extends Equatable {
  final int? caixaId;
  final String valor;
  final String descricao;
  final Suprimento? suprimento;
  final String? erro;
  final SuprimentoStep step;

  const SuprimentoState({
    this.caixaId,
    this.valor = '',
    this.descricao = '',
    this.suprimento,
    this.erro,
    required this.step,
  });

  const SuprimentoState.initial()
      : caixaId = null,
        valor = '',
        descricao = '',
        suprimento = null,
        erro = null,
        step = SuprimentoStep.inicial;

  SuprimentoState copyWith({
    int? caixaId,
    String? valor,
    String? descricao,
    Suprimento? suprimento,
    String? erro,
    SuprimentoStep? step,
  }) {
    return SuprimentoState(
      caixaId: caixaId ?? this.caixaId,
      valor: valor ?? this.valor,
      descricao: descricao ?? this.descricao,
      suprimento: suprimento ?? this.suprimento,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props =>
      [caixaId, valor, descricao, suprimento, erro, step];
}

enum SuprimentoStep {
  inicial,
  editando,
  salvando,
  criado,
  validacaoInvalida,
  falha,
}
