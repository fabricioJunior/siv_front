import 'package:core/remote_data_sourcers.dart';
import 'package:promocoes/data/remote/dtos/promocao_dto.dart';
import 'package:promocoes/domain/data/remote/i_promocoes_remote_data_source.dart';
import 'package:promocoes/domain/models/promocao.dart';

class PromocoesRemoteDataSource extends RemoteDataSourceBase
    implements IPromocoesRemoteDataSource {
  PromocoesRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/promocoes/{id}';

  @override
  Future<Promocao> atualizarPromocao(Promocao promocao) async {
    final response = await put(
      pathParameters: {'id': promocao.id.toString()},
      body: PromocaoDto.fromModel(promocao).toUpdateJson(),
    );

    return PromocaoDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<Promocao> criarPromocao(Promocao promocao) async {
    final response = await post(
      body: PromocaoDto.fromModel(promocao).toCreateJson(),
    );

    return PromocaoDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<Promocao?> recuperarPromocao(int id) async {
    final response = await get(pathParameters: {'id': id.toString()});
    return PromocaoDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<List<Promocao>> recuperarPromocoes({
    String? nome,
    bool? ativa,
    bool? vigente,
  }) async {
    final response = await get(
      queryParameters: {
        if (nome != null && nome.trim().isNotEmpty) 'nome': nome,
        if (ativa != null) 'ativa': ativa.toString(),
        if (vigente != null) 'vigente': vigente.toString(),
      },
    );

    final body = response.body as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>? ?? const [];
    return items
        .map((json) => PromocaoDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
