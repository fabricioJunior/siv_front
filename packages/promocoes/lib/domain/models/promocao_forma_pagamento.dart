import 'package:core/equals.dart';
import 'package:promocoes/domain/models/regra_desconto.dart';

// Linha de override de desconto por forma de pagamento. Se restringirFormasPagamento
// da promocao for true, so as formas presentes aqui podem pagar; se false, a lista
// so serve pra declarar overrides (formas ausentes usam o desconto padrao).
class PromocaoFormaPagamento extends Equatable {
  final int formaDePagamentoId;
  final double? valorPercentual;
  final double? valorFixo;
  final double? precoFixo;

  const PromocaoFormaPagamento({
    required this.formaDePagamentoId,
    this.valorPercentual,
    this.valorFixo,
    this.precoFixo,
  });

  factory PromocaoFormaPagamento.fromJson(Map<String, dynamic> json) {
    return PromocaoFormaPagamento(
      formaDePagamentoId: (json['formaDePagamentoId'] as num).toInt(),
      valorPercentual: _parseDouble(json['valorPercentual']),
      valorFixo: _parseDouble(json['valorFixo']),
      precoFixo: _parseDouble(json['precoFixo']),
    );
  }

  Map<String, dynamic> toJson() => {
        'formaDePagamentoId': formaDePagamentoId,
        if (valorPercentual != null) 'valorPercentual': valorPercentual,
        if (valorFixo != null) 'valorFixo': valorFixo,
        if (precoFixo != null) 'precoFixo': precoFixo,
      };

  // Constroi uma copia so com o campo de valor referente ao tipoDesconto
  // atual da promocao preenchido (os outros dois sempre null).
  PromocaoFormaPagamento comValor(TipoDesconto tipoDesconto, double? valor) {
    switch (tipoDesconto) {
      case TipoDesconto.percentual:
        return PromocaoFormaPagamento(
          formaDePagamentoId: formaDePagamentoId,
          valorPercentual: valor,
        );
      case TipoDesconto.valorFixo:
        return PromocaoFormaPagamento(
          formaDePagamentoId: formaDePagamentoId,
          valorFixo: valor,
        );
      case TipoDesconto.precoFixo:
        return PromocaoFormaPagamento(
          formaDePagamentoId: formaDePagamentoId,
          precoFixo: valor,
        );
    }
  }

  double? valorPara(TipoDesconto tipoDesconto) {
    switch (tipoDesconto) {
      case TipoDesconto.percentual:
        return valorPercentual;
      case TipoDesconto.valorFixo:
        return valorFixo;
      case TipoDesconto.precoFixo:
        return precoFixo;
    }
  }

  @override
  List<Object?> get props =>
      [formaDePagamentoId, valorPercentual, valorFixo, precoFixo];

  @override
  bool? get stringify => true;
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
