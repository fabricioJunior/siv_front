import 'dart:typed_data';

import 'package:comercial/domain/models/documento_fiscal.dart';

abstract class IIntegracaoFiscalRemoteDataSource {
  Future<List<String>> listarProviders();
  Future<EmpresaIntegracaoFiscal?> getConfiguracao();
  Future<EmpresaIntegracaoFiscal> salvarConfiguracao({
    required String provider,
    required bool ativo,
    Map<String, dynamic>? configuracao,
  });
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
  });
  Future<DocumentoFiscal> reprocessar(int id);
  Future<DocumentoFiscalDetalhe> getDetalhe(int id);

  /// Baixa o PDF da DANFE pronta direto do backend, que faz o proxy
  /// autenticado pro gateway fiscal (credenciais nunca chegam no app).
  Future<Uint8List> baixarDanfe(int id);

  /// Envia o certificado A1 (.pfx/.p12) do provider SEFAZ. Retorna
  /// `{ certificadoStorageKey, validade }`.
  Future<Map<String, dynamic>> enviarCertificadoFiscal({
    required String filePath,
    required String senha,
    void Function(int sent, int total)? onSendProgress,
  });

  /// Remove o certificado A1 salvo. Backend só aceita se já expirado e o
  /// provider sefaz não estiver ativo — erro chega como [HttpException].
  Future<void> excluirCertificadoFiscal();
}
