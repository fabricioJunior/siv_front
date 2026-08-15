import 'package:comercial/domain/models/relatorios.dart';
import 'package:comercial/presentation/blocs/relatorio_pontos_fidelidade_bloc/relatorio_pontos_fidelidade_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

String _fmtPontos(double v) {
  final s = v.toStringAsFixed(2);
  final p = s.split('.');
  final inteiro = p[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]}.',
  );
  return '$inteiro,${p[1]}';
}

String _fmtData(String? iso) {
  if (iso == null || iso.isEmpty) return '-';
  final p = iso.split('-');
  return p.length == 3 ? '${p[2]}/${p[1]}/${p[0]}' : iso;
}

class RelatorioPontosFidelidadePage extends StatefulWidget {
  const RelatorioPontosFidelidadePage({super.key});

  @override
  State<RelatorioPontosFidelidadePage> createState() =>
      _RelatorioPontosFidelidadePageState();
}

class _RelatorioPontosFidelidadePageState
    extends State<RelatorioPontosFidelidadePage> {
  late final RelatorioPontosFidelidadeBloc _bloc;
  String? _situacaoCadastro;

  @override
  void initState() {
    super.initState();
    _bloc = sl<RelatorioPontosFidelidadeBloc>()
      ..add(RelatorioPontosFidelidadeCarregar());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _aplicar({int page = 1}) {
    _bloc.add(RelatorioPontosFidelidadeCarregar(
      situacaoCadastro: _situacaoCadastro,
      page: page,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RelatorioPontosFidelidadeBloc>.value(
      value: _bloc,
      child: BlocBuilder<RelatorioPontosFidelidadeBloc,
          RelatorioPontosFidelidadeState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Pontos de Fidelidade')),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                if (state.step == RelatorioPontosFidelidadeStep.sucesso &&
                    state.dados != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                      ),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.stars_outlined,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Saldo total de pontos',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                            Text(
                              _fmtPontos(state.dados!.saldoPontosTotal),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Clientes',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                            Text(
                              '${state.dados!.meta.totalItems}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Filtros
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Situação no portal',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('Todos'),
                              selected: _situacaoCadastro == null,
                              onSelected: (_) {
                                setState(() => _situacaoCadastro = null);
                                _aplicar();
                              },
                            ),
                            ChoiceChip(
                              label: const Text('Cadastrados'),
                              selected: _situacaoCadastro == 'cadastrado',
                              onSelected: (_) {
                                setState(
                                    () => _situacaoCadastro = 'cadastrado');
                                _aplicar();
                              },
                            ),
                            ChoiceChip(
                              label: const Text('Não cadastrados'),
                              selected: _situacaoCadastro == 'nao_cadastrado',
                              onSelected: (_) {
                                setState(() =>
                                    _situacaoCadastro = 'nao_cadastrado');
                                _aplicar();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (state.step == RelatorioPontosFidelidadeStep.carregando)
                  const _EstadoCard(
                    titulo: 'Carregando pontos',
                    descricao: 'Buscando clientes do programa de fidelidade...',
                    loading: true,
                  )
                else if (state.step == RelatorioPontosFidelidadeStep.falha)
                  _EstadoCard(
                    titulo: 'Falha ao carregar',
                    descricao: state.erro ?? '',
                    onRetry: _aplicar,
                  )
                else if (state.dados != null) ...[
                  if (state.dados!.items.isEmpty)
                    const _EstadoCard(
                      titulo: 'Nenhum cliente encontrado',
                      descricao: 'Nenhum cliente encontrado para o filtro informado.',
                    )
                  else
                    ...state.dados!.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ClienteCard(item: item),
                      ),
                    ),
                  if (state.totalPages > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.chevron_left),
                          label: const Text('Anterior'),
                          onPressed: state.page > 1
                              ? () => _aplicar(page: state.page - 1)
                              : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '${state.page}/${state.totalPages}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.chevron_right),
                          label: const Text('Próxima'),
                          onPressed: state.page < state.totalPages
                              ? () => _aplicar(page: state.page + 1)
                              : null,
                        ),
                      ],
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ClienteCard extends StatelessWidget {
  final RelatorioPontoFidelidadeItem item;
  const _ClienteCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF6A1B9A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFFEDE7F6),
                      child: Icon(Icons.person_outline,
                          color: Color(0xFF6A1B9A), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.clienteNome.toUpperCase(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          Row(
                            children: [
                              Text(
                                item.cadastradoPortal
                                    ? item.dataCadastroPortal != null
                                        ? 'Cadastrado em ${_fmtData(item.dataCadastroPortal)}'
                                        : 'Cadastrado'
                                    : 'Não cadastrado',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: item.cadastradoPortal
                                      ? Colors.green
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_fmtPontos(item.saldoPontos)} pts',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          'Últ. crédito: ${_fmtData(item.dataUltimoCredito)}',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoCard extends StatelessWidget {
  final String titulo;
  final String descricao;
  final bool loading;
  final VoidCallback? onRetry;

  const _EstadoCard({
    required this.titulo,
    required this.descricao,
    this.loading = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (loading)
                const CircularProgressIndicator.adaptive()
              else
                const Icon(Icons.stars_outlined, size: 40),
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
