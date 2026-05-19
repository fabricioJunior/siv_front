import 'package:autenticacao/domain/models/credenciais_de_autenticacao.dart';

abstract class ICredenciaisDeAutenticacaoRepository {
  Future<void> salvar(CredenciaisDeAutenticacao credenciais);

  Future<CredenciaisDeAutenticacao?> recuperar();

  Future<void> limpar();
}