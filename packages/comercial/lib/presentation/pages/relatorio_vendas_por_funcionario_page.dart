import 'package:comercial/presentation/blocs/relatorio_vendas_por_funcionario_bloc/relatorio_vendas_por_funcionario_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
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

  Future<void> _selecionarData(bool isInicial) async {
    final initial = DateTime.tryParse(isInicial ? _dataInicial : _dataFinal);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked == null) return;
    final fmt =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    setState(() {
      if (isInicial) {
        _dataInicial = fmt;
      } else {
        _dataFinal = fmt;
      }
    });
  }

  void _aplicarFiltro() {
    _bloc.add(RelatorioVendasPorFuncionarioCarregar(
      funcionariosSelecionados: _funcionariosSelecionados,
      dataInicial: _dataInicial,
      dataFinal: _dataFinal,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RelatorioVendasPorFuncionarioBloc>.value(
      value: _bloc,
      child: BlocBuilder<RelatorioVendasPorFuncionarioBloc,
          RelatorioVendasPorFuncionarioState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Vendas por Funcionário')),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filtros',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        widget.funcionariosSeletor.call(
                          itemsSelecionadosInicial: _funcionariosSelecionados,
                          onChanged: (selecionados) {
                            setState(() {
                              _funcionariosSelecionados = selecionados;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _DateButton(
                                label: 'De',
                                date: _fmtData(_dataInicial),
                                onTap: () => _selecionarData(true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _DateButton(
                                label: 'Até',
                                date: _fmtData(_dataFinal),
                                onTap: () => _selecionarData(false),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _funcionariosSelecionados.isEmpty
                                ? null
                                : _aplicarFiltro,
                            icon: const Icon(Icons.search),
                            label: const Text('Consultar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (state.step == RelatorioVendasPorFuncionarioStep.carregando)
                  const _EstadoCard(
                    icon: Icons.hourglass_top,
                    titulo: 'Carregando relatório',
                    descricao: 'Consultando vendas dos funcionários...',
                    loading: true,
                  )
                else if (state.step == RelatorioVendasPorFuncionarioStep.falha)
                  _EstadoCard(
                    icon: Icons.error_outline,
                    titulo: 'Falha ao carregar',
                    descricao: state.erro ?? 'Erro desconhecido',
                    onRetry: _aplicarFiltro,
                  )
                else if (state.step ==
                    RelatorioVendasPorFuncionarioStep.inicial)
                  const _EstadoCard(
                    icon: Icons.groups_outlined,
                    titulo: 'Selecione os funcionários',
                    descricao:
                        'Escolha um ou mais funcionários e o período, depois toque em Consultar.',
                  )
                else if (state.dados.isEmpty)
                  const _EstadoCard(
                    icon: Icons.search_off,
                    titulo: 'Nenhuma venda encontrada',
                    descricao:
                        'Não há romaneios de venda encerrados para os funcionários e período selecionados.',
                  )
                else
                  ...state.dados.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FuncionarioCard(item: item),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback onTap;

  const _DateButton(
      {required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text('$label: ',
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
            Expanded(
              child: Text(date,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
            ),
            const Icon(Icons.calendar_today_outlined, size: 16),
          ],
        ),
      ),
    );
  }
}

class _FuncionarioCard extends StatelessWidget {
  final dynamic item;
  const _FuncionarioCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.funcionarioNome as String,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _Metrica(
                  label: 'Valor total vendido',
                  valor: _fmtMoeda(item.total as double),
                ),
                _Metrica(
                  label: 'Ticket médio',
                  valor: _fmtMoeda(item.ticketMedio as double),
                ),
                _Metrica(
                  label: 'Quantidade de vendas',
                  valor: '${item.quantidadeVendas}',
                ),
                _Metrica(
                  label: 'Produtos vendidos',
                  valor: '${item.quantidadeProdutosVendidos}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metrica extends StatelessWidget {
  final String label;
  final String valor;
  const _Metrica({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 2),
          Text(valor,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _EstadoCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String descricao;
  final bool loading;
  final VoidCallback? onRetry;

  const _EstadoCard({
    required this.icon,
    required this.titulo,
    required this.descricao,
    this.loading = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (loading)
              const CircularProgressIndicator.adaptive()
            else
              Icon(icon, size: 40),
            const SizedBox(height: 12),
            Text(titulo,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(descricao,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
