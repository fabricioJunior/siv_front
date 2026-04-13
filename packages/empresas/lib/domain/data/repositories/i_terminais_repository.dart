import 'package:empresas/domain/entities/terminal.dart';

abstract class ITerminaisRepository {
  Future<Terminal> criarTerminal({
    required int empresaId,
    required String nome,
  });

  Future<List<Terminal>> recuperarTerminais({
    required int empresaId,
    String? nome,
    bool? inativo,
  });

  Future<Terminal?> recuperarTerminal({
    required int empresaId,
    required int id,
  });

  Future<Terminal> atualizarTerminal({
    required int empresaId,
    required int id,
    required String nome,
  });

  Future<void> desativarTerminal({required int empresaId, required int id});
}
