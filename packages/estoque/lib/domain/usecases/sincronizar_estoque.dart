import 'package:core/paginacao.dart';
import 'package:estoque/estoque.dart';

class SincronizarEstoque {
  final IEstoqueRepository _estoqueRepository;

  SincronizarEstoque({required IEstoqueRepository estoqueRepository})
    : _estoqueRepository = estoqueRepository;

  Stream<Paginacao> call() async* {
    yield* _estoqueRepository.syncEstoque();
  }
}
