import 'package:core/services/sync_web_socket_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('interpreta o evento do servidor (tipo e situação em minúsculas)', () {
    final evento = ImportacaoProgressoEvent.fromJson({
      'id': 9,
      'tipo': 'Estoque',
      'situacao': 'Processando',
      'totalRegistros': 100,
      'processados': 40,
      'importados': 38,
      'rejeitados': 2,
      'erro': null,
    });

    expect(evento.id, 9);
    expect(evento.tipo, 'estoque');
    expect(evento.situacao, 'processando');
    expect(
      [
        evento.totalRegistros,
        evento.processados,
        evento.importados,
        evento.rejeitados
      ],
      [100, 40, 38, 2],
    );
    expect(evento.erro, isNull);
  });

  test('campos ausentes viram zero e a mensagem de erro é preservada', () {
    final evento = ImportacaoProgressoEvent.fromJson({
      'id': 3,
      'tipo': 'cliente',
      'situacao': 'falha',
      'erro': 'Cabeçalho CSV inválido',
    });

    expect(evento.totalRegistros, 0);
    expect(evento.processados, 0);
    expect(evento.erro, 'Cabeçalho CSV inválido');
  });
}
