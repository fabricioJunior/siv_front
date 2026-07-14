import 'package:comercial/presentation/blocs/pagamentos_realizados_bloc/pagamentos_realizados_bloc.dart';
import 'package:comercial/domain/models/pagamentos_realizados_resumo.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PagamentosRealizadosWidget extends StatelessWidget {
  final String hashLista;
  final PagamentosRealizadosResumo? resumoInicial;
  final int? pessoaId;
  final String? cpfClienteInicial;
  final SeletorWidget formasDePagamentoSeletor;
  // Desconto já persistido no romaneio (fora deste diálogo) -- usado só pra
  // pré-carregar o desconto do diálogo com esse valor, reaproveitando os
  // botões "Editar desconto"/"Remover desconto" já existentes pra corrigir
  // ou zerar. Só relevante quando o pagamento é de um romaneio já existente
  // (ver romaneio_page.dart); fica 0 nos outros usos (criação de venda nova).
  final double descontoJaAplicadoNoRomaneio;

  const PagamentosRealizadosWidget({
    super.key,
    required this.hashLista,
    this.resumoInicial,
    this.pessoaId,
    this.cpfClienteInicial,
    required this.formasDePagamentoSeletor,
    this.descontoJaAplicadoNoRomaneio = 0,
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
            cpfClienteInicial: cpfClienteInicial,
            descontoJaAplicadoNoRomaneio: descontoJaAplicadoNoRomaneio,
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
              'descontosItens': state.descontosItensAplicado.entries
                  .map((e) => {'produtoId': e.key, 'valor': e.value})
                  .toList(),
              'resumoFormasDePagamento': state.linhas
                  .where((linha) => linha.formaDePagamento != null)
                  .map(
                    (linha) => {
                      'nome': linha.formaDePagamento!.nome,
                      'valor': linha.valor,
                    },
                  )
                  .toList(),
              'valorTotalRecebido': state.valorLiquido,
              'valorTroco': state.valorTroco,
              'incluirCpfNaNota': state.incluirCpfNaNota,
              'cpfNaNota': state.incluirCpfNaNota ? state.cpfNaNota : '',
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

          final ultimoId = state.linhas.isEmpty ? null : state.linhas.last.id;

          final dialog = AlertDialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            title: Row(
              children: [
                const Expanded(child: Text('Pagamento realizado')),
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
                    if ((state.resumo?.produtosCompartilhados ?? [])
                        .isNotEmpty) ...[
                      _ProdutosCard(
                        state: state,
                        podeEditar:
                            state.step == PagamentosRealizadosStep.editando,
                      ),
                      const SizedBox(height: 12),
                    ],
                    _ResumoPagamentoCard(
                      state: state,
                      onDescontoPressed:
                          state.step == PagamentosRealizadosStep.editando
                              ? () => _abrirDialogoDesconto(context, state)
                              : null,
                    ),
                    if (state.erro != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        state.erro!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
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

class _ResumoPagamentoCard extends StatefulWidget {
  final PagamentosRealizadosState state;
  final VoidCallback? onDescontoPressed;

  const _ResumoPagamentoCard({
    required this.state,
    required this.onDescontoPressed,
  });

  @override
  State<_ResumoPagamentoCard> createState() => _ResumoPagamentoCardState();
}

class _ResumoPagamentoCardState extends State<_ResumoPagamentoCard> {
  late final TextEditingController _cpfController;

  @override
  void initState() {
    super.initState();
    _cpfController = TextEditingController(text: widget.state.cpfNaNota);
  }

  @override
  void didUpdateWidget(covariant _ResumoPagamentoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.cpfNaNota != _cpfController.text &&
        widget.state.cpfNaNota != oldWidget.state.cpfNaNota) {
      _cpfController.text = widget.state.cpfNaNota;
    }
  }

  @override
  void dispose() {
    _cpfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final onDescontoPressed = widget.onDescontoPressed;
    final theme = Theme.of(context);
    final possuiPessoa = state.pessoaId != null;
    final carregandoCredito = state.carregandoSaldoCreditoDevolucao;

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
                  titulo: 'Desconto por produto',
                  valor: _formatarMoeda(state.valorDescontoItensTotal),
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
                  titulo: 'Valor restante',
                  valor: _formatarMoeda(state.valorRestante),
                ),
                if (possuiPessoa && !carregandoCredito)
                  _InfoBox(
                    titulo: 'Crédito de devolução',
                    valor: _formatarMoeda(state.saldoCreditoDevolucao),
                  ),
              ],
            ),
            if (!possuiPessoa) ...[
              const SizedBox(height: 8),
              Text(
                'Cliente não informado. Não foi possível consultar saldo de crédito de devolução.',
                style: theme.textTheme.bodySmall,
              ),
            ] else if (carregandoCredito) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Consultando saldo de crédito de devolução...',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final pessoaId = state.pessoaId;
                    if (pessoaId == null) return;
                    Navigator.of(context).pushNamed(
                      '/credito_devolucao_movimentacoes',
                      arguments: {'pessoaId': pessoaId},
                    );
                  },
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: const Text('Ver movimentações de crédito'),
                ),
              ),
            ],
            const Divider(height: 24),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: state.incluirCpfNaNota,
              title: const Text('Incluir CPF do cliente na nota fiscal'),
              onChanged: (value) {
                context.read<PagamentosRealizadosBloc>().add(
                      PagamentosRealizadosIncluirCpfAlterado(
                        incluirCpfNaNota: value ?? true,
                      ),
                    );
              },
            ),
            if (state.incluirCpfNaNota)
              CPFInput(
                controller: _cpfController,
                obrigatorio: false,
                onChanged: (value) {
                  context.read<PagamentosRealizadosBloc>().add(
                        PagamentosRealizadosCpfAlterado(cpfNaNota: value),
                      );
                },
              ),
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
            TextFormField(
              key: ValueKey('valor-${linha.id}'),
              autofocus: autofocusValor,
              initialValue: linha.valorTexto,
              decoration: const InputDecoration(
                labelText: 'Valor recebido',
                border: OutlineInputBorder(),
              ),
              inputFormatters: [_decimalInputFormatter],
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
              onChanged: (value) => bloc.add(
                PagamentosRealizadosValorAlterado(
                  linhaId: linha.id,
                  valorTexto: value,
                ),
              ),
            ),
            const SizedBox(height: 12),
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

class _ProdutosCard extends StatelessWidget {
  final PagamentosRealizadosState state;
  final bool podeEditar;

  const _ProdutosCard({required this.state, required this.podeEditar});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final produtos = state.resumo?.produtosCompartilhados ?? [];

    final possuiAlgumDesconto = state.descontosItensAplicado.values.any(
      (valor) => valor > 0,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Produtos', style: theme.textTheme.titleMedium),
                ),
                if (possuiAlgumDesconto)
                  TextButton.icon(
                    onPressed: podeEditar
                        ? () => context.read<PagamentosRealizadosBloc>().add(
                            const PagamentosRealizadosDescontosItensLimpos())
                        : null,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Limpar todos os descontos'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ...produtos.map((produto) {
              final valorTotalItem = produto.quantidade * produto.valorUnitario;
              final descontoAplicado =
                  state.descontosItensAplicado[produto.produtoId] ?? 0;
              final descricao = [
                produto.nome,
                if (produto.corNome.isNotEmpty) produto.corNome,
                if (produto.tamanhoNome.isNotEmpty) produto.tamanhoNome,
              ].join(' - ');

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(descricao, overflow: TextOverflow.ellipsis),
                    ),
                    Expanded(
                      child: Text('Qtd: ${produto.quantidade}'),
                    ),
                    Expanded(
                      child: Text(_formatarMoeda(produto.valorUnitario)),
                    ),
                    Expanded(
                      child: Text(
                        descontoAplicado > 0
                            ? _formatarMoeda(valorTotalItem - descontoAplicado)
                            : _formatarMoeda(valorTotalItem),
                        style: descontoAplicado > 0
                            ? TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              )
                            : null,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: podeEditar
                          ? () => _abrirDialogoDescontoItem(
                                context,
                                state,
                                produto,
                              )
                          : null,
                      icon: const Icon(Icons.percent, size: 16),
                      label: Text(descontoAplicado > 0 ? 'Editar' : 'Desconto'),
                    ),
                  ],
                ),
              );
            }),
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
                          child: Text('Valor manual'),
                        ),
                        DropdownMenuItem(
                          value: DescontoTipo.porcentagem,
                          child: Text('Porcentagem'),
                        ),
                        DropdownMenuItem(
                          value: DescontoTipo.forcaValorTotal,
                          child: Text('Valor total manual'),
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
                      onFieldSubmitted: (_) =>
                          Navigator.of(dialogContext).pop(true),
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

Future<void> _abrirDialogoDescontoItem(
  BuildContext context,
  PagamentosRealizadosState state,
  ProdutoCompartilhado produto,
) async {
  final bloc = context.read<PagamentosRealizadosBloc>();
  final valorBase = produto.quantidade * produto.valorUnitario;
  final tipoAtual = state.descontosItensTipo[produto.produtoId];
  final valorTextoAtual =
      state.descontosItensValorTexto[produto.produtoId] ?? '';
  final valorAplicadoAtual =
      state.descontosItensAplicado[produto.produtoId] ?? 0;

  var tipoSelecionado = tipoAtual ?? DescontoTipo.valorBruto;
  final valorInicial = valorTextoAtual.isNotEmpty
      ? valorTextoAtual
      : (tipoAtual == DescontoTipo.forcaValorTotal
          ? (valorBase - valorAplicadoAtual).toStringAsFixed(2)
          : valorAplicadoAtual.toStringAsFixed(2));
  final controller = TextEditingController(
    text: valorAplicadoAtual > 0 ? valorInicial : '',
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
              dica = 'Informe um valor entre 0 e ${_formatarMoeda(valorBase)}.';
            case DescontoTipo.porcentagem:
              label = 'Percentual de desconto';
              dica = 'Informe um percentual entre 0 e 100.';
            case DescontoTipo.forcaValorTotal:
              label = 'Novo valor total do item';
              dica =
                  'Informe o total final desejado para o item. O desconto sera valor original menos esse total.';
          }

          return AlertDialog(
            title: Text('Desconto em ${produto.nome}'),
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
                          child: Text('Valor manual'),
                        ),
                        DropdownMenuItem(
                          value: DescontoTipo.porcentagem,
                          child: Text('Porcentagem'),
                        ),
                        DropdownMenuItem(
                          value: DescontoTipo.forcaValorTotal,
                          child: Text('Valor total manual'),
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
                      onFieldSubmitted: (_) =>
                          Navigator.of(dialogContext).pop(true),
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
              if (valorAplicadoAtual > 0)
                TextButton(
                  onPressed: () {
                    bloc.add(
                      PagamentosRealizadosDescontoItemAlterado(
                        produtoId: produto.produtoId,
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
      PagamentosRealizadosDescontoItemAlterado(
        produtoId: produto.produtoId,
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
                descricao:
                    'Finaliza os pagamentos quando a tela estiver em edicao.',
              ),
              SizedBox(height: 8),
              _AtalhoInfo(
                atalho: 'Enter',
                descricao: 'No campo Valor recebido, fecha o teclado.',
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
