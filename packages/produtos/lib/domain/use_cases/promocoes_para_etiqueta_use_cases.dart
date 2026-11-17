import 'package:produtos/domain/data/gateways/i_promocoes_etiquetas_gateway.dart';
import 'package:produtos/domain/models/etiqueta_promocao.dart';

class RecuperarPromocoesParaEtiqueta {
  final IPromocoesEtiquetasGateway _gateway;

  RecuperarPromocoesParaEtiqueta(this._gateway);

  Future<List<PromocaoParaEtiqueta>> call({required bool apenasVigentes}) =>
      _gateway.promocoes(apenasVigentes: apenasVigentes);
}

class RecuperarItensDaPromocaoParaEtiqueta {
  final IPromocoesEtiquetasGateway _gateway;

  RecuperarItensDaPromocaoParaEtiqueta(this._gateway);

  Future<List<ItemEtiquetaPromocao>> call({
    required int promocaoId,
    required int tabelaDePrecoId,
  }) => _gateway.itens(promocaoId: promocaoId, tabelaDePrecoId: tabelaDePrecoId);
}
