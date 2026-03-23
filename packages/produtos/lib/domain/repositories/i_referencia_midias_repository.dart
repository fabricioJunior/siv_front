import '../models/referencia_midia.dart';
import 'dart:io';

abstract class IReferenciaMidiasRepository {
  Future<List<ReferenciaMidia>> carregarMidias(int referenciaId);
  Future<void> adicionarMidias(
    int referenciaId,
    List<dynamic> midias,
  ); // dynamic para aceitar ReferenciaMidiaUpload
  Future<void> removerMidia(int referenciaId, int midiaId);
}
