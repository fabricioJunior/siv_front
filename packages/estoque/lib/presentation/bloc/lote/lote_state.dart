part of 'lote_bloc.dart';

enum LoteStatus { initial, loading, ready, success, error }

class LoteProdutoPendente extends Equatable {
  final int produtoId;
  final double quantidadeContada;
  final String? descricao;

  const LoteProdutoPendente({
    required this.produtoId,
    required this.quantidadeContada,
    this.descricao,
  });

  LoteProdutoPendente copyWith({
    int? produtoId,
    double? quantidadeContada,
    String? descricao,
  }) {
    return LoteProdutoPendente(
      produtoId: produtoId ?? this.produtoId,
      quantidadeContada: quantidadeContada ?? this.quantidadeContada,
      descricao: descricao ?? this.descricao,
    );
  }

  @override
  List<Object?> get props => [produtoId, quantidadeContada, descricao];
}

class LoteState extends Equatable {
  final LoteStatus status;
  final String? message;
  final BalancoLote? lote;
  final List<BalancoLoteItem> itens;
  final List<LoteProdutoPendente> produtosPendentes;

  const LoteState({
    this.status = LoteStatus.initial,
    this.message,
    this.lote,
    this.itens = const [],
    this.produtosPendentes = const [],
  });

  LoteState copyWith({
    LoteStatus? status,
    String? message,
    bool clearMessage = false,
    BalancoLote? lote,
    List<BalancoLoteItem>? itens,
    List<LoteProdutoPendente>? produtosPendentes,
  }) {
    return LoteState(
      status: status ?? this.status,
      message: clearMessage ? null : (message ?? this.message),
      lote: lote ?? this.lote,
      itens: itens ?? this.itens,
      produtosPendentes: produtosPendentes ?? this.produtosPendentes,
    );
  }

  @override
  List<Object?> get props => [status, message, lote, itens, produtosPendentes];
}
