import 'dart:math' as math;

import 'package:comercial/presentation/blocs/pagamentos_realizados_bloc/pagamentos_realizados_bloc.dart';
import 'package:comercial/domain/models/pagamentos_realizados_resumo.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PagamentosRealizadosWidget extends StatelessWidget {
  final String hashLista;
  final PagamentosRealizadosResumo? resumoInicial;
  final int? pessoaId;
  final SeletorWidget formasDePagamentoSeletor;

  const PagamentosRealizadosWidget({
    super.key,
    required this.hashLista,
    this.resumoInicial,
    this.pessoaId,
    required this.formasDePagamentoSeletor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PagamentosRealizadosBloc>(
      create: (_) => sl<PagamentosRealizadosBloc>()
        ..add(
          PagamentosRealizadosIniciado(
            hashLista: hashLista,
            resumoInicial: resumoInicial,
            pessoaId: pessoaId,
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
            Navigator.of(context).pop({
              'formasDePagamentoRealizadas': state.resultado,
              'desconto': state.valorDescontoAplicado,
            });
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

            final ultimoId =
              state.linhas.isEmpty ? null : state.linhas.last.id;

          final dialog = AlertDialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            title: Row(
              children: [
                const Expanded(child: Text('Pagamentos realizados')),
                IconButton(
                  tooltip: 'Ajuda de atalhos',
                  onPressed: () => _abrirAjudaAtalhos(context),
                  icon: const Icon(Icons.help_outline),
                ),
              ],
            ),
            content: SizedBox(
              width: 760,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ResumoPagamentoCard(
                      state: state,
                      onDescontoPressed:
                          state.step == PagamentosRealizadosStep.editando
                              ? () => _abrirDialogoDesconto(context, state)
                              : null,
                    ),
                    const SizedBox(height: 12),
                    _DetalhePagamentoCard(state: state),
                    const SizedBox(height: 12),
                    _SaldoCreditoDevolucaoCard(state: state),
                    const SizedBox(height: 16),
                    ...state.linhas.map(
                      (linha) => _LinhaPagamentoCard(
                        linha: linha,
                        formasDePagamentoSeletor: formasDePagamentoSeletor,
                        autofocusValor: linha.id == ultimoId,
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
                    if (state.linhas.isNotEmpty)
                      Text(
                        'Distribua o valor recebido entre as formas de pagamento.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
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

          return CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.escape): () {
                Navigator.of(context).pop();
              },
              const SingleActivator(LogicalKeyboardKey.enter, control: true):
                  () {
                if (state.step == PagamentosRealizadosStep.editando) {
                  context.read<PagamentosRealizadosBloc>().add(
                    const PagamentosRealizadosFinalizacaoSolicitada(),
                  );
                }
              },
            },
            child: Focus(
              autofocus: true,
              child: dialog,
            ),
          );
        },
      ),
    );
  }
}

class _SaldoCreditoDevolucaoCard extends StatelessWidget {
  final PagamentosRealizadosState state;

  const _SaldoCreditoDevolucaoCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final possuiPessoa = state.pessoaId != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Credito de devolucao do cliente',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            if (!possuiPessoa)
              const Text(
                'Cliente nao informado. Nao foi possivel consultar saldo de credito de devolucao.',
              )
            else if (state.carregandoSaldoCreditoDevolucao)
              const Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Consultando saldo...'),
                ],
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  _InfoBox(
                    titulo: 'Saldo disponivel',
                    valor: _formatarMoeda(state.saldoCreditoDevolucao),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      final pessoaId = state.pessoaId;
                      if (pessoaId == null) return;
                      Navigator.of(context).pushNamed(
                        '/credito_devolucao_movimentacoes',
                        arguments: {'pessoaId': pessoaId},
                      );
                    },
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: const Text('Ver movimentacoes'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ResumoPagamentoCard extends StatelessWidget {
  final PagamentosRealizadosState state;
  final VoidCallback? onDescontoPressed;

  const _ResumoPagamentoCard({
    required this.state,
    required this.onDescontoPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Resumo da venda',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: onDescontoPressed,
                  icon: const Icon(Icons.percent),
                  label: Text(
                    state.valorDescontoAplicado > 0
                        ? 'Editar desconto'
                        : 'Adicionar desconto',
                  ),
                ),
              ],
            ),
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
                  titulo: 'Desconto',
                  valor: _formatarMoeda(state.valorDescontoAplicado),
                ),
                _InfoBox(
                  titulo: 'Total c/ desconto',
                  valor: _formatarMoeda(state.valorTotalComDesconto),
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
    final total = state.valorTotalComDesconto <= 0
        ? state.valorTotalProdutos
        : state.valorTotalComDesconto;
    final pagoLimitado = math.min(state.valorTotalBruto, total);
    final progresso = total <= 0 ? 1.0 : (pagoLimitado / total).clamp(0.0, 1.0);

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
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progresso),
            const SizedBox(height: 4),
            Text(
              'Progresso do recebimento: ${(progresso * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.bodySmall,
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
  final bool autofocusValor;

  const _LinhaPagamentoCard({
    required this.linha,
    required this.formasDePagamentoSeletor,
    required this.autofocusValor,
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
                      final forma =
                          selecionadas.isNotEmpty ? selecionadas.first : null;
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
                            PagamentosRealizadosLinhaRemovida(
                                linhaId: linha.id),
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
                    autofocus: autofocusValor,
                    initialValue: linha.valorTexto,
                    decoration: const InputDecoration(
                      labelText: 'Valor recebido',
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [_decimalInputFormatter],
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: formaSelecionada != null && linha.aceitaParcelamento
                        ? TextInputAction.next
                        : TextInputAction.done,
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    onFieldSubmitted: (_) {
                      if (formaSelecionada != null && linha.aceitaParcelamento) {
                        FocusScope.of(context).nextFocus();
                        return;
                      }
                      FocusScope.of(context).unfocus();
                    },
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
                      inputFormatters: [_integerInputFormatter],
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
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
                bloc.state.valorTotalBruto >
                    bloc.state.valorTotalComDesconto) ...[
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

Future<void> _abrirDialogoDesconto(
  BuildContext context,
  PagamentosRealizadosState state,
) async {
  final bloc = context.read<PagamentosRealizadosBloc>();
  var tipoSelecionado = state.descontoTipo ?? DescontoTipo.valorBruto;
  final valorInicial = state.descontoValorTexto.isNotEmpty
      ? state.descontoValorTexto
      : (state.descontoTipo == DescontoTipo.forcaValorTotal
          ? state.valorTotalComDesconto.toStringAsFixed(2)
          : state.valorDescontoAplicado.toStringAsFixed(2));
  final controller = TextEditingController(
    text: state.valorDescontoAplicado > 0 ? valorInicial : '',
  );

  final confirmou = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          String dica;
          String label;

          switch (tipoSelecionado) {
            case DescontoTipo.valorBruto:
              label = 'Valor do desconto';
              dica =
                  'Informe um valor entre 0 e ${_formatarMoeda(state.valorTotalProdutos)}.';
            case DescontoTipo.porcentagem:
              label = 'Percentual de desconto';
              dica = 'Informe um percentual entre 0 e 100.';
            case DescontoTipo.forcaValorTotal:
              label = 'Novo valor total';
              dica =
                  'Informe o total final desejado. O desconto sera valor original menos esse total.';
          }

          return AlertDialog(
            title: const Text('Aplicar desconto'),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<DescontoTipo>(
                      value: tipoSelecionado,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de desconto',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: DescontoTipo.valorBruto,
                          child: Text('Valor bruto'),
                        ),
                        DropdownMenuItem(
                          value: DescontoTipo.porcentagem,
                          child: Text('Porcentagem'),
                        ),
                        DropdownMenuItem(
                          value: DescontoTipo.forcaValorTotal,
                          child: Text('Forca valor total'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          tipoSelecionado = value;
                          controller.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: controller,
                      autofocus: true,
                      inputFormatters: [_decimalInputFormatter],
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.done,
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      onFieldSubmitted: (_) => Navigator.of(dialogContext).pop(true),
                      decoration: InputDecoration(
                        labelText: label,
                        border: const OutlineInputBorder(),
                        helperText: dica,
                        helperMaxLines: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              if (state.valorDescontoAplicado > 0)
                TextButton(
                  onPressed: () {
                    bloc.add(
                      const PagamentosRealizadosDescontoAlterado(
                        tipo: null,
                        valorTexto: '',
                      ),
                    );
                    Navigator.of(dialogContext).pop(false);
                  },
                  child: const Text('Remover desconto'),
                ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Aplicar'),
              ),
            ],
          );
        },
      );
    },
  );

  if (confirmou == true) {
    bloc.add(
      PagamentosRealizadosDescontoAlterado(
        tipo: tipoSelecionado,
        valorTexto: controller.text,
      ),
    );
  }
}

Future<void> _abrirAjudaAtalhos(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Atalhos disponiveis'),
        content: const SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AtalhoInfo(
                atalho: 'Esc',
                descricao: 'Fecha o dialogo de pagamentos.',
              ),
              SizedBox(height: 8),
              _AtalhoInfo(
                atalho: 'Ctrl + Enter',
                descricao: 'Finaliza os pagamentos quando a tela estiver em edicao.',
              ),
              SizedBox(height: 8),
              _AtalhoInfo(
                atalho: 'Enter',
                descricao: 'No campo Valor recebido, avanca para Parcelas quando houver parcelamento.',
              ),
              SizedBox(height: 8),
              _AtalhoInfo(
                atalho: 'Enter',
                descricao: 'No campo de desconto, aplica o desconto.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Fechar'),
          ),
        ],
      );
    },
  );
}

String _formatarMoeda(double valor) {
  return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
}

class _AtalhoInfo extends StatelessWidget {
  final String atalho;
  final String descricao;

  const _AtalhoInfo({required this.atalho, required this.descricao});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            atalho,
            style: theme.textTheme.labelLarge,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(descricao)),
      ],
    );
  }
}

final _integerInputFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'\d*'),
);

final _decimalInputFormatter = TextInputFormatter.withFunction(
  (oldValue, newValue) {
    if (newValue.text.isEmpty) return newValue;

    final normalizado = newValue.text.replaceAll('.', ',');
    final regex = RegExp(r'^\d+(,\d{0,2})?$');
    if (!regex.hasMatch(normalizado)) {
      return oldValue;
    }

    return newValue.copyWith(text: normalizado);
  },
);
