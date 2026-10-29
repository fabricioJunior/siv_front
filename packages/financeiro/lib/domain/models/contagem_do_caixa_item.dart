import 'package:core/equals.dart';

abstract class ContagemDoCaixaItem implements Equatable {
  int? get id;
  double get valor;
  TipoContagemDoCaixaItem get tipoDocumento;

  @override
  List<Object?> get props => [id, valor, tipoDocumento];

  @override
  bool? get stringify => true;
}

enum TipoContagemDoCaixaItem {
  dinheiro,
  pix,
  cartao,
  cartaoDeDebito,
  fatura,
  cheque,
  troco,
  voucher,
  tedDoc,
  adiantamento,
  creditoDeDevolucao,
}

extension TipoContagemDoCaixaItemApi on TipoContagemDoCaixaItem {
  /// Valor aceito pelo backend em `tipoDocumento` (o `name` do enum só serve para os tipos de uma palavra).
  String get valorApi => this == TipoContagemDoCaixaItem.cartaoDeDebito ? 'Cartão de débito' : name;
}
