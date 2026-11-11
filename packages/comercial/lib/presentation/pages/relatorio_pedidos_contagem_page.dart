import 'package:comercial/domain/models/relatorio_pedidos_contagem.dart';
import 'package:comercial/presentation/blocs/relatorio_pedidos_contagem_cubit/relatorio_pedidos_contagem_cubit.dart';
import 'package:comercial/presentation/relatorios/csv/relatorio_csv_exporter.dart';
import 'package:comercial/presentation/relatorios/pdf/relatorio_pdf_exporter.dart';
import 'package:comercial/presentation/widgets/frequencia/frequencia_formato.dart';
import 'package:comercial/presentation/widgets/pedidos_contagem/pedidos_contagem_etapas.dart';
import 'package:comercial/presentation/widgets/pedidos_contagem/pedidos_contagem_filtros.dart';
import 'package:comercial/presentation/widgets/pedidos_contagem/pedidos_contagem_formato.dart';
import 'package:comercial/presentation/widgets/pedidos_contagem/pedidos_contagem_lista.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

class RelatorioPedidosContagemPage extends StatefulWidget {
  final SeletorWidget fornecedorSeletor;
  final SeletorWidget tabelaPrecoSeletor;

  const RelatorioPedidosContagemPage({
    super.key,
    required this.fornecedorSeletor,
    required this.tabelaPrecoSeletor,
  });

  @override
  State<RelatorioPedidosContagemPage> createState() =>
      _RelatorioPedidosContagemPageState();
}

class _RelatorioPedidosContagemPageState
    extends State<RelatorioPedidosContagemPage> {
  late final RelatorioPedidosContagemCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<RelatorioPedidosContagemCubit>()..iniciar();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _abrir(int pedidoId) => Navigator.of(
        context,
      ).pushNamed('/pedido_entrada', arguments: {'pedidoId': pedidoId});

  Future<void> _exportar({required bool pdf}) async {
    final msg = ScaffoldMessenger.of(context);
    final s = _cubit.state;
    try {
      final linhas = await _cubit.todasAsLinhas();
      if (pdf) {
        await RelatorioPdfExporter.exportarPedidosContagem(
          linhas,
          s.resumo,
          pcPeriodoTexto(s.filtro),
        );
      } else {
        final destino = await RelatorioCsvExporter.exportarPedidosContagem(
          linhas,
        );
        msg.showSnackBar(
          SnackBar(
            content: Text(
              destino == null
                  ? 'CSV gerado (${linhas.length} pedidos).'
                  : 'CSV salvo em $destino (${linhas.length} pedidos).',
            ),
          ),
        );
      }
    } catch (e) {
      msg.showSnackBar(SnackBar(content: Text('Falha ao exportar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile = relatorioMobile(context);
    return BlocProvider<RelatorioPedidosContagemCubit>.value(
      value: _cubit,
      child: BlocBuilder<RelatorioPedidosContagemCubit,
          RelatorioPedidosContagemState>(
        builder: (context, s) => Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: RelatorioScaffold(
                    titulo: 'Pedidos por contagem',
                    acoes: [
                      _Exportar(
                        icone: Icons.download_outlined,
                        rotulo: 'CSV',
                        mobile: mobile,
                        onTap: () => _exportar(pdf: false),
                      ),
                      _Exportar(
                        icone: Icons.description_outlined,
                        rotulo: 'PDF',
                        mobile: mobile,
                        onTap: () => _exportar(pdf: true),
                      ),
                    ],
                    corpo: _Corpo(
                      state: s,
                      fornecedorSeletor: widget.fornecedorSeletor,
                      tabelaPrecoSeletor: widget.tabelaPrecoSeletor,
                      onAbrir: _abrir,
                    ),
                  ),
                ),
                if (!mobile &&
                    s.erro == null &&
                    !s.carregando &&
                    s.linhas.isNotEmpty)
                  RodapeTotalContagem(resumo: s.resumo),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Exportar extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final bool mobile;
  final VoidCallback onTap;

  const _Exportar({
    required this.icone,
    required this.rotulo,
    required this.mobile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => mobile
      ? IconButton(tooltip: rotulo, icon: Icon(icone), onPressed: onTap)
      : OutlinedButton.icon(
          key: Key('contagem_exportar_${rotulo.toLowerCase()}'),
          onPressed: onTap,
          icon: Icon(icone, size: 16),
          label: Text(rotulo),
        );
}

class _Corpo extends StatelessWidget {
  final RelatorioPedidosContagemState state;
  final SeletorWidget fornecedorSeletor;
  final SeletorWidget tabelaPrecoSeletor;
  final ValueChanged<int> onAbrir;

  const _Corpo({
    required this.state,
    required this.fornecedorSeletor,
    required this.tabelaPrecoSeletor,
    required this.onAbrir,
  });

  @override
  Widget build(BuildContext context) {
    final s = state;
    final cubit = context.read<RelatorioPedidosContagemCubit>();
    final primeira = s.carregando && s.linhas.isEmpty && s.resumo.pedidos == 0;

    final Widget conteudo;
    if (s.erro != null) {
      conteudo = _Mensagem(
        texto: s.erro!,
        acao: FilledButton(
          onPressed: cubit.recarregar,
          child: const Text('Tentar de novo'),
        ),
      );
    } else if (primeira) {
      conteudo = const RelatorioEsqueleto();
    } else {
      conteudo = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (s.carregando) const LinearProgressIndicator(minHeight: 2),
          _Kpis(state: s),
          const SizedBox(height: 14),
          if (s.resumo.porEtapa.isNotEmpty &&
              s.filtro.situacao != SituacaoContagem.faturado) ...[
            CustoPorEtapa(
              etapas: s.resumo.porEtapa,
              selecionada: s.filtro.etapa,
              onEtapa: cubit.alternarEtapa,
            ),
            const SizedBox(height: 14),
          ],
          if (s.linhas.isEmpty && !s.carregando)
            _Mensagem(
              texto: 'Nenhum pedido por contagem nesse filtro.',
              acao: s.temFiltro
                  ? TextButton(
                      onPressed: cubit.limparFiltros,
                      child: const Text('Limpar filtros'),
                    )
                  : null,
            )
          else
            ListaPedidosContagem(state: s, onAbrir: onAbrir),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FiltrosPedidosContagem(
          state: s,
          fornecedorSeletor: fornecedorSeletor,
          tabelaPrecoSeletor: tabelaPrecoSeletor,
        ),
        SizedBox(height: relatorioMobile(context) ? 8 : 14),
        conteudo,
      ],
    );
  }
}

class _Mensagem extends StatelessWidget {
  final String texto;
  final Widget? acao;
  const _Mensagem({required this.texto, this.acao});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Text(
              texto,
              textAlign: TextAlign.center,
              style: context.sivTextos.corpo.copyWith(
                color: context.sivColors.textoApoio,
              ),
            ),
            if (acao != null) ...[const SizedBox(height: 12), acao!],
          ],
        ),
      );
}

class _Kpis extends StatelessWidget {
  final RelatorioPedidosContagemState state;
  const _Kpis({required this.state});

  @override
  Widget build(BuildContext context) {
    final r = state.resumo;
    final sit = state.filtro.situacao;
    final rotuloCusto = switch (sit) {
      SituacaoContagem.aberto => 'Custo em aberto',
      SituacaoContagem.faturado => 'Custo faturado no período',
      SituacaoContagem.todos => 'Custo no período',
    };

    final semPreco = r.pecasSemValor > 0;
    final notaValor = [
      if (semPreco) '${pcQtd(r.pecasSemValor)} pç sem preço',
      if (state.tabelaPrecoNome != null)
        'simulado com ${state.tabelaPrecoNome}',
    ].join(' · ');

    if (relatorioMobile(context)) {
      final c = context.sivColors;
      final t = context.sivTextos;
      final apoio = t.apoio.copyWith(color: c.textoApoio);
      return Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.superficie,
              border: Border.all(color: c.aco),
              borderRadius: BorderRadius.circular(SivDimensoes.raio),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rotuloCusto.toUpperCase(),
                  style: t.apoio.copyWith(
                    fontSize: 10.5,
                    letterSpacing: 1.4,
                    color: c.acoAtivo,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  frequenciaMoeda(r.custo),
                  style: t.titulo.copyWith(fontSize: 32, height: 1),
                ),
                const SizedBox(height: 6),
                Text(
                  '${r.pedidos} pedidos · ${pcQtd(r.pecas)} peças'
                  '${r.pecasSemCusto > 0 ? ' · ${pcQtd(r.pecasSemCusto)} sem custo' : ''}',
                  style: apoio,
                ),
                const SizedBox(height: 2),
                Text(
                  'Valor de venda ${frequenciaMoeda(r.valor)}'
                  '${notaValor.isEmpty ? '' : ' · $notaValor'}',
                  style: apoio,
                ),
                const SizedBox(height: 2),
                Text(
                  pcPeriodoTexto(state.filtro),
                  style: apoio.copyWith(fontSize: 11.5),
                ),
              ],
            ),
          ),
          ...sivCantosBlueprint(c.aco.withValues(alpha: 0.4)),
        ],
      );
    }

    final semCusto = r.pecasSemCusto > 0;
    final quarto = sit == SituacaoContagem.faturado
        ? RelatorioKpiCard(
            rotulo: 'Custo médio por peça',
            valor: frequenciaMoeda(r.pecas > 0 ? r.custo / r.pecas : 0),
          )
        : RelatorioKpiCard(
            rotulo: 'Peças sem custo',
            valor: pcQtd(r.pecasSemCusto),
            tom: semCusto ? RelatorioKpiTom.atencao : RelatorioKpiTom.aco,
            valorAtencao: semCusto,
            nota: semCusto ? 'falta associar referência' : null,
          );
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: RelatorioKpiCard(
              rotulo: rotuloCusto,
              valor: frequenciaMoeda(r.custo),
              destaque: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RelatorioKpiCard(
              rotulo: 'Valor de venda',
              valor: frequenciaMoeda(r.valor),
              tom: semPreco ? RelatorioKpiTom.atencao : RelatorioKpiTom.aco,
              valorAtencao: semPreco,
              nota: notaValor.isEmpty ? null : notaValor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RelatorioKpiCard(rotulo: 'Pedidos', valor: '${r.pedidos}'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RelatorioKpiCard(
              rotulo: 'Peças contadas',
              valor: pcQtd(r.pecas),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: quarto),
        ],
      ),
    );
  }
}
