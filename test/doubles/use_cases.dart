import 'package:autenticacao/uses_cases.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  OnAutenticado,
  OnDesautenticado,
  EstaAutenticado,
  Deslogar,
  RecuperarUsuarioDaSessao,
])
void main() {}
