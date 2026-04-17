import 'package:core/equals.dart';

abstract class ContagemDoCaixaItem implements Equatable {
  int? get id;
  double get valor;
  TipoContagemDoCaixaItem get tipo;

  @override
  List<Object?> get props => [id, valor, tipo];

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
