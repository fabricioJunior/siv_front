import 'package:core/paginacao/paginacao.dart';
import 'package:estoque/domain/models/filtro_produto_do_estoque.dart';
import 'package:estoque/domain/models/saldo_do_estoque.dart';

abstract class IEstoqueRepository {
  Future<SaldoDoEstoque> obterSaldo({required FiltroProdutoDoEstoque filtro});
  Future<SaldoDoEstoque> sincronizarSaldo({
    required FiltroProdutoDoEstoque filtro,
  });

  Stream<Paginacao> syncEstoque();
}
