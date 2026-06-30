import 'package:comercial/domain/models/documento_fiscal.dart';

abstract class IIntegracaoFiscalRepository {
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
    int page,
    int limit,
  });
  Future<DocumentoFiscal> reprocessar(int id);
  Future<DocumentoFiscalDetalhe> getDetalhe(int id);
}
