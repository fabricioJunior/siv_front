import 'package:comercial/data/remote/dtos/lista_grupo_dto.dart';
import 'package:comercial/domain/data/remote/i_ecommerce_vitrine_remote_data_source.dart';
import 'package:comercial/domain/models/ecommerce_vitrine.dart';
import 'package:core/remote_data_sourcers.dart';

class EcommerceVitrineRemoteDataSource extends RemoteDataSourceBase
    implements IEcommerceVitrineRemoteDataSource {
  EcommerceVitrineRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/e-commerce/{id}';

  @override
  Future<EcommerceVitrine> recuperar(int ecommerceId) async {
    final response = await get(pathParameters: {'id': '$ecommerceId/vitrine'});
    return EcommerceVitrineDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<void> salvar(
    int ecommerceId,
    VitrineLocal local,
    List<EcommerceVitrineItem> itens,
  ) async {
    await put(
      pathParameters: {'id': '$ecommerceId/vitrine/${local.name}'},
      body: EcommerceVitrineDto.itensToJson(itens),
    );
  }
}
