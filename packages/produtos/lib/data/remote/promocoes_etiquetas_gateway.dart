import 'package:core/remote_data_sourcers.dart';
import 'package:produtos/domain/data/gateways/i_promocoes_etiquetas_gateway.dart';
import 'package:produtos/domain/models/etiqueta_promocao.dart';

class PromocoesEtiquetasGateway implements IPromocoesEtiquetasGateway {
  final _ListaPromocoes _lista;
  final _ItensPromocao _itens;

  PromocoesEtiquetasGateway({
    required IInformacoesParaRequests informacoesParaRequest,
  }) : _lista = _ListaPromocoes(informacoesParaRequest),
       _itens = _ItensPromocao(informacoesParaRequest);

  @override
  Future<List<PromocaoParaEtiqueta>> promocoes({
    required bool apenasVigentes,
  }) async {
    final response = await _lista.get(
      queryParameters: {if (apenasVigentes) 'vigente': 'true'},
    );
    final items = (response.body as Map<String, dynamic>)['items'] as List?;
    return [
      for (final j in items ?? const [])
        PromocaoParaEtiqueta(
          id: (j['id'] as num).toInt(),
          nome: j['nome'] as String? ?? '',
          tipoEscopo: j['tipoEscopo'] as String?,
          dataInicio: DateTime.tryParse('${j['dataInicio']}'),
          dataFim: DateTime.tryParse('${j['dataFim']}'),
        ),
    ];
  }

  @override
  Future<List<ItemEtiquetaPromocao>> itens({
    required int promocaoId,
    required int tabelaDePrecoId,
  }) async {
    final response = await _itens.get(
      pathParameters: {'id': promocaoId.toString()},
      queryParameters: {'tabelaDePrecoId': tabelaDePrecoId.toString()},
    );
    final itens = (response.body as Map<String, dynamic>)['itens'] as List?;
    return [
      for (final j in itens ?? const [])
        ItemEtiquetaPromocao(
          produtoId: (j['produtoId'] as num).toInt(),
          referenciaId: (j['referenciaId'] as num).toInt(),
          referenciaNome: j['referenciaNome'] as String? ?? '',
          corNome: j['corNome'] as String?,
          tamanhoNome: j['tamanhoNome'] as String?,
          codigoBarras: j['codigoBarras'] as String?,
          saldo: (j['saldo'] as num).toInt(),
          precoTabela: (j['precoTabela'] as num?)?.toDouble() ?? 0,
          precoPromocional: (j['precoPromocional'] as num?)?.toDouble(),
        ),
    ];
  }
}

class _ListaPromocoes extends RemoteDataSourceBase {
  _ListaPromocoes(IInformacoesParaRequests info)
    : super(informacoesParaRequest: info);

  @override
  String get path => '/v1/promocoes';
}

class _ItensPromocao extends RemoteDataSourceBase {
  _ItensPromocao(IInformacoesParaRequests info)
    : super(informacoesParaRequest: info);

  @override
  String get path => '/v1/promocoes/{id}/etiquetas';
}
