import 'package:entregas/domain/data/repositories/i_integracao_entrega_repository.dart';
import 'package:entregas/domain/models/entrega.dart';

class EstimarEntrega {
  final IIntegracaoEntregaRepository _repository;

  EstimarEntrega({required IIntegracaoEntregaRepository repository})
      : _repository = repository;

  Future<EstimativaEntrega> call({
    required EnderecoEntrega partida,
    required EnderecoEntrega destino,
    int? categoriaId,
    String? categoriaNome,
    String? data,
    String? hora,
    bool? comRetorno,
  }) =>
      _repository.estimar(
        partida: partida,
        destino: destino,
        categoriaId: categoriaId,
        categoriaNome: categoriaNome,
        data: data,
        hora: hora,
        comRetorno: comRetorno,
      );
}
