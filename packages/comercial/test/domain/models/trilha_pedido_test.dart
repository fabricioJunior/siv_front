import 'package:comercial/domain/models/pedido.dart';
import 'package:comercial/domain/models/pedido_item.dart';
import 'package:comercial/domain/models/pedido_pagamento.dart';
import 'package:comercial/domain/models/trilha_pedido.dart';
import 'package:flutter_test/flutter_test.dart';

final _t = DateTime(2026, 1, 1);

Pedido _p({
  String origem = 'atendente_humano',
  String tipo = 'venda',
  String mod = 'retirada',
  bool naEntrega = false,
  String sit = 'em_andamento',
  String? ent,
  DateTime? conferido,
  DateTime? retirado,
  int? func = 1,
  double total = 100,
  bool exigeCodigo = true,
}) =>
    Pedido.create(
      origem: origem,
      tipo: tipo,
      modalidadeEntrega: mod,
      pagamentoNaEntrega: naEntrega,
      situacao: sit,
      situacaoEntrega: ent,
      conferidoEm: conferido,
      retiradoEm: retirado,
      funcionarioId: func,
      valorTotal: total,
      exigeCodigoRetirada: exigeCodigo,
    );

// ok = confirmado; online = tipo controlado.
PedidoPagamento _pg({bool ok = false, bool online = false, double v = 100}) =>
    PedidoPagamento.create(
      valorEsperado: v,
      tipo: online ? 'controlado' : 'manual',
      confirmadoEm: ok ? _t : null,
      valorConfirmado: ok ? v : null,
    );

PedidoItem _item() => PedidoItem.create(produtoId: 1);

class _Caso {
  final String nome;
  final Pedido pedido;
  final List<PedidoPagamento> pags;
  final List<PedidoItem> itens;
  final TipoTrilhaPedido trilha;
  final IdEtapaPedido? atual;
  final AcaoPedido? f9;
  final bool habilitada;
  _Caso(this.nome, this.pedido, this.trilha, this.atual, this.f9,
      {this.pags = const [], List<PedidoItem>? itens, this.habilitada = true})
      : itens = itens ?? [_item()];
}

void main() {
  final casos = <_Caso>[
    // T1 e-commerce retirada
    _Caso('T1 sem vendedor -> assumir', _p(origem: 'ecommerce', func: null),
        TipoTrilhaPedido.ecommerceRetirada, IdEtapaPedido.assumir, AcaoPedido.assumirPedido),
    _Caso('T1 em andamento assumido -> conferir', _p(origem: 'ecommerce'),
        TipoTrilhaPedido.ecommerceRetirada, IdEtapaPedido.conferir, AcaoPedido.concluirConferencia),
    _Caso(
        'T1 encerrado nao conferido -> conferir',
        _p(origem: 'ecommerce', sit: 'encerrado', ent: 'nao_aplicavel'),
        TipoTrilhaPedido.ecommerceRetirada,
        IdEtapaPedido.conferir,
        AcaoPedido.concluirConferencia),
    _Caso(
        'T1 conferido encerrado aguardando_chamada -> embalar',
        _p(origem: 'ecommerce', sit: 'encerrado', ent: 'aguardando_chamada', conferido: _t),
        TipoTrilhaPedido.ecommerceRetirada,
        IdEtapaPedido.embalar,
        AcaoPedido.marcarEmbalado),
    _Caso(
        'T1 embalado -> retirada',
        _p(origem: 'ecommerce', sit: 'encerrado', ent: 'embalado', conferido: _t),
        TipoTrilhaPedido.ecommerceRetirada,
        IdEtapaPedido.retirada,
        AcaoPedido.confirmarRetirada),
    _Caso(
        'T1 retirado -> concluida',
        _p(origem: 'ecommerce', sit: 'encerrado', ent: 'embalado', conferido: _t, retirado: _t),
        TipoTrilhaPedido.ecommerceRetirada,
        null,
        null),
    _Caso(
        'T1 antigo conferido encerrado nao_aplicavel -> retirada (embalado implicito)',
        _p(origem: 'ecommerce', sit: 'encerrado', ent: 'nao_aplicavel', conferido: _t),
        TipoTrilhaPedido.ecommerceRetirada,
        IdEtapaPedido.retirada,
        AcaoPedido.confirmarRetirada),
    // T2 e-commerce entrega
    _Caso(
        'T2 conferido aguardando_chamada -> embalar',
        _p(origem: 'ecommerce', mod: 'entrega', sit: 'encerrado', ent: 'aguardando_chamada', conferido: _t),
        TipoTrilhaPedido.ecommerceEntrega,
        IdEtapaPedido.embalar,
        AcaoPedido.marcarEmbalado),
    _Caso(
        'T2 embalado -> chamar',
        _p(origem: 'ecommerce', mod: 'entrega', sit: 'encerrado', ent: 'embalado', conferido: _t),
        TipoTrilhaPedido.ecommerceEntrega,
        IdEtapaPedido.chamarEntregador,
        AcaoPedido.chamarEntregador),
    _Caso(
        'T2 chamado -> entregue',
        _p(origem: 'ecommerce', mod: 'entrega', sit: 'encerrado', ent: 'chamado', conferido: _t),
        TipoTrilhaPedido.ecommerceEntrega,
        IdEtapaPedido.entregue,
        AcaoPedido.confirmarEntrega),
    _Caso(
        'T2 entregue -> concluida',
        _p(origem: 'ecommerce', mod: 'entrega', sit: 'encerrado', ent: 'entregue', conferido: _t),
        TipoTrilhaPedido.ecommerceEntrega,
        null,
        null),
    // T3 venda retirada
    _Caso('T3 sem itens -> itens desabilitado', _p(), TipoTrilhaPedido.vendaRetirada,
        IdEtapaPedido.itens, AcaoPedido.irParaPagamento,
        itens: [], habilitada: false),
    _Caso('T3 itens sem pagamento -> itens habilitado', _p(), TipoTrilhaPedido.vendaRetirada,
        IdEtapaPedido.itens, AcaoPedido.irParaPagamento),
    _Caso('T3 pagamento parcial -> pagamento', _p(), TipoTrilhaPedido.vendaRetirada,
        IdEtapaPedido.pagamento, AcaoPedido.lancarPagamento,
        pags: [_pg(v: 40)]),
    _Caso('T3 pago manual nao confirmado -> confirmacao desabilitada', _p(),
        TipoTrilhaPedido.vendaRetirada, IdEtapaPedido.confirmacao, AcaoPedido.faturar,
        pags: [_pg()], habilitada: false),
    _Caso('T3 tudo confirmado nao faturado -> faturar habilitado', _p(),
        TipoTrilhaPedido.vendaRetirada, IdEtapaPedido.confirmacao, AcaoPedido.faturar,
        pags: [_pg(ok: true)]),
    _Caso('T3 faturada aguardando_chamada -> embalar', _p(sit: 'encerrado', ent: 'aguardando_chamada'),
        TipoTrilhaPedido.vendaRetirada, IdEtapaPedido.embalar, AcaoPedido.marcarEmbalado,
        pags: [_pg(ok: true)]),
    _Caso('T3 embalada -> retirada', _p(sit: 'encerrado', ent: 'embalado'),
        TipoTrilhaPedido.vendaRetirada, IdEtapaPedido.retirada, AcaoPedido.confirmarRetirada,
        pags: [_pg(ok: true)]),
    _Caso('T3 ANTIGA encerrada nao_aplicavel -> retirada (embalado implicito)',
        _p(sit: 'encerrado', ent: 'nao_aplicavel'),
        TipoTrilhaPedido.vendaRetirada, IdEtapaPedido.retirada, AcaoPedido.confirmarRetirada,
        pags: [_pg(ok: true)]),
    _Caso('T3 ANTIGA encerrada sem pagamentos carregados -> retirada',
        _p(sit: 'encerrado', ent: 'nao_aplicavel'),
        TipoTrilhaPedido.vendaRetirada, IdEtapaPedido.retirada, AcaoPedido.confirmarRetirada),
    _Caso('T3 ANTIGA retirada -> concluida',
        _p(sit: 'encerrado', ent: 'nao_aplicavel', retirado: _t),
        TipoTrilhaPedido.vendaRetirada, null, null),
    _Caso('T3 cancelada -> sem atual', _p(sit: 'cancelado'), TipoTrilhaPedido.vendaRetirada, null, null),
    // T4 entrega online
    _Caso('T4 online pendente -> confirmacao desabilitada',
        _p(mod: 'entrega'), TipoTrilhaPedido.vendaEntregaOnline, IdEtapaPedido.confirmacao,
        AcaoPedido.faturar,
        pags: [_pg(online: true)], habilitada: false),
    _Caso('T4 faturada aguardando_chamada -> embalar',
        _p(mod: 'entrega', sit: 'encerrado', ent: 'aguardando_chamada'),
        TipoTrilhaPedido.vendaEntregaOnline, IdEtapaPedido.embalar, AcaoPedido.marcarEmbalado,
        pags: [_pg(ok: true, online: true)]),
    _Caso('T4 faturada nao_aplicavel entrega -> embalar desabilitado',
        _p(mod: 'entrega', sit: 'encerrado', ent: 'nao_aplicavel'),
        TipoTrilhaPedido.vendaEntregaOnline, IdEtapaPedido.embalar, AcaoPedido.marcarEmbalado,
        pags: [_pg(ok: true, online: true)], habilitada: false),
    _Caso('T4 embalado -> chamar', _p(mod: 'entrega', sit: 'encerrado', ent: 'embalado'),
        TipoTrilhaPedido.vendaEntregaOnline, IdEtapaPedido.chamarEntregador,
        AcaoPedido.chamarEntregador,
        pags: [_pg(ok: true, online: true)]),
    _Caso('T4 chamado -> entregue', _p(mod: 'entrega', sit: 'encerrado', ent: 'chamado'),
        TipoTrilhaPedido.vendaEntregaOnline, IdEtapaPedido.entregue, AcaoPedido.confirmarEntrega,
        pags: [_pg(ok: true, online: true)]),
    // T5 entrega pagamento ao entregador
    _Caso('T5 forma prevista pendente -> pagamento', _p(mod: 'entrega', naEntrega: true),
        TipoTrilhaPedido.vendaEntregaNoAto, IdEtapaPedido.pagamento, AcaoPedido.lancarPagamento,
        pags: [_pg(v: 40)]),
    _Caso('T5 prevista lancada -> embalar (sem faturar)',
        _p(mod: 'entrega', naEntrega: true),
        TipoTrilhaPedido.vendaEntregaNoAto, IdEtapaPedido.embalar, AcaoPedido.marcarEmbalado,
        pags: [_pg()]),
    _Caso('T5 embalado -> chamar', _p(mod: 'entrega', naEntrega: true, ent: 'embalado'),
        TipoTrilhaPedido.vendaEntregaNoAto, IdEtapaPedido.chamarEntregador,
        AcaoPedido.chamarEntregador,
        pags: [_pg()]),
    _Caso('T5 chamado pagamento nao recebido -> acerto desabilitado',
        _p(mod: 'entrega', naEntrega: true, ent: 'chamado'),
        TipoTrilhaPedido.vendaEntregaNoAto, IdEtapaPedido.acerto, AcaoPedido.fecharAcerto,
        pags: [_pg()], habilitada: false),
    _Caso('T5 chamado tudo recebido -> acerto habilitado',
        _p(mod: 'entrega', naEntrega: true, ent: 'chamado'),
        TipoTrilhaPedido.vendaEntregaNoAto, IdEtapaPedido.acerto, AcaoPedido.fecharAcerto,
        pags: [_pg(ok: true)]),
    _Caso('T5 entregue e encerrado -> concluida',
        _p(mod: 'entrega', naEntrega: true, ent: 'entregue', sit: 'encerrado'),
        TipoTrilhaPedido.vendaEntregaNoAto, null, null,
        pags: [_pg(ok: true)]),
    // taxa_entrega: sem Itens
    _Caso('taxa_entrega sem pagamento -> pagamento (sem itens)',
        _p(tipo: 'taxa_entrega', mod: 'entrega', total: 10),
        TipoTrilhaPedido.vendaEntregaOnline, IdEtapaPedido.pagamento, AcaoPedido.lancarPagamento,
        itens: []),
    _Caso('taxa_entrega pagamentoNaEntrega -> T5',
        _p(tipo: 'taxa_entrega', mod: 'entrega', naEntrega: true, total: 10),
        TipoTrilhaPedido.vendaEntregaNoAto, IdEtapaPedido.pagamento, AcaoPedido.lancarPagamento,
        itens: []),
    // transferencia_saida
    _Caso('transferencia_saida -> faturar', _p(tipo: 'transferencia_saida'),
        TipoTrilhaPedido.minima, IdEtapaPedido.faturar, AcaoPedido.faturar),
    _Caso('transferencia_saida faturada -> concluida',
        _p(tipo: 'transferencia_saida', sit: 'encerrado'), TipoTrilhaPedido.minima, null, null),
    // entrada
    _Caso('compra -> entrada', _p(tipo: 'compra'), TipoTrilhaPedido.entrada, null, null),
    _Caso('transferencia_entrada -> entrada', _p(tipo: 'transferencia_entrada'),
        TipoTrilhaPedido.entrada, null, null),
  ];

  for (final c in casos) {
    test(c.nome, () {
      final t = derivarTrilhaPedido(c.pedido, c.pags, c.itens);
      expect(t.tipo, c.trilha);
      expect(t.atual?.id, c.atual);
      expect(t.acaoPrincipal, c.f9);
      if (c.f9 != null) expect(t.acaoPrincipalHabilitada, c.habilitada, reason: '${t.motivoDesabilitada}');
      if (c.atual == null && c.trilha != TipoTrilhaPedido.entrada && !c.pedido.situacao!.contains('cancel')) {
        expect(t.concluida, isTrue);
      }
    });
  }

  test('entrada abre /pedido_entrada sem etapas', () {
    final t = derivarTrilhaPedido(_p(tipo: 'compra'), [], []);
    expect(t.abreEntrada, isTrue);
    expect(t.etapas, isEmpty);
  });

  test('somenteLeitura antes de assumir', () {
    expect(derivarTrilhaPedido(_p(origem: 'ecommerce', func: null), [], []).somenteLeitura, isTrue);
  });

  test('conferenciaRetroativa: encerrado -> marcarConferido; em andamento -> conferir', () {
    final a = derivarTrilhaPedido(_p(origem: 'ecommerce', sit: 'encerrado', ent: 'nao_aplicavel'), [], []);
    final b = derivarTrilhaPedido(_p(origem: 'ecommerce'), [], []);
    expect(a.conferenciaRetroativa, isTrue);
    expect(b.conferenciaRetroativa, isFalse);
  });

  test('exigeCodigoRetirada propaga do pedido', () {
    final t = derivarTrilhaPedido(_p(sit: 'encerrado', exigeCodigo: false), [], [_item()]);
    expect(t.exigeCodigoRetirada, isFalse);
  });

  test('T5 antesDaSaida insere confirmacao antes de embalar', () {
    final t = derivarTrilhaPedido(
        _p(mod: 'entrega', naEntrega: true), [_pg()], [_item()],
        pontoT5: PontoFaturamentoT5.antesDaSaida);
    expect(t.etapas.map((e) => e.id).toList(), [
      IdEtapaPedido.itens,
      IdEtapaPedido.pagamento,
      IdEtapaPedido.confirmacao,
      IdEtapaPedido.embalar,
      IdEtapaPedido.chamarEntregador,
      IdEtapaPedido.acerto,
    ]);
    expect(t.atual?.id, IdEtapaPedido.confirmacao);
  });

  test('so uma etapa atual e faturamento T5 padrao = acerto', () {
    final t = derivarTrilhaPedido(_p(mod: 'entrega', naEntrega: true), [_pg()], [_item()]);
    expect(t.etapas.where((e) => e.estado == EstadoEtapa.atual).length, 1);
    expect(t.etapas.any((e) => e.id == IdEtapaPedido.confirmacao), isFalse);
  });

  test('T4: backend só fatura depois de entregar -> Confirmação feita sem faturar, Faturar no fim',
      () {
    final emb = derivarTrilhaPedido(
        _p(mod: 'entrega', ent: 'aguardando_chamada'), [_pg(ok: true, online: true)], [_item()]);
    expect(emb.atual?.id, IdEtapaPedido.embalar);
    expect(emb.etapas.last.id, IdEtapaPedido.faturar);
    final fat = derivarTrilhaPedido(
        _p(mod: 'entrega', ent: 'entregue'), [_pg(ok: true, online: true)], [_item()]);
    expect(fat.atual?.id, IdEtapaPedido.faturar);
    expect(fat.acaoPrincipalHabilitada, isTrue);
  });

  test('total passado pela tela vence o valorTotal do backend (desconto do pedido)', () {
    final ped = _p(total: 100);
    expect(derivarTrilhaPedido(ped, [_pg(v: 100)], [_item()]).atual?.id,
        IdEtapaPedido.confirmacao);
    expect(derivarTrilhaPedido(ped, [_pg(v: 100)], [_item()], total: 120).atual?.id,
        IdEtapaPedido.pagamento);
  });

  test('T5: etapa de pagamento se chama "Forma prevista"', () {
    final t = derivarTrilhaPedido(_p(mod: 'entrega', naEntrega: true), [], [_item()]);
    expect(t.etapas[1].titulo, 'Forma prevista');
  });
}
