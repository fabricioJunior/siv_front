import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/presentation/pagamento/indicador_promocao.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promocoes/models.dart';

const _pix = 1;
const _cartao = 2;

SelectData _forma(int id, String nome) =>
    SelectData(id: id, nome: nome, data: const {});

PagamentoRealizadoLinha _linha(int? formaId) => PagamentoRealizadoLinha(
      id: '$formaId',
      formaDePagamento: formaId == null
          ? null
          : _forma(formaId, formaId == _pix ? 'Pix' : 'Cartão'),
      valorTexto: '',
      parcelasTexto: '1',
    );

const _produto = ProdutoCompartilhado(
  hash: 'h',
  produtoId: 1,
  hashLista: 'l',
  quantidade: 2,
  valorUnitario: 100,
  nome: 'Calça',
  corNome: '',
  tamanhoNome: '',
);

const _promoPix = OpcaoElegivel(
  tipo: 'promocao',
  id: 7,
  nome: 'DESCONTO PIX - 10%',
  valorDesconto: 10,
  valorFinalUnitario: 90,
  formasPagamentoPermitidasIds: [_pix],
);

const _promoLivre = OpcaoElegivel(
  tipo: 'promocao',
  id: 8,
  nome: 'Livre',
  valorDesconto: 10,
  valorFinalUnitario: 90,
);

PagamentosRealizadosState _state(OpcaoElegivel promo, List<int?> formas) =>
    PagamentosRealizadosState(
      resumo: const PagamentosRealizadosResumo(
        listaCompartilhada: null,
        produtosCompartilhados: [_produto],
        quantidadeTotalProdutos: 2,
        valorTotalProdutos: 200,
      ),
      formasDePagamento: [_forma(_pix, 'Pix'), _forma(_cartao, 'Cartão')],
      linhas: formas.map(_linha).toList(),
      promocaoEscolhidaPorItem: {1: promo},
    );

void main() {
  test('Pix permitido: desconto ativo e enviado', () {
    final s = _state(_promoPix, [_pix]);
    expect(s.valorDescontoPromocaoTotal, 20);
    expect(s.promocaoAtivaPorItem.keys, [1]);
    expect(s.valorTotalComDesconto, 180);
  });

  test('trocar para Cartão suspende; voltar ao Pix reativa', () {
    final s = _state(_promoPix, [_cartao]);
    expect(s.valorDescontoPromocaoTotal, 0);
    expect(s.promocaoAtivaPorItem, isEmpty);
    expect(s.valorTotalComDesconto, 200);
    expect(s.promocaoEscolhidaPorItem.length, 1);
    expect(s.copyWith(linhas: [_linha(_pix)]).valorDescontoPromocaoTotal, 20);
  });

  test('sem forma escolhida: prévia ativa', () {
    expect(_state(_promoPix, [null]).valorDescontoPromocaoTotal, 20);
  });

  test('misto Pix+Cartão: suspensa', () {
    final s = _state(_promoPix, [_pix, _cartao]);
    expect(s.promocaoAtivaPorItem, isEmpty);
    expect(s.valorDescontoPromocaoTotal, 0);
  });

  test('promoção sem restrição não muda', () {
    final s = _state(_promoLivre, [_cartao]);
    expect(s.valorDescontoPromocaoTotal, 20);
    expect(s.promocaoAtivaPorItem.keys, [1]);
  });

  test('item com promoção suspensa aceita desconto manual', () {
    expect(_state(_promoPix, [_pix]).produtoIdsComPromocao, {1});
    final s = _state(_promoPix, [_cartao]);
    expect(s.produtoIdsComPromocao, isEmpty);
    expect(s.valorTotalProdutosSemPromocao, 200);
  });

  Future<void> pump(WidgetTester t, PagamentosRealizadosState s) =>
      t.pumpWidget(MaterialApp(
        theme: SivTheme.tema,
        home: Scaffold(body: IndicadorPromocao(state: s)),
      ));

  testWidgets('indicador: ativa e suspensa', (t) async {
    await pump(t, _state(_promoPix, [_pix]));
    expect(find.text('Promoção: DESCONTO PIX - 10%'), findsOneWidget);
    await pump(t, _state(_promoPix, [_cartao]));
    expect(find.text('DESCONTO PIX - 10% — só em Pix'), findsOneWidget);
  });
}
