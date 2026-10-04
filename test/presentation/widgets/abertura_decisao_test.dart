import 'package:flutter_test/flutter_test.dart';
import 'package:siv_front/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:siv_front/presentation/widgets/abertura_decisao.dart';

void main() {
  test(
    'destino: autenticado vai pra /home (ou a rota de teste), deslogado pra /login',
    () {
      expect(destinoDaAbertura(StatusAutenticacao.autenticado), '/home');
      expect(
        destinoDaAbertura(StatusAutenticacao.autenticado, rotaDeTeste: '/x'),
        '/x',
      );
      expect(destinoDaAbertura(StatusAutenticacao.naoAutenticao), '/login');
      expect(destinoDaAbertura(StatusAutenticacao.falhaInicializacao), isNull);
      expect(destinoDaAbertura(StatusAutenticacao.autenticando), isNull);
    },
  );

  group('segurarCarga', () {
    bool segurar(
      StatusAutenticacao status,
      String? rota, {
      bool veioDaCarga = true,
    }) =>
        segurarCarga(veioDaCarga: veioDaCarga, status: status, rotaAtual: rota);

    test(
      'autenticado: segura enquanto a rota não é /home (a tela de login não aparece)',
      () {
        expect(segurar(StatusAutenticacao.autenticado, '/login'), isTrue);
        expect(segurar(StatusAutenticacao.autenticado, null), isTrue);
        expect(segurar(StatusAutenticacao.autenticado, '/home'), isFalse);
      },
    );

    test('deslogado: solta assim que está em /login', () {
      expect(segurar(StatusAutenticacao.naoAutenticao, '/home'), isTrue);
      expect(segurar(StatusAutenticacao.naoAutenticao, '/login'), isFalse);
    });

    test(
      'não segura sem ter vindo da carga, nem em erro/login em andamento',
      () {
        expect(
          segurar(StatusAutenticacao.autenticado, '/login', veioDaCarga: false),
          isFalse,
        );
        expect(segurar(StatusAutenticacao.falhaInicializacao, null), isFalse);
        expect(segurar(StatusAutenticacao.autenticando, null), isFalse);
      },
    );
  });
}
