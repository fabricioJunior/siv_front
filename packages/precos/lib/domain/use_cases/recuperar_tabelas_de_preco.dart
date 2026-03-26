import 'package:precos/models.dart';
import 'package:precos/repositorios.dart';

class RecuperarTabelasDePreco {
  final ITabelasDePrecoRepository _tabelasDePrecoRepository;

  RecuperarTabelasDePreco({
    required ITabelasDePrecoRepository tabelasDePrecoRepository,
  }) : _tabelasDePrecoRepository = tabelasDePrecoRepository;

  Future<List<TabelaDePreco>> call({String? nome, bool? inativa}) async {
    final tabelas = await _tabelasDePrecoRepository.obterTabelasDePreco(
      nome: nome,
      inativa: inativa,
    );
    tabelas.sort(
      (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
    );
    return tabelas;
  }
}
