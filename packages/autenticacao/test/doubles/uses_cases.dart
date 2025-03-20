import 'package:autenticacao/domain/usecases/criar_token_de_autenticacao.dart';
import 'package:autenticacao/domain/usecases/recuperar_usuario.dart';
import 'package:autenticacao/domain/usecases/recuperar_usuarios.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  CriarTokenDeAutenticacao,
  RecuperarUsuarios,
  RecuperarUsuario,
])
void main() {}
