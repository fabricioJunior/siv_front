import 'package:financeiro/domain/data/repositories/i_despesas_repository.dart';
import 'package:financeiro/domain/models/despesa.dart';

class AtualizarDespesa {
  final IDespesasRepository repository;

  AtualizarDespesa({required this.repository});

  Future<Despesa> call(
    int id, {
    double? valor,
    int? categoriaId,
    int? origemPagamentoId,
    DateTime? dataPagamento,
    StatusDespesa? status,
  }) {
    return repository.atualizarDespesa(
      id,
      valor: valor,
      categoriaId: categoriaId,
      origemPagamentoId: origemPagamentoId,
      dataPagamento: dataPagamento,
      status: status,
    );
  }
}
