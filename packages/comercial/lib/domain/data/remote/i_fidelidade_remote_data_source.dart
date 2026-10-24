import 'package:comercial/domain/models/opcoes_resgate_pontos.dart';

abstract class IFidelidadeRemoteDataSource {
  Future<bool> verificarElegibilidade({required int pessoaId});

  Future<OpcoesResgatePontos> recuperarOpcoesResgate({required int pessoaId});
}
