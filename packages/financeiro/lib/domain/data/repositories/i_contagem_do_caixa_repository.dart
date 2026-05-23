import 'package:financeiro/domain/models/contagem_do_caixa.dart';
import 'package:financeiro/domain/models/contagem_do_caixa_item.dart';

abstract class IContagemDoCaixaRepository {
  Future<ContagemDoCaixa?> recuperarContagemDoCaixa({required int caixaId});

  Future<void> encerrarContagemDoCaixa({required int caixaId});

  Future<ContagemDoCaixa> salvarItemDaContagemDoCaixa({
    required int caixaId,
    required ContagemDoCaixa contagemDoCaixa,
  });

  Future<List<ContagemDoCaixaItem>> recuperarItensPendentesParaContagemDoCaixa({
    required int caixaId,
  });
}
