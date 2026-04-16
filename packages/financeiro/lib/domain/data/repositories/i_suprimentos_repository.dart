import 'package:financeiro/domain/models/suprimento.dart';

abstract class ISuprimentosRepository {
  Future<Suprimento> criarSuprimento({
    required int caixaId,
    required double valor,
    required String descricao,
  });

  Future<List<Suprimento>> recuperarSuprimentos({required int caixaId});

  Future<Suprimento> recuperarSuprimento({
    required int caixaId,
    required int suprimentoId,
  });

  Future<void> cancelarSuprimento({
    required int caixaId,
    required int suprimentoId,
    required String motivo,
  });
}
