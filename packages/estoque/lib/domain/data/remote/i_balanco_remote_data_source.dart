import 'package:estoque/domain/models/balanco.dart';

abstract class IBalancoRemoteDataSource {
  /// Criar novo balanço
  Future<Balanco> criarBalanco({required String? observacao});

  /// Listar balanços com filtro de situação
  Future<List<Balanco>> listarBalancos({
    required String? situacao, // em_andamento, encerrado, cancelado
    required int page,
    required int limit,
  });

  /// Obter balanço por ID
  Future<Balanco> obterBalanco({required int balancoId});

  /// Atualizar balanço
  Future<Balanco> atualizarBalanco({
    required int balancoId,
    required String? observacao,
  });

  /// Encerrar balanço
  Future<Balanco> encerrarBalanco({
    required int balancoId,
    required String? observacao,
  });

  /// Cancelar balanço
  Future<Balanco> cancelarBalanco({
    required int balancoId,
    required String motivo,
  });

  /// Obter resumo do balanço (com estatísticas)
  Future<Map<String, dynamic>> obterResumo({required int balancoId});

  // ===== ITENS DO BALANÇO =====

  /// Adicionar item ao balanço
  Future<BalancoItem> adicionarItem({
    required int balancoId,
    required int produtoId,
  });

  /// Adicionar múltiplos itens ao balanço por referência
  Future<void> adicionarMultiplosItensPorReferencia({
    required int balancoId,
    required List<int> referenciaIds,
  });

  /// Listar itens do balanço
  Future<List<BalancoItem>> listarItensDoBalanco({
    required int balancoId,
    int page = 1,
    int limit = 25,
    bool? comDivergencia,
    List<String>? referencias,
    List<String>? ordenacao,
  });

  /// Remover item do balanço
  Future<void> removerItemDoBalanco({
    required int balancoId,
    required int produtoId,
  });

  // ===== LOTES DO BALANÇO =====

  /// Criar novo lote
  Future<BalancoLote> criarLote({
    required int balancoId,
    required String lote,
    required String? observacao,
  });

  /// Listar lotes do balanço
  Future<List<BalancoLote>> listarLotes({required int balancoId});

  /// Atualizar lote
  Future<BalancoLote> atualizarLote({
    required int balancoId,
    required int loteId,
    required String? lote,
    required String? observacao,
  });

  /// Cancelar lote
  Future<BalancoLote> cancelarLote({
    required int balancoId,
    required int loteId,
    required String motivo,
  });

  // ===== ITENS DO LOTE =====

  /// Adicionar item ao lote (com quantidade contada)
  Future<BalancoLoteItem> adicionarItemAoLote({
    required int balancoId,
    required int loteId,
    required int produtoId,
    required double quantidadeContada,
  });

  /// Adicionar múltiplos itens ao lote
  Future<void> adicionarMultiplosItensAoLote({
    required int balancoId,
    required int loteId,
    required List<Map<String, dynamic>>
    itens, // [{'produtoId': ..., 'quantidadeContada': ...}]
  });

  /// Listar itens do lote
  Future<List<BalancoLoteItem>> listarItensDoLote({
    required int balancoId,
    required int loteId,
  });

  /// Remover item do lote
  Future<void> removerItemDoLote({
    required int balancoId,
    required int loteId,
    required int produtoId,
  });

  Future<void> calcularItensDoBalanco({required int balancoId});

  /// Verifica se há balanço em andamento para a empresa da sessão
  Future<Balanco?> obterBalancoEmAndamento();
}
