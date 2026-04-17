import 'package:financeiro/domain/models/contagem_do_caixa.dart';

abstract class IContagemDoCaixaRemoteDataSource {
  Future<ContagemDoCaixa?> recuperarContagemDoCaixa({required int caixaId});

  Future<void> salvarItemDaContagemDoCaixa({
    required int caixaId,
    required ContagemDoCaixa contagemDoCaixa,
  });
}
