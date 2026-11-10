import 'package:core/remote_data_sourcers.dart';
import 'package:produtos/domain/data/remote/i_consulta_referencias_remote_data_source.dart';
import 'package:produtos/domain/models/consulta_referencias.dart';

class ConsultaReferenciasRemoteDataSource extends RemoteDataSourceBase
    implements IConsultaReferenciasRemoteDataSource {
  ConsultaReferenciasRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/referencias/consulta';

  @override
  Future<ConsultaReferenciasPagina> consultar({
    String? busca,
    List<int> corIds = const [],
    List<int> tamanhoIds = const [],
    List<int> estampaIds = const [],
    int? tabelaPrecoId,
    int page = 1,
    int limit = 30,
  }) async {
    final response = await get(
      queryParameters: {
        if (busca != null && busca.trim().isNotEmpty) 'busca': busca.trim(),
        if (corIds.isNotEmpty) 'corIds': corIds.join(','),
        if (tamanhoIds.isNotEmpty) 'tamanhoIds': tamanhoIds.join(','),
        if (estampaIds.isNotEmpty) 'estampaIds': estampaIds.join(','),
        if (tabelaPrecoId != null) 'tabelaPrecoId': '$tabelaPrecoId',
        'page': '$page',
        'limit': '$limit',
      },
    );
    return consultaDeJson((response.body as Map).cast<String, dynamic>());
  }
}

ConsultaReferenciasPagina consultaDeJson(Map<String, dynamic> json) {
  int numero(Object? v) => (v as num?)?.toInt() ?? 0;
  final meta = (json['meta'] as Map?)?.cast<String, dynamic>() ?? const {};
  return ConsultaReferenciasPagina(
    produtoIdLido: (json['produtoIdLido'] as num?)?.toInt(),
    page: numero(meta['page']),
    totalItems: numero(meta['totalItems']),
    totalPages: numero(meta['totalPages']),
    items: [
      for (final i in json['items'] as List? ?? const [])
        ConsultaReferenciaItem(
          referenciaId: numero(i['referenciaId']),
          idExterno: i['idExterno']?.toString(),
          nome: i['nome'] as String? ?? '',
          capaUrl: i['capaUrl'] as String?,
          preco: (i['preco'] as num?)?.toDouble(),
          saldoFiltrado: numero(i['saldoFiltrado']),
          variacoes: [
            for (final v in i['variacoes'] as List? ?? const [])
              ConsultaVariacao(
                produtoId: numero(v['produtoId']),
                corId: numero(v['corId']),
                corNome: v['corNome'] as String? ?? '',
                tamanhoId: numero(v['tamanhoId']),
                tamanhoNome: v['tamanhoNome'] as String? ?? '',
                estampaId: (v['estampaId'] as num?)?.toInt(),
                estampaNome: v['estampaNome'] as String?,
                saldo: numero(v['saldo']),
                bateFiltro: v['bateFiltro'] as bool? ?? false,
              ),
          ],
        ),
    ],
  );
}
