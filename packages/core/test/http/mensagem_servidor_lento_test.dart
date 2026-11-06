import 'package:core/http/remote_data_source_base.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('502/503/504 viram o aviso de servidor lento, outros usam a mensagem da API', () {
    for (final status in [502, 503, 504]) {
      final erro = HttpException('x', statusCode: status, apiMessage: '<html>');
      expect(mensagemDeErroApi(erro, 'fallback'), mensagemServidorLento);
    }
    final erro400 = HttpException('x', statusCode: 400, apiMessage: 'Estoque insuficiente');
    expect(mensagemDeErroApi(erro400, 'fallback'), 'Estoque insuficiente');
    expect(mensagemDeErroApi(erro400.statusCode, 'fallback'), 'fallback');
  });
}
