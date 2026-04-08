import 'package:precos/models.dart';

abstract class ITabelasDePrecoLocalDataSource {
  Future<void> salvarTabelaDePreco(TabelaDePreco tabela);
  Future<TabelaDePreco?> obterTabelaDePreco(int id);
  Future<List<TabelaDePreco>> obterTabelasDePreco();
  Future<void> salvarTabelasDePreco(List<TabelaDePreco> tabelas);
  Future<void> limparTabelasDePreco();
}
