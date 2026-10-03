import 'package:autenticacao/domain/models/licenciado.dart';
import 'package:autenticacao/presentation/bloc/login_bloc/login_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const a = Licenciado(id: '1', nome: 'Flor', urlApi: 'https://a');
  const b = Licenciado(id: '2', nome: 'Outra Loja', urlApi: 'https://b');
  const todos = [a, b];

  test('acha por id ou por nome (sem diferenciar maiúsculas)', () {
    expect(licenciadoDaUrl(todos, Uri.parse('https://x/?licenciado=2')), b);
    expect(
      licenciadoDaUrl(todos, Uri.parse('https://x/?licenciado=outra%20LOJA')),
      b,
    );
  });

  test('aceita o parâmetro depois do # (hash routing)', () {
    expect(
      licenciadoDaUrl(todos, Uri.parse('https://x/#/login?licenciado=1')),
      a,
    );
  });

  test('sem parâmetro ou licenciado inexistente devolve null', () {
    expect(licenciadoDaUrl(todos, Uri.parse('https://x/')), isNull);
    expect(
        licenciadoDaUrl(todos, Uri.parse('https://x/?licenciado=9')), isNull);
    expect(licenciadoDaUrl(todos, Uri.parse('https://x/?licenciado=')), isNull);
  });
}
