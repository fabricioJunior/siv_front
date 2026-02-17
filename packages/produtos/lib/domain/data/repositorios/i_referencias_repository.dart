import 'package:produtos/models.dart';

abstract class IReferenciasRepository {
  Future<List<Referencia>> obterReferencias({String? nome, bool? inativo});
}
