import 'package:mockito/annotations.dart';
import 'package:pessoas/uses_cases.dart';

@GenerateMocks([
  CriarPessoa,
  RecuperarPessoaPeloDocumento,
  RecuperarPessoas,
  RecuperarPessoa,
  SalvarPessoa,
])
void main() {}
