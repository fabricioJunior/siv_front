import 'package:estoque/domain/data/remote/i_importacao_estoque_remote_data_source.dart';
import 'package:estoque/domain/data/repositorios/i_importacao_estoque_repository.dart';
import 'package:estoque/domain/models/item_importacao_estoque.dart';

class ImportacaoEstoqueRepository implements IImportacaoEstoqueRepository {
  final IImportacaoEstoqueRemoteDataSource remoteDataSource;

  ImportacaoEstoqueRepository({required this.remoteDataSource});

  @override
  Future<void> importar(List<ItemImportacaoEstoque> itens) {
    return remoteDataSource.importar(itens);
  }
}
