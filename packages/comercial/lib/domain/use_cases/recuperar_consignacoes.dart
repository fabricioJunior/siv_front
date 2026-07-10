import 'package:comercial/domain/data/repositories/i_consignacoes_repository.dart';
import 'package:comercial/models.dart';

class RecuperarConsignacoes {
  final IConsignacoesRepository repository;

  RecuperarConsignacoes({required this.repository});

  Future<List<Consignacao>> call({
    List<int>? empresaIds,
    List<int>? pessoaIds,
    List<int>? funcionarioIds,
    List<SituacaoConsignacao>? situacoes,
    bool incluirItens = false,
  }) {
    return repository.buscarPorFiltro(
      empresaIds: empresaIds,
      pessoaIds: pessoaIds,
      funcionarioIds: funcionarioIds,
      situacoes: situacoes,
      incluirItens: incluirItens,
    );
  }
}
