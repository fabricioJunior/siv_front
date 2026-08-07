import 'package:entregas/domain/data/remote/i_integracao_entrega_remote_data_source.dart';
import 'package:entregas/domain/data/repositories/i_integracao_entrega_repository.dart';
import 'package:entregas/domain/models/entrega.dart';

class IntegracaoEntregaRepository implements IIntegracaoEntregaRepository {
  final IIntegracaoEntregaRemoteDataSource remoteDataSource;

  IntegracaoEntregaRepository({required this.remoteDataSource});

  @override
  Future<EmpresaIntegracaoEntrega?> getConfiguracao() =>
      remoteDataSource.getConfiguracao();

  @override
  Future<EmpresaIntegracaoEntrega> salvarConfiguracao({
    required String provider,
    bool? ativo,
    Map<String, dynamic>? configuracao,
  }) =>
      remoteDataSource.salvarConfiguracao(
        provider: provider,
        ativo: ativo,
        configuracao: configuracao,
      );

  @override
  Future<EstimativaEntrega> estimar({
    required EnderecoEntrega partida,
    required EnderecoEntrega destino,
    int? categoriaId,
    String? categoriaNome,
    String? data,
    String? hora,
    bool? comRetorno,
  }) =>
      remoteDataSource.estimar(
        partida: partida,
        destino: destino,
        categoriaId: categoriaId,
        categoriaNome: categoriaNome,
        data: data,
        hora: hora,
        comRetorno: comRetorno,
      );

  @override
  Future<double> getSaldo() => remoteDataSource.getSaldo();

  @override
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
  }) =>
      remoteDataSource.abrirSolicitacao(
        categoriaId: categoriaId,
        categoriaNome: categoriaNome,
        formaPagamento: formaPagamento,
        condutorIdentificacao: condutorIdentificacao,
        partida: partida,
        paradas: paradas,
        retorno: retorno,
        data: data,
        hora: hora,
        antecedencia: antecedencia,
        valorEstimado: valorEstimado,
      );

  @override
  Future<List<RastreioEntrega>> getRastreio(int id) =>
      remoteDataSource.getRastreio(id);

  @override
  Future<SolicitacaoEntrega> cancelar(int id, {int? motivoId}) =>
      remoteDataSource.cancelar(id, motivoId: motivoId);
}
