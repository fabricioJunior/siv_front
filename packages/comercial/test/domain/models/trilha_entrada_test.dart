import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/domain/models/trilha_entrada.dart';
import 'package:flutter_test/flutter_test.dart';

// Estado do mock "entrada 4821" (handoff): 7 contagens + 3 livres.
Map<String, dynamic> _base({
  bool livres = true,
  Map<String, dynamic> extra = const {},
}) =>
    {
      'pedidoId': 4821,
      'origemEntrada': 'CONTAGEM',
      'nfe': null,
      'linhas': [],
      'contagens': [
        {'produtoId': 9001, 'quantidade': 6, 'referenciaId': 41288, 'referenciaNome': 'Sutiã Renda Liz', 'corNome': 'Preto', 'tamanhoNome': '42'},
        {'produtoId': 9003, 'quantidade': 4, 'referenciaId': 41288, 'referenciaNome': 'Sutiã Renda Liz', 'corNome': 'Branco', 'tamanhoNome': '42'},
      ],
      'contagensLivres': livres
          ? [
              {'id': 77, 'descricao': 'Body rendado vinho', 'corId': 5, 'tamanhoId': 202, 'quantidade': 3},
              {'id': 78, 'descricao': 'Body rendado vinho', 'corId': 5, 'tamanhoId': 203, 'quantidade': 2},
              {'id': 79, 'descricao': 'Camisola cetim champagne', 'corId': 6, 'tamanhoId': 201, 'quantidade': 4},
            ]
          : [],
      'totais': {'nfe': 0, 'contado': 56},
      'pendencias': [],
      ...extra,
    };

EntradaResumo _r(Map<String, dynamic> j) => EntradaResumo.fromJson(j);

void main() {
  test('sem nada contado: etapa Contar', () {
    final r = _r({..._base(), 'contagens': [], 'contagensLivres': []});
    expect(TrilhaEntrada.etapaAtual(r), 0);
    final t = TrilhaEntrada.trilha(r, passo: 0);
    expect(t.first.status, StatusPasso.ativo);
    expect(t.first.subtitulo, 'nada contado');
  });

  test('com contagem livre: Associar ativo e Etiquetas bloqueada', () {
    final r = _r(_base());
    expect(TrilhaEntrada.etapaAtual(r), 1);
    expect(TrilhaEntrada.etiquetasBloqueadas(r), isTrue);
    final t = TrilhaEntrada.trilha(r, passo: 1);
    expect(t[0].status, StatusPasso.concluido);
    expect(t[0].subtitulo, '56 peças · 3 produtos');
    expect(t[1].status, StatusPasso.ativo);
    expect(t[1].subtitulo, '2 sem referência');
    expect(t[2].subtitulo, 'após associar');
    expect(t[2].status, StatusPasso.futuro);
  });

  test('tudo associado, sem etiquetas: Etiquetas', () {
    final r = _r(_base(livres: false));
    expect(TrilhaEntrada.etapaAtual(r), 2);
    expect(TrilhaEntrada.etiquetasBloqueadas(r), isFalse);
    expect(TrilhaEntrada.trilha(r, passo: 2)[2].subtitulo, '56 a imprimir');
  });

  test('etapa do servidor manda quando existe', () {
    final r = _r(_base(livres: false, extra: {
      'etapa': 'conferindo',
      'etiquetas': {'impressasEm': '2026-10-08T09:31:00-03:00', 'puladas': false, 'impressasPorProduto': {'9001': 6, '9003': 4}},
      'conferencia': {'totalContado': 56, 'totalLido': 25, 'itens': [
        {'produtoId': 9001, 'contado': 6, 'lido': 6, 'situacao': 'conferido'},
        {'produtoId': 9003, 'contado': 4, 'lido': 1, 'situacao': 'parcial'},
      ]},
    }));
    expect(TrilhaEntrada.etapaAtual(r), 3);
    final t = TrilhaEntrada.trilha(r, passo: 3);
    expect(t[2].status, StatusPasso.concluido);
    expect(t[3].status, StatusPasso.ativo);
    expect(t[3].subtitulo, '25 de 56 peças');
  });

  test('diferença de etiquetas após editar a contagem', () {
    final r = _r(_base(livres: false, extra: {
      'etiquetas': {'impressasEm': '2026-10-08T09:31:00-03:00', 'impressasPorProduto': {'9001': 6, '9003': 6, '9999': 2}},
    }));
    final d = TrilhaEntrada.diffEtiquetas(r);
    expect(d.imprimir, isEmpty);
    expect(d.descartar.map((e) => (e.produtoId, e.quantidade)),
        [(9003, 2.0), (9999, 2.0)]);

    final r2 = _r(_base(livres: false, extra: {
      'etiquetas': {'impressasEm': '2026-10-08T09:31:00-03:00', 'impressasPorProduto': {'9001': 5}},
    }));
    final d2 = TrilhaEntrada.diffEtiquetas(r2);
    expect(d2.imprimir.map((e) => (e.produtoId, e.quantidade)),
        [(9001, 1.0), (9003, 4.0)]);
    expect(TrilhaEntrada.trilha(r2, passo: 0)[2].subtitulo,
        '+5 a imprimir · 0 a descartar');
  });

  test('revisão: divergência sem decisão bloqueia faturar e vira atenção', () {
    final r = _r(_base(livres: false, extra: {
      'etapa': 'conferindo',
      'etiquetas': {'puladas': true},
      'divergencias': [
        {'produtoId': 9011, 'descricao': 'X', 'grade': 'P', 'contado': 12, 'lido': 11, 'tipo': 'falta', 'decisao': 'manter', 'observacao': 'a menos'},
        {'produtoId': 9021, 'descricao': 'Y', 'grade': 'P', 'contado': 5, 'lido': 6, 'tipo': 'excede', 'decisao': null},
      ],
    }));
    expect(TrilhaEntrada.divergenciasSemDecisao(r), 1);
    expect(TrilhaEntrada.podeFaturar(r), isFalse);
    final t = TrilhaEntrada.trilha(r, passo: 4);
    expect(t[3].status, StatusPasso.atencao);
    expect(t[3].subtitulo, '1 itens a decidir');
    expect(t[4].status, StatusPasso.ativo);
  });

  test('faturado: todos os passos concluídos', () {
    final r = _r(_base(livres: false, extra: {'etapa': 'faturado', 'etiquetas': {'puladas': true}}));
    final t = TrilhaEntrada.trilha(r, passo: 4);
    expect(t[4].subtitulo, 'faturado');
    expect(t.take(4).every((p) => p.status == StatusPasso.concluido), isTrue);
  });

  test('variações novas: Associar ativo com subtítulo próprio', () {
    final r = _r(_base(extra: {
      'contagensLivres': [
        {'id': 1, 'descricao': 'X', 'corId': 1, 'tamanhoId': 2, 'quantidade': 2, 'referenciaId': 7, 'referenciaNome': 'X'},
        {'id': 2, 'descricao': 'X', 'corId': 1, 'tamanhoId': 3, 'quantidade': 1, 'referenciaId': 7, 'referenciaNome': 'X'},
      ],
    }));
    expect(r.variacoesNovas, hasLength(2));
    expect(r.livresSemReferencia, isEmpty);
    expect(TrilhaEntrada.etapaAtual(r), 1);
    expect(TrilhaEntrada.etiquetasBloqueadas(r), isTrue);
    expect(TrilhaEntrada.trilha(r, passo: 1)[1].subtitulo, '2 variações a cadastrar');
  });

  test('ContagemLivre tolera backend sem referenciaId', () {
    final c = ContagemLivre.fromJson(
        {'id': 1, 'descricao': 'X', 'corId': 1, 'tamanhoId': 2, 'quantidade': 1});
    expect(c.referenciaId, isNull);
    expect(c.ehVariacaoNova, isFalse);
    final v = ContagemLivre.fromJson({
      'id': 2, 'descricao': 'Y', 'corId': 1, 'tamanhoId': 2, 'quantidade': 1,
      'referenciaId': 9, 'referenciaNome': 'Y'
    });
    expect(v.ehVariacaoNova, isTrue);
    expect(v.referenciaNome, 'Y');
  });
}
