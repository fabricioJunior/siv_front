import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContagemDoCaixaPage extends StatelessWidget {
  final int caixaId;

  const ContagemDoCaixaPage({super.key, required this.caixaId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ContagemDoCaixaBloc>(
      create: (_) {
        final bloc = sl<ContagemDoCaixaBloc>();
        bloc.add(ContagemDoCaixaIniciou(caixaId: caixaId));
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Contagem do caixa')),
        body: BlocConsumer<ContagemDoCaixaBloc, ContagemDoCaixaState>(
          listenWhen: (previous, current) =>
              current.erro != null ||
              current.step == ContagemDoCaixaStep.cancelada,
          listener: (context, state) {
            if (state.step == ContagemDoCaixaStep.cancelada) {
              Navigator.of(context).pop(true);
              return;
            }

            if (state.step == ContagemDoCaixaStep.falha &&
                state.itemSendoSalvo == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.erro ?? 'Erro ao carregar a contagem.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.step == ContagemDoCaixaStep.carregando) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Carregando contagem...'),
                  ],
                ),
              );
            }

            if (state.step == ContagemDoCaixaStep.falha &&
                state.contagem == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 36,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.erro ??
                            'Falha ao carregar a contagem do caixa. Tente novamente.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () {
                          context.read<ContagemDoCaixaBloc>().add(
                                ContagemDoCaixaIniciou(caixaId: caixaId),
                              );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return _ContagemDoCaixaForm(caixaId: caixaId);
          },
        ),
      ),
    );
  }
}

class _ContagemDoCaixaForm extends StatefulWidget {
  final int caixaId;

  const _ContagemDoCaixaForm({required this.caixaId});

  @override
  State<_ContagemDoCaixaForm> createState() => _ContagemDoCaixaFormState();
}

class _ContagemDoCaixaFormState extends State<_ContagemDoCaixaForm> {
  final Map<TipoContagemDoCaixaItem, TextEditingController> _controllers = {};
  bool _houveTentativaDeSalvar = false;

  @override
  void initState() {
    super.initState();
    for (final tipo in TipoContagemDoCaixaItem.values) {
      _controllers[tipo] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _confirmarCancelamento(BuildContext context) async {
    final bloc = context.read<ContagemDoCaixaBloc>();

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancelar contagem'),
          content: const Text(
            'Os valores já preenchidos nesta contagem serão descartados e o '
            'caixa volta a ficar aberto normalmente. Deseja continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Voltar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Cancelar contagem'),
            ),
          ],
        );
      },
    );

    if (confirmou == true) {
      bloc.add(const ContagemDoCaixaCancelamentoSolicitado());
    }
  }

  void _syncControllersFromState(ContagemDoCaixaState state) {
    for (final tipo in state.tiposPendentes) {
      _controllers.putIfAbsent(tipo, () => TextEditingController());
      final controller = _controllers[tipo]!;
      final valor = state.valoresEditados[tipo] ?? '';
      if (controller.text != valor) {
        controller.text = valor;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContagemDoCaixaBloc, ContagemDoCaixaState>(
      listenWhen: (previous, current) =>
          previous.contagem != current.contagem ||
          previous.step != current.step,
      listener: (context, state) {
        _syncControllersFromState(state);

        if (state.step == ContagemDoCaixaStep.salvandoItem) {
          _houveTentativaDeSalvar = true;
        }

        if (_houveTentativaDeSalvar &&
            state.step == ContagemDoCaixaStep.editando &&
            state.erro == null &&
            state.itemSendoSalvo == null &&
            state.contagem != null) {
          _houveTentativaDeSalvar = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Itens salvos com sucesso.'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        if (state.step == ContagemDoCaixaStep.falha ||
            state.step == ContagemDoCaixaStep.validacaoInvalida) {
          _houveTentativaDeSalvar = false;
        }
      },
      builder: (context, state) {
        _syncControllersFromState(state);
        final salvando = state.step == ContagemDoCaixaStep.salvandoItem;
        final cancelando = state.step == ContagemDoCaixaStep.cancelando;
        for (final tipo in state.tiposPendentes) {
          _controllers.putIfAbsent(tipo, () => TextEditingController());
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            if (state.tiposPendentes.isNotEmpty) ...[
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.playlist_add_check_circle_outlined),
                  title: const Text('Contagem pendente'),
                  subtitle: Text(
                    'Preencha os itens pendentes de pagamento para concluir o fechamento.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: Chip(
                    label: Text('${state.tiposPendentes.length} itens'),
                  ),
                ),
              ),
            ] else
              const Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(Icons.check_circle_outline, color: Colors.green),
                  title: Text('Nenhum item pendente'),
                  subtitle: Text('Nao ha contagens pendentes para este caixa.'),
                ),
              ),
            ...state.tiposPendentes.map(
              (tipo) => _ItemContagemCard(
                tipo: tipo,
                controller: _controllers[tipo]!,
                state: state,
              ),
            ),
            const SizedBox(height: 8),
            if (state.step == ContagemDoCaixaStep.validacaoInvalida &&
                state.tipoComErro == null &&
                state.erro != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  state.erro!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: salvando || cancelando
                    ? null
                    : () {
                        context.read<ContagemDoCaixaBloc>().add(
                              ContagemDoCaixaSalvarTodosSolicitado(),
                            );
                      },
                icon: salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  state.tiposPendentes.isEmpty
                      ? 'Confirmar contagem zerada'
                      : 'Salvar todos os itens preenchidos',
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: salvando || cancelando
                    ? null
                    : () => _confirmarCancelamento(context),
                icon: cancelando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cancel_outlined),
                label: Text(
                  cancelando ? 'Cancelando contagem...' : 'Cancelar contagem',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ItemContagemCard extends StatelessWidget {
  final TipoContagemDoCaixaItem tipo;
  final TextEditingController controller;
  final ContagemDoCaixaState state;

  const _ItemContagemCard({
    required this.tipo,
    required this.controller,
    required this.state,
  });

  bool get _jaSalvo =>
      state.contagem?.itens.any((i) => i.tipoDocumento == tipo) ?? false;

  bool get _salvandoEsteItem => state.itemSendoSalvo == tipo;

  bool get _erroNesteItem => state.tipoComErro == tipo && state.erro != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorIcone = _corTipo(tipo);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorIcone.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_iconeTipo(tipo), color: colorIcone, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _labelTipo(tipo),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (_jaSalvo) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [_decimalInputFormatter],
                    decoration: InputDecoration(
                      prefixText: 'R\$ ',
                      isDense: true,
                      hintText: '0,00',
                      errorText: _erroNesteItem ? state.erro : null,
                    ),
                    onChanged: (valor) {
                      context.read<ContagemDoCaixaBloc>().add(
                            ContagemDoCaixaItemValorAlterado(
                              tipo: tipo,
                              valor: valor,
                            ),
                          );
                    },
                  ),
                ],
              ),
            ),
            if (_salvandoEsteItem)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _labelTipo(TipoContagemDoCaixaItem tipo) {
    switch (tipo) {
      case TipoContagemDoCaixaItem.dinheiro:
        return 'Dinheiro';
      case TipoContagemDoCaixaItem.pix:
        return 'Pix';
      case TipoContagemDoCaixaItem.cartao:
        return 'Cartão';
      case TipoContagemDoCaixaItem.fatura:
        return 'Fatura';
      case TipoContagemDoCaixaItem.cheque:
        return 'Cheque';
      case TipoContagemDoCaixaItem.troco:
        return 'Troco';
      case TipoContagemDoCaixaItem.voucher:
        return 'Voucher';
      case TipoContagemDoCaixaItem.tedDoc:
        return 'TED/DOC';
      case TipoContagemDoCaixaItem.adiantamento:
        return 'Adiantamento';
      case TipoContagemDoCaixaItem.creditoDeDevolucao:
        return 'Crédito de devolução';
    }
  }

  IconData _iconeTipo(TipoContagemDoCaixaItem tipo) {
    switch (tipo) {
      case TipoContagemDoCaixaItem.dinheiro:
        return Icons.payments_outlined;
      case TipoContagemDoCaixaItem.pix:
        return Icons.pix;
      case TipoContagemDoCaixaItem.cartao:
        return Icons.credit_card_outlined;
      case TipoContagemDoCaixaItem.fatura:
        return Icons.receipt_long_outlined;
      case TipoContagemDoCaixaItem.cheque:
        return Icons.request_quote_outlined;
      case TipoContagemDoCaixaItem.troco:
        return Icons.currency_exchange;
      case TipoContagemDoCaixaItem.voucher:
        return Icons.confirmation_number_outlined;
      case TipoContagemDoCaixaItem.tedDoc:
        return Icons.swap_horiz_outlined;
      case TipoContagemDoCaixaItem.adiantamento:
        return Icons.trending_up_outlined;
      case TipoContagemDoCaixaItem.creditoDeDevolucao:
        return Icons.assignment_return_outlined;
    }
  }

  Color _corTipo(TipoContagemDoCaixaItem tipo) {
    switch (tipo) {
      case TipoContagemDoCaixaItem.dinheiro:
        return Colors.green;
      case TipoContagemDoCaixaItem.pix:
        return Colors.teal;
      case TipoContagemDoCaixaItem.cartao:
        return Colors.blue;
      case TipoContagemDoCaixaItem.fatura:
        return Colors.indigo;
      case TipoContagemDoCaixaItem.cheque:
        return Colors.brown;
      case TipoContagemDoCaixaItem.troco:
        return Colors.orange;
      case TipoContagemDoCaixaItem.voucher:
        return Colors.deepPurple;
      case TipoContagemDoCaixaItem.tedDoc:
        return Colors.cyan;
      case TipoContagemDoCaixaItem.adiantamento:
        return Colors.deepOrange;
      case TipoContagemDoCaixaItem.creditoDeDevolucao:
        return Colors.pink;
    }
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
