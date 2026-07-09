import 'package:core/produtos_compartilhados.dart';

import '../data/repositories/i_orcamento_repository.dart';
import '../models/orcamento_local.dart';

class CarregarOrcamento {
  final IOrcamentoRepository _repository;

  CarregarOrcamento({required IOrcamentoRepository repository})
      : _repository = repository;

  Future<OrcamentoLocal?> call(String hash) async {
    final orcamento = await _repository.recuperar(hash);
    if (orcamento == null) return null;

    final itensAjustados = <ProdutoCompartilhado>[];

    for (final item in orcamento.itens) {
      final estoqueDisponivel = await _repository.obterEstoqueDisponivel(
        produtoId: item.produtoId,
        tabelaPrecoId: orcamento.tabelaPrecoId,
      );

      if (estoqueDisponivel == null || estoqueDisponivel <= 0) {
        continue;
      }

      itensAjustados.add(
        estoqueDisponivel < item.quantidade
            ? item.copyWith(quantidade: estoqueDisponivel)
            : item,
      );
    }

    return orcamento.copyWith(itens: itensAjustados);
  }
}
