import 'dart:typed_data';

import 'package:comercial/data/remote/lista_personalizada_remote_data_source.dart';
import 'package:comercial/domain/models/lista_personalizada.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/http_fake.dart';

void main() {
  late HttpFake http;
  late ListaPersonalizadaRemoteDataSource ds;

  setUp(() {
    http = HttpFake({'id': 3, 'hash': 'h', 'situacao': 'agendada', 'tipo': 'catalogo'});
    ds = ListaPersonalizadaRemoteDataSource(informacoesParaRequest: InfoFake(http));
  });

  test('criar catálogo por filtro monta o JSON do contrato (sem nulos/vazios)', () async {
    final lista = await ds.criar(
      const ListaPersonalizadaInput(
        titulo: ' Novidades ',
        tipo: ListaTipo.catalogo,
        modo: ListaModo.filtro,
        filtro: ListaFiltro(
          categoriaIds: [1],
          subCategoriaIds: [2],
          tamanhoIds: [3],
          corIds: [4],
          estoque: ListaFiltroEstoque(operador: EstoqueOperador.aPartir, quantidade: 5),
          promocaoIds: [5],
        ),
      ),
    );

    expect(http.chamadas, ['POST /v1/listas-personalizadas']);
    expect(http.bodies.single, {
      'tipo': 'catalogo',
      'modo': 'filtro',
      'titulo': 'Novidades',
      'filtro': {
        'categoriaIds': [1],
        'subCategoriaIds': [2],
        'tamanhoIds': [3],
        'corIds': [4],
        'estoque': {'operador': 'a_partir', 'quantidade': 5},
        'promocaoIds': [5],
      },
    });
    expect(lista.situacao, ListaPersonalizadaSituacao.agendada);
    expect(lista.tipo, ListaTipo.catalogo);
  });

  test('atualizar sem prazo/tabela envia null explícito (limpa no backend)', () async {
    await ds.atualizar(3, const ListaPersonalizadaInput(titulo: 'x', tipo: ListaTipo.catalogo));

    expect(http.chamadas, ['PATCH /v1/listas-personalizadas/3']);
    final body = http.bodies.single as Map;
    expect(body.containsKey('dataInicio') && body['dataInicio'] == null, isTrue);
    expect(body.containsKey('dataExpiracao') && body['dataExpiracao'] == null, isTrue);
    expect(body.containsKey('tabelaPrecoId') && body['tabelaPrecoId'] == null, isTrue);
    expect(body.containsKey('filtro') && body['filtro'] == null, isTrue);
  });

  test('adicionar em lote chama /itens/por-filtro com categorias e subcategorias', () async {
    http.resposta = {'adicionadas': 12, 'total': 20};

    final r = await ds.adicionarPorFiltro(
      3,
      const ListaItensLote(categoriaIds: [1], subCategoriaIds: [2], apenasPublicadasNoEcommerce: true),
    );

    expect(http.chamadas, ['POST /v1/listas-personalizadas/3/itens/por-filtro']);
    expect(http.bodies.single, {
      'categoriaIds': [1],
      'subCategoriaIds': [2],
      'apenasPublicadasNoEcommerce': true,
    });
    expect((r.adicionadas, r.total), (12, 20));
  });

  test('listar filtra por tipo; ícone vai por multipart; prévia pagina', () async {
    http.resposta = {
      'items': [],
      'meta': {
        'totalItems': 0,
        'itemCount': 0,
        'itemsPerPage': 20,
        'totalPages': 0,
        'currentPage': 1,
      },
    };
    await ds.listar(tipo: ListaTipo.catalogo);
    await ds.previa(3, page: 2);
    http.resposta = {'id': 3, 'icone': 'https://x/i.png'};
    final lista = await ds.enviarIcone(3, Uint8List(2), 'i.png');

    expect(http.chamadas, [
      'GET /v1/listas-personalizadas?page=1&limit=20&tipo=catalogo',
      'GET /v1/listas-personalizadas/3/previa?page=2&limit=20',
      'POST(multipart) /v1/listas-personalizadas/3/icone',
    ]);
    expect(lista.icone, 'https://x/i.png');
  });

  test('backend antigo (sem campos novos): defaults seguros', () async {
    http.resposta = {
      'id': 1,
      'hash': 'h',
      'tabelaPrecoId': 2,
      'dataExpiracao': '2030-01-01T00:00:00.000Z',
      'situacao': 'ativa',
    };
    final l = await ds.buscarPorId(1);

    expect(l.tipo, ListaTipo.provador);
    expect(l.modo, ListaModo.manual);
    expect(l.dataInicio, isNull);
    expect(l.filtro, isNull);
    expect(l.tabelaPrecoId, 2);
  });
}
