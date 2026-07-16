import 'package:core/equals.dart';
import 'package:financeiro/domain/models/caixa.dart';
import 'package:financeiro/domain/models/contagem_do_caixa_item.dart';

abstract class ReciboFechamentoCaixa implements Equatable {
  int get caixaId;
  int get empresaId;
  int get terminalId;
  DateTime get data;
  DateTime? get abertura;
  DateTime? get fechamento;
  double get valorAbertura;
  double? get valorFechamento;
  SituacaoCaixa get situacao;
  int get operadorAberturaId;
  String? get operadorAberturaNome;
  int? get operadorFechamentoId;
  String? get operadorFechamentoNome;

  FaturamentoResumoRecibo get faturamentoCaixa;
  FaturamentoResumoRecibo get faturamentoDia;
  FaturamentoMesRecibo get faturamentoMes;

  List<ValorContadoRecibo> get valoresContados;
  List<SangriaRecibo> get sangrias;

  @override
  List<Object?> get props => [
        caixaId,
        empresaId,
        terminalId,
        data,
        abertura,
        fechamento,
        valorAbertura,
        valorFechamento,
        situacao,
        operadorAberturaId,
        operadorAberturaNome,
        operadorFechamentoId,
        operadorFechamentoNome,
        faturamentoCaixa,
        faturamentoDia,
        faturamentoMes,
        valoresContados,
        sangrias,
      ];

  @override
  bool? get stringify => true;
}

abstract class FaturamentoResumoRecibo implements Equatable {
  double get total;
  int get quantidadeVendas;
  int get quantidadeProdutosVendidos;
  double get ticketMedio;

  @override
  List<Object?> get props =>
      [total, quantidadeVendas, quantidadeProdutosVendidos, ticketMedio];

  @override
  bool? get stringify => true;
}

abstract class FaturamentoMesRecibo implements Equatable {
  double get total;

  @override
  List<Object?> get props => [total];

  @override
  bool? get stringify => true;
}

abstract class ValorContadoRecibo implements Equatable {
  TipoContagemDoCaixaItem get tipoDocumento;
  double get valor;

  @override
  List<Object?> get props => [tipoDocumento, valor];

  @override
  bool? get stringify => true;
}

abstract class SangriaRecibo implements Equatable {
  int get id;
  double get valor;
  String get origem;
  String? get descricao;
  DateTime get dataHora;
  int get operadorId;
  String? get operadorNome;
  bool get cancelado;
  String? get motivoCancelamento;

  @override
  List<Object?> get props => [
        id,
        valor,
        origem,
        descricao,
        dataHora,
        operadorId,
        operadorNome,
        cancelado,
        motivoCancelamento,
      ];

  @override
  bool? get stringify => true;
}
