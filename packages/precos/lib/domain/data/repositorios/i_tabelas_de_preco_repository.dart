import 'package:precos/models.dart';

abstract class ITabelasDePrecoRepository {
  Future<TabelaDePreco> criarTabelaDePreco({
    required String nome,
    double? terminador,
  });
  Future<List<TabelaDePreco>> obterTabelasDePreco({
    String? nome,
    bool? inativa,
  });
  Future<TabelaDePreco?> obterTabelaDePreco(int id);
  Future<void> desativarTabelaDePreco(int id);
  Future<TabelaDePreco> atualizarTabelaDePreco({
    required int id,
    required String nome,
    double? terminador,
  });
}
