import 'package:comercial/presentation/blocs/pagamentos_realizados_bloc/pagamentos_realizados_bloc.dart';
import 'package:comercial/domain/models/pagamentos_realizados_resumo.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';

class PagamentosRealizadosWidget extends StatelessWidget {
  final String hashLista;
  final PagamentosRealizadosResumo? resumoInicial;
  final SeletorWidget formasDePagamentoSeletor;

  const PagamentosRealizadosWidget({
    super.key,
    required this.hashLista,
    this.resumoInicial,
    required this.formasDePagamentoSeletor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PagamentosRealizadosBloc>(
      create: (_) => PagamentosRealizadosBloc(sl())
        ..add(
          PagamentosRealizadosIniciado(
            hashLista: hashLista,
            resumoInicial: resumoInicial,
          ),
        ),
      child: BlocConsumer<PagamentosRealizadosBloc, PagamentosRealizadosState>(
            listenWhen: (previous, current) =>
                previous.step != current.step || previous.erro != current.erro,
            listener: (context, state) {
              if (state.step == PagamentosRealizadosStep.falha &&
                  state.erro != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.erro!)),
                );
              }

              if (state.step == PagamentosRealizadosStep.concluido) {
                Navigator.of(context).pop(state.resultado);
              }
            },
            builder: (context, state) {
              if (state.step == PagamentosRealizadosStep.carregando ||
                  state.step == PagamentosRealizadosStep.inicial) {
                return const SizedBox(
                  width: 640,
                  height: 420,
                  child: Center(child: CircularProgressIndicator.adaptive()),
                );
              }

              return AlertDialog(
                insetPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                title: const Text('Pagamentos realizados'),
                content: SizedBox(
                  width: 760,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ResumoPagamentoCard(state: state),
                        const SizedBox(height: 16),
                        ...state.linhas.map(
                          (linha) => _LinhaPagamentoCard(
                            linha: linha,
                            formasDePagamentoSeletor: formasDePagamentoSeletor,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: state.podeAdicionarLinha
                              ? () => context
                                  .read<PagamentosRealizadosBloc>()
                                  .add(const PagamentosRealizadosLinhaAdicionada())
                              : null,
                          icon: const Icon(Icons.add),
                          label: const Text('Adicionar forma de pagamento'),
                        ),
                        const SizedBox(height: 8),
                        _DetalhePagamentoCard(state: state),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: state.step == PagamentosRealizadosStep.editando
                        ? () => context
                            .read<PagamentosRealizadosBloc>()
                            .add(const PagamentosRealizadosFinalizacaoSolicitada())
                        : null,
                    child: const Text('Finalizar pagamentos'),
                  ),
                ],
              );
            },
          ),
    );
  }
}

class _ResumoPagamentoCard extends StatelessWidget {
  final PagamentosRealizadosState state;

  const _ResumoPagamentoCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Resumo da venda', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _InfoBox(
                  titulo: 'Quantidade',
                  valor: '${state.quantidadeTotalProdutos}',
                ),
                _InfoBox(
                  titulo: 'Valor dos produtos',
                  valor: _formatarMoeda(state.valorTotalProdutos),
                ),
                _InfoBox(
                  titulo: 'Pago bruto',
                  valor: _formatarMoeda(state.valorTotalBruto),
                ),
                _InfoBox(
                  titulo: 'Troco',
                  valor: _formatarMoeda(state.valorTroco),
                ),
                _InfoBox(
                  titulo: 'Restante',
                  valor: _formatarMoeda(state.valorRestante),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetalhePagamentoCard extends StatelessWidget {
  final PagamentosRealizadosState state;

  const _DetalhePagamentoCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final restante = state.valorRestante;
    final theme = Theme.of(context);

    return Card(
      color: restante.abs() < 0.01
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              restante.abs() < 0.01
                  ? 'Pagamento completo'
                  : 'Valor pendente: ${_formatarMoeda(restante)}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              restante.abs() < 0.01
                  ? 'O valor informado cobre o total da venda.'
                  : 'Adicione formas de pagamento até zerar o valor pendente.',
            ),
            if (state.erro != null) ...[
              const SizedBox(height: 8),
              Text(
                state.erro!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LinhaPagamentoCard extends StatelessWidget {
  final PagamentoRealizadoLinha linha;
  final SeletorWidget formasDePagamentoSeletor;

  const _LinhaPagamentoCard({
    required this.linha,
    required this.formasDePagamentoSeletor,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PagamentosRealizadosBloc>();
    final formaSelecionada = linha.formaDePagamento;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: formasDePagamentoSeletor(
                    itemsSelecionadosInicial: formaSelecionada == null
                        ? const []
                        : [formaSelecionada],
                    onChanged: (selecionadas) {
                      final forma = selecionadas.isNotEmpty
                          ? selecionadas.first
                          : null;
                      bloc.add(
                        PagamentosRealizadosFormaAlterada(
                          linhaId: linha.id,
                          formaDePagamento: forma,
                        ),
                      );
                    },
                    onlyView: false,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: bloc.state.linhas.length == 1
                      ? null
                      : () => bloc.add(
                          PagamentosRealizadosLinhaRemovida(linhaId: linha.id),
                        ),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remover forma de pagamento',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey('valor-${linha.id}'),
                    initialValue: linha.valorTexto,
                    decoration: const InputDecoration(
                      labelText: 'Valor recebido',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) => bloc.add(
                      PagamentosRealizadosValorAlterado(
                        linhaId: linha.id,
                        valorTexto: value,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (formaSelecionada != null && linha.aceitaParcelamento)
                  Expanded(
                    child: TextFormField(
                      key: ValueKey('parcelas-${linha.id}'),
                      initialValue: linha.parcelasTexto,
                      decoration: InputDecoration(
                        labelText: 'Parcelas (${linha.parcelasMaximas})',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => bloc.add(
                        PagamentosRealizadosParcelasAlteradas(
                          linhaId: linha.id,
                          parcelasTexto: value,
                        ),
                      ),
                    ),
                  ),
                if (formaSelecionada != null && linha.aceitaParcelamento)
                  const SizedBox(width: 8),
                if (formaSelecionada != null)
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Valor da parcela',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _formatarMoeda(linha.valorParcela),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
              ],
            ),
            if (linha.ehDinheiro &&
                bloc.state.valorTotalBruto > bloc.state.valorTotalProdutos) ...[
              const SizedBox(height: 8),
              Text(
                'Troco estimado: ${_formatarMoeda(bloc.state.valorTroco)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String titulo;
  final String valor;

  const _InfoBox({required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            valor,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatarMoeda(double valor) {
  return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
}