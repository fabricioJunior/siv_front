import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/sistema.dart';

void main() {
  test('deve desserializar configuração do sistema', () {
    final configuracao = ConfiguracaoSTMPDto.fromJson({
      'id': 1,
      'servidor': 'smtp.exemplo.com',
      'porta': 587,
      'usuario': 'usuario',
      'senha': 'senha',
      'redefinirSenhaTemplate': {
        'assunto': 'Redefinir senha',
        'corpo': 'Use o link para redefinir sua senha',
      },
    });

    expect(configuracao.id, 1);
    expect(configuracao.servidor, 'smtp.exemplo.com');
    expect(configuracao.porta, 587);
    expect(configuracao.usuario, 'usuario');
    expect(configuracao.senha, 'senha');
    expect(configuracao.redefinirSenhaTemplate.assunto, 'Redefinir senha');
    expect(
      configuracao.redefinirSenhaTemplate.corpo,
      'Use o link para redefinir sua senha',
    );
  });
}
