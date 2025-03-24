import 'package:autenticacao/domain/usecases/criar_token_de_autenticacao.dart';
import 'package:autenticacao/domain/usecases/recuperar_usuario.dart';
import 'package:autenticacao/domain/usecases/recuperar_usuarios.dart';
import 'package:autenticacao/uses_cases.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  CriarTokenDeAutenticacao,
  RecuperarUsuario,
  SalvarUsuario,
  RecuperarUsuarios,
  RecuperarUsuarioDaSessao,
])
void main() {}
