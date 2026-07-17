import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:financeiro/domain/models/caixa.dart';
import 'package:financeiro/domain/models/filtro_historico_de_caixas.dart';
import 'package:financeiro/presentation/blocs/historico_de_caixas_bloc/historico_de_caixas_bloc.dart';
import 'package:flutter/material.dart';

/// Lista caixas para seleção (usada por [SeletorCaixa]). Por padrão exibe
/// os caixas do dia atual, mas permite escolher outro período via
/// date range picker -- reaproveita o mesmo bloc/endpoint de
/// [HistoricoDeCaixasPage] (`GET /caixas`).
class SelecionarCaixaPage extends StatefulWidget {
  const SelecionarCaixaPage({super.key});

  @override
  State<SelecionarCaixaPage> createState() => _SelecionarCaixaPageState();
}

class _SelecionarCaixaPageState extends State<SelecionarCaixaPage> {
  late final HistoricoDeCaixasBloc _bloc;
  late DateTime _dataInicio;
  late DateTime _dataFim;

  @override
  void initState() {
    super.initState();
    final hoje = DateTime.now();
    _dataInicio = DateTime(hoje.year, hoje.month, hoje.day);
    _dataFim = _dataInicio;
    _bloc = sl<HistoricoDeCaixasBloc>()
      ..add(HistoricoDeCaixasIniciou(filtro: _montarFiltro()));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  FiltroHistoricoDeCaixas _montarFiltro() {
    return FiltroHistoricoDeCaixas(dataInicio: _dataInicio, dataFim: _dataFim);
  }

  Future<void> _selecionarPeriodo() async {
    final agora = DateTime.now();
    final selecionado = await showDateRangePicker(
      context: context,
      firstDate: DateTime(agora.year - 2),
      lastDate: agora,
      initialDateRange: DateTimeRange(start: _dataInicio, end: _dataFim),
    );
    if (selecionado == null || !mounted) return;

    setState(() {
      _dataInicio = selecionado.start;
      _dataFim = selecionado.end;
    });
    _bloc.add(HistoricoDeCaixasIniciou(filtro: _montarFiltro()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HistoricoDeCaixasBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Selecionar caixa'),
          actions: [
            IconButton(
              onPressed: _selecionarPeriodo,
              icon: const Icon(Icons.date_range),
              tooltip: 'Selecionar período',
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Período: ${_formatarData(_dataInicio)} até ${_formatarData(_dataFim)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            Expanded(
              child:
                  BlocBuilder<HistoricoDeCaixasBloc, HistoricoDeCaixasState>(
                builder: (context, state) {
                  if (state.step == HistoricoDeCaixasStep.carregando) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }

                  if (state.step == HistoricoDeCaixasStep.falha) {
                    return Center(
                      child: Text(state.erro ?? 'Erro ao carregar caixas.'),
                    );
                  }

                  if (state.itens.isEmpty) {
                    return const Center(
                      child: Text('Nenhum caixa encontrado para o período.'),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.itens.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final caixa = state.itens[index];
                      return Card(
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          title: Text('Caixa #${caixa.id}'),
                          subtitle: Text(
                            '${_situacaoLabel(caixa.situacao)} · '
                            'Aberto por ${caixa.operadorAberturaNome}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).pop(caixa),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatarData(DateTime data) {
  final local = data.toLocal();
  String dois(int v) => v.toString().padLeft(2, '0');
  return '${dois(local.day)}/${dois(local.month)}/${local.year}';
}

String _situacaoLabel(SituacaoCaixa situacao) => switch (situacao) {
      SituacaoCaixa.aberto => 'Aberto',
      SituacaoCaixa.contagem => 'Em contagem',
      SituacaoCaixa.fechado => 'Fechado',
    };
