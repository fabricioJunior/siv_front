import 'package:core/equals.dart';

enum StatusDespesa {
  pendente,
  pago,
  cancelado;

  static StatusDespesa fromString(String? value) {
    switch (value) {
      case 'pago':
        return StatusDespesa.pago;
      case 'cancelado':
        return StatusDespesa.cancelado;
      case 'pendente':
      default:
        return StatusDespesa.pendente;
    }
  }

  String get value => name;

  String get label {
    switch (this) {
      case StatusDespesa.pendente:
        return 'Pendente';
      case StatusDespesa.pago:
        return 'Pago';
      case StatusDespesa.cancelado:
        return 'Cancelado';
    }
  }
}

class Despesa extends Equatable {
  final int? id;
  final int? empresaId;
  final String descricao;
  final double valor;
  final int categoriaId;
  final int origemPagamentoId;
  final int? formaPagamentoId;
  final int? caixaId;
  final DateTime? dataPagamento;
  final StatusDespesa? status;
  final bool recorrente;
  final int? diaVencimento;
  final int? parcelas;
  final String? grupoParcelamentoId;
  final int? numeroParcela;
  final int? totalParcelas;

  const Despesa({
    this.id,
    this.empresaId,
    required this.descricao,
    required this.valor,
    required this.categoriaId,
    required this.origemPagamentoId,
    this.formaPagamentoId,
    this.caixaId,
    this.dataPagamento,
    this.status,
    this.recorrente = false,
    this.diaVencimento,
    this.parcelas,
    this.grupoParcelamentoId,
    this.numeroParcela,
    this.totalParcelas,
  });

  @override
  List<Object?> get props => [
        id,
        empresaId,
        descricao,
        valor,
        categoriaId,
        origemPagamentoId,
        formaPagamentoId,
        caixaId,
        dataPagamento,
        status,
        recorrente,
        diaVencimento,
        parcelas,
        grupoParcelamentoId,
        numeroParcela,
        totalParcelas,
      ];

  @override
  bool? get stringify => true;
}
