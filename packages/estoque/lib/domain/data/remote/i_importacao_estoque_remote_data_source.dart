import 'package:estoque/domain/models/item_importacao_estoque.dart';

abstract class IImportacaoEstoqueRemoteDataSource {
  Future<void> importar(List<ItemImportacaoEstoque> itens);
}
