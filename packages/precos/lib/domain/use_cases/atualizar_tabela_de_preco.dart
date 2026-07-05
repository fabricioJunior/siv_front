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
    bool? padrao,
  }) {
    return _tabelasDePrecoRepository.atualizarTabelaDePreco(
      id: id,
      nome: nome,
      terminador: terminador,
      padrao: padrao,
    );
  }
}
