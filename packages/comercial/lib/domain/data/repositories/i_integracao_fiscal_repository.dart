import 'dart:typed_data';

import 'package:comercial/domain/models/documento_fiscal.dart';

abstract class IIntegracaoFiscalRepository {
  Future<List<String>> listarProviders();

  /// [empresaId] opcional: rota administrativa (qualquer empresa) quando
  /// informado, rota de sessão de sempre quando omitido -- ver
  /// IIntegracaoFiscalRemoteDataSource.
  Future<EmpresaIntegracaoFiscal?> getConfiguracao({int? empresaId});
  Future<EmpresaIntegracaoFiscal> salvarConfiguracao({
    required String provider,
    required bool ativo,
    Map<String, dynamic>? configuracao,
    int? empresaId,
  });
  Future<Map<String, dynamic>> listarDocumentos({
    int? romaneioId,
    int? pedidoId,
    String? cliente,
    String? status,
    String? formaPagamento,
    DateTime? dataInicio,
    DateTime? dataFim,
    int page,
    int limit,
  });
  Future<DocumentoFiscal> reprocessar(int id);
  Future<DocumentoFiscalDetalhe> getDetalhe(int id);
  Future<Uint8List> baixarDanfe(int id);
  Future<Uint8List> baixarXml(int id);
  Future<void> reenviarEmail(int id, {String? emailDestino});

  Future<Map<String, dynamic>> enviarCertificadoFiscal({
    required String filePath,
    required String senha,
    void Function(int sent, int total)? onSendProgress,
    int? empresaId,
  });
  Future<void> excluirCertificadoFiscal({int? empresaId});
}
