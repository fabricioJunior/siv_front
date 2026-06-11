import 'package:estoque/domain/data/remote/i_balanco_remote_data_source.dart';
import 'package:estoque/domain/models/balanco.dart';
import 'package:estoque/domain/repositories/i_balanco_repository.dart';

class BalancoRepository implements IBalancoRepository {
  final IBalancoRemoteDataSource remoteDataSource;

  BalancoRepository({required this.remoteDataSource});

  @override
  Future<Balanco> criarBalanco({required String? observacao}) {
    return remoteDataSource.criarBalanco(observacao: observacao);
  }

  @override
  Future<List<Balanco>> listarBalancos({
    required String? situacao,
    required int page,
    required int limit,
  }) {
    return remoteDataSource.listarBalancos(
      situacao: situacao,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<Balanco> obterBalanco({required int balancoId}) {
    return remoteDataSource.obterBalanco(balancoId: balancoId);
  }

  @override
  Future<Balanco> atualizarBalanco({
    required int balancoId,
    required String? observacao,
  }) {
    return remoteDataSource.atualizarBalanco(
      balancoId: balancoId,
      observacao: observacao,
    );
  }

  @override
  Future<Balanco> encerrarBalanco({
    required int balancoId,
    required String? observacao,
  }) {
    return remoteDataSource.encerrarBalanco(
      balancoId: balancoId,
      observacao: observacao,
    );
  }

  @override
  Future<Balanco> cancelarBalanco({
    required int balancoId,
    required String motivo,
  }) {
    return remoteDataSource.cancelarBalanco(
      balancoId: balancoId,
      motivo: motivo,
    );
  }

  @override
  Future<Map<String, dynamic>> obterResumo({required int balancoId}) {
    return remoteDataSource.obterResumo(balancoId: balancoId);
  }

  @override
  Future<BalancoItem> adicionarItem({
    required int balancoId,
    required int produtoId,
  }) {
    return remoteDataSource.adicionarItem(
      balancoId: balancoId,
      produtoId: produtoId,
    );
  }

  @override
  Future<void> adicionarMultiplosItensPorReferencia({
    required int balancoId,
    required List<int> referenciaIds,
  }) {
    return remoteDataSource.adicionarMultiplosItensPorReferencia(
      balancoId: balancoId,
      referenciaIds: referenciaIds,
    );
  }

  @override
  Future<List<BalancoItem>> listarItensDoBalanco({required int balancoId}) {
    return remoteDataSource.listarItensDoBalanco(balancoId: balancoId);
  }

  @override
  Future<void> removerItemDoBalanco({
    required int balancoId,
    required int produtoId,
  }) {
    return remoteDataSource.removerItemDoBalanco(
      balancoId: balancoId,
      produtoId: produtoId,
    );
  }

  @override
  Future<BalancoLote> criarLote({
    required int balancoId,
    required String lote,
    required String? observacao,
  }) {
    return remoteDataSource.criarLote(
      balancoId: balancoId,
      lote: lote,
      observacao: observacao,
    );
  }

  @override
  Future<List<BalancoLote>> listarLotes({required int balancoId}) {
    return remoteDataSource.listarLotes(balancoId: balancoId);
  }

  @override
  Future<BalancoLote> atualizarLote({
    required int balancoId,
    required int loteId,
    required String? lote,
    required String? observacao,
  }) {
    return remoteDataSource.atualizarLote(
      balancoId: balancoId,
      loteId: loteId,
      lote: lote,
      observacao: observacao,
    );
  }

  @override
  Future<BalancoLote> cancelarLote({
    required int balancoId,
    required int loteId,
    required String motivo,
  }) {
    return remoteDataSource.cancelarLote(
      balancoId: balancoId,
      loteId: loteId,
      motivo: motivo,
    );
  }

  @override
  Future<BalancoLoteItem> adicionarItemAoLote({
    required int balancoId,
    required int loteId,
    required int produtoId,
    required double quantidadeContada,
  }) {
    return remoteDataSource.adicionarItemAoLote(
      balancoId: balancoId,
      loteId: loteId,
      produtoId: produtoId,
      quantidadeContada: quantidadeContada,
    );
  }

  @override
  Future<void> adicionarMultiplosItensAoLote({
    required int balancoId,
    required int loteId,
    required List<Map<String, dynamic>> itens,
  }) {
    return remoteDataSource.adicionarMultiplosItensAoLote(
      balancoId: balancoId,
      loteId: loteId,
      itens: itens,
    );
  }

  @override
  Future<List<BalancoLoteItem>> listarItensDoLote({
    required int balancoId,
    required int loteId,
  }) {
    return remoteDataSource.listarItensDoLote(
      balancoId: balancoId,
      loteId: loteId,
    );
  }

  @override
  Future<void> removerItemDoLote({
    required int balancoId,
    required int loteId,
    required int produtoId,
  }) {
    return remoteDataSource.removerItemDoLote(
      balancoId: balancoId,
      loteId: loteId,
      produtoId: produtoId,
    );
  }
}
