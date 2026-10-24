import 'package:comercial/domain/models/opcoes_resgate_pontos.dart';
import 'package:comercial/presentation/blocs/pagamentos_realizados_bloc/pagamentos_realizados_bloc.dart';
import 'package:comercial/presentation/pagamento/pagamento_contexto.dart';
import 'package:core/bloc.dart';
import 'package:core/presentation.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promocoes/models.dart';

String pagamentoMoeda(double valor) =>
    'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

final pagamentoDecimalFormatter = TextInputFormatter.withFunction(
  (oldValue, newValue) {
    if (newValue.text.isEmpty) return newValue;
    final normalizado = newValue.text.replaceAll('.', ',');
    return RegExp(r'^\d+(,\d{0,2})?$').hasMatch(normalizado)
        ? newValue.copyWith(text: normalizado)
        : oldValue;
  },
);

List<OpcaoElegivel> _promocoesDistintas(
  Map<int, List<OpcaoElegivel>> opcoesPorItem,
) {
  final mapa = <int, OpcaoElegivel>{};
  for (final opcao in opcoesPorItem.values.expand((l) => l)) {
    if (!opcao.ehCupom) mapa[opcao.id] = opcao;
  }
  return mapa.values.toList(growable: false);
}

/// Coluna "Resumo" da etapa de pagamento: itens, cupom, promoções, extrato e
/// A PAGAR. Desconto de item/geral/entrega abrem painel inline (sem modal).
class PagamentoResumo extends StatelessWidget {
  final PagamentosRealizadosState state;
  final PagamentoContexto contexto;

  /// F4 abre/fecha o painel de desconto geral.
  final ValueNotifier<bool> descontoGeralAberto;

  /// Chamado quando um painel de valor fecha com o foco dentro dele.
  final VoidCallback? aoFecharPainel;

  /// Desktop: itens rolam e o extrato + A PAGAR ficam colados no fim.
  final bool fixarTotais;

  const PagamentoResumo({
    super.key,
    this.fixarTotais = false,
    required this.state,
    required this.contexto,
    required this.descontoGeralAberto,
    this.aoFecharPainel,
  });

  PagamentoRecursos get _r => contexto.recursos;
  bool get _editavel =>
      state.step == PagamentosRealizadosStep.editando &&
      !contexto.descontosTravados;

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final bloc = context.read<PagamentosRealizadosBloc>();
    final produtos = state.resumo?.produtosCompartilhados ?? const [];

    final topo = <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text('RESUMO', style: textos.rotulo),
          Text(
            '${produtos.length} referências · ${state.quantidadeTotalProdutos} peças',
            style: textos.apoio,
          ),
        ],
      ),
      const SizedBox(height: 12),
      for (final produto in produtos)
        _ItemResumo(
          key: ValueKey('item-${produto.produtoId}'),
          produto: produto,
          state: state,
          podeDescontoItem: _r.descontoItem && _editavel,
          podePromocao: _r.promocoes && _editavel,
          aoFecharPainel: aoFecharPainel,
        ),
      if (contexto.descontosTravados) ...[
        const SizedBox(height: 8),
        const SivAvisoAtencao(
          'Remova os pagamentos lançados para alterar descontos',
        ),
      ],
      if (_r.cupom) ...[
        const SizedBox(height: 12),
        _Cupom(state: state, habilitado: _editavel),
      ],
      if (_r.promocoes &&
          _editavel &&
          _promocoesDistintas(state.opcoesElegiveisPorItem).isNotEmpty) ...[
        const SizedBox(height: 8),
        _PromocoesDisponiveis(state: state),
      ],
    ];
    final totais = <Widget>[
      const Divider(height: 28),
      _Linha('Subtotal', pagamentoMoeda(state.valorTotalProdutos)),
      if (state.valorDescontoPromocaoTotal > 0)
        _Linha(
          // Pedido grava o desconto padrão; a forma de pagamento pode mudá-lo no faturamento.
          contexto.origem == PagamentoOrigem.pedido &&
                  state.promocaoEscolhidaPorItem.values.any(
                    (o) => o.overridesPorFormaPagamento?.isNotEmpty ?? false,
                  )
              ? 'Promoções (estimado)'
              : 'Promoções',
          '−${pagamentoMoeda(state.valorDescontoPromocaoTotal)}',
        ),
      if (_r.descontoGeral || state.valorDescontoItensTotal > 0)
        _Linha(
          'Desconto',
          state.valorDescontoItensTotal > 0
              ? '−${pagamentoMoeda(state.valorDescontoItensTotal)}'
              : '—',
          acao: _r.descontoGeral && _editavel
              ? _Acao(
                  'editar · F4',
                  () => descontoGeralAberto.value = !descontoGeralAberto.value,
                )
              : null,
        ),
      if (_r.descontoGeral && _editavel)
        ValueListenableBuilder<bool>(
          valueListenable: descontoGeralAberto,
          builder: (context, aberto, _) => aberto
              ? _PainelValor(
                  aoFechar: aoFecharPainel,
                  key: const ValueKey('painel-desconto-geral'),
                  titulo: 'Desconto geral',
                  tiposPermitidos: _ordemDesconto,
                  tipoInicial: state.descontoTipo,
                  textoInicial: state.valorDescontoAplicado > 0
                      ? state.descontoValorTexto
                      : '',
                  temValor: state.valorDescontoAplicado > 0,
                  onAplicar: (tipo, texto) {
                    bloc.add(
                      PagamentosRealizadosDescontoAlterado(
                        tipo: tipo,
                        valorTexto: texto,
                      ),
                    );
                    descontoGeralAberto.value = false;
                  },
                  onRemover: () {
                    bloc.add(
                      const PagamentosRealizadosDescontoAlterado(
                        tipo: null,
                        valorTexto: '',
                      ),
                    );
                    descontoGeralAberto.value = false;
                  },
                  onFechar: () => descontoGeralAberto.value = false,
                )
              : const SizedBox.shrink(),
        ),
      if (_r.resgatePontos &&
          state.clienteElegivelFidelidade &&
          state.opcoesResgate != null)
        _Pontos(
          state: state,
          editavel: _editavel,
          aoFecharPainel: aoFecharPainel,
        ),
      if (_r.creditoCliente && state.pessoaId != null && !state.clienteGenerico)
        _Linha(
          'Crédito de devolução',
          state.carregandoSaldoCreditoDevolucao
              ? '…'
              : pagamentoMoeda(state.saldoCreditoDevolucao),
        ),
      if (_r.taxaEntrega)
        _TaxaEntrega(
            state: state,
            editavel: state.step == PagamentosRealizadosStep.editando,
            aoFecharPainel: aoFecharPainel)
      else if (contexto.origem == PagamentoOrigem.pedido)
        _Linha(
          'Entrega',
          state.valorTaxaEntregaAplicado > 0
              ? pagamentoMoeda(state.valorTaxaEntregaAplicado)
              : 'na entrega',
        ),
      for (final a in contexto.abatimentos)
        _Linha(a.rotulo, '−${pagamentoMoeda(a.valor)}'),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: cores.hairline)),
        ),
        child: Row(
          children: [
            Text('A PAGAR', style: textos.rotulo),
            const Spacer(),
            Text(
              pagamentoMoeda(state.valorTotalAPagar),
              style: textos.valor.copyWith(fontSize: 30),
            ),
          ],
        ),
      ),
    ];

    if (!fixarTotais) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [...topo, ...totais],
      );
    }
    // hasScrollBody:false = Spacer cola o extrato no fim; rola se não couber.
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [...topo, const Spacer(), ...totais],
          ),
        ),
      ],
    );
  }
}

class _Acao {
  final String rotulo;
  final VoidCallback onTap;

  const _Acao(this.rotulo, this.onTap);
}

class _Linha extends StatelessWidget {
  final String rotulo;
  final String valor;
  final _Acao? acao;

  const _Linha(this.rotulo, this.valor, {this.acao});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(rotulo, style: textos.corpo),
          if (acao != null) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: acao!.onTap,
              child: Text(
                acao!.rotulo,
                style: textos.apoio.copyWith(
                  color: cores.aco,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
          const Spacer(),
          Text(valor, style: textos.corpo),
        ],
      ),
    );
  }
}

class _Pontos extends StatefulWidget {
  final PagamentosRealizadosState state;
  final bool editavel;
  final VoidCallback? aoFecharPainel;

  const _Pontos({
    required this.state,
    required this.editavel,
    this.aoFecharPainel,
  });

  @override
  State<_Pontos> createState() => _PontosState();
}

class _PontosState extends State<_Pontos> {
  bool _aberto = false;
  late final _controller =
      TextEditingController(text: widget.state.resgatePontos?.toString() ?? '');
  final _foco = FocusNode();

  void _alternar() {
    setState(() => _aberto = !_aberto);
    if (_aberto) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _foco.requestFocus();
      });
    } else {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => widget.aoFecharPainel?.call());
    }
  }

  void _escolher({int? faixaId, int? pontos}) {
    context.read<PagamentosRealizadosBloc>().add(
          PagamentosRealizadosResgateEscolhido(
            faixaId: faixaId,
            pontos: pontos,
          ),
        );
    _alternar();
  }

  @override
  void dispose() {
    _foco.dispose();
    _controller.dispose();
    super.dispose();
  }

  static String _faixa(FaixaResgate f) =>
      '${f.pontos} pts → ${f.ehPercentual ? '${f.valor.toStringAsFixed(f.valor == f.valor.roundToDouble() ? 0 : 2)}%' : pagamentoMoeda(f.valor)}';

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final state = widget.state;
    final opcoes = state.opcoesResgate!;
    final vpp = opcoes.valorPorPonto;
    final motivoLivres = state.motivoPontosLivresIndisponivel;
    final pontos = int.tryParse(_controller.text.trim());
    final pontosValidos =
        pontos != null && pontos >= 1 && pontos <= state.maxPontosLivres;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Linha(
          'Pontos (saldo ${opcoes.saldo})',
          state.possuiResgate
              ? '−${pagamentoMoeda(state.valorDescontoResgate)}'
              : '—',
          acao: widget.editavel && opcoes.possuiOpcoes
              ? _Acao(state.possuiResgate ? 'alterar' : 'resgatar', _alternar)
              : null,
        ),
        if (_aberto && widget.editavel && opcoes.possuiOpcoes)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cores.superficieRecuada,
              border: Border.all(color: cores.hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('RESGATAR PONTOS', style: textos.rotulo),
                for (final faixa in opcoes.faixas)
                  Builder(builder: (_) {
                    final motivo = state.motivoFaixaIndisponivel(faixa);
                    return Opacity(
                      opacity: motivo == null ? 1 : 0.5,
                      child: InkWell(
                        onTap: motivo != null
                            ? null
                            : () => _escolher(faixaId: faixa.id),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Icon(
                                state.resgateFaixaId == faixa.id
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(_faixa(faixa), style: textos.corpo),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  motivo ??
                                      (faixa.cumulativo
                                          ? 'Cumulativo'
                                          : 'Não cumulativo'),
                                  style: textos.apoio,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                if (vpp != null) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _controller,
                    focusNode: _foco,
                    enabled: motivoLivres == null,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Usar pontos (1 a ${state.maxPontosLivres})',
                      helperText: motivoLivres ??
                          (pontosValidos
                              ? 'Desconto: ${pagamentoMoeda(double.parse((pontos * vpp).toStringAsFixed(2)))}'
                              : '${pagamentoMoeda(vpp)} por ponto'),
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) {
                      if (pontosValidos) _escolher(pontos: pontos);
                    },
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: _alternar, child: const Text('Fechar')),
                    if (state.possuiResgate)
                      TextButton(
                        onPressed: _escolher,
                        child: const Text('Remover'),
                      ),
                    if (vpp != null)
                      FilledButton(
                        onPressed: motivoLivres == null && pontosValidos
                            ? () => _escolher(pontos: pontos)
                            : null,
                        child: const Text('Aplicar'),
                      ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TaxaEntrega extends StatefulWidget {
  final PagamentosRealizadosState state;
  final bool editavel;

  final VoidCallback? aoFecharPainel;

  const _TaxaEntrega({
    required this.state,
    required this.editavel,
    this.aoFecharPainel,
  });

  @override
  State<_TaxaEntrega> createState() => _TaxaEntregaState();
}

class _TaxaEntregaState extends State<_TaxaEntrega> {
  bool _aberto = false;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final bloc = context.read<PagamentosRealizadosBloc>();
    final tem = state.valorTaxaEntregaAplicado > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Linha(
          'Entrega',
          tem ? pagamentoMoeda(state.valorTaxaEntregaAplicado) : '—',
          acao: widget.editavel
              ? _Acao(tem ? 'editar' : 'adicionar',
                  () => setState(() => _aberto = !_aberto))
              : null,
        ),
        if (_aberto)
          _PainelValor(
            aoFechar: widget.aoFecharPainel,
            titulo: 'Taxa de entrega paga pelo cliente',
            textoInicial: tem ? state.taxaEntregaValorTexto : '',
            temValor: tem,
            onAplicar: (_, texto) {
              bloc.add(
                  PagamentosRealizadosTaxaEntregaAlterada(valorTexto: texto));
              setState(() => _aberto = false);
            },
            onRemover: () {
              bloc.add(
                const PagamentosRealizadosTaxaEntregaAlterada(valorTexto: ''),
              );
              setState(() => _aberto = false);
            },
            onFechar: () => setState(() => _aberto = false),
          ),
      ],
    );
  }
}

class _ItemResumo extends StatefulWidget {
  final ProdutoCompartilhado produto;
  final PagamentosRealizadosState state;
  final bool podeDescontoItem;
  final bool podePromocao;
  final VoidCallback? aoFecharPainel;

  const _ItemResumo({
    super.key,
    this.aoFecharPainel,
    required this.produto,
    required this.state,
    required this.podeDescontoItem,
    required this.podePromocao,
  });

  @override
  State<_ItemResumo> createState() => _ItemResumoState();
}

class _ItemResumoState extends State<_ItemResumo> {
  bool _aberto = false;

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final bloc = context.read<PagamentosRealizadosBloc>();
    final produto = widget.produto;
    final state = widget.state;
    final id = produto.produtoId;

    final bruto = produto.quantidade * produto.valorUnitario;
    final manual = state.descontosItensAplicado[id] ?? 0;
    final promocao = state.promocaoEscolhidaPorItem[id];
    final cupons = state.cuponsEscolhidosPorItem[id] ?? const <OpcaoElegivel>[];
    // Prévia só recalcula por forma quando há 1 forma escolhida (o cálculo
    // final é do backend, ver formaDePagamentoUnicaId no state).
    final promocaoUnit = promocao?.valorDescontoParaForma(
          state.formaDePagamentoUnicaId,
          valorUnitario: produto.valorUnitario,
        ) ??
        0;
    final manualUnit =
        produto.quantidade > 0 ? manual / produto.quantidade : 0.0;
    final descontoPromo = (promocaoUnit +
            PagamentosRealizadosState.descontoCuponsUnitario(
              cupons,
              produto.valorUnitario,
              jaDescontadoUnitario: promocaoUnit + manualUnit,
            )) *
        produto.quantidade;
    final liquido = bruto - manual - descontoPromo;
    final temDesconto = manual > 0 || descontoPromo > 0;
    final variacao = [
      if (produto.corNome.isNotEmpty) produto.corNome,
      if (produto.tamanhoNome.isNotEmpty) produto.tamanhoNome,
    ].join(' · ');
    final opcoes = (state.opcoesElegiveisPorItem[id] ?? const <OpcaoElegivel>[])
        .where((o) => !o.ehCupom)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(produto.nome, style: textos.corpo),
                    Text(
                      [
                        if (variacao.isNotEmpty) variacao,
                        '${produto.quantidade} × ${pagamentoMoeda(produto.valorUnitario)}',
                      ].join(' · '),
                      style: textos.apoio,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (temDesconto)
                    Text(
                      pagamentoMoeda(bruto),
                      style: textos.apoio.copyWith(
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text(pagamentoMoeda(liquido), style: textos.corpo),
                ],
              ),
              if (widget.podeDescontoItem || widget.podePromocao)
                IconButton(
                  tooltip: 'Desconto do item',
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.percent,
                    size: 18,
                    color: _aberto || temDesconto ? cores.aco : null,
                  ),
                  onPressed: () => setState(() => _aberto = !_aberto),
                ),
            ],
          ),
          if (promocao != null)
            SivAvisoAtencao(
              '${promocao.nome} · −${pagamentoMoeda(promocaoUnit * produto.quantidade)}',
            ),
          if (cupons.isNotEmpty)
            SivAvisoAtencao(
              cupons.map((o) => o.codigo ?? o.nome).join(' + '),
            ),
          if (_aberto) ...[
            if (widget.podeDescontoItem)
              _PainelValor(
                aoFechar: widget.aoFecharPainel,
                titulo: 'Desconto no item',
                tiposPermitidos: _ordemDesconto,
                // O bloc semeia R$ em todo item; sem desconto aplicado vale o padrão (%).
                tipoInicial: manual > 0 ? state.descontosItensTipo[id] : null,
                textoInicial: manual > 0
                    ? (state.descontosItensValorTexto[id] ?? '')
                    : '',
                temValor: manual > 0,
                onAplicar: (tipo, texto) {
                  bloc.add(
                    PagamentosRealizadosDescontoItemAlterado(
                      produtoId: id,
                      tipo: tipo,
                      valorTexto: texto,
                    ),
                  );
                  setState(() => _aberto = false);
                },
                onRemover: () {
                  bloc.add(
                    PagamentosRealizadosDescontoItemAlterado(
                      produtoId: id,
                      tipo: null,
                      valorTexto: '',
                    ),
                  );
                  setState(() => _aberto = false);
                },
                onFechar: () => setState(() => _aberto = false),
              ),
            if (widget.podePromocao && opcoes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('PROMOÇÃO DO ITEM', style: textos.rotulo),
              _OpcaoPromocao(
                rotulo: 'Nenhuma',
                marcado: promocao == null,
                onTap: () => bloc.add(
                  PagamentosRealizadosPromocaoEscolhida(
                    produtoId: id,
                    opcao: null,
                  ),
                ),
              ),
              for (final o in opcoes)
                _OpcaoPromocao(
                  rotulo:
                      '${o.nome} · −${pagamentoMoeda(o.valorDesconto)} por unidade',
                  marcado: promocao?.id == o.id,
                  onTap: () => bloc.add(
                    PagamentosRealizadosPromocaoEscolhida(
                      produtoId: id,
                      opcao: o,
                    ),
                  ),
                ),
            ],
          ],
          const Divider(height: 12),
        ],
      ),
    );
  }
}

class _OpcaoPromocao extends StatelessWidget {
  final String rotulo;
  final bool marcado;
  final VoidCallback onTap;

  const _OpcaoPromocao({
    required this.rotulo,
    required this.marcado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              marcado ? Icons.check_box : Icons.check_box_outline_blank,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(rotulo, style: textos.corpo)),
          ],
        ),
      ),
    );
  }
}

/// Ordem dos tipos no painel de desconto; o primeiro é o padrão.
const _ordemDesconto = [
  DescontoTipo.porcentagem,
  DescontoTipo.valorBruto,
  DescontoTipo.forcaValorTotal,
];

/// Painel inline (no lugar de AlertDialog) para valor de desconto/taxa.
class _PainelValor extends StatefulWidget {
  final String titulo;
  final List<DescontoTipo>? tiposPermitidos;
  final DescontoTipo? tipoInicial;
  final String textoInicial;
  final bool temValor;
  final void Function(DescontoTipo? tipo, String texto) onAplicar;
  final VoidCallback onRemover;
  final VoidCallback onFechar;
  final VoidCallback? aoFechar;

  const _PainelValor({
    super.key,
    this.aoFechar,
    required this.titulo,
    this.tiposPermitidos,
    this.tipoInicial,
    required this.textoInicial,
    required this.temValor,
    required this.onAplicar,
    required this.onRemover,
    required this.onFechar,
  });

  @override
  State<_PainelValor> createState() => _PainelValorState();
}

class _PainelValorState extends State<_PainelValor> {
  late DescontoTipo? _tipo = widget.tiposPermitidos == null
      ? null
      : (widget.tipoInicial ?? DescontoTipo.porcentagem);
  late final _controller = TextEditingController(text: widget.textoInicial);
  final _foco = FocusNode();

  // O autofocus do TextField não vale com o foco já em outro nó da etapa.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _foco.requestFocus();
      _controller.selection =
          TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
    });
  }

  static const _rotulos = {
    DescontoTipo.valorBruto: 'R\$',
    DescontoTipo.porcentagem: '%',
    DescontoTipo.forcaValorTotal: 'Total',
  };

  @override
  void dispose() {
    final aoFechar = widget.aoFechar;
    if (aoFechar != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => aoFechar());
    }
    _foco.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cores.superficieRecuada,
        border: Border.all(color: cores.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.titulo.toUpperCase(), style: textos.rotulo),
          const SizedBox(height: 8),
          if (widget.tiposPermitidos != null) ...[
            Row(
              children: [
                for (final t in widget.tiposPermitidos!)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceButton(
                      rotulo: _rotulos[t]!,
                      selecionado: _tipo == t,
                      onTap: () => setState(() {
                        _tipo = t;
                        _controller.clear();
                      }),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          TextField(
            controller: _controller,
            focusNode: _foco,
            inputFormatters: [pagamentoDecimalFormatter],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              isDense: true,
              hintText: _tipo == DescontoTipo.porcentagem
                  ? 'Percentual (0 a 100)'
                  : _tipo == DescontoTipo.forcaValorTotal
                      ? 'Novo valor total'
                      : 'Valor',
            ),
            onSubmitted: (_) => widget.onAplicar(_tipo, _controller.text),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: widget.onFechar, child: const Text('Fechar')),
              if (widget.temValor)
                TextButton(
                  onPressed: widget.onRemover,
                  child: const Text('Remover'),
                ),
              FilledButton(
                onPressed: () => widget.onAplicar(_tipo, _controller.text),
                child: const Text('Aplicar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Botão de opção (substitui Chip/ChoiceChip do Material).
class ChoiceButton extends StatelessWidget {
  final String rotulo;
  final bool selecionado;
  final VoidCallback? onTap;

  const ChoiceButton({
    super.key,
    required this.rotulo,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 36, minWidth: 48),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selecionado ? cores.acoEscuro : cores.superficie,
          border: Border.all(color: cores.hairline),
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
        ),
        child: Text(
          rotulo,
          style: textos.corpo.copyWith(
            color: selecionado
                ? cores.textoSobreEscuroTitulo
                : cores.textoPrincipal,
          ),
        ),
      ),
    );
  }
}

class _Cupom extends StatefulWidget {
  final PagamentosRealizadosState state;
  final bool habilitado;

  const _Cupom({required this.state, required this.habilitado});

  @override
  State<_Cupom> createState() => _CupomState();
}

class _CupomState extends State<_Cupom> {
  final _controller = TextEditingController();

  @override
  void didUpdateWidget(covariant _Cupom old) {
    super.didUpdateWidget(old);
    if (widget.state.cuponsAplicados.length >
        old.state.cuponsAplicados.length) {
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _aplicar(BuildContext context) {
    final codigo = _controller.text.trim();
    if (codigo.isEmpty) return;
    context
        .read<PagamentosRealizadosBloc>()
        .add(PagamentosRealizadosCupomInformado(codigo: codigo));
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final state = widget.state;
    final bloc = context.read<PagamentosRealizadosBloc>();
    final ocupado = state.carregandoElegibilidade;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final codigo in state.cuponsAplicados)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.confirmation_number_outlined, size: 16),
                const SizedBox(width: 6),
                Text('Cupom $codigo', style: textos.corpo),
                const Spacer(),
                if (widget.habilitado)
                  InkWell(
                    onTap: () => bloc.add(
                      PagamentosRealizadosCupomRemovido(codigo: codigo),
                    ),
                    child: Text(
                      'remover',
                      style: textos.apoio.copyWith(
                        color: cores.aco,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (widget.habilitado && state.podeAdicionarCupom)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: !ocupado,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: state.possuiCupomAplicado
                        ? 'Adicionar outro cupom'
                        : 'Código do cupom',
                    errorText: state.cupomErro,
                  ),
                  onSubmitted: (_) => _aplicar(context),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: ocupado ? null : () => _aplicar(context),
                child: ocupado
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Aplicar'),
              ),
            ],
          )
        else if (widget.habilitado)
          Text(
            'Máximo de ${PagamentosRealizadosState.maxCupons} cupons por venda.',
            style: textos.apoio,
          ),
      ],
    );
  }
}

class _PromocoesDisponiveis extends StatefulWidget {
  final PagamentosRealizadosState state;

  const _PromocoesDisponiveis({required this.state});

  @override
  State<_PromocoesDisponiveis> createState() => _PromocoesDisponiveisState();
}

class _PromocoesDisponiveisState extends State<_PromocoesDisponiveis> {
  bool _aberto = false;

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final state = widget.state;
    final bloc = context.read<PagamentosRealizadosBloc>();
    final promocoes = _promocoesDistintas(state.opcoesElegiveisPorItem);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() => _aberto = !_aberto),
            icon: const Icon(Icons.local_offer_outlined, size: 16),
            label: Text('Promoções disponíveis (${promocoes.length})'),
          ),
        ),
        if (_aberto)
          for (final promocao in promocoes)
            Builder(builder: (context) {
              final elegiveis = state.opcoesElegiveisPorItem.entries
                  .where((e) =>
                      e.value.any((o) => o.id == promocao.id && !o.ehCupom))
                  .map((e) => e.key)
                  .toList();
              bool escolhida(int p) {
                final a = state.promocaoEscolhidaPorItem[p];
                return a != null && a.id == promocao.id && !a.ehCupom;
              }

              bool conflita(int p) {
                final a = state.promocaoEscolhidaPorItem[p];
                return a != null && a.id != promocao.id && !a.ehCupom;
              }

              final marcado = elegiveis.any(escolhida);
              final conflitantes = elegiveis.where(conflita).toList();
              final bloqueada = !marcado && conflitantes.isNotEmpty;

              return Opacity(
                opacity: bloqueada ? 0.5 : 1,
                child: _OpcaoPromocao(
                  rotulo: bloqueada
                      ? '${promocao.nome} · conflita com '
                          '${state.promocaoEscolhidaPorItem[conflitantes.first]!.nome}'
                      : '${promocao.nome} · ${elegiveis.length} produto(s)',
                  marcado: marcado,
                  onTap: bloqueada
                      ? () {}
                      : () => bloc.add(
                            PagamentosRealizadosPromocaoGlobalAlterada(
                              promocaoId: promocao.id,
                              marcado: !marcado,
                            ),
                          ),
                ),
              );
            }),
        if (_aberto && promocoes.isEmpty)
          Text('Nenhuma promoção.', style: textos.apoio),
      ],
    );
  }
}
