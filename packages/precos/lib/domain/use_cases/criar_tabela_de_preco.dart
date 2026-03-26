import 'package:precos/models.dart';
import 'package:precos/repositorios.dart';

class CriarTabelaDePreco {
  final ITabelasDePrecoRepository _tabelasDePrecoRepository;

  CriarTabelaDePreco({
    required ITabelasDePrecoRepository tabelasDePrecoRepository,
  }) : _tabelasDePrecoRepository = tabelasDePrecoRepository;

  Future<TabelaDePreco> call({
    required String nome,
    double? terminador,
  }) {
    return _tabelasDePrecoRepository.criarTabelaDePreco(
      nome: nome,
      terminador: terminador,
    );
  }
}
