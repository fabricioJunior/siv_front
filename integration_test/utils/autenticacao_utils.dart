import 'package:autenticacao/domain/usecases/criar_token_de_autenticacao.dart';
import 'package:autenticacao/uses_cases.dart';
import 'package:core/injecoes.dart';
import 'package:siv_front/infra/local_data_sourcers/dtos/empresa_dto.dart';

abstract class AutenticacaoUtils {
  static Future<void> reiniciarAutenticacao() async {
    return sl<Deslogar>().call();
  }

  static Future<void> logarComUsuarioDeTeste() async {
    await sl<CriarTokenDeAutenticacao>().call(
      usuario: 'apollo',
      senha: 'start',
      empresa: EmpresaDto(
        id: 1,
        nome: 'Vale do Ceara',
      ),
    );
  }
}
