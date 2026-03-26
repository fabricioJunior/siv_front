import 'package:precos/models.dart';
import 'package:precos/repositorios.dart';

class AtualizarTabelaDePreco {
  final ITabelasDePrecoRepository _tabelasDePrecoRepository;

  AtualizarTabelaDePreco({
    required ITabelasDePrecoRepository tabelasDePrecoRepository,
  }) : _tabelasDePrecoRepository = tabelasDePrecoRepository;

  Future<TabelaDePreco> call({
    required int id,
    required String nome,
    double? terminador,
  }) {
    return _tabelasDePrecoRepository.atualizarTabelaDePreco(
      id: id,
      nome: nome,
      terminador: terminador,
    );
  }
}
