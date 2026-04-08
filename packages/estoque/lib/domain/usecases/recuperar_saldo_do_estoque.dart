import 'package:estoque/domain/data/repositorios/i_estoque_repository.dart';
import 'package:estoque/domain/models/filtro_produto_do_estoque.dart';
import 'package:estoque/domain/models/saldo_do_estoque.dart';

class RecuperarSaldoDoEstoque {
  final IEstoqueRepository _estoqueRepository;

  RecuperarSaldoDoEstoque({required IEstoqueRepository estoqueRepository})
    : _estoqueRepository = estoqueRepository;

  Future<SaldoDoEstoque> call({required FiltroProdutoDoEstoque filtro}) {
    return _estoqueRepository.obterSaldo(filtro: filtro);
  }

  Future<SaldoDoEstoque> sincronizarPagina({
    required FiltroProdutoDoEstoque filtro,
  }) {
    return _estoqueRepository.sincronizarSaldo(filtro: filtro);
  }
}
