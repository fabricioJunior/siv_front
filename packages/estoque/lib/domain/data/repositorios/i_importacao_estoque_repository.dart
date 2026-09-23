import 'package:estoque/domain/models/item_importacao_estoque.dart';

abstract class IImportacaoEstoqueRepository {
  Future<void> importar(List<ItemImportacaoEstoque> itens);
}
