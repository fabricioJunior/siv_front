import 'package:promocoes/domain/models/cupom.dart';

abstract class ICuponsRemoteDataSource {
  Future<List<Cupom>> recuperarCupons({
    String? codigo,
    bool? ativa,
    bool? vigente,
  });

  Future<Cupom?> recuperarCupom(int id);

  Future<Cupom> criarCupom(Cupom cupom);

  Future<Cupom> atualizarCupom(Cupom cupom);
}
