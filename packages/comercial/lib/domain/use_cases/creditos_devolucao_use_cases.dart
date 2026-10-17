import 'package:comercial/data.dart';
import 'package:comercial/models.dart';

class BuscarCreditosDevolucao {
  final ICreditoDevolucaoRepository _repository;
  BuscarCreditosDevolucao({required ICreditoDevolucaoRepository repository})
      : _repository = repository;

  /// [situacao]: disponivel | encerrado | todos.
  Future<List<CreditoDevolucao>> call({
    required int pessoaId,
    String situacao = 'todos',
  }) =>
      _repository.buscarCreditos(pessoaId: pessoaId, situacao: situacao);
}

class BuscarResumoCreditoDevolucao {
  final ICreditoDevolucaoRepository _repository;
  BuscarResumoCreditoDevolucao(
      {required ICreditoDevolucaoRepository repository})
      : _repository = repository;

  Future<ResumoCreditoDevolucao> call({required int pessoaId}) =>
      _repository.buscarResumo(pessoaId: pessoaId);
}

class AdicionarCreditoAvulso {
  final ICreditoDevolucaoRepository _repository;
  AdicionarCreditoAvulso({required ICreditoDevolucaoRepository repository})
      : _repository = repository;

  Future<ResultadoAcaoCredito> call({
    required int pessoaId,
    required double valor,
    required String motivo,
    required String observacao,
    DateTime? validade,
    int? empresaId,
  }) =>
      _repository.adicionar(
        pessoaId: pessoaId,
        valor: valor,
        motivo: motivo,
        observacao: observacao,
        validade: validade,
        empresaId: empresaId,
      );
}

class RemoverCreditoDevolucao {
  final ICreditoDevolucaoRepository _repository;
  RemoverCreditoDevolucao({required ICreditoDevolucaoRepository repository})
      : _repository = repository;

  /// [valor] nulo remove todo o restante.
  Future<ResultadoAcaoCredito> call({
    required int pessoaId,
    required int creditoId,
    double? valor,
    required String motivo,
    String? observacao,
  }) =>
      _repository.remover(
        pessoaId: pessoaId,
        creditoId: creditoId,
        valor: valor,
        motivo: motivo,
        observacao: observacao,
      );
}

class ExpirarCreditoDevolucao {
  final ICreditoDevolucaoRepository _repository;
  ExpirarCreditoDevolucao({required ICreditoDevolucaoRepository repository})
      : _repository = repository;

  Future<ResultadoAcaoCredito> call({
    required int pessoaId,
    required int creditoId,
    String? motivo,
  }) =>
      _repository.expirar(
        pessoaId: pessoaId,
        creditoId: creditoId,
        motivo: motivo,
      );
}
