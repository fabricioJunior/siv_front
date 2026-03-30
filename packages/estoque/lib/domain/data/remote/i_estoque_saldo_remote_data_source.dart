import 'package:estoque/models.dart';

abstract class IEstoqueSaldoRemoteDataSource {
  Future<SaldoDoEstoque> obterSaldo({required FiltroProdutoDoEstoque filtro});
}
