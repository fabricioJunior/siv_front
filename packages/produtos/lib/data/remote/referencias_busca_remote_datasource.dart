import 'package:core/remote_data_sourcers.dart';
import 'package:produtos/data/remote/dtos/referencia_dto.dart';
import 'package:produtos/domain/data/remote/i_referencias_busca_remote_data_source.dart';
import 'package:produtos/domain/models/referencias_busca.dart';

class ReferenciasBuscaRemoteDataSource extends RemoteDataSourceBase
    implements IReferenciasBuscaRemoteDataSource {
  ReferenciasBuscaRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/referencias/busca';

  @override
  Future<ReferenciasBuscaResultado> buscar({
    String? busca,
    int? categoriaId,
    bool semNcm = false,
    bool semPeso = false,
    String orderBy = 'nome',
    String orderDir = 'ASC',
    int page = 1,
  }) async {
    final response = await get(
      queryParameters: {
        if (busca != null && busca.trim().isNotEmpty) 'busca': busca.trim(),
        if (categoriaId != null) 'categoriaId': '$categoriaId',
        if (semNcm) 'semNcm': 'true',
        if (semPeso) 'semPeso': 'true',
        'orderBy': orderBy,
        'orderDir': orderDir,
        'page': '$page',
      },
    );

    // Aceita qualquer Map (um `{}` vazio chega como Map<dynamic, dynamic>).
    Map<String, dynamic> mapa(Object? v) =>
        (v as Map?)?.cast<String, dynamic>() ?? const {};
    final corpo = mapa(response.body);
    final meta = mapa(corpo['meta']);
    final resumo = mapa(corpo['resumo']);
    int numero(Object? v) => (v as num?)?.toInt() ?? 0;

    return ReferenciasBuscaResultado(
      items: [
        for (final item in corpo['items'] as List<dynamic>)
          ItemListaReferencia(
            referencia: ReferenciaDto.fromJson(item as Map<String, dynamic>),
            marcaNome: item['marcaNome'] as String?,
          ),
      ],
      totalItems: numero(meta['totalItems']),
      totalPages: numero(meta['totalPages']),
      currentPage: numero(meta['currentPage']),
      resumo: ResumoReferencias(
        semNcm: numero(resumo['semNcm']),
        semPeso: numero(resumo['semPeso']),
        categorias: [
          for (final c in resumo['categorias'] as List<dynamic>? ?? const [])
            CategoriaDoResumo(
              id: numero(c['id']),
              nome: c['nome'] as String? ?? '',
              total: numero(c['total']),
            ),
        ],
      ),
    );
  }
}
