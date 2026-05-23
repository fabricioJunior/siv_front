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
  fatura,
  cheque,
  troco,
  voucher,
  tedDoc,
  adiantamento,
  creditoDeDevolucao,
}
