import 'package:core/remote_data_sourcers.dart';
import 'package:estoque/domain/data/remote/i_importacao_estoque_remote_data_source.dart';
import 'package:estoque/domain/models/item_importacao_estoque.dart';

class ImportacaoEstoqueRemoteDataSource extends RemoteDataSourceBase
    implements IImportacaoEstoqueRemoteDataSource {
  ImportacaoEstoqueRemoteDataSource({required super.informacoesParaRequest});

  @override
  Future<void> importar(List<ItemImportacaoEstoque> itens) {
    // Endpoint síncrono -- recebe um array JSON puro no body (não multipart,
    // não é ImportacaoEntity) e valida a lista inteira de uma vez: se algum
    // item for inválido, a chamada inteira falha.
    return post(body: itens.map((item) => item.toJson()).toList());
  }

  @override
  String get path => '/v1/estoque/importar';
}
