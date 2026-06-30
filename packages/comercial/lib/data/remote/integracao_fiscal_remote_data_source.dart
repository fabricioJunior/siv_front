import 'package:comercial/data/remote/dtos/documento_fiscal_dto.dart';
import 'package:comercial/domain/data/remote/i_integracao_fiscal_remote_data_source.dart';
import 'package:comercial/domain/models/documento_fiscal.dart';
import 'package:core/remote_data_sourcers.dart';

class IntegracaoFiscalRemoteDataSource extends RemoteDataSourceBase
    implements IIntegracaoFiscalRemoteDataSource {
  IntegracaoFiscalRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/integracoes-fiscais{path}';

  @override
  Future<List<String>> listarProviders() async {
    final response = await get(pathParameters: {'path': '/providers'});
    return (response.body as List<dynamic>).cast<String>();
  }

  @override
  Future<EmpresaIntegracaoFiscal?> getConfiguracao() async {
    try {
      final response = await get(pathParameters: {'path': '/configuracao'});
      if (response.body == null) return null;
      return EmpresaIntegracaoFiscalDto.fromJson(
        response.body as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<EmpresaIntegracaoFiscal> salvarConfiguracao({
    required String provider,
    required bool ativo,
    Map<String, dynamic>? configuracao,
  }) async {
    final response = await post(
      pathParameters: {'path': '/configuracao'},
      body: {
        'provider': provider,
        'ativo': ativo,
        if (configuracao != null) 'configuracao': configuracao,
      },
    );
    return EmpresaIntegracaoFiscalDto.fromJson(
      response.body as Map<String, dynamic>,
    );
  }

  @override
  Future<Map<String, dynamic>> listarDocumentos({
    int? romaneioId,
    int? pedidoId,
    String? cliente,
    String? status,
    String? formaPagamento,
    DateTime? dataInicio,
    DateTime? dataFim,
    int page = 1,
    int limit = 25,
  }) async {
    final response = await get(
      pathParameters: {'path': ''},
      queryParameters: {
        'page': '$page',
        'limit': '$limit',
        if (romaneioId != null) 'romaneioId': '$romaneioId',
        if (pedidoId != null) 'pedidoId': '$pedidoId',
        if (cliente != null && cliente.isNotEmpty) 'cliente': cliente,
        if (status != null) 'status': status,
        if (formaPagamento != null && formaPagamento.isNotEmpty)
          'formaPagamento': formaPagamento,
        if (dataInicio != null) 'dataInicio': dataInicio.toIso8601String(),
        if (dataFim != null) 'dataFim': dataFim.toIso8601String(),
      },
    );
    final body = response.body as Map<String, dynamic>;
    final items = (body['items'] as List<dynamic>? ?? [])
        .map((j) => DocumentoFiscalDto.fromJson(j as Map<String, dynamic>))
        .toList();
    return {'items': items, 'total': (body['total'] as num?)?.toInt() ?? 0};
  }

  @override
  Future<DocumentoFiscal> reprocessar(int id) async {
    final response = await post(
      pathParameters: {'path': '/$id/reprocessar'},
      body: {'forcar': true},
    );
    return DocumentoFiscalDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<DocumentoFiscalDetalhe> getDetalhe(int id) async {
    final response = await get(pathParameters: {'path': '/$id'});
    return DocumentoFiscalDetalheDto.fromJson(
      response.body as Map<String, dynamic>,
    );
  }
}
