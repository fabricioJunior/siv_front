import 'package:precos/repositorios.dart';

class DesativarTabelaDePreco {
  final ITabelasDePrecoRepository _tabelasDePrecoRepository;

  DesativarTabelaDePreco({
    required ITabelasDePrecoRepository tabelasDePrecoRepository,
  }) : _tabelasDePrecoRepository = tabelasDePrecoRepository;

  Future<void> call(int id) {
    return _tabelasDePrecoRepository.desativarTabelaDePreco(id);
  }
}
