import 'package:comercial/data/remote/dtos/romaneio_dto.dart';
import 'package:comercial/data/remote/dtos/romaneio_item_dto.dart';
import 'package:comercial/domain/data/remote/i_romaneios_remote_data_source.dart';
import 'package:comercial/models.dart';
import 'package:core/remote_data_sourcers.dart';

class RomaneiosRemoteDataSource extends RemoteDataSourceBase
    implements IRomaneiosRemoteDataSource {
  RomaneiosRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/romaneios/{id}';

  @override
  Future<void> adicionarItemRomaneio(int romaneioId, RomaneioItem item) async {
    await post(
      pathParameters: {'id': '$romaneioId/itens'},
      body: RomaneioItemDto.fromModel(item).toAddRemoveJson(),
    );
  }

  @override
  Future<Romaneio> atualizarObservacao(int id, String observacao) async {
    final response = await put(
      pathParameters: {'id': '$id/observacao'},
      body: {'observacao': observacao},
    );
    return RomaneioDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<Romaneio> atualizarRomaneio(Romaneio romaneio) async {
    final response = await put(
      pathParameters: {'id': romaneio.id.toString()},
      body: RomaneioDto.fromModel(romaneio).toUpdateJson(),
    );
    return RomaneioDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<Romaneio> criarRomaneio(Romaneio romaneio) async {
    final response =
        await post(body: RomaneioDto.fromModel(romaneio).toCreateJson());
    return RomaneioDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<Romaneio> recuperarRomaneio(int id) async {
    final response = await get(pathParameters: {'id': id.toString()});
    return RomaneioDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<List<RomaneioItem>> recuperarItensRomaneio(int romaneioId) async {
    final response = await get(pathParameters: {'id': '$romaneioId/itens'});
    final body = response.body as List<dynamic>? ?? const [];
    return body
        .map((json) => RomaneioItemDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Romaneio>> recuperarRomaneios(
      {int page = 1, int limit = 50}) async {
    final response = await get(
      queryParameters: {
        'page': '$page',
        'limit': '$limit',
      },
    );

    final body = response.body as Map<String, dynamic>;
    final itens = (body['items'] as List<dynamic>? ?? const []);
    return itens
        .map((json) => RomaneioDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> removerItemRomaneio(int romaneioId, RomaneioItem item) async {
    await delete(
      pathParameters: {'id': '$romaneioId/itens'},
      body: RomaneioItemDto.fromModel(item).toAddRemoveJson(),
    );
  }
}
