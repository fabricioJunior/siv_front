import 'package:core/equals.dart';
import 'package:financeiro/domain/models/caixa.dart';

class FiltroHistoricoDeCaixas extends Equatable {
  final int? terminalId;
  final int? operadorAberturaId;
  final SituacaoCaixa? situacao;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final int page;
  final int limit;

  const FiltroHistoricoDeCaixas({
    this.terminalId,
    this.operadorAberturaId,
    this.situacao,
    this.dataInicio,
    this.dataFim,
    this.page = 1,
    this.limit = 20,
  });

  FiltroHistoricoDeCaixas copyWith({
    int? terminalId,
    int? operadorAberturaId,
    SituacaoCaixa? situacao,
    DateTime? dataInicio,
    DateTime? dataFim,
    int? page,
    int? limit,
  }) {
    return FiltroHistoricoDeCaixas(
      terminalId: terminalId ?? this.terminalId,
      operadorAberturaId: operadorAberturaId ?? this.operadorAberturaId,
      situacao: situacao ?? this.situacao,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  @override
  List<Object?> get props => [
    terminalId,
    operadorAberturaId,
    situacao,
    dataInicio,
    dataFim,
    page,
    limit,
  ];
}
