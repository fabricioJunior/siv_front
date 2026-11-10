import 'package:produtos/domain/models/etiqueta_promocao.dart';

abstract class IPromocoesEtiquetasGateway {
  Future<List<PromocaoParaEtiqueta>> promocoes({required bool apenasVigentes});

  Future<List<ItemEtiquetaPromocao>> itens({
    required int promocaoId,
    required int tabelaDePrecoId,
  });
}
