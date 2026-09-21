import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/tema.dart';
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

        final cores = context.sivColors;
        final textos = context.sivTextos;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Informe o valor contado para cada forma de pagamento.',
                    style: textos.apoio.copyWith(color: cores.textoApoio),
                  ),
                ),
                TextButton(
                  onPressed: salvando || cancelando
                      ? null
                      : () => _confirmarCancelamento(context),
                  style: TextButton.styleFrom(foregroundColor: cores.vinho),
                  child: cancelando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Cancelar contagem'),
                ),
              ],
            ),
            const SizedBox(height: SivDimensoes.gapCards),
            if (state.tiposPendentes.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cores.atencaoFundo,
                  border: Border.all(color: cores.atencaoBorda),
                  borderRadius: BorderRadius.circular(SivDimensoes.raio),
                ),
                child: Text(
                  '${state.tiposPendentes.length} forma(s) de pagamento pendente(s) de contagem.',
                  style: textos.apoio.copyWith(color: cores.textoPrincipal),
                ),
              )
            else
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cores.selecaoFundo,
                  border: Border.all(color: cores.aco),
                  borderRadius: BorderRadius.circular(SivDimensoes.raio),
                ),
                child: Text(
                  'Nenhum item pendente de contagem para este caixa.',
                  style: textos.apoio.copyWith(color: cores.textoPrincipal),
                ),
              ),
            ...state.tiposPendentes.map(
              (tipo) => _ItemContagemCard(
                tipo: tipo,
                controller: _controllers[tipo]!,
                state: state,
              ),
            ),
            if (state.step == ContagemDoCaixaStep.validacaoInvalida &&
                state.tipoComErro == null &&
                state.erro != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Text(
                  state.erro!,
                  style: textos.apoio.copyWith(color: cores.vinho),
                ),
              ),
            const SizedBox(height: SivDimensoes.gapCards),
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
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  state.tiposPendentes.isEmpty
                      ? 'CONFIRMAR CONTAGEM ZERADA'
                      : 'CONCLUIR CONTAGEM',
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
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cores.superficie,
        border: Border.all(color: cores.hairline),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Row(
        children: [
          Icon(_iconeTipo(tipo), color: _corTipo(tipo), size: 18),
          const SizedBox(width: 10),
          Text(_labelTipo(tipo), style: textos.corpo),
          if (_jaSalvo) ...[
            const SizedBox(width: 6),
            Icon(Icons.check_circle, size: 15, color: cores.acoProfundo),
          ],
          const Spacer(),
          SizedBox(
            width: 140,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.right,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [_decimalInputFormatter],
              style: textos.secao.copyWith(fontSize: 16),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                prefixText: 'R\$ ',
                hintText: '0,00',
                errorText: _erroNesteItem ? state.erro : null,
                errorStyle: textos.apoio.copyWith(color: cores.vinho),
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
          ),
          if (_salvandoEsteItem)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
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
