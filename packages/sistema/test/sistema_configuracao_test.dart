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
      'urlVerificacaoEmail': 'https://exemplo.com/verificar',
      'verificacaoEmailTemplate': {
        'assunto': 'Verifique seu cadastro',
        'corpo': 'Use o link para verificar seu cadastro',
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
    expect(configuracao.urlVerificacaoEmail, 'https://exemplo.com/verificar');
    expect(
      configuracao.verificacaoEmailTemplate?.assunto,
      'Verifique seu cadastro',
    );
    expect(
      configuracao.verificacaoEmailTemplate?.corpo,
      'Use o link para verificar seu cadastro',
    );
  });

  test(
      'deve desserializar configuração sem urlVerificacaoEmail/verificacaoEmailTemplate '
      '(config antiga, campo nunca preenchido)', () {
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
      'urlVerificacaoEmail': null,
      'verificacaoEmailTemplate': null,
    });

    expect(configuracao.urlVerificacaoEmail, isNull);
    expect(configuracao.verificacaoEmailTemplate, isNull);
  });
}
