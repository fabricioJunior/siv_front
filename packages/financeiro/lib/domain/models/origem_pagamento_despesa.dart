import 'package:core/equals.dart';

enum TipoOrigemPagamentoDespesa {
  cartaoCredito,
  cartaoDebito,
  contaCorrente,
  dinheiro,
  pix;

  static TipoOrigemPagamentoDespesa fromString(String? value) {
    switch (value) {
      case 'cartao_credito':
        return TipoOrigemPagamentoDespesa.cartaoCredito;
      case 'cartao_debito':
        return TipoOrigemPagamentoDespesa.cartaoDebito;
      case 'conta_corrente':
        return TipoOrigemPagamentoDespesa.contaCorrente;
      case 'pix':
        return TipoOrigemPagamentoDespesa.pix;
      case 'dinheiro':
      default:
        return TipoOrigemPagamentoDespesa.dinheiro;
    }
  }

  String get value {
    switch (this) {
      case TipoOrigemPagamentoDespesa.cartaoCredito:
        return 'cartao_credito';
      case TipoOrigemPagamentoDespesa.cartaoDebito:
        return 'cartao_debito';
      case TipoOrigemPagamentoDespesa.contaCorrente:
        return 'conta_corrente';
      case TipoOrigemPagamentoDespesa.dinheiro:
        return 'dinheiro';
      case TipoOrigemPagamentoDespesa.pix:
        return 'pix';
    }
  }

  bool get diaVencimentoObrigatorio =>
      this == TipoOrigemPagamentoDespesa.cartaoCredito;

  String get label {
    switch (this) {
      case TipoOrigemPagamentoDespesa.cartaoCredito:
        return 'Cartão de crédito';
      case TipoOrigemPagamentoDespesa.cartaoDebito:
        return 'Cartão de débito';
      case TipoOrigemPagamentoDespesa.contaCorrente:
        return 'Conta corrente';
      case TipoOrigemPagamentoDespesa.dinheiro:
        return 'Dinheiro';
      case TipoOrigemPagamentoDespesa.pix:
        return 'Pix';
    }
  }
}

class OrigemPagamentoDespesa extends Equatable {
  final int? id;
  final int? empresaId;
  final String nome;
  final TipoOrigemPagamentoDespesa tipo;
  final int? diaVencimento;

  const OrigemPagamentoDespesa({
    this.id,
    this.empresaId,
    required this.nome,
    required this.tipo,
    this.diaVencimento,
  });

  @override
  List<Object?> get props => [id, empresaId, nome, tipo, diaVencimento];

  @override
  bool? get stringify => true;
}
