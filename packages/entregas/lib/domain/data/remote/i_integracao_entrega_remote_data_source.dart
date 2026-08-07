import 'package:entregas/domain/models/entrega.dart';

abstract class IIntegracaoEntregaRemoteDataSource {
  Future<EmpresaIntegracaoEntrega?> getConfiguracao();

  Future<EmpresaIntegracaoEntrega> salvarConfiguracao({
    required String provider,
    bool? ativo,
    Map<String, dynamic>? configuracao,
  });

  Future<EstimativaEntrega> estimar({
    required EnderecoEntrega partida,
    required EnderecoEntrega destino,
    int? categoriaId,
    String? categoriaNome,
    String? data,
    String? hora,
    bool? comRetorno,
  });

  Future<double> getSaldo();

  Future<SolicitacaoEntrega> abrirSolicitacao({
    required int categoriaId,
    required String categoriaNome,
    String? formaPagamento,
    int? condutorIdentificacao,
    required EnderecoEntrega partida,
    required List<ParadaEntrega> paradas,
    bool? retorno,
    String? data,
    String? hora,
    int? antecedencia,
    double? valorEstimado,
  });

  Future<List<RastreioEntrega>> getRastreio(int id);

  Future<SolicitacaoEntrega> cancelar(int id, {int? motivoId});
}
