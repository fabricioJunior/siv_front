import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Enum real do backend (SituacaoPedido): em_andamento, conferido, faturado, encerrado, cancelado.
// 'pago' e' situacaoPagamento, dimensao separada, exibida como mais um chip.
const _situacoesFiltro = [
  'em_andamento',
  'conferido',
  'faturado',
  'encerrado',
  'cancelado',
  'pago',
];

SivEtiquetaSituacao _etiquetaSituacao(String? situacao) =>
    switch (situacao?.toLowerCase()) {
      'em_andamento' => SivEtiquetaSituacao.emAndamento,
      'conferido' => SivEtiquetaSituacao.conferido,
      'faturado' => SivEtiquetaSituacao.faturado,
      'encerrado' => SivEtiquetaSituacao.encerrado,
      'cancelado' => SivEtiquetaSituacao.cancelado,
      _ => SivEtiquetaSituacao.emAndamento,
    };

String _labelSituacaoPedido(String? situacao) =>
    switch (situacao?.toLowerCase()) {
      'em_andamento' => 'Em andamento',
      'conferido' => 'Conferido',
      'faturado' => 'Faturado',
      'encerrado' => 'Encerrado',
      'cancelado' => 'Cancelado',
      _ => situacao ?? '-',
    };

String _labelFiltroSituacao(String filtro) =>
    filtro == 'pago' ? 'Pago' : _labelSituacaoPedido(filtro);

String _data(DateTime? dt) {
  if (dt == null) return '-';
  final local = dt.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}';
}

String _moeda(double? valor) {
  if (valor == null) return '-';
  return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
}

class PedidosPage extends StatefulWidget {
  const PedidosPage({super.key});

  @override
  State<PedidosPage> createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  late final PedidosBloc _bloc;
  final _buscaController = TextEditingController();
  final _buscaDebouncer = Debouncer(milliseconds: 350);
  final _scrollController = ScrollController();
  final _chipsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _bloc = sl<PedidosBloc>()..add(PedidosIniciou());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _bloc.add(PedidosCarregarMais());
      }
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    _buscaDebouncer.cancel();
    _scrollController.dispose();
    _chipsScrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  bool get _telaDesktop =>
      MediaQuery.sizeOf(context).width >= SivDimensoes.breakpointMenuDrawer;

  Widget _botaoNovoPedido(BuildContext context) => FilledButton.icon(
        onPressed: () async {
          await Navigator.pushNamed(context, '/pedido');
          if (mounted) _bloc.add(PedidosIniciou());
        },
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Novo pedido'),
      );

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PedidosBloc>.value(
      value: _bloc,
      child: BlocBuilder<PedidosBloc, PedidosState>(
        builder: (context, state) {
          final desktop = _telaDesktop;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: SivDimensoes.gapCards),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [_botaoNovoPedido(context)],
                ),
              ),
              _buildBuscaEPeriodo(context, state, desktop: desktop),
              const SizedBox(height: 12),
              _buildChipsSituacao(context, state),
              const SizedBox(height: SivDimensoes.gapCards),
              Expanded(
                child: desktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: _buildConteudoTabela(context, state)),
                          const SizedBox(width: SivDimensoes.gapCards),
                          SizedBox(
                            width: 400,
                            child: SingleChildScrollView(
                              child: _buildPainelDireito(context, state),
                            ),
                          ),
                        ],
                      )
                    : _buildListaMobile(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBuscaEPeriodo(BuildContext context, PedidosState state,
      {required bool desktop}) {
    final temPeriodo = state.dataInicial != null || state.dataFinal != null;
    final busca = TextField(
      controller: _buscaController,
      decoration: InputDecoration(
        hintText: 'Buscar por ID, pessoa ou situação',
        prefixIcon: const Icon(Icons.search_outlined),
        suffixIcon: _buscaController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _buscaController.clear();
                  setState(() {});
                  _bloc.add(PedidosBuscaAlterada(''));
                },
              )
            : null,
      ),
      onChanged: (v) {
        setState(() {});
        _buscaDebouncer.run(() => _bloc.add(PedidosBuscaAlterada(v)));
      },
    );

    final botaoPeriodo = OutlinedButton.icon(
      onPressed: () => _abrirFiltroPeriodo(context, state),
      icon: const Icon(Icons.date_range_outlined, size: 18),
      label: Text(
        temPeriodo
            ? '${_data(state.dataInicial)} — ${_data(state.dataFinal)}'
            : 'Período',
      ),
    );

    final botaoLimpar = temPeriodo
        ? IconButton(
            tooltip: 'Limpar período',
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => _bloc.add(PedidosFiltroPeriodoAlterado()),
          )
        : null;

    if (!desktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          busca,
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: botaoPeriodo),
              if (botaoLimpar != null) botaoLimpar,
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: busca),
        const SizedBox(width: 12),
        botaoPeriodo,
        if (botaoLimpar != null) botaoLimpar,
      ],
    );
  }

  Future<void> _abrirFiltroPeriodo(
      BuildContext context, PedidosState state) async {
    final agora = DateTime.now();
    final selecionado = await abrirFiltroPeriodoSheet(
      context: context,
      dataInicioAtual:
          state.dataInicial ?? DateTime(agora.year, agora.month, 1),
      dataFimAtual: state.dataFinal ?? agora,
      permitirHora: false,
    );
    if (selecionado == null) return;
    _bloc.add(
      PedidosFiltroPeriodoAlterado(
        dataInicial: selecionado.dataInicio,
        dataFinal: selecionado.dataFim,
      ),
    );
  }

  int _contarSituacao(List<Pedido> pedidos, String filtro) {
    return pedidos.where((pedido) {
      if (filtro == 'pago') {
        return (pedido.situacaoPagamento ?? '').toLowerCase() == 'pago';
      }
      return (pedido.situacao ?? '').toLowerCase() == filtro;
    }).length;
  }

  int? _contarSituacaoDaContagem(
    ContagemPedidosPorSituacao? contagem,
    String filtro,
  ) {
    if (contagem == null) return null;
    return filtro == 'pago' ? contagem.pago : contagem.contar(filtro);
  }

  // Usuário não descobre sozinho que dá pra arrastar a lista com o mouse (drag-to-scroll não
  // vem habilitado por padrão pra ponteiro de mouse no Flutter, só toque/trackpad) -- habilita
  // via ScrollConfiguration e soma botões de seta como alternativa explícita e descobrível.
  void _rolarChips(double delta) {
    final posicao = _chipsScrollController.position;
    final destino = (posicao.pixels + delta).clamp(
      posicao.minScrollExtent,
      posicao.maxScrollExtent,
    );
    _chipsScrollController.animateTo(
      destino,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  Widget _buildChipsSituacao(BuildContext context, PedidosState state) {
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Rolar filtros pra esquerda',
            onPressed: () => _rolarChips(-150),
          ),
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  ...PointerDeviceKind.values,
                },
              ),
              child: ListView(
                controller: _chipsScrollController,
                scrollDirection: Axis.horizontal,
                children: [
                  _ChipSituacao(
                    label:
                        'Todos (${state.contagem?.total ?? state.pedidos.length})',
                    selecionado: state.situacoesFiltro.isEmpty,
                    onTap: () =>
                        _bloc.add(PedidosFiltroSituacaoAlterado(const {})),
                  ),
                  for (final situacao in _situacoesFiltro)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _ChipSituacao(
                        label: '${_labelFiltroSituacao(situacao)} '
                            '(${_contarSituacaoDaContagem(state.contagem, situacao) ?? _contarSituacao(state.pedidos, situacao)})',
                        selecionado: state.situacoesFiltro.contains(situacao),
                        onTap: () {
                          final atualizado =
                              Set<String>.from(state.situacoesFiltro);
                          if (!atualizado.remove(situacao)) {
                            atualizado.add(situacao);
                          }
                          _bloc.add(PedidosFiltroSituacaoAlterado(atualizado));
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Rolar filtros pra direita',
            onPressed: () => _rolarChips(150),
          ),
        ],
      ),
    );
  }

  Widget _buildConteudoTabela(BuildContext context, PedidosState state) {
    if (state.step == PedidosStep.carregando) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (state.step == PedidosStep.falha) {
      return _EstadoVazio(
        icone: Icons.error_outline,
        titulo: 'Falha ao carregar',
        descricao: state.erro ?? 'Não foi possível carregar os pedidos.',
        acao: TextButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Tentar novamente'),
          onPressed: () => _bloc.add(PedidosIniciou()),
        ),
      );
    }
    if (state.pedidos.isEmpty) {
      return _EstadoVazio(
        icone: Icons.receipt_long_outlined,
        titulo: state.busca.isNotEmpty
            ? 'Nenhum resultado pra busca'
            : 'Nenhum pedido por aqui',
        descricao: state.busca.isNotEmpty
            ? 'Tente outro termo de busca.'
            : 'Crie um novo pedido pra começar.',
      );
    }

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SivTabela(
            colunas: const [
              SivTabelaColuna.numerica(titulo: 'Nº', flex: 1),
              SivTabelaColuna(titulo: 'CLIENTE', flex: 3),
              SivTabelaColuna(titulo: 'SITUAÇÃO', flex: 2),
              SivTabelaColuna(titulo: 'ENTREGA', flex: 2),
              SivTabelaColuna.numerica(titulo: 'VALOR', flex: 2),
            ],
            quantidadeLinhas: state.pedidos.length,
            linhaSelecionada: (indice) =>
                state.pedidos[indice].id == state.pedidoSelecionadoId,
            onLinhaTap: (indice) =>
                _bloc.add(PedidosPedidoSelecionou(state.pedidos[indice].id)),
            linhaBuilder: (context, indice) {
              final pedido = state.pedidos[indice];
              final cancelado = pedido.situacao?.toLowerCase() == 'cancelado';
              final entrega = pedido.modalidadeEntrega == 'entrega'
                  ? 'Entrega · ${_data(pedido.previsaoDeEntrega)}'
                  : 'Retirada · ${_data(pedido.previsaoDeEntrega)}';

              final celulas = <Widget>[
                Text('#${pedido.id ?? '-'}', style: context.sivTextos.apoio),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pedido.pessoaNome?.toUpperCase() ??
                          (pedido.pessoaId != null
                              ? 'Pessoa #${pedido.pessoaId}'
                              : '-'),
                      style: context.sivTextos.corpo,
                    ),
                    // TODO: cidade do cliente e nome do terminal não estão
                    // disponíveis em Pedido hoje -- mostra só o vendedor.
                    Text(
                      pedido.funcionarioNome?.toUpperCase() ?? '-',
                      style: context.sivTextos.apoio,
                    ),
                  ],
                ),
                SivEtiqueta(
                  situacao: _etiquetaSituacao(pedido.situacao),
                  texto: _labelSituacaoPedido(pedido.situacao),
                ),
                Text(entrega, style: context.sivTextos.apoio),
                Text(_moeda(pedido.valorTotal), style: context.sivTextos.corpo),
              ];

              return cancelado
                  ? celulas.map((w) => Opacity(opacity: 0.6, child: w)).toList()
                  : celulas;
            },
          ),
          if (state.carregandoMais)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListaMobile(BuildContext context, PedidosState state) {
    if (state.step == PedidosStep.carregando) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (state.step == PedidosStep.falha) {
      return _EstadoVazio(
        icone: Icons.error_outline,
        titulo: 'Falha ao carregar',
        descricao: state.erro ?? 'Não foi possível carregar os pedidos.',
        acao: TextButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Tentar novamente'),
          onPressed: () => _bloc.add(PedidosIniciou()),
        ),
      );
    }
    if (state.pedidos.isEmpty) {
      return _EstadoVazio(
        icone: Icons.receipt_long_outlined,
        titulo: state.busca.isNotEmpty
            ? 'Nenhum resultado pra busca'
            : 'Nenhum pedido por aqui',
        descricao: state.busca.isNotEmpty
            ? 'Tente outro termo de busca.'
            : 'Crie um novo pedido pra começar.',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.pedidos.length + (state.carregandoMais ? 1 : 0),
      itemBuilder: (context, indice) {
        if (indice == state.pedidos.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator.adaptive(strokeWidth: 2.5),
              ),
            ),
          );
        }
        final pedido = state.pedidos[indice];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _CardPedido(
            pedido: pedido,
            onTap: () {
              _bloc.add(PedidosPedidoSelecionou(pedido.id));
              _abrirDetalheMobile(context);
            },
          ),
        );
      },
    );
  }

  Future<void> _abrirDetalheMobile(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Detalhes do pedido')),
          body: BlocProvider<PedidosBloc>.value(
            value: _bloc,
            child: BlocBuilder<PedidosBloc, PedidosState>(
              builder: (context, state) => SingleChildScrollView(
                padding: const EdgeInsets.all(SivDimensoes.paginaHorizontal),
                child: _buildPainelDireito(context, state),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPainelDireito(BuildContext context, PedidosState state) {
    final pedido = state.pedidoSelecionado;
    if (pedido == null) {
      return SivCard(
        child: Text(
          'Selecione um pedido pra ver os detalhes.',
          style: context.sivTextos.corpo,
        ),
      );
    }
    return _PainelPedido(
      pedido: pedido,
      itens: state.itensDoPedidoSelecionado,
      carregandoItens: state.carregandoItensDoPedidoSelecionado,
      onAbrirPedido: () async {
        await Navigator.pushNamed(context, '/pedido',
            arguments: {'idPedido': pedido.id});
        if (mounted) _bloc.add(PedidosIniciou());
      },
      onCancelar: () => _cancelarPedido(context, pedido),
    );
  }

  Future<void> _cancelarPedido(BuildContext context, Pedido pedido) async {
    final motivoController = TextEditingController();
    await SivDialogo.mostrar(
      context,
      titulo: 'Cancelar pedido #${pedido.id}',
      corpo: TextField(
        controller: motivoController,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Motivo do cancelamento'),
      ),
      textoAcao: 'Cancelar pedido',
      onConfirmar: (_) {
        final motivo = motivoController.text.trim();
        if (motivo.isEmpty || pedido.id == null) return;
        _bloc
            .add(PedidosPedidoCancelou(pedido.id!, motivoCancelamento: motivo));
      },
    );
  }
}

class _ChipSituacao extends StatelessWidget {
  final String label;
  final bool selecionado;
  final VoidCallback onTap;

  const _ChipSituacao(
      {required this.label, required this.selecionado, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Center(
        child: ChoiceChip(
          label: Text(label),
          selected: selecionado,
          onSelected: (_) => onTap(),
        ),
      ),
    );
  }
}

class _CardPedido extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback onTap;

  const _CardPedido({required this.pedido, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    final cancelado = pedido.situacao?.toLowerCase() == 'cancelado';
    final entrega = pedido.modalidadeEntrega == 'entrega'
        ? 'Entrega · ${_data(pedido.previsaoDeEntrega)}'
        : 'Retirada · ${_data(pedido.previsaoDeEntrega)}';

    return Opacity(
      opacity: cancelado ? 0.6 : 1,
      // InkWell precisa de Material ancestor -- mesmo bug já corrigido em
      // ecommerces_page.dart/ecommerce_referencias_page.dart.
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: cores.hairline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('#${pedido.id ?? '-'}', style: textos.corpo),
                    const SizedBox(width: 8),
                    SivEtiqueta(
                      situacao: _etiquetaSituacao(pedido.situacao),
                      texto: _labelSituacaoPedido(pedido.situacao),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  pedido.pessoaNome?.toUpperCase() ??
                      (pedido.pessoaId != null
                          ? 'Pessoa #${pedido.pessoaId}'
                          : '-'),
                  style: textos.corpo,
                ),
                const SizedBox(height: 2),
                Text(pedido.funcionarioNome?.toUpperCase() ?? '-',
                    style: textos.apoio),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entrega, style: textos.apoio),
                    Text(_moeda(pedido.valorTotal), style: textos.corpo),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String descricao;
  final Widget? acao;

  const _EstadoVazio({
    required this.icone,
    required this.titulo,
    required this.descricao,
    this.acao,
  });

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 40, color: context.sivColors.textoApoio),
            const SizedBox(height: 12),
            Text(titulo, style: textos.secao, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(descricao, style: textos.corpo, textAlign: TextAlign.center),
            if (acao != null) ...[const SizedBox(height: 12), acao!],
          ],
        ),
      ),
    );
  }
}

class _PainelPedido extends StatelessWidget {
  final Pedido pedido;
  final List<PedidoItem> itens;
  final bool carregandoItens;
  final VoidCallback onAbrirPedido;
  final VoidCallback onCancelar;

  const _PainelPedido({
    required this.pedido,
    required this.itens,
    required this.carregandoItens,
    required this.onAbrirPedido,
    required this.onCancelar,
  });

  bool get _cancelado => pedido.situacao?.toLowerCase() == 'cancelado';

  bool get _podeCancelar {
    final situacao = pedido.situacao?.toLowerCase();
    return situacao != 'encerrado' &&
        situacao != 'faturado' &&
        situacao != 'cancelado';
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SivCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pedido #${pedido.id ?? '-'}', style: textos.secao),
              const SizedBox(height: 4),
              Text(
                pedido.pessoaNome?.toUpperCase() ?? '-',
                style: textos.corpo.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Abertura: ${_data(pedido.criadoEm)}   ·   Vendedor: ${pedido.funcionarioNome ?? '-'}',
                style: textos.apoio,
              ),
              // TODO: terminal de abertura não está disponível em Pedido
              // hoje (só existe em Romaneio/Caixa) -- sem esse campo pra
              // mostrar aqui.
              const SizedBox(height: 16),
              if (_cancelado)
                SivEtiqueta(
                    situacao: SivEtiquetaSituacao.cancelado,
                    texto: 'Pedido cancelado')
              else
                SivTrilhaDeProgresso(passos: _passosTrilha(pedido)),
            ],
          ),
        ),
        const SizedBox(height: SivDimensoes.gapCards),
        SivCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _linha(context, 'Itens',
                  carregandoItens ? '...' : '${itens.length}'),
              _linha(
                context,
                'Entrega',
                pedido.modalidadeEntrega == 'entrega'
                    ? 'Entrega'
                    : 'Retirada em loja',
              ),
              _linha(
                  context, 'Pagamento', pedido.situacaoPagamento ?? 'Pendente'),
              // TODO: número/status da nota fiscal não está no model Pedido
              // -- pra ver a nota, abre o pedido completo (botão abaixo).
              _linha(context, 'Nota fiscal',
                  pedido.fiscal == true ? 'Emitida no romaneio' : '-'),
            ],
          ),
        ),
        const SizedBox(height: SivDimensoes.gapCards),
        SivCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Itens', style: textos.rotulo),
              const SizedBox(height: 8),
              if (carregandoItens)
                const Center(child: CircularProgressIndicator.adaptive())
              else if (itens.isEmpty)
                Text('Sem itens carregados.', style: textos.apoio)
              else ...[
                for (final item in itens.take(3))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${item.referenciaNome ?? 'Item'} · ${item.corNome ?? '-'}/${item.tamanhoNome ?? '-'} · ${item.solicitado?.toStringAsFixed(0) ?? '-'}un',
                      style: textos.apoio,
                    ),
                  ),
                if (itens.length > 3)
                  Text('+ ${itens.length - 3} itens', style: textos.apoio),
              ],
            ],
          ),
        ),
        const SizedBox(height: SivDimensoes.gapCards),
        SivCard(
          variante: SivCardVariante.destaque,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total',
                  style: textos.corpo.copyWith(color: cores.superficie)),
              const SizedBox(height: 4),
              Text(_moeda(pedido.valorTotal),
                  style: textos.titulo.copyWith(color: cores.superficie)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onAbrirPedido,
          icon: const Icon(Icons.gif_box_outlined),
          label: const Text('Detalhes'),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onAbrirPedido,
                icon: const Icon(Icons.print_outlined, size: 18),
                label: const Text('Imprimir'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _podeCancelar ? onCancelar : null,
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _linha(BuildContext context, String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.sivTextos.corpo),
          Text(valor, style: context.sivTextos.corpo),
        ],
      ),
    );
  }
}

List<(String, bool)> _passosTrilha(Pedido pedido) {
  final situacao = pedido.situacao?.toLowerCase();
  final conferido = pedido.conferidoEm != null ||
      situacao == 'faturado' ||
      situacao == 'encerrado';
  final faturado = situacao == 'faturado' || situacao == 'encerrado';
  final encerrado = situacao == 'encerrado';

  return [
    ('Aberto', true),
    ('Conferido', conferido),
    ('Faturado', faturado),
    ('Encerrado', encerrado),
  ];
}
