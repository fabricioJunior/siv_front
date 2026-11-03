import 'package:comercial/domain/data/gateways/i_filtros_pedidos_contagem_gateway.dart';
import 'package:comercial/domain/models/relatorio_pedidos_contagem.dart';
import 'package:comercial/presentation/blocs/relatorio_pedidos_contagem_cubit/relatorio_pedidos_contagem_cubit.dart';
import 'package:comercial/presentation/widgets/frequencia/frequencia_formato.dart';
import 'package:comercial/presentation/widgets/pedidos_contagem/pedidos_contagem_opcoes.dart';
import 'package:core/bloc.dart';
import 'package:core/presentation.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

const _situacoes = {
  SituacaoContagem.aberto: 'Em aberto',
  SituacaoContagem.faturado: 'Faturados',
  SituacaoContagem.todos: 'Todos',
};

/// Situação, período, filtros de item (categoria > referência > produto),
/// fornecedor, busca e limpar. Na tela estreita os grupos rolam na horizontal.
class FiltrosPedidosContagem extends StatefulWidget {
  final RelatorioPedidosContagemState state;
  final SeletorWidget fornecedorSeletor;
  final SeletorWidget tabelaPrecoSeletor;

  const FiltrosPedidosContagem({
    super.key,
    required this.state,
    required this.fornecedorSeletor,
    required this.tabelaPrecoSeletor,
  });

  @override
  State<FiltrosPedidosContagem> createState() => _FiltrosPedidosContagemState();
}

class _FiltrosPedidosContagemState extends State<FiltrosPedidosContagem> {
  final _debouncer = Debouncer(milliseconds: 500);
  final _busca = TextEditingController();

  RelatorioPedidosContagemCubit get _cubit =>
      context.read<RelatorioPedidosContagemCubit>();

  @override
  void didUpdateWidget(FiltrosPedidosContagem old) {
    super.didUpdateWidget(old);
    if (old.state.limpezas != widget.state.limpezas) _busca.clear();
  }

  @override
  void dispose() {
    _debouncer.cancel();
    _busca.dispose();
    super.dispose();
  }

  Future<void> _periodo(PeriodoContagem p) async {
    if (p != PeriodoContagem.personalizado) {
      if (p != widget.state.periodo) _cubit.alterarPeriodo(p);
      return;
    }
    final f = widget.state.filtro;
    final hoje = DateTime.now();
    final r = await abrirFiltroPeriodoSheet(
      context: context,
      dataInicioAtual: f.de ?? hoje,
      dataFimAtual: f.ate ?? hoje,
      firstDate: DateTime(2020),
      lastDate: hoje,
      permitirHora: false,
    );
    if (r == null || !mounted) return;
    _cubit.alterarDatas(r.dataInicio, r.dataFim);
  }

  Future<void> _escolher({
    required String titulo,
    required Future<List<OpcaoFiltro>> Function(String) carregar,
    required String rotuloTodas,
    required void Function(OpcaoFiltro?) aplicar,
    bool servidor = false,
    bool permiteVazio = true,
  }) async {
    final r = await abrirOpcoesContagem(
      context,
      titulo: titulo,
      carregar: carregar,
      rotuloTodas: rotuloTodas,
      buscaNoServidor: servidor,
      permiteVazio: permiteVazio,
    );
    if (r != null) aplicar(r.valor);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final f = s.filtro;
    final mobile = relatorioMobile(context);
    final c = context.sivColors;

    final situacao = SegmentedButton<SituacaoContagem>(
      key: const Key('contagem_situacao'),
      showSelectedIcon: false,
      style: const ButtonStyle(
        minimumSize: WidgetStatePropertyAll(
          Size(0, SivDimensoes.alvoToqueMinimo),
        ),
      ),
      segments: [
        for (final e in _situacoes.entries)
          ButtonSegment(value: e.key, label: Text(e.value)),
      ],
      selected: {f.situacao},
      onSelectionChanged: (v) => _cubit.alterarSituacao(v.first),
    );

    final periodos = [
      for (final p in PeriodoContagem.values)
        RelatorioFiltroChip.toggle(
          key: Key('contagem_periodo_${p.name}'),
          rotulo: p == PeriodoContagem.personalizado &&
                  s.periodo == p &&
                  f.de != null &&
                  f.ate != null
              ? '${frequenciaDia(f.de!)} - ${frequenciaDia(f.ate!)}'
              : p.rotulo,
          marcado: s.periodo == p,
          onChanged: (_) => _periodo(p),
        ),
    ];

    final categoria = RelatorioFiltroChip(
      key: const Key('contagem_filtro_categoria'),
      rotulo: 'Categoria',
      valor: s.categoria?.nome ?? 'todas',
      onTap: () => _escolher(
        titulo: 'Categoria',
        carregar: (_) => _cubit.categorias(),
        rotuloTodas: 'Todas',
        aplicar: _cubit.alterarCategoria,
      ),
    );
    final referencia = RelatorioFiltroChip(
      key: const Key('contagem_filtro_referencia'),
      rotulo: 'Referência',
      valor: s.referencia?.nome ?? 'todas',
      onTap: () => _escolher(
        titulo: 'Referência',
        carregar: _cubit.referencias,
        rotuloTodas: 'Todas',
        aplicar: _cubit.alterarReferencia,
        servidor: true,
        permiteVazio: s.categoria != null,
      ),
    );
    final produto = Opacity(
      opacity: s.referencia == null ? 0.5 : 1,
      child: IgnorePointer(
        ignoring: s.referencia == null,
        child: RelatorioFiltroChip(
          key: const Key('contagem_filtro_produto'),
          rotulo: 'Produto',
          valor: s.produto?.nome ??
              (s.referencia == null ? 'escolha a referência' : 'todos'),
          onTap: () => _escolher(
            titulo: 'Produto',
            carregar: (_) => _cubit.produtos(),
            rotuloTodas: 'Todos',
            aplicar: _cubit.alterarProduto,
          ),
        ),
      ),
    );
    final fornecedor = SizedBox(
      width: 240,
      child: KeyedSubtree(
        key: ValueKey('fornecedor_${s.limpezas}'),
        child: widget.fornecedorSeletor(
          SeletorData(
            compacto: true,
            onChanged: (l) =>
                _cubit.alterarFornecedor(l.isEmpty ? null : l.first.id),
          ),
        ),
      ),
    );
    final tabela = SizedBox(
      width: 240,
      child: KeyedSubtree(
        key: ValueKey('tabela_${s.limpezas}'),
        child: widget.tabelaPrecoSeletor(
          SeletorData(
            compacto: true,
            onChanged: (l) => _cubit.alterarTabelaPreco(
              l.isEmpty ? null : l.first.id,
              l.isEmpty ? null : l.first.nome,
            ),
          ),
        ),
      ),
    );
    final busca = SizedBox(
      width: 200,
      child: TextField(
        key: const Key('contagem_busca'),
        controller: _busca,
        onChanged: (v) => _debouncer.run(() => _cubit.buscar(v)),
        style: context.sivTextos.apoio,
        decoration: const InputDecoration(
          isDense: true,
          hintText: 'Nº do pedido ou texto',
          prefixIcon: Icon(Icons.search, size: 18),
        ),
      ),
    );
    final limpar = s.temFiltro
        ? TextButton(
            key: const Key('contagem_limpar'),
            onPressed: _cubit.limparFiltros,
            child: const Text('Limpar filtros'),
          )
        : null;

    Widget linha(List<Widget> l) => SizedBox(
          height: SivDimensoes.alvoToqueMinimo + 8,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: l.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => Center(child: l[i]),
          ),
        );

    if (mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          situacao,
          linha(periodos),
          linha([
            categoria,
            referencia,
            produto,
            fornecedor,
            tabela,
            busca,
            if (limpar != null) limpar
          ]),
        ],
      );
    }

    final apoio = context.sivTextos.apoio.copyWith(color: c.textoApoio);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            situacao,
            Wrap(spacing: 6, runSpacing: 6, children: periodos),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            categoria,
            referencia,
            produto,
            fornecedor,
            tabela,
            busca,
            if (limpar != null) limpar
          ],
        ),
        const SizedBox(height: 6),
        Text(_nota(f), style: apoio.copyWith(fontSize: 11.5)),
      ],
    );
  }

  String _nota(FiltroPedidosContagem f) {
    final base = switch (f.situacao) {
      SituacaoContagem.faturado =>
        'Período pela data de faturamento. Custo gravado nos itens do pedido ao faturar.',
      SituacaoContagem.aberto =>
        'Período pela data de abertura. Pedidos ainda não faturados; '
            '"em aberto há" fica âmbar acima de $diasAlertaContagemAberta dias.',
      SituacaoContagem.todos =>
        'Período pela data de abertura. Inclui em aberto e faturados.',
    };
    return f.temFiltroItem
        ? '$base Com filtro de categoria/referência/produto, peças, custo e valor somam só os itens que batem.'
        : base;
  }
}
