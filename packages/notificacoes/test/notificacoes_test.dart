import 'dart:async';

import 'package:core/sync.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notificacoes/data/notificacoes_remote_data_source.dart';
import 'package:notificacoes/domain/notificacao.dart';
import 'package:notificacoes/domain/notificacoes_gateway.dart';
import 'package:notificacoes/domain/use_cases.dart';
import 'package:notificacoes/presentation/notificacoes_bloc.dart';

Map<String, dynamic> _json(int id) => {
  'id': id,
  'tipo': 'x',
  'titulo': 't$id',
  'corpo': 'c$id',
  'payload': {'a': 1},
  'criadoEm': '2026-11-09T10:00:00.000Z',
  'lidaEm': null,
};

class _FakeGateway implements NotificacoesGateway {
  List<Notificacao> naoLidas = [];
  final marcadas = <int>[];

  @override
  Future<List<Notificacao>> listarNaoLidas({int page = 1, int limit = 20}) async =>
      naoLidas;
  @override
  Future<int> contarNaoLidas() async => naoLidas.length;
  @override
  Future<void> marcarLida(int id) async => marcadas.add(id);
  @override
  Future<void> marcarTodasLidas() async => naoLidas = [];
}

void main() {
  test('parse de Notificacao', () {
    final n = Notificacao.fromJson(_json(7));
    expect(n.id, 7);
    expect(n.payload, {'a': 1});
    expect(n.lidaEm, isNull);
    expect(n.criadoEm.year, 2026);
  });

  test('parseLista tolera lista simples e data/items', () {
    expect(NotificacoesRemoteDataSource.parseLista([_json(1)]).length, 1);
    expect(NotificacoesRemoteDataSource.parseLista({'data': [_json(1)]}).length, 1);
    expect(NotificacoesRemoteDataSource.parseLista({'items': [_json(1)]}).length, 1);
  });

  group('NotificacoesBloc', () {
    late _FakeGateway gw;
    late StreamController<NotificacaoEvent> novas;
    late StreamController<bool> conectado;
    late List<String> exibidas;
    late NotificacoesBloc bloc;

    NotificacaoEvent evento(int id) => NotificacaoEvent(
      id: id,
      titulo: 't$id',
      corpo: 'c$id',
      json: _json(id),
    );

    setUp(() {
      gw = _FakeGateway();
      novas = StreamController.broadcast();
      conectado = StreamController.broadcast();
      exibidas = [];
      bloc = NotificacoesBloc(
        ListarNotificacoesNaoLidas(gw),
        ContarNotificacoesNaoLidas(gw),
        MarcarNotificacaoLida(gw),
        MarcarTodasNotificacoesLidas(gw),
        ({required titulo, required corpo}) async => exibidas.add(titulo),
        novas: novas.stream,
        conectado: conectado.stream,
        desautenticado: const Stream.empty(),
      );
    });

    tearDown(() async {
      await bloc.close();
      await novas.close();
      await conectado.close();
    });

    Future<void> pump() => Future<void>.delayed(const Duration(milliseconds: 20));

    test('evento novo incrementa contagem, insere no topo e exibe', () async {
      await pump();
      novas.add(evento(1));
      await pump();
      novas.add(evento(2));
      await pump();
      expect(bloc.state.naoLidas, 2);
      expect(bloc.state.lista.map((n) => n.id), [2, 1]);
      expect(exibidas, ['t1', 't2']);
    });

    test('marcar lida remove e decrementa', () async {
      await pump();
      novas.add(evento(1));
      await pump();
      bloc.add(NotificacaoMarcouLida(1));
      await pump();
      expect(bloc.state.naoLidas, 0);
      expect(bloc.state.lista, isEmpty);
      expect(gw.marcadas, [1]);
    });

    test('marcar todas zera', () async {
      await pump();
      novas.add(evento(1));
      await pump();
      bloc.add(NotificacoesMarcouTodasLidas());
      await pump();
      expect(bloc.state.naoLidas, 0);
      expect(bloc.state.lista, isEmpty);
    });

    test('catch-up após reconexão exibe só as ainda não exibidas', () async {
      await pump(); // carga inicial (vazia, silenciosa)
      novas.add(evento(1));
      await pump();
      expect(exibidas, ['t1']);

      gw.naoLidas = [
        Notificacao.fromJson(_json(2)),
        Notificacao.fromJson(_json(1)),
      ];
      conectado.add(true);
      await pump();
      expect(exibidas, ['t1', 't2']);
      expect(bloc.state.naoLidas, 2);

      conectado.add(true);
      await pump();
      expect(exibidas, ['t1', 't2']);
    });
  });
}
