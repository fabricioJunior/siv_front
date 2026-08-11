import 'package:empresas/domain/entities/terminal.dart';

abstract class ITerminaisRemoteDataSource {
  Future<List<Terminal>> recuperarTerminais({
    required int empresaId,
    String? nome,
    bool? inativo,
  });

  Future<Terminal?> recuperarTerminal({
    required int empresaId,
    required int id,
  });

  Future<Terminal> criarTerminal({
    required int empresaId,
    required String nome,
    String tipo = 'fisico',
  });

  Future<Terminal> atualizarTerminal({
    required int empresaId,
    required int id,
    required String nome,
    String tipo = 'fisico',
  });

  Future<void> desativarTerminal({required int empresaId, required int id});
}
