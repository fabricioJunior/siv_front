import 'package:precos/models.dart';

abstract class ITabelasDePrecoRemoteDataSource {
  Future<TabelaDePreco> createTabelaDePreco({
    required String nome,
    double? terminador,
  });
  Future<List<TabelaDePreco>> fetchTabelasDePreco({
    String? nome,
    bool? inativa,
  });
  Future<TabelaDePreco?> fetchTabelaDePreco(int id);
  Future<void> desativarTabelaDePreco(int id);
  Future<TabelaDePreco> atualizarTabelaDePreco({
    required int id,
    required String nome,
    double? terminador,
  });
}
