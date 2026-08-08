import 'package:core/remote_data_sourcers.dart';
import 'package:promocoes/data/remote/dtos/cupom_dto.dart';
import 'package:promocoes/domain/data/remote/i_cupons_remote_data_source.dart';
import 'package:promocoes/domain/models/cupom.dart';

class CuponsRemoteDataSource extends RemoteDataSourceBase
    implements ICuponsRemoteDataSource {
  CuponsRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/cupons/{id}';

  @override
  Future<Cupom> atualizarCupom(Cupom cupom) async {
    final response = await put(
      pathParameters: {'id': cupom.id.toString()},
      body: CupomDto.fromModel(cupom).toUpdateJson(),
    );

    return CupomDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<Cupom> criarCupom(Cupom cupom) async {
    final response = await post(
      body: CupomDto.fromModel(cupom).toCreateJson(),
    );

    return CupomDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<Cupom?> recuperarCupom(int id) async {
    final response = await get(pathParameters: {'id': id.toString()});
    return CupomDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<List<Cupom>> recuperarCupons({
    String? codigo,
    bool? ativa,
    bool? vigente,
  }) async {
    final response = await get(
      queryParameters: {
        if (codigo != null && codigo.trim().isNotEmpty) 'codigo': codigo,
        if (ativa != null) 'ativa': ativa.toString(),
        if (vigente != null) 'vigente': vigente.toString(),
      },
    );

    final body = response.body as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>? ?? const [];
    return items
        .map((json) => CupomDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
