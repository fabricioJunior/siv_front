import 'package:comercial/domain/models/relatorio_pedidos_contagem.dart';
import 'package:comercial/presentation/blocs/relatorio_pedidos_contagem_cubit/relatorio_pedidos_contagem_cubit.dart';
import 'package:comercial/presentation/widgets/frequencia/frequencia_formato.dart';
import 'package:comercial/presentation/widgets/pedidos_contagem/pedidos_contagem_formato.dart';
import 'package:core/bloc.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

const _flex = [1, 5, 2, 2, 4, 1, 2, 2];
const _numericas = {5, 6, 7};
const _larguraChevron = 30.0;

/// Linha de 8 colunas (mesmos flex do cabeçalho, das linhas e do rodapé).
Widget _grade(List<Widget> c, {Widget? fim}) => Row(
      children: [
        for (var i = 0; i < c.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            flex: _flex[i],
            child: Align(
              alignment: _numericas.contains(i)
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: c[i],
            ),
          ),
        ],
        const SizedBox(width: 12),
        SizedBox(width: _larguraChevron, child: fim),
      ],
    );

class ListaPedidosContagem extends StatelessWidget {
  final RelatorioPedidosContagemState state;
  final ValueChanged<int> onAbrir;

  const ListaPedidosContagem({
    super.key,
    required this.state,
    required this.onAbrir,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RelatorioPedidosContagemCubit>();
    final mobile = relatorioMobile(context);
    final c = context.sivColors;
    final hoje = DateTime.now();
    final faturados = state.filtro.situacao == SituacaoContagem.faturado;

    final linhas = [
      for (final l in state.linhas)
        mobile
            ? _CartaoPedido(
                linha: l,
                state: state,
                hoje: hoje,
                onAbrir: onAbrir,
              )
            : _LinhaPedido(
                linha: l,
                state: state,
                hoje: hoje,
                onAbrir: onAbrir,
              ),
    ];

    final carregarMais = state.temMais
        ? Padding(
            padding: const EdgeInsets.only(top: 12),
            child: state.carregandoMais
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : OutlinedButton(
                    key: const Key('contagem_carregar_mais'),
                    onPressed: cubit.carregarMais,
                    child: Text(
                      'Carregar mais (${state.totalItems - state.linhas.length})',
                    ),
                  ),
          )
        : const SizedBox.shrink();

    if (mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final w in linhas)
            Padding(padding: const EdgeInsets.only(bottom: 10), child: w),
          carregarMais,
        ],
      );
    }

    final f = state.filtro;
    Widget cab(String t, {String? ordem}) {
      final texto = Text(
        t,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.sivTextos.apoio.copyWith(
          fontFamily: sivFonteCondensed,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: c.acoAtivo,
        ),
      );
      if (ordem == null) return texto;
      final ativa = f.ordenarPor == ordem;
      return InkWell(
        key: Key('contagem_ordenar_$ordem'),
        onTap: () => cubit.ordenar(ordem),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: texto),
            if (ativa)
              Icon(
                f.ordem == 'asc' ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: c.aco,
              ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: c.superficie,
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
            border: Border.all(color: c.hairline),
          ),
          child: Column(
            children: [
              Container(
                color: c.superficieRecuada,
                padding: const EdgeInsets.symmetric(
                  horizontal: SivDimensoes.linhaTabelaHorizontal,
                  vertical: 12,
                ),
                child: _grade([
                  cab('PEDIDO'),
                  cab('FORNECEDOR · RESPONSÁVEL'),
                  cab(faturados ? 'FATURADO' : 'ABERTO EM', ordem: 'data'),
                  cab(faturados ? 'ABERTURA' : 'EM ABERTO HÁ'),
                  cab('STATUS DA CONTAGEM'),
                  cab('PEÇAS', ordem: 'pecas'),
                  cab('CUSTO', ordem: 'custo'),
                  cab('VALOR', ordem: 'valor'),
                ]),
              ),
              ...linhas,
            ],
          ),
        ),
        carregarMais,
      ],
    );
  }
}

/// Rodapé fixo (fora da rolagem): `TOTAL`, pedidos, peças, custo e valor.
class RodapeTotalContagem extends StatelessWidget {
  final ResumoPedidosContagem resumo;
  const RodapeTotalContagem({super.key, required this.resumo});

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    final t = context.sivTextos;
    final semCusto = resumo.pecasSemCusto > 0
        ? ' · ${pcQtd(resumo.pecasSemCusto)} peças sem custo fora do total'
        : '';
    return Container(
      key: const Key('contagem_rodape'),
      padding: const EdgeInsets.symmetric(
        horizontal: SivDimensoes.paddingBarraTituloHorizontal +
            SivDimensoes.linhaTabelaHorizontal,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: c.superficie,
        border: Border(top: BorderSide(color: c.acoEscuro, width: 2)),
      ),
      child: _grade([
        Text('TOTAL', style: t.secao.copyWith(fontSize: 14)),
        Text(
          '${resumo.pedidos} pedidos$semCusto',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: t.corpo.copyWith(color: c.textoApoio),
        ),
        const SizedBox.shrink(),
        const SizedBox.shrink(),
        const SizedBox.shrink(),
        Text(
          pcQtd(resumo.pecas),
          style: t.corpo.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(frequenciaMoeda(resumo.custo), style: t.secao),
        Text(frequenciaMoeda(resumo.valor), style: t.secao),
      ]),
    );
  }
}

String _primeiro(PedidoContagemLinha l, RelatorioPedidosContagemState s) =>
    pcPrimeiroProduto(l, comVariacao: s.filtro.produtoId != null);

class _LinhaPedido extends StatelessWidget {
  final PedidoContagemLinha linha;
  final RelatorioPedidosContagemState state;
  final DateTime hoje;
  final ValueChanged<int> onAbrir;

  const _LinhaPedido({
    required this.linha,
    required this.state,
    required this.hoje,
    required this.onAbrir,
  });

  @override
  Widget build(BuildContext context) {
    final l = linha;
    final c = context.sivColors;
    final t = context.sivTextos;
    final aberto = state.expandidos.contains(l.pedidoId);
    final faturados = state.filtro.situacao == SituacaoContagem.faturado;
    final alerta = pcAlerta(l, hoje);
    final etapaIdx = etapasContagem.indexOf(l.etapa);

    final col3 = faturados ? l.faturadoEm : l.abertoEm;
    final col4 = faturados
        ? pcData(l.abertoEm)
        : (l.faturado || l.abertoEm == null
            ? '—'
            : pcEmAbertoHa(l.abertoEm!, hoje));

    return Column(
      children: [
        InkWell(
          key: Key('contagem_linha_${l.pedidoId}'),
          hoverColor: c.selecaoFundo,
          onTap: () => context
              .read<RelatorioPedidosContagemCubit>()
              .alternarLinha(l.pedidoId),
          onLongPress: () => onAbrir(l.pedidoId),
          child: Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.hairline)),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: SivDimensoes.linhaTabelaHorizontal,
              vertical: 11,
            ),
            child: _grade(
              [
                Text('#${l.pedidoId}', style: t.secao.copyWith(fontSize: 14.5)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: l.fornecedor,
                        children: [
                          if (l.funcionario != null)
                            TextSpan(
                              text: ' · ${l.funcionario}',
                              style: t.apoio.copyWith(color: c.textoApoio),
                            ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.corpo,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.sell_outlined, size: 12, color: c.aco),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _primeiro(l, state),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.apoio,
                          ),
                        ),
                        if (pcMaisProdutos(l).isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            pcMaisProdutos(l),
                            style: t.apoio.copyWith(color: c.textoApoio),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                Text(pcData(col3),
                    style: t.corpo.copyWith(color: c.textoApoio)),
                Text(
                  col4,
                  style: t.corpo.copyWith(
                    color: alerta && !faturados ? c.atencao : c.textoApoio,
                    fontWeight: alerta && !faturados ? FontWeight.w600 : null,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        EtapaTag(l.etapa),
                        if (etapaIdx >= 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${etapaIdx + 1}/5',
                            style: t.apoio.copyWith(
                              fontSize: 11,
                              color: c.textoApoio,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    TrilhaContagem(l.etapa, largura: 150),
                  ],
                ),
                Text(pcQtd(l.pecas), style: t.corpo),
                _Custo(linha: l, state: state),
                _Valor(linha: l, state: state),
              ],
              fim: Icon(
                aberto ? Icons.expand_less : Icons.expand_more,
                size: 18,
                color: c.textoApoio,
              ),
            ),
          ),
        ),
        if (aberto)
          Container(
            width: double.infinity,
            color: c.selecaoFundo,
            padding: const EdgeInsets.fromLTRB(
              SivDimensoes.linhaTabelaHorizontal + 96,
              4,
              SivDimensoes.linhaTabelaHorizontal,
              12,
            ),
            child: _Itens(linha: l, state: state, onAbrir: onAbrir),
          ),
      ],
    );
  }
}

class _Custo extends StatelessWidget {
  final PedidoContagemLinha linha;
  final RelatorioPedidosContagemState state;
  const _Custo({required this.linha, required this.state});

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    final t = context.sivTextos;
    final l = linha;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(frequenciaMoeda(l.custo), style: t.secao.copyWith(fontSize: 15)),
        if (l.pecasSemCusto > 0)
          Text(
            '+ ${pcQtd(l.pecasSemCusto)} pç sem custo',
            style: t.apoio.copyWith(fontSize: 11, color: c.atencao),
          ),
        if (state.filtro.temFiltroItem)
          Text(
            'de ${frequenciaMoeda(l.custoPedido)} no pedido',
            style: t.apoio.copyWith(fontSize: 11, color: c.textoApoio),
          ),
      ],
    );
  }
}

class _Valor extends StatelessWidget {
  final PedidoContagemLinha linha;
  final RelatorioPedidosContagemState state;
  const _Valor({required this.linha, required this.state});

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    final t = context.sivTextos;
    final l = linha;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(frequenciaMoeda(l.valor), style: t.secao.copyWith(fontSize: 15)),
        if (l.pecasSemValor > 0)
          Text(
            '+ ${pcQtd(l.pecasSemValor)} pç sem preço',
            style: t.apoio.copyWith(fontSize: 11, color: c.atencao),
          ),
        if (state.filtro.temFiltroItem)
          Text(
            'de ${frequenciaMoeda(l.valorPedido)} no pedido',
            style: t.apoio.copyWith(fontSize: 11, color: c.textoApoio),
          ),
      ],
    );
  }
}

class _CartaoPedido extends StatelessWidget {
  final PedidoContagemLinha linha;
  final RelatorioPedidosContagemState state;
  final DateTime hoje;
  final ValueChanged<int> onAbrir;

  const _CartaoPedido({
    required this.linha,
    required this.state,
    required this.hoje,
    required this.onAbrir,
  });

  @override
  Widget build(BuildContext context) {
    final l = linha;
    final c = context.sivColors;
    final t = context.sivTextos;
    final aberto = state.expandidos.contains(l.pedidoId);
    final faturados = state.filtro.situacao == SituacaoContagem.faturado;
    final alerta = pcAlerta(l, hoje);
    final data = l.faturado || faturados
        ? 'Faturado ${pcData(l.faturadoEm)}'
        : 'Aberto ${pcData(l.abertoEm)}'
            '${l.abertoEm == null ? '' : ' · ${pcEmAbertoHa(l.abertoEm!, hoje)}'}';

    return Stack(
      children: [
        Material(
          color: c.superficie,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
            side: BorderSide(color: c.hairline),
          ),
          child: InkWell(
            key: Key('contagem_linha_${l.pedidoId}'),
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
            onTap: () => context
                .read<RelatorioPedidosContagemCubit>()
                .alternarLinha(l.pedidoId),
            onLongPress: () => onAbrir(l.pedidoId),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Pedido #${l.pedidoId}',
                          style: t.secao.copyWith(fontSize: 15),
                        ),
                      ),
                      EtapaTag(l.etapa),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    [
                      l.fornecedor,
                      if (l.funcionario != null) l.funcionario!,
                    ].join(' · '),
                    style: t.apoio.copyWith(color: c.textoApoio),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.sell_outlined, size: 12, color: c.aco),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _primeiro(l, state),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.apoio,
                        ),
                      ),
                      if (pcMaisProdutos(l).isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          pcMaisProdutos(l),
                          style: t.apoio.copyWith(color: c.textoApoio),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  TrilhaContagem(l.etapa),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          data,
                          style: t.apoio.copyWith(
                            color: alerta ? c.atencao : c.textoApoio,
                          ),
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          text: '${pcQtd(l.pecas)} pç · ',
                          style: t.apoio.copyWith(color: c.textoApoio),
                          children: [
                            TextSpan(
                              text: frequenciaMoeda(l.custo),
                              style: t.secao.copyWith(
                                fontSize: 16,
                                color: c.tinta,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Valor de venda ${frequenciaMoeda(l.valor)}'
                      '${state.filtro.temFiltroItem ? ' (de ${frequenciaMoeda(l.valorPedido)} no pedido)' : ''}',
                      style: t.apoio.copyWith(
                        fontSize: 11.5,
                        color: c.textoApoio,
                      ),
                    ),
                  ),
                  if (l.pecasSemValor > 0)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '+ ${pcQtd(l.pecasSemValor)} pç sem preço',
                        style:
                            t.apoio.copyWith(fontSize: 11.5, color: c.atencao),
                      ),
                    ),
                  if (l.pecasSemCusto > 0)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '+ ${pcQtd(l.pecasSemCusto)} pç sem custo (falta associar)',
                        style:
                            t.apoio.copyWith(fontSize: 11.5, color: c.atencao),
                      ),
                    ),
                  if (state.filtro.temFiltroItem)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'de ${frequenciaMoeda(l.custoPedido)} no pedido',
                        style: t.apoio.copyWith(
                          fontSize: 11.5,
                          color: c.textoApoio,
                        ),
                      ),
                    ),
                  if (aberto) ...[
                    Divider(color: c.hairline),
                    _Itens(linha: l, state: state, onAbrir: onAbrir),
                  ],
                ],
              ),
            ),
          ),
        ),
        ...sivCantosBlueprint(c.aco.withValues(alpha: 0.4)),
      ],
    );
  }
}

/// Itens do pedido (B2), sob demanda; fora do filtro ficam a 40%.
class _Itens extends StatelessWidget {
  final PedidoContagemLinha linha;
  final RelatorioPedidosContagemState state;
  final ValueChanged<int> onAbrir;

  const _Itens({
    required this.linha,
    required this.state,
    required this.onAbrir,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    final t = context.sivTextos;
    final mobile = relatorioMobile(context);
    final itens = state.itens[linha.pedidoId];
    final apoio = t.apoio.copyWith(color: c.textoApoio);

    final Widget corpo;
    if (state.itensComErro.contains(linha.pedidoId)) {
      corpo = Row(
        children: [
          Text('Falha ao carregar os itens.', style: apoio),
          TextButton(
            onPressed: () => context
                .read<RelatorioPedidosContagemCubit>()
                .carregarItens(linha.pedidoId),
            child: const Text('Tentar de novo'),
          ),
        ],
      );
    } else if (itens == null) {
      corpo = const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: LinearProgressIndicator(minHeight: 2),
      );
    } else if (mobile) {
      corpo = Column(
        children: [for (final i in itens) _ItemMobile(item: i)],
      );
    } else {
      Widget linhaItem(List<Widget> cel, {double opacidade = 1}) => Opacity(
            opacity: opacidade,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Expanded(flex: 5, child: cel[0]),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: cel[1]),
                  const SizedBox(width: 12),
                  Expanded(
                      flex: 1,
                      child: Align(
                          alignment: Alignment.centerRight, child: cel[2])),
                  const SizedBox(width: 12),
                  Expanded(
                      flex: 2,
                      child: Align(
                          alignment: Alignment.centerRight, child: cel[3])),
                  const SizedBox(width: 12),
                  Expanded(
                      flex: 2,
                      child: Align(
                          alignment: Alignment.centerRight, child: cel[4])),
                  const SizedBox(width: 12),
                  Expanded(
                      flex: 2,
                      child: Align(
                          alignment: Alignment.centerRight, child: cel[5])),
                  const SizedBox(width: 12),
                  Expanded(
                      flex: 2,
                      child: Align(
                          alignment: Alignment.centerRight, child: cel[6])),
                ],
              ),
            ),
          );
      Text cab(String s) => Text(
            s,
            style: t.apoio.copyWith(
                fontSize: 10.5, letterSpacing: 1.2, color: c.textoApoio),
          );
      corpo = Column(
        children: [
          linhaItem([
            cab('REFERÊNCIA'),
            cab('COR · TAMANHO'),
            cab('PEÇAS'),
            cab('CUSTO UN.'),
            cab('SUBTOTAL'),
            cab('PREÇO UN.'),
            cab('SUBTOTAL VENDA'),
          ]),
          for (final i in itens)
            linhaItem(
              [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _nomeItem(i),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.corpo,
                      ),
                    ),
                    if (i.semReferencia) ...[
                      const SizedBox(width: 8),
                      const _TagSemReferencia(),
                    ],
                  ],
                ),
                Text(i.variacao, style: t.corpo.copyWith(color: c.textoApoio)),
                Text(pcQtd(i.quantidade), style: t.corpo),
                Text(
                  i.custoUnitario == null
                      ? '—'
                      : frequenciaMoeda(i.custoUnitario!),
                  style: t.corpo.copyWith(color: c.textoApoio),
                ),
                Text(
                  i.subtotal == null ? '—' : frequenciaMoeda(i.subtotal!),
                  style: t.corpo,
                ),
                Text(
                  i.valorUnitario == null
                      ? '—'
                      : frequenciaMoeda(i.valorUnitario!),
                  style: t.corpo.copyWith(color: c.textoApoio),
                ),
                Text(
                  i.subtotalVenda == null
                      ? '—'
                      : frequenciaMoeda(i.subtotalVenda!),
                  style: t.corpo,
                ),
              ],
              opacidade: i.bateFiltro ? 1 : 0.4,
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        corpo,
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            key: Key('contagem_abrir_${linha.pedidoId}'),
            onPressed: () => onAbrir(linha.pedidoId),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Abrir pedido'),
          ),
        ),
      ],
    );
  }
}

String _nomeItem(ItemPedidoContagem i) => (i.referenciaIdExterno ?? '').isEmpty
    ? i.referenciaNome
    : '${i.referenciaIdExterno} · ${i.referenciaNome}';

class _TagSemReferencia extends StatelessWidget {
  const _TagSemReferencia();

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: c.atencaoFundo,
        border: Border.all(color: c.atencaoBorda),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Sem referência',
        style:
            context.sivTextos.apoio.copyWith(fontSize: 10.5, color: c.atencao),
      ),
    );
  }
}

class _ItemMobile extends StatelessWidget {
  final ItemPedidoContagem item;
  const _ItemMobile({required this.item});

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    final t = context.sivTextos;
    final un =
        item.custoUnitario == null ? '—' : frequenciaMoeda(item.custoUnitario!);
    return Opacity(
      opacity: item.bateFiltro ? 1 : 0.4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    children: [
                      Text(_nomeItem(item), style: t.corpo),
                      if (item.semReferencia) const _TagSemReferencia(),
                    ],
                  ),
                  Text(
                    [
                      if (item.variacao.isNotEmpty) item.variacao,
                      '${pcQtd(item.quantidade)} × $un',
                      'venda ${item.subtotalVenda == null ? '—' : frequenciaMoeda(item.subtotalVenda!)}',
                    ].join(' · '),
                    style: t.apoio.copyWith(color: c.textoApoio),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              item.subtotal == null ? '—' : frequenciaMoeda(item.subtotal!),
              style: t.corpo,
            ),
          ],
        ),
      ),
    );
  }
}
