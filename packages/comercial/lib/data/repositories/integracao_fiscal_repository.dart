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
  Future<EmpresaIntegracaoFiscal?> getConfiguracao() =>
      remoteDataSource.getConfiguracao();

  @override
  Future<EmpresaIntegracaoFiscal> salvarConfiguracao({
    required String provider,
    required bool ativo,
    Map<String, dynamic>? configuracao,
  }) =>
      remoteDataSource.salvarConfiguracao(
        provider: provider,
        ativo: ativo,
        configuracao: configuracao,
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
}
