import 'package:core/paginacao/paginacao.dart';
import 'package:precos/models.dart';
import 'package:precos/repositorios.dart';

class SincronizarPrecos {
  final IPrecosDeReferenciasRepository precosDeReferenciasRepository;

  SincronizarPrecos({required this.precosDeReferenciasRepository});

  Stream<Paginacao<PrecoDaReferencia>> call() async* {
    yield* precosDeReferenciasRepository.syncPrecosDasReferencias();
  }
}
