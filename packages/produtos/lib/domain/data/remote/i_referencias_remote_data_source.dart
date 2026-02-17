import 'package:produtos/models.dart';

abstract class IReferenciasRemoteDataSource {
  Future<List<Referencia>> fetchReferencias({String? nome, bool? inativo});
}
