import 'contagem_do_caixa_item.dart';

abstract class ContagemDoCaixa {
  String get observacao;

  List<ContagemDoCaixaItem> get itens;
}
