import 'package:estoque/domain/models/balanco.dart';
import 'package:estoque/domain/repositories/i_balanco_repository.dart';

// ===== BALANÇO =====

class CriarBalancoUseCase {
  final IBalancoRepository repository;

  CriarBalancoUseCase({required this.repository});

  Future<Balanco> call({required String? observacao}) {
    return repository.criarBalanco(observacao: observacao);
  }
}

class ListarBalancosUseCase {
  final IBalancoRepository repository;

  ListarBalancosUseCase({required this.repository});

  Future<List<Balanco>> call({
    required String? situacao,
    required int page,
    required int limit,
  }) {
    return repository.listarBalancos(
      situacao: situacao,
      page: page,
      limit: limit,
    );
  }
}

class ObterBalancoUseCase {
  final IBalancoRepository repository;

  ObterBalancoUseCase({required this.repository});

  Future<Balanco> call({required int balancoId}) {
    return repository.obterBalanco(balancoId: balancoId);
  }
}

class AtualizarBalancoUseCase {
  final IBalancoRepository repository;

  AtualizarBalancoUseCase({required this.repository});

  Future<Balanco> call({required int balancoId, required String? observacao}) {
    return repository.atualizarBalanco(
      balancoId: balancoId,
      observacao: observacao,
    );
  }
}

class EncerrarBalancoUseCase {
  final IBalancoRepository repository;

  EncerrarBalancoUseCase({required this.repository});

  Future<Balanco> call({required int balancoId, required String? observacao}) {
    return repository.encerrarBalanco(
      balancoId: balancoId,
      observacao: observacao,
    );
  }
}

class CancelarBalancoUseCase {
  final IBalancoRepository repository;

  CancelarBalancoUseCase({required this.repository});

  Future<Balanco> call({required int balancoId, required String motivo}) {
    return repository.cancelarBalanco(balancoId: balancoId, motivo: motivo);
  }
}

class ObterResumoBalancoUseCase {
  final IBalancoRepository repository;

  ObterResumoBalancoUseCase({required this.repository});

  Future<Map<String, dynamic>> call({required int balancoId}) {
    return repository.obterResumo(balancoId: balancoId);
  }
}

// ===== ITENS DO BALANÇO =====

class AdicionarItemAoBalancoUseCase {
  final IBalancoRepository repository;

  AdicionarItemAoBalancoUseCase({required this.repository});

  Future<BalancoItem> call({required int balancoId, required int produtoId}) {
    return repository.adicionarItem(balancoId: balancoId, produtoId: produtoId);
  }
}

class AdicionarMultiplosItensAoBalancoUseCase {
  final IBalancoRepository repository;

  AdicionarMultiplosItensAoBalancoUseCase({required this.repository});

  Future<void> call({
    required int balancoId,
    required List<int> referenciaIds,
  }) {
    return repository.adicionarMultiplosItensPorReferencia(
      balancoId: balancoId,
      referenciaIds: referenciaIds,
    );
  }
}

class ListarItensDoBalancoUseCase {
  final IBalancoRepository repository;

  ListarItensDoBalancoUseCase({required this.repository});

  Future<List<BalancoItem>> call({required int balancoId}) {
    return repository.listarItensDoBalanco(balancoId: balancoId);
  }
}

class RemoverItemDoBalancoUseCase {
  final IBalancoRepository repository;

  RemoverItemDoBalancoUseCase({required this.repository});

  Future<void> call({required int balancoId, required int produtoId}) {
    return repository.removerItemDoBalanco(
      balancoId: balancoId,
      produtoId: produtoId,
    );
  }
}

// ===== LOTES DO BALANÇO =====

class CriarLoteBalancoUseCase {
  final IBalancoRepository repository;

  CriarLoteBalancoUseCase({required this.repository});

  Future<BalancoLote> call({
    required int balancoId,
    required String lote,
    required String? observacao,
  }) {
    return repository.criarLote(
      balancoId: balancoId,
      lote: lote,
      observacao: observacao,
    );
  }
}

class ListarLotesBalancoUseCase {
  final IBalancoRepository repository;

  ListarLotesBalancoUseCase({required this.repository});

  Future<List<BalancoLote>> call({required int balancoId}) {
    return repository.listarLotes(balancoId: balancoId);
  }
}

class AtualizarLoteBalancoUseCase {
  final IBalancoRepository repository;

  AtualizarLoteBalancoUseCase({required this.repository});

  Future<BalancoLote> call({
    required int balancoId,
    required int loteId,
    required String? lote,
    required String? observacao,
  }) {
    return repository.atualizarLote(
      balancoId: balancoId,
      loteId: loteId,
      lote: lote,
      observacao: observacao,
    );
  }
}

class CancelarLoteBalancoUseCase {
  final IBalancoRepository repository;

  CancelarLoteBalancoUseCase({required this.repository});

  Future<BalancoLote> call({
    required int balancoId,
    required int loteId,
    required String motivo,
  }) {
    return repository.cancelarLote(
      balancoId: balancoId,
      loteId: loteId,
      motivo: motivo,
    );
  }
}

// ===== ITENS DO LOTE =====

class AdicionarItemAoLoteBalancoUseCase {
  final IBalancoRepository repository;

  AdicionarItemAoLoteBalancoUseCase({required this.repository});

  Future<BalancoLoteItem> call({
    required int balancoId,
    required int loteId,
    required int produtoId,
    required double quantidadeContada,
  }) {
    return repository.adicionarItemAoLote(
      balancoId: balancoId,
      loteId: loteId,
      produtoId: produtoId,
      quantidadeContada: quantidadeContada,
    );
  }
}

class AdicionarMultiplosItensAoLoteBalancoUseCase {
  final IBalancoRepository repository;

  AdicionarMultiplosItensAoLoteBalancoUseCase({required this.repository});

  Future<void> call({
    required int balancoId,
    required int loteId,
    required List<Map<String, dynamic>> itens,
  }) {
    return repository.adicionarMultiplosItensAoLote(
      balancoId: balancoId,
      loteId: loteId,
      itens: itens,
    );
  }
}

class ListarItensDoLoteBalancoUseCase {
  final IBalancoRepository repository;

  ListarItensDoLoteBalancoUseCase({required this.repository});

  Future<List<BalancoLoteItem>> call({
    required int balancoId,
    required int loteId,
  }) {
    return repository.listarItensDoLote(balancoId: balancoId, loteId: loteId);
  }
}

class RemoverItemDoLoteBalancoUseCase {
  final IBalancoRepository repository;

  RemoverItemDoLoteBalancoUseCase({required this.repository});

  Future<void> call({
    required int balancoId,
    required int loteId,
    required int produtoId,
  }) {
    return repository.removerItemDoLote(
      balancoId: balancoId,
      loteId: loteId,
      produtoId: produtoId,
    );
  }
}
