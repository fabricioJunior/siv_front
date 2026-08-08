import 'package:financeiro/domain/models/contagem_do_caixa_item.dart';

abstract class FaturamentoItem {
  TipoContagemDoCaixaItem get tipoDocumento;
  double get valor;
}

abstract class FaturamentoDoCaixa {
  List<FaturamentoItem> get contabilizado;
  List<FaturamentoItem> get naoContabilizado;
  double get totalContabilizado;
  double get totalNaoContabilizado;
  double get totalFaturamento;
}
