import 'package:comercial/domain/models/relatorios.dart';
import 'package:comercial/presentation/blocs/relatorio_vendas_por_funcionario_bloc/relatorio_vendas_por_funcionario_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

String _fmtMoeda(double v) {
  final s = v.toStringAsFixed(2);
  final p = s.split('.');
  final inteiro = p[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]}.',
  );
  return 'R\$ $inteiro,${p[1]}';
}

String _fmtData(String iso) {
  if (iso.isEmpty) return '-';
  final p = iso.split('-');
  return p.length == 3 ? '${p[2]}/${p[1]}/${p[0]}' : iso;
}

String _isoDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

(String, String) _mesAtual() {
  final now = DateTime.now();
  final ultimo = DateTime(now.year, now.month + 1, 0).day;
  final m = now.month.toString().padLeft(2, '0');
  return (
    '${now.year}-$m-01',
    '${now.year}-$m-${ultimo.toString().padLeft(2, '0')}',
  );
}

class RelatorioVendasPorFuncionarioPage extends StatefulWidget {
  final SeletorWidget funcionariosSeletor;

  const RelatorioVendasPorFuncionarioPage({
    super.key,
    required this.funcionariosSeletor,
  });

  @override
  State<RelatorioVendasPorFuncionarioPage> createState() =>
      _RelatorioVendasPorFuncionarioPageState();
}

class _RelatorioVendasPorFuncionarioPageState
    extends State<RelatorioVendasPorFuncionarioPage> {
  late final RelatorioVendasPorFuncionarioBloc _bloc;
  late String _dataInicial;
  late String _dataFinal;
  List<SelectData> _funcionariosSelecionados = const [];

  @override
  void initState() {
    super.initState();
    final (ini, fim) = _mesAtual();
    _dataInicial = ini;
    _dataFinal = fim;
    _bloc = sl<RelatorioVendasPorFuncionarioBloc>();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _abrirFiltroPeriodo() async {
    final resultado = await abrirFiltroPeriodoSheet(
      context: context,
      dataInicioAtual: DateTime.tryParse(_dataInicial) ?? DateTime.now(),
      dataFimAtual: DateTime.tryParse(_dataFinal) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      permitirHora: false,
    );
    if (resultado == null || !mounted) return;
    setState(() {
      _dataInicial = _isoDate(resultado.dataInicio);
      _dataFinal = _isoDate(resultado.dataFim);
    });
  }

  void _aplicarFiltro() {
    _bloc.add(RelatorioVendasPorFuncionarioCarregar(
      funcionariosSelecionados: _funcionariosSelecionados,
      dataInicial: _dataInicial,
      dataFinal: _dataFinal,
    ));
  }

  Future<void> _abrirFuncionarios() async {
    await SivModal.mostrar<void>(
      context,
      titulo: 'Funcionário',
      larguraMaxima: 480,
      corpo: Padding(
        padding: const EdgeInsets.all(SivDimensoes.paddingCard),
        child: widget.funcionariosSeletor.call(
          SeletorData(
            itemsSelecionadosInicial: _funcionariosSelecionados,
            onChanged: (selecionados) =>
                setState(() => _funcionariosSelecionados = selecionados),
          ),
        ),
      ),
      acoes: [
        Builder(
          builder: (ctx) => FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Consultar'),
          ),
        ),
      ],
    );
    if (mounted && _funcionariosSelecionados.isNotEmpty) _aplicarFiltro();
  }

  String get _rotuloFuncionarios {
    final n = _funcionariosSelecionados.length;
    if (n == 0) return 'Selecione';
    if (n == 1) return _funcionariosSelecionados.first.nome;
    return '$n selecionados';
  }

  void _detalhe(RelatorioVendasPorFuncionarioItem item) {
    final corpo = _Detalhe(item: item);
    if (relatorioMobile(context)) {
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => SafeArea(child: corpo),
      );
    } else {
      SivModal.mostrar<void>(
        context,
        titulo: item.funcionarioNome,
        larguraMaxima: 420,
        corpo: corpo,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return BlocProvider<RelatorioVendasPorFuncionarioBloc>.value(
      value: _bloc,
      child: BlocBuilder<RelatorioVendasPorFuncionarioBloc,
          RelatorioVendasPorFuncionarioState>(
        builder: (context, state) {
          final dados = [...state.dados]
            ..sort((a, b) => b.total.compareTo(a.total));
          final maior = dados.isEmpty ? 0.0 : dados.first.total;
          final soma = dados.fold<double>(0, (s, i) => s + i.total);
          final inicial =
              state.step == RelatorioVendasPorFuncionarioStep.inicial;
          return Scaffold(
            body: SafeArea(
              child: RelatorioScaffold(
                titulo: 'Vendas por Funcionário',
                filtros: [
                  RelatorioFiltroChip(
                    rotulo: 'Período',
                    valor:
                        '${_fmtData(_dataInicial)} - ${_fmtData(_dataFinal)}',
                    onTap: _abrirFiltroPeriodo,
                  ),
                  RelatorioFiltroChip(
                    rotulo: 'Funcionário',
                    valor: _rotuloFuncionarios,
                    onTap: _abrirFuncionarios,
                  ),
                ],
                carregando:
                    state.step == RelatorioVendasPorFuncionarioStep.carregando,
                erro: state.step == RelatorioVendasPorFuncionarioStep.falha
                    ? (state.erro ?? 'Erro desconhecido')
                    : null,
                onTentarDeNovo: _aplicarFiltro,
                vazio: !inicial &&
                    state.step == RelatorioVendasPorFuncionarioStep.sucesso &&
                    dados.isEmpty,
                corpo: inicial
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Text(
                          'Selecione o funcionário para consultar.',
                          textAlign: TextAlign.center,
                          style: textos.corpo.copyWith(color: cores.textoApoio),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final i in dados)
                            _BarraFuncionario(
                              item: i,
                              maior: maior,
                              onTap: () => _detalhe(i),
                            ),
                          const SizedBox(height: 8),
                          Divider(color: cores.hairline),
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            spacing: 16,
                            children: [
                              Text(
                                '${dados.length} funcionários com venda no período',
                                style: textos.apoio
                                    .copyWith(color: cores.textoApoio),
                              ),
                              Text(
                                'Total: ${_fmtMoeda(soma)}',
                                style: textos.corpo
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BarraFuncionario extends StatelessWidget {
  final RelatorioVendasPorFuncionarioItem item;
  final double maior;
  final VoidCallback onTap;
  const _BarraFuncionario({
    required this.item,
    required this.maior,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final frac = maior > 0 ? (item.total / maior).clamp(0.0, 1.0) : 0.0;
    final nome = Text(
      item.funcionarioNome,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textos.corpo,
    );
    final valor = Text(
      _fmtMoeda(item.total),
      style: textos.corpo.copyWith(fontWeight: FontWeight.w700),
    );
    final barra = ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 14,
        color: cores.selecaoFundo,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: frac,
          child: Container(color: cores.aco),
        ),
      ),
    );
    final mobile = relatorioMobile(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: mobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: nome),
                      const SizedBox(width: 8),
                      valor,
                    ],
                  ),
                  const SizedBox(height: 6),
                  barra,
                ],
              )
            : Row(
                children: [
                  SizedBox(width: 170, child: nome),
                  const SizedBox(width: 12),
                  Expanded(child: barra),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: valor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Detalhe extends StatelessWidget {
  final RelatorioVendasPorFuncionarioItem item;
  const _Detalhe({required this.item});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    Widget linha(String r, String v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(r, style: textos.corpo.copyWith(color: cores.textoApoio)),
              Text(v,
                  style: textos.corpo.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        );
    return Padding(
      padding: const EdgeInsets.all(SivDimensoes.paddingCard),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (relatorioMobile(context))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(item.funcionarioNome, style: textos.secao),
            ),
          linha('Ticket médio', _fmtMoeda(item.ticketMedio)),
          linha('Vendas', '${item.quantidadeVendas}'),
          linha('Peças', '${item.quantidadeProdutosVendidos}'),
          linha('Devoluções', _fmtMoeda(item.valorDevolucoes)),
        ],
      ),
    );
  }
}
