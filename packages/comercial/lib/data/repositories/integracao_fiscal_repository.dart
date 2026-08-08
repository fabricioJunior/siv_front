import 'dart:typed_data';

import 'package:comercial/data.dart';
import 'package:comercial/domain/models/documento_fiscal.dart';

class IntegracaoFiscalRepository implements IIntegracaoFiscalRepository {
  final IIntegracaoFiscalRemoteDataSource remoteDataSource;

  IntegracaoFiscalRepository({required this.remoteDataSource});

  @override
  Future<List<String>> listarProviders() =>
      remoteDataSource.listarProviders();

  @override
  Future<EmpresaIntegracaoFiscal?> getConfiguracao({int? empresaId}) =>
      remoteDataSource.getConfiguracao(empresaId: empresaId);

  @override
  Future<EmpresaIntegracaoFiscal> salvarConfiguracao({
    required String provider,
    required bool ativo,
    Map<String, dynamic>? configuracao,
    int? empresaId,
  }) =>
      remoteDataSource.salvarConfiguracao(
        provider: provider,
        ativo: ativo,
        configuracao: configuracao,
        empresaId: empresaId,
      );

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
  }) =>
      remoteDataSource.listarDocumentos(
        romaneioId: romaneioId,
        pedidoId: pedidoId,
        cliente: cliente,
        status: status,
        formaPagamento: formaPagamento,
        dataInicio: dataInicio,
        dataFim: dataFim,
        page: page,
        limit: limit,
      );

  @override
  Future<DocumentoFiscal> reprocessar(int id) =>
      remoteDataSource.reprocessar(id);

  @override
  Future<DocumentoFiscalDetalhe> getDetalhe(int id) =>
      remoteDataSource.getDetalhe(id);

  @override
  Future<Uint8List> baixarDanfe(int id) => remoteDataSource.baixarDanfe(id);

  @override
  Future<Uint8List> baixarXml(int id) => remoteDataSource.baixarXml(id);

  @override
  Future<void> reenviarEmail(int id, {String? emailDestino}) =>
      remoteDataSource.reenviarEmail(id, emailDestino: emailDestino);

  @override
  Future<Map<String, dynamic>> enviarCertificadoFiscal({
    required String filePath,
    required String senha,
    void Function(int sent, int total)? onSendProgress,
    int? empresaId,
  }) =>
      remoteDataSource.enviarCertificadoFiscal(
        filePath: filePath,
        senha: senha,
        onSendProgress: onSendProgress,
        empresaId: empresaId,
      );

  @override
  Future<void> excluirCertificadoFiscal({int? empresaId}) =>
      remoteDataSource.excluirCertificadoFiscal(empresaId: empresaId);
}
