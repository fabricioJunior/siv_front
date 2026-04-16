import 'package:financeiro/domain/models/suprimento.dart';

abstract class ISuprimentosRemoteDataSource {
  Future<Suprimento> criarSuprimento({
    required int caixaId,
    required double valor,
    required String descricao,
  });

  Future<List<Suprimento>> recuperarSuprimentos({required int caixaId});

  Future<Suprimento> recuperarSuprimento({
    required int suprimentoId,
    required int caixaId,
  });

  Future<void> cancelarSuprimento({
    required int suprimentoId,
    required int caixaId,
    required String motivo,
  });
}
