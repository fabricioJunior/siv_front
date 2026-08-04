import 'package:core/equals.dart';

class FiltroHistoricoEstoque extends Equatable {
  final String? busca;
  final int? referenciaId;
  final List<int> referenciaIds;
  final int? produtoId;
  final List<int> produtoIds;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final int? operadorId;
  final int? funcionarioId;
  final int? caixaId;
  final int page;
  final int limit;

  const FiltroHistoricoEstoque({
    this.busca,
    this.referenciaId,
    this.referenciaIds = const [],
    this.produtoId,
    this.produtoIds = const [],
    this.dataInicio,
    this.dataFim,
    this.operadorId,
    this.funcionarioId,
    this.caixaId,
    this.page = 1,
    this.limit = 20,
  });

  FiltroHistoricoEstoque copyWith({
    String? busca,
    int? referenciaId,
    List<int>? referenciaIds,
    int? produtoId,
    List<int>? produtoIds,
    DateTime? dataInicio,
    DateTime? dataFim,
    int? operadorId,
    int? funcionarioId,
    int? caixaId,
    int? page,
    int? limit,
  }) {
    return FiltroHistoricoEstoque(
      busca: busca ?? this.busca,
      referenciaId: referenciaId ?? this.referenciaId,
      referenciaIds: referenciaIds ?? this.referenciaIds,
      produtoId: produtoId ?? this.produtoId,
      produtoIds: produtoIds ?? this.produtoIds,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      operadorId: operadorId ?? this.operadorId,
      funcionarioId: funcionarioId ?? this.funcionarioId,
      caixaId: caixaId ?? this.caixaId,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  @override
  List<Object?> get props => [
    busca,
    referenciaId,
    referenciaIds,
    produtoId,
    produtoIds,
    dataInicio,
    dataFim,
    operadorId,
    funcionarioId,
    caixaId,
    page,
    limit,
  ];
}
