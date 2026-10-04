import 'package:comercial/domain/data/remote/i_pedido_entrada_remote_data_source.dart';
import 'package:comercial/domain/models/pedido_entrada.dart';

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

  Future<EntradaResumo> call(int pedidoId, List<ItemContagem> itens) =>
      _remote.registrarContagem(pedidoId, itens);
}
