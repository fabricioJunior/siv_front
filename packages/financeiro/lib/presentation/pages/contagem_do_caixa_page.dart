import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/presentation.dart';
import 'package:flutter/material.dart';

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
          listenWhen: (previous, current) => current.erro != null,
          listener: (context, state) {
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

  void _syncControllersFromState(ContagemDoCaixaState state) {
    for (final tipo in TipoContagemDoCaixaItem.values) {
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
        final salvando = state.step == ContagemDoCaixaStep.salvandoItem;

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            if (state.contagem != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Itens já contados: ${state.contagem!.itens.length} / ${TipoContagemDoCaixaItem.values.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ...TipoContagemDoCaixaItem.values.map(
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
                onPressed: salvando
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
                label: const Text('Salvar todos os itens preenchidos'),
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
      state.contagem?.itens.any((i) => i.tipo == tipo) ?? false;

  bool get _salvandoEsteItem => state.itemSendoSalvo == tipo;

  bool get _erroNesteItem => state.tipoComErro == tipo && state.erro != null;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _labelTipo(tipo),
                        style: Theme.of(context).textTheme.titleSmall,
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
                    decoration: InputDecoration(
                      prefixText: 'R\$ ',
                      isDense: true,
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
}
