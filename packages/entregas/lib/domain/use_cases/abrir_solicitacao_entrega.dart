import 'package:entregas/domain/data/repositories/i_integracao_entrega_repository.dart';
import 'package:entregas/domain/models/entrega.dart';

class AbrirSolicitacaoEntrega {
  final IIntegracaoEntregaRepository _repository;

  AbrirSolicitacaoEntrega({required IIntegracaoEntregaRepository repository})
      : _repository = repository;

  Future<SolicitacaoEntrega> call({
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
      _repository.abrirSolicitacao(
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
}
