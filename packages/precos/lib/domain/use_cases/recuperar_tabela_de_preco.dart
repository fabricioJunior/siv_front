import 'package:precos/models.dart';
import 'package:precos/repositorios.dart';

class RecuperarTabelaDePreco {
  final ITabelasDePrecoRepository _tabelasDePrecoRepository;

  RecuperarTabelaDePreco({
    required ITabelasDePrecoRepository tabelasDePrecoRepository,
  }) : _tabelasDePrecoRepository = tabelasDePrecoRepository;

  Future<TabelaDePreco?> call(int id) {
    return _tabelasDePrecoRepository.obterTabelaDePreco(id);
  }
}
