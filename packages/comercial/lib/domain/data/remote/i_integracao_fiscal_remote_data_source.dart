import 'dart:typed_data';

import 'package:comercial/domain/models/documento_fiscal.dart';
import 'package:comercial/domain/models/resumo_fiscal.dart';

abstract class IIntegracaoFiscalRemoteDataSource {
  Future<List<String>> listarProviders();

  /// [empresaId] opcional: quando informado, usa a rota administrativa
  /// `empresas/:empresaId/integracoes-fiscais/...` (configura QUALQUER
  /// empresa, não só a da sessão logada -- ver IntegracaoFiscalEmpresaController
  /// no apollo-api). Omitido, usa a rota de sessão de sempre.
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
    int page = 1,
    int limit = 25,
  });
  /// Saldo consolidado/pendente/total do periodo/filtro (tela de relatorio fiscal), mesmos filtros
  /// de [listarDocumentos] sem paginacao.
  Future<ResumoFiscal> getResumo({
    int? romaneioId,
    int? pedidoId,
    String? cliente,
    String? status,
    String? formaPagamento,
    DateTime? dataInicio,
    DateTime? dataFim,
  });

  Future<DocumentoFiscal> reprocessar(int id);
  Future<DocumentoFiscalDetalhe> getDetalhe(int id);

  /// Baixa o PDF da DANFE pronta direto do backend, que faz o proxy
  /// autenticado pro gateway fiscal (credenciais nunca chegam no app).
  Future<Uint8List> baixarDanfe(int id);

  /// Baixa o XML autorizado da nota (nfeProc) -- só disponível pro provider
  /// sefaz (emissão direta guarda o XML; webmania não expõe XML cru pro
  /// backend, só PDF hospedado). Erro HTTP chega como [HttpException].
  Future<Uint8List> baixarXml(int id);

  /// Reenvia a nota fiscal por e-mail. [emailDestino] opcional -- se
  /// omitido, backend usa o e-mail cadastrado da pessoa do romaneio.
  Future<void> reenviarEmail(int id, {String? emailDestino});

  /// Envia o certificado A1 (.pfx/.p12) do provider SEFAZ. Retorna
  /// `{ certificadoStorageKey, validade }`.
  Future<Map<String, dynamic>> enviarCertificadoFiscal({
    required String filePath,
    required String senha,
    void Function(int sent, int total)? onSendProgress,
    int? empresaId,
  });

  /// Remove o certificado A1 salvo. Backend só aceita se já expirado e o
  /// provider sefaz não estiver ativo — erro chega como [HttpException].
  Future<void> excluirCertificadoFiscal({int? empresaId});
}
