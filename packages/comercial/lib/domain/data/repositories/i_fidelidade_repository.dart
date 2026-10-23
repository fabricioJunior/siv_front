import 'package:comercial/domain/models/opcoes_resgate_pontos.dart';

abstract class IFidelidadeRepository {
  Future<bool> verificarElegibilidade({required int pessoaId});

  Future<OpcoesResgatePontos> recuperarOpcoesResgate({required int pessoaId});
}
