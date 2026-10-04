import 'package:comercial/presentation/blocs/pedido_entrada_bloc/pedido_entrada_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';

/// Inicia um Pedido de Entrada pela contagem física (mercadoria sem NF-e ou
/// ainda sem cadastro). Cria o pedido e abre a tela de contagem; nada entra no
/// estoque até a conferência e o faturamento do pedido.
class EntradaPorContagemPage extends StatefulWidget {
  final SeletorWidget fornecedorSeletor;
  final SeletorWidget tabelaDePrecoSeletor;

  const EntradaPorContagemPage({
    super.key,
    required this.fornecedorSeletor,
    required this.tabelaDePrecoSeletor,
  });

  @override
  State<EntradaPorContagemPage> createState() => _EntradaPorContagemPageState();
}

class _EntradaPorContagemPageState extends State<EntradaPorContagemPage> {
  late final PedidoEntradaBloc _bloc = sl<PedidoEntradaBloc>();
  int? _fornecedorId;
  int? _tabelaDePrecoId;

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return BlocProvider<PedidoEntradaBloc>.value(
      value: _bloc,
      child: BlocConsumer<PedidoEntradaBloc, PedidoEntradaState>(
        listener: (context, state) {
          final erro = state.erro;
          if (erro != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(erro)));
          }
          final resumo = state.resumo;
          if (resumo != null && !state.salvando) {
            Navigator.of(context).pushReplacementNamed(
              '/pedido_entrada',
              arguments: {'pedidoId': resumo.pedidoId},
            );
          }
        },
        builder: (context, state) {
          final podeIniciar = _fornecedorId != null &&
              _tabelaDePrecoId != null &&
              !state.salvando;
          return Scaffold(
            appBar: AppBar(title: const Text('Entrada por contagem')),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Conte a mercadoria recebida por referência, cor e '
                          'tamanho. Referências ainda não cadastradas podem ser '
                          'criadas na própria contagem. Nada entra no estoque '
                          'até a conferência e o faturamento.',
                          style: tema.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 20),
                        Text('1. Fornecedor',
                            style: tema.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        widget.fornecedorSeletor(
                          SeletorData(
                            compacto: true,
                            onChanged: (itens) => setState(
                              () => _fornecedorId =
                                  itens.isEmpty ? null : itens.first.id,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '2. Tabela de preço do pedido',
                          style: tema.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        widget.tabelaDePrecoSeletor(
                          SeletorData(
                            compacto: true,
                            onChanged: (itens) => setState(
                              () => _tabelaDePrecoId =
                                  itens.isEmpty ? null : itens.first.id,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          key: const Key('iniciar_contagem_button'),
                          onPressed: podeIniciar
                              ? () => _bloc.add(
                                    PedidoEntradaCriouPorContagem(
                                      pessoaId: _fornecedorId!,
                                      tabelaPrecoId: _tabelaDePrecoId!,
                                    ),
                                  )
                              : null,
                          icon: state.salvando
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.fact_check_outlined),
                          label: const Text('Iniciar contagem'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
