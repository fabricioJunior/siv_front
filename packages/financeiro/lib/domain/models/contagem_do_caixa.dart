import 'package:core/equals.dart';

import 'contagem_do_caixa_item.dart';

abstract class ContagemDoCaixa implements Equatable {
  int? get id;
  int get caixaId;
  String get observacao;
  List<ContagemDoCaixaItem> get itens;

  @override
  List<Object?> get props => [id, caixaId, observacao, itens];

  @override
  bool? get stringify => true;
}
