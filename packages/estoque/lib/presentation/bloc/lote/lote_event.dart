part of 'lote_bloc.dart';

sealed class LoteEvent extends Equatable {
  const LoteEvent();

  @override
  List<Object?> get props => [];
}

class CriarLoteEvent extends LoteEvent {
  final int balancoId;
  final String lote;
  final String? observacao;

  const CriarLoteEvent({
    required this.balancoId,
    required this.lote,
    this.observacao,
  });

  @override
  List<Object?> get props => [balancoId, lote, observacao];
}

class AtualizarLoteEvent extends LoteEvent {
  final int balancoId;
  final int loteId;
  final String? lote;
  final String? observacao;

  const AtualizarLoteEvent({
    required this.balancoId,
    required this.loteId,
    this.lote,
    this.observacao,
  });

  @override
  List<Object?> get props => [balancoId, loteId, lote, observacao];
}

class CancelarLoteEvent extends LoteEvent {
  final int balancoId;
  final int loteId;
  final String motivo;

  const CancelarLoteEvent({
    required this.balancoId,
    required this.loteId,
    required this.motivo,
  });

  @override
  List<Object?> get props => [balancoId, loteId, motivo];
}

class CarregarItensDoLoteEvent extends LoteEvent {
  final int balancoId;
  final int loteId;

  const CarregarItensDoLoteEvent({
    required this.balancoId,
    required this.loteId,
  });

  @override
  List<Object?> get props => [balancoId, loteId];
}

class AdicionarProdutoPendenteEvent extends LoteEvent {
  final int produtoId;
  final double quantidadeContada;
  final String? descricao;

  const AdicionarProdutoPendenteEvent({
    required this.produtoId,
    required this.quantidadeContada,
    this.descricao,
  });

  @override
  List<Object?> get props => [produtoId, quantidadeContada, descricao];
}

class RemoverProdutoPendenteEvent extends LoteEvent {
  final int produtoId;

  const RemoverProdutoPendenteEvent({required this.produtoId});

  @override
  List<Object?> get props => [produtoId];
}

class LimparProdutosPendentesEvent extends LoteEvent {
  const LimparProdutosPendentesEvent();
}

class SalvarProdutosPendentesEvent extends LoteEvent {
  final int balancoId;
  final int loteId;

  const SalvarProdutosPendentesEvent({
    required this.balancoId,
    required this.loteId,
  });

  @override
  List<Object?> get props => [balancoId, loteId];
}

class RemoverItemDoLoteEvent extends LoteEvent {
  final int balancoId;
  final int loteId;
  final int produtoId;

  const RemoverItemDoLoteEvent({
    required this.balancoId,
    required this.loteId,
    required this.produtoId,
  });

  @override
  List<Object?> get props => [balancoId, loteId, produtoId];
}

class LoteLeituraItem extends Equatable {
  final int produtoId;
  final double quantidadeContada;

  const LoteLeituraItem({
    required this.produtoId,
    required this.quantidadeContada,
  });

  @override
  List<Object?> get props => [produtoId, quantidadeContada];
}

class SalvarLeituraDoLoteEvent extends LoteEvent {
  final int balancoId;
  final int loteId;
  final List<LoteLeituraItem> itensLidos;

  const SalvarLeituraDoLoteEvent({
    required this.balancoId,
    required this.loteId,
    required this.itensLidos,
  });

  @override
  List<Object?> get props => [balancoId, loteId, itensLidos];
}
