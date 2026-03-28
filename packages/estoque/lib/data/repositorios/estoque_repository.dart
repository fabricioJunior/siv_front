import 'package:estoque/domain/data/remote/i_estoque_saldo_remote_data_source.dart';
import 'package:estoque/domain/data/repositorios/i_estoque_repository.dart';
import 'package:estoque/domain/models/filtro_produto_do_estoque.dart';
import 'package:estoque/domain/models/saldo_do_estoque.dart';

class EstoqueRepository implements IEstoqueRepository {
  final IEstoqueSaldoRemoteDataSource estoqueSaldoRemoteDataSource;

  EstoqueRepository({required this.estoqueSaldoRemoteDataSource});

  @override
  Future<SaldoDoEstoque> obterSaldo({required FiltroProdutoDoEstoque filtro}) {
    return estoqueSaldoRemoteDataSource.obterSaldo(filtro: filtro);
  }
}
