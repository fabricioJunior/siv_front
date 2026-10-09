import 'package:comercial/presentation/blocs/pedido_entrada_bloc/pedido_entrada_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
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
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Para mercadoria sem NF-e ou sem cadastro. Cria um '
                              'pedido de entrada; nada entra no estoque antes de '
                              'faturar.',
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
                              '2. Tabela de preço',
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
                            const SizedBox(height: 4),
                            Text('Preço da etiqueta e do pedido.',
                                style: context.sivTextos.apoio),
                            const SizedBox(height: 24),
                            const _CincoPassos(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                RodapeAcaoEntrada(
                  acao: BotaoPrincipalEntrada(
                    key: const Key('iniciar_contagem_button'),
                    rotulo: 'INICIAR CONTAGEM',
                    icone: state.salvando ? null : Icons.fact_check_outlined,
                    onPressed: podeIniciar
                        ? () => _bloc.add(
                              PedidoEntradaCriouPorContagem(
                                pessoaId: _fornecedorId!,
                                tabelaPrecoId: _tabelaDePrecoId!,
                              ),
                            )
                        : null,
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

/// Card "5 passos" (5a).
class _CincoPassos extends StatelessWidget {
  const _CincoPassos();

  static const _passos = [
    ('Contar', ' por cor e tamanho'),
    ('Associar', ' o que não tem referência'),
    ('Etiquetas', ', uma por peça'),
    ('Conferir', ' bipando as etiquetas'),
    ('Faturar', ': as conferidas entram no estoque'),
  ];

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return Container(
      key: const Key('card_cinco_passos'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cores.superficie,
        border: Border.all(color: cores.hairline),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('5 PASSOS', style: textos.rotulo.copyWith(color: cores.aco)),
          const SizedBox(height: 8),
          for (var i = 0; i < _passos.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: cores.acoEscuro,
                    child: Text(
                      '${i + 1}',
                      style: textos.rotulo.copyWith(
                        letterSpacing: 0,
                        color: cores.textoSobreEscuroTitulo,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: _passos[i].$1,
                            style: textos.corpo
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: _passos[i].$2, style: textos.corpo),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
