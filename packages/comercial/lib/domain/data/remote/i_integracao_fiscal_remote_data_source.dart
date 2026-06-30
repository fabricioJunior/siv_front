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
}
