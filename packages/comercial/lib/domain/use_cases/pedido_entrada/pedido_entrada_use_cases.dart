import 'package:comercial/domain/data/remote/i_pedido_entrada_remote_data_source.dart';
import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/domain/use_cases/conferir_pedido.dart';
import 'package:comercial/domain/use_cases/faturar_pedido.dart';

// Casos de uso do Pedido de Entrada (NF-e / contagem): finos, só delegam à API.
// O estoque NÃO muda aqui -- só no faturamento do pedido (fluxo de sempre).

class ImportarNfeEntrada {
  final IPedidoEntradaRemoteDataSource _remote;
  ImportarNfeEntrada(this._remote);

  Future<EntradaResumo> call({
    required String filePath,
    required int tabelaPrecoId,
  }) =>
      _remote.importarNfe(filePath: filePath, tabelaPrecoId: tabelaPrecoId);
}

class CriarEntradaPorContagem {
  final IPedidoEntradaRemoteDataSource _remote;
  CriarEntradaPorContagem(this._remote);

  Future<EntradaResumo> call({
    required int pessoaId,
    required int tabelaPrecoId,
    int? funcionarioId,
    String? observacao,
  }) =>
      _remote.criarPorContagem(
        pessoaId: pessoaId,
        tabelaPrecoId: tabelaPrecoId,
        funcionarioId: funcionarioId,
        observacao: observacao,
      );
}

class ObterPedidoEntrada {
  final IPedidoEntradaRemoteDataSource _remote;
  ObterPedidoEntrada(this._remote);

  Future<EntradaResumo> call(int pedidoId) => _remote.obter(pedidoId);
}

class VincularLinhaEntrada {
  final IPedidoEntradaRemoteDataSource _remote;
  VincularLinhaEntrada(this._remote);

  Future<EntradaResumo> call(int pedidoId, int linhaId, int referenciaId) =>
      _remote.vincularReferencia(pedidoId, linhaId, referenciaId);
}

class PreCadastrarLinhaEntrada {
  final IPedidoEntradaRemoteDataSource _remote;
  PreCadastrarLinhaEntrada(this._remote);

  Future<EntradaResumo> call(
    int pedidoId,
    int linhaId, {
    required int categoriaId,
    String? nome,
  }) =>
      _remote.preCadastrar(
        pedidoId,
        linhaId,
        categoriaId: categoriaId,
        nome: nome,
      );
}

class IgnorarLinhaEntrada {
  final IPedidoEntradaRemoteDataSource _remote;
  IgnorarLinhaEntrada(this._remote);

  Future<EntradaResumo> call(int pedidoId, int linhaId, bool ignorar) =>
      _remote.ignorar(pedidoId, linhaId, ignorar);
}

class ResolverDivergenciaEntrada {
  final IPedidoEntradaRemoteDataSource _remote;
  ResolverDivergenciaEntrada(this._remote);

  Future<EntradaResumo> call(int pedidoId, int linhaId, String? observacao) =>
      _remote.resolverDivergencia(pedidoId, linhaId, observacao);
}

class RegistrarContagemEntrada {
  final IPedidoEntradaRemoteDataSource _remote;
  RegistrarContagemEntrada(this._remote);

  Future<EntradaResumo> call(
    int pedidoId,
    List<ItemContagem> itens, {
    String? origem,
    String? motivo,
  }) =>
      _remote.registrarContagem(pedidoId, itens, origem: origem, motivo: motivo);
}

class RegistrarContagemLivreEntrada {
  final IPedidoEntradaRemoteDataSource _remote;
  RegistrarContagemLivreEntrada(this._remote);

  Future<EntradaResumo> call(int pedidoId, List<ItemContagem> itens) =>
      _remote.registrarContagemLivre(pedidoId, itens);
}

class AssociarContagemLivreEntrada {
  final IPedidoEntradaRemoteDataSource _remote;
  AssociarContagemLivreEntrada(this._remote);

  Future<EntradaResumo> call(
    int pedidoId,
    List<int> ids, {
    int? referenciaId,
    int? categoriaId,
    String? nome,
  }) =>
      _remote.associarContagemLivre(
        pedidoId,
        ids,
        referenciaId: referenciaId,
        categoriaId: categoriaId,
        nome: nome,
      );
}

class CorrigirContagemEntrada {
  final IPedidoEntradaRemoteDataSource _remote;
  CorrigirContagemEntrada(this._remote);

  Future<EntradaResumo> call(
    int pedidoId,
    int produtoId,
    double para, {
    String? motivo,
    required String origem,
  }) =>
      _remote.corrigirContagem(
        pedidoId,
        produtoId,
        para,
        motivo: motivo,
        origem: origem,
      );
}

class DecidirDivergenciaEntrada {
  final IPedidoEntradaRemoteDataSource _remote;
  DecidirDivergenciaEntrada(this._remote);

  Future<EntradaResumo> call(
    int pedidoId,
    int produtoId,
    AcaoDivergencia acao, {
    String? observacao,
  }) =>
      _remote.decidirDivergencia(
        pedidoId,
        produtoId,
        acao,
        observacao: observacao,
      );
}

class RegistrarEtiquetasEntrada {
  final IPedidoEntradaRemoteDataSource _remote;
  RegistrarEtiquetasEntrada(this._remote);

  Future<EntradaResumo> call(
    int pedidoId, {
    Map<int, double>? itens,
    bool pular = false,
  }) =>
      _remote.registrarEtiquetas(pedidoId, itens: itens, pular: pular);
}

/// Faturar a entrada: marca a conferência (as divergências já têm decisão) e
/// fatura. Só o atendido (conferido) entra no estoque -- regra do servidor.
class FaturarEntrada {
  final ConferirPedido _conferir;
  final FaturarPedido _faturar;
  FaturarEntrada(this._conferir, this._faturar);

  Future<void> call(int pedidoId, {required int caixaId}) async {
    await _conferir(pedidoId, processarComDivergencia: true);
    await _faturar(pedidoId, caixaId: caixaId);
  }
}

class RegistrarLeiturasEntrada {
  final IPedidoEntradaRemoteDataSource _remote;
  RegistrarLeiturasEntrada(this._remote);

  Future<EntradaResumo> call(int pedidoId, Map<int, int> deltas) =>
      _remote.registrarLeituras(pedidoId, deltas);
}
