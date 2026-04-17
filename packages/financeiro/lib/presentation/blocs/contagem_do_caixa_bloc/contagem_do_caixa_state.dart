part of 'contagem_do_caixa_bloc.dart';

class ContagemDoCaixaState extends Equatable {
  final int? caixaId;
  final ContagemDoCaixa? contagem;
  final Map<TipoContagemDoCaixaItem, String> valoresEditados;
  final TipoContagemDoCaixaItem? itemSendoSalvo;
  final TipoContagemDoCaixaItem? tipoComErro;
  final String? erro;
  final ContagemDoCaixaStep step;

  const ContagemDoCaixaState({
    this.caixaId,
    this.contagem,
    this.valoresEditados = const {},
    this.itemSendoSalvo,
    this.tipoComErro,
    this.erro,
    required this.step,
  });

  const ContagemDoCaixaState.initial()
      : caixaId = null,
        contagem = null,
        valoresEditados = const {},
        itemSendoSalvo = null,
        tipoComErro = null,
        erro = null,
        step = ContagemDoCaixaStep.inicial;

  ContagemDoCaixaState copyWith({
    int? caixaId,
    ContagemDoCaixa? contagem,
    Map<TipoContagemDoCaixaItem, String>? valoresEditados,
    TipoContagemDoCaixaItem? itemSendoSalvo,
    TipoContagemDoCaixaItem? tipoComErro,
    String? erro,
    ContagemDoCaixaStep? step,
    bool clearItemSendoSalvo = false,
    bool clearTipoComErro = false,
  }) {
    return ContagemDoCaixaState(
      caixaId: caixaId ?? this.caixaId,
      contagem: contagem ?? this.contagem,
      valoresEditados: valoresEditados ?? this.valoresEditados,
      itemSendoSalvo:
          clearItemSendoSalvo ? null : itemSendoSalvo ?? this.itemSendoSalvo,
      tipoComErro: clearTipoComErro ? null : tipoComErro ?? this.tipoComErro,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [
        caixaId,
        contagem,
        valoresEditados,
        itemSendoSalvo,
        tipoComErro,
        erro,
        step,
      ];
}

enum ContagemDoCaixaStep {
  inicial,
  carregando,
  editando,
  salvandoItem,
  validacaoInvalida,
  falha,
}
