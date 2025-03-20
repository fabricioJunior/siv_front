import 'package:autenticacao/domain/usecases/criar_token_de_autenticacao.dart';
import 'package:autenticacao/uses_cases.dart';
import 'package:core/injecoes.dart';

abstract class AutenticacaoUtils {
  static Future<void> reiniciarAutenticacao() async {
    return sl<Deslogar>().call();
  }

  static Future<void> logarComUsuarioDeTeste() async {
    await sl<CriarTokenDeAutenticacao>().call(
      usuario: 'apollo',
      senha: 'start',
    );
  }
}
