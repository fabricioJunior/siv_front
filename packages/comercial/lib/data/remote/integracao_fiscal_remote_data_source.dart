import 'dart:io';
import 'dart:typed_data';

import 'package:comercial/data/remote/dtos/documento_fiscal_dto.dart';
import 'package:comercial/domain/data/remote/i_integracao_fiscal_remote_data_source.dart';
import 'package:comercial/domain/models/documento_fiscal.dart';
import 'package:comercial/domain/models/resumo_fiscal.dart';
import 'package:core/remote_data_sourcers.dart';

class IntegracaoFiscalRemoteDataSource extends RemoteDataSourceBase
    implements IIntegracaoFiscalRemoteDataSource {
  IntegracaoFiscalRemoteDataSource({required super.informacoesParaRequest});

  // Setado/limpo dentro do mesmo método (sem await entre as duas pontas) quando empresaId vem
  // explícito -- mesma técnica já usada no datasource de entregas pra rota de profundidade
  // diferente. path getter é lido de forma síncrona antes do único await (a request em si),
  // então não há race entre chamadas concorrentes desta instância.
  int? _empresaIdOverride;

  @override
  String get path => _empresaIdOverride != null
      ? '/v1/empresas/$_empresaIdOverride/integracoes-fiscais{path}'
      : '/v1/integracoes-fiscais{path}';

  @override
  Future<List<String>> listarProviders() async {
    final response = await get(pathParameters: {'path': '/providers'});
    return (response.body as List<dynamic>).cast<String>();
  }

  @override
  Future<EmpresaIntegracaoFiscal?> getConfiguracao({int? empresaId}) async {
    _empresaIdOverride = empresaId;
    try {
      final response = await get(pathParameters: {'path': '/configuracao'});
      if (response.body == null) return null;
      return EmpresaIntegracaoFiscalDto.fromJson(
        response.body as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    } finally {
      _empresaIdOverride = null;
    }
  }

  @override
  Future<EmpresaIntegracaoFiscal> salvarConfiguracao({
    required String provider,
    required bool ativo,
    Map<String, dynamic>? configuracao,
    int? empresaId,
  }) async {
    _empresaIdOverride = empresaId;
    try {
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
    } finally {
      _empresaIdOverride = null;
    }
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
  Future<ResumoFiscal> getResumo({
    int? romaneioId,
    int? pedidoId,
    String? cliente,
    String? status,
    String? formaPagamento,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    final response = await get(
      pathParameters: {'path': '/resumo'},
      queryParameters: {
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
    return ResumoFiscalDto.fromJson(response.body as Map<String, dynamic>);
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

  @override
  Future<Uint8List> baixarDanfe(int id) {
    return getBytes(pathParameters: {'path': '/$id/danfe'});
  }

  @override
  Future<Uint8List> baixarXml(int id) {
    return getBytes(pathParameters: {'path': '/$id/xml'});
  }

  @override
  Future<void> reenviarEmail(int id, {String? emailDestino}) async {
    await post(
      pathParameters: {'path': '/$id/reenviar-email'},
      body: {if (emailDestino != null && emailDestino.isNotEmpty) 'emailDestino': emailDestino},
    );
  }

  @override
  Future<Map<String, dynamic>> enviarCertificadoFiscal({
    required String filePath,
    required String senha,
    void Function(int sent, int total)? onSendProgress,
    int? empresaId,
  }) async {
    _empresaIdOverride = empresaId;
    try {
      final response = await postFile(
        field: 'file',
        bytes: await File(filePath).readAsBytes(),
        fileName: filePath.split(Platform.pathSeparator).last,
        fileType: FileType.other,
        pathParameters: {'path': '/configuracao/certificado'},
        body: {'senha': senha},
        onSendProgress: onSendProgress,
      );
      return response.body as Map<String, dynamic>;
    } finally {
      _empresaIdOverride = null;
    }
  }

  @override
  Future<void> excluirCertificadoFiscal({int? empresaId}) async {
    _empresaIdOverride = empresaId;
    try {
      await delete(pathParameters: {'path': '/configuracao/certificado'});
    } finally {
      _empresaIdOverride = null;
    }
  }
}
