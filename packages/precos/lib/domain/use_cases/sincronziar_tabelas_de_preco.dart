import 'package:core/paginacao/paginacao.dart';
import 'package:precos/models.dart';
import 'package:precos/repositorios.dart';

class SincronziarTabelasDePreco {
  final ITabelasDePrecoRepository tabelasDePrecoRepository;

  SincronziarTabelasDePreco({required this.tabelasDePrecoRepository});

  Stream<Paginacao<TabelaDePreco>> call() async* {
    yield* tabelasDePrecoRepository.syncTabelas();
  }
}
