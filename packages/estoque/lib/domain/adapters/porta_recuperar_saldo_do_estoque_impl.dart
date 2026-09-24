import 'package:core/estoque_portas.dart';
import 'package:estoque/domain/models/filtro_produto_do_estoque.dart';
import 'package:estoque/domain/usecases/recuperar_saldo_do_estoque.dart';

class PortaRecuperarSaldoDoEstoqueImpl implements PortaRecuperarSaldoDoEstoque {
  final RecuperarSaldoDoEstoque _recuperarSaldoDoEstoque;

  PortaRecuperarSaldoDoEstoqueImpl(this._recuperarSaldoDoEstoque);

  @override
  Future<List<SaldoPorCorETamanho>> sincronizarPorReferencia({
    required int referenciaId,
    int limit = 10000,
  }) async {
    final saldo = await _recuperarSaldoDoEstoque.sincronizarPagina(
      filtro: FiltroProdutoDoEstoque(
        referenciaIds: [referenciaId],
        limit: limit,
      ),
    );
    return saldo.items
        .map(
          (item) => SaldoPorCorETamanho(
            corId: item.corId,
            tamanhoId: item.tamanhoId,
            saldo: item.saldo,
          ),
        )
        .toList(growable: false);
  }
}
