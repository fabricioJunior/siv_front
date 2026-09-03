import 'dart:async';

import 'package:comercial/presentation.dart';
import 'package:comercial/models.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes/injecoes.dart';
import 'package:core/leitor/data_source/i_leitor_busca_data_datasource.dart';
import 'package:core/leitor/data_source/i_leitor_data_datasource.dart';
import 'package:core/leitor/leitor_bloc/leitor_bloc.dart';
import 'package:core/leitor/leitor_widget.dart';
import 'package:core/presentation.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:estoque/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String _resultadoRomaneioStatusKey = 'status';
const String _resultadoRomaneioIdKey = 'romaneioId';
const String _resultadoRomaneioStatusSucesso = 'sucesso';
const String _resultadoRomaneioStatusFalha = 'falha';
const String _resultadoRomaneioStatusParcial = 'parcial';

class VendaPage extends StatefulWidget {
  final SeletorWidget pessoaSeletor;
  final SeletorWidget vendedoresSeletor;
  final SeletorWidget tabelasDePrecoSeletor;
  final SeletorWidget formasDePagamentoSeletor;

  const VendaPage({
    super.key,
    required this.pessoaSeletor,
    required this.vendedoresSeletor,
    required this.tabelasDePrecoSeletor,
    required this.formasDePagamentoSeletor,
  });

  @override
  State<VendaPage> createState() => _VendaPageState();
}

enum _VendaAcao { finalizar }

class _VendaPageState extends State<VendaPage> {
  late final LeitorController _leitorController;
  final _codigoController = TextEditingController();
  final _codigoFocusNode = FocusNode();
  LeitorBloc? _leitorBloc;
  int? _leitorBlocTabelaId;
  bool _modoRemocao = false;
  DateTime? _ultimaLeituraEm;
  int _ultimoOrcamentoSalvoContador = 0;
  Timer? _relogio;

  @override
  void initState() {
    super.initState();
    _leitorController = LeitorController();
    // ponytail: tick de 1s pra "Última leitura há Xs" no rodapé da tabela --
    // custo desprezível numa tela única de POS, sem precisar de outro bloc.
    _relogio = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _relogio?.cancel();
    _leitorController.dispose();
    _leitorBloc?.close();
    _codigoController.dispose();
    _codigoFocusNode.dispose();
    SivPageAcoes.limpar();
    super.dispose();
  }

  void _solicitarFocoLeitura() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _codigoFocusNode.requestFocus();
    });
  }

  void _garantirLeitorBloc(int? tabelaDePrecoId) {
    if (_leitorBloc != null && _leitorBlocTabelaId == tabelaDePrecoId) {
      return;
    }
    final estadoAnterior = _leitorBloc?.state;
    if (_leitorBloc != null) {
      _leitorController.unbind(_leitorBloc!);
      _leitorBloc!.close();
    }
    _leitorBloc = LeitorBloc(
      dataSource: sl<ILeitorDataDatasource>(),
      controlarQuantidade: true,
      tabelaDePrecoId: tabelaDePrecoId,
      aceitarApenasProdutosComPreco: true,
      estadoInicial: estadoAnterior,
    );
    _leitorBlocTabelaId = tabelaDePrecoId;
    _leitorController.bind(_leitorBloc!);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VendaBloc>(
      create: (_) =>
          sl<VendaBloc>()..add(const VendaClienteNaoCadastradoSolicitado()),
      child: BlocConsumer<VendaBloc, VendaState>(
        listenWhen: (previous, current) =>
            (previous.erro != current.erro && current.erro != null) ||
            (previous.listaCompartilhadaHash !=
                    current.listaCompartilhadaHash &&
                current.listaCompartilhadaHash != null) ||
            (previous.pedidoCriadoId != current.pedidoCriadoId &&
                current.pedidoCriadoId != null) ||
            previous.orcamentoSalvoContador != current.orcamentoSalvoContador,
        listener: (context, state) async {
          final erro = state.erro;
          if (erro != null) {
            SivAviso.mostrar(context, mensagem: erro, tipo: SivAvisoTipo.falha);
          }

          if (state.orcamentoSalvoContador != _ultimoOrcamentoSalvoContador) {
            _ultimoOrcamentoSalvoContador = state.orcamentoSalvoContador;
            SivAviso.mostrar(context, mensagem: 'Orçamento salvo com sucesso.');
            _reiniciarFluxo(context);
            return;
          }

          final listaCompartilhadaHash = state.listaCompartilhadaHash;
          if (listaCompartilhadaHash != null) {
            final result = await Navigator.of(context).pushNamed(
              '/criar_romaneio_por_parametros',
              arguments: {
                'listaCompartilhadaHash': listaCompartilhadaHash,
                'formasDePagamentoRealizadas':
                    state.formasDePagamentoRealizadas,
                'desconto': state.valorDesconto,
                'descontosItens': state.descontosItens,
                'descontosPromocao': state.descontosPromocao,
                'cupom': state.cupom,
                'valorTaxaEntrega': state.valorTaxaEntrega,
                'incluirCpfNaNota': state.incluirCpfNaNota,
                'cpfNaNota': state.cpfNaNota,
                'pontuarFidelidade': state.pontuarFidelidade,
                'enviarNotaPorEmail': state.enviarNotaPorEmail,
                'emailNota': state.emailNota,
              },
            );

            if (!context.mounted) return;

            final resultadoStatus = result is Map<String, dynamic>
                ? result[_resultadoRomaneioStatusKey]?.toString()
                : result == true
                    ? _resultadoRomaneioStatusSucesso
                    : null;
            final resultadoRomaneioId = result is Map<String, dynamic>
                ? result[_resultadoRomaneioIdKey]
                : null;

            if (resultadoStatus == _resultadoRomaneioStatusSucesso) {
              SivAviso.mostrar(context,
                  mensagem: 'Venda finalizada com sucesso.');
              final orcamentoId = state.orcamentoId;
              if (orcamentoId != null) {
                context.read<VendaBloc>().add(
                      VendaOrcamentoExcluirAposFinalizarSolicitado(
                        hash: orcamentoId,
                      ),
                    );
              }
              _reiniciarFluxo(context);
              return;
            }

            if (resultadoStatus == _resultadoRomaneioStatusFalha) {
              SivAviso.mostrar(
                context,
                mensagem:
                    'Não foi possível concluir a venda. Confira o pagamento e tente de novo.',
                tipo: SivAvisoTipo.falha,
              );
              return;
            }

            if (resultadoStatus == _resultadoRomaneioStatusParcial) {
              final romaneioId = resultadoRomaneioId?.toString() ?? '-';
              SivAviso.mostrar(
                context,
                mensagem:
                    'Venda gerou o romaneio #$romaneioId, mas o processamento não foi concluído automaticamente.',
                tipo: SivAvisoTipo.atencao,
              );
              final orcamentoId = state.orcamentoId;
              if (orcamentoId != null) {
                context.read<VendaBloc>().add(
                      VendaOrcamentoExcluirAposFinalizarSolicitado(
                        hash: orcamentoId,
                      ),
                    );
              }
              _reiniciarFluxo(context);
            }
          }

          final pedidoCriadoId = state.pedidoCriadoId;
          if (pedidoCriadoId != null) {
            SivAviso.mostrar(
              context,
              mensagem: 'Pedido #$pedidoCriadoId criado com sucesso.',
            );

            Navigator.of(context).pushNamed(
              '/pedido',
              arguments: {'idPedido': pedidoCriadoId},
            );
          }
        },
        builder: (context, state) {
          if (state.leituraIniciada) {
            _garantirLeitorBloc(state.tabelaDePrecoId);
            _atualizarAcoesDaBarraDeTitulo(context, state);
          } else {
            SivPageAcoes.limpar();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!state.leituraIniciada) ...[
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildConfiguracaoCard(context, state),
                      ],
                    ),
                  ),
                ),
              ] else
                Expanded(child: _buildLeituraAtiva(context, state)),
            ],
          );
        },
      ),
    );
  }

  void _atualizarAcoesDaBarraDeTitulo(BuildContext context, VendaState state) {
    final temItens = _leitorController.itens.isNotEmpty;

    SivPageAcoes.definir([
      OutlinedButton.icon(
        onPressed: temItens && !state.processando
            ? () => _confirmarReinicio(context)
            : null,
        icon: const Icon(Icons.refresh_outlined, size: 18),
        label: const Text('Reiniciar contagem'),
      ),
      OutlinedButton.icon(
        onPressed: temItens && !state.processando
            ? () => _salvarOrcamento(context)
            : null,
        icon: state.processoAtual == VendaProcesso.salvarOrcamento
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_outlined, size: 18),
        label: const Text('Salvar orçamento'),
      ),
      OutlinedButton.icon(
        onPressed: temItens && !state.processando
            ? () => _salvarComoPedido(context)
            : null,
        icon: state.processoAtual == VendaProcesso.criarPedido
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.assignment_outlined, size: 18),
        label: const Text('Salvar como pedido'),
      ),
    ]);
  }

  Widget _buildLeituraAtiva(BuildContext context, VendaState state) {
    final leitorBloc = _leitorBloc!;
    return CallbackShortcuts(
      bindings: {
        LogicalKeySet(LogicalKeyboardKey.f2): () =>
            _abrirBuscaManual(context, state),
        LogicalKeySet(LogicalKeyboardKey.f9): () {
          if (_leitorController.itens.isNotEmpty && !state.processando) {
            _abrirConfirmacao(context, state, _VendaAcao.finalizar);
          }
        },
        LogicalKeySet(LogicalKeyboardKey.escape): () =>
            _confirmarReinicio(context),
      },
      child: Focus(
        autofocus: true,
        child: BlocProvider.value(
          value: leitorBloc,
          child: BlocConsumer<LeitorBloc, LeitorState>(
            listener: (context, leitorState) {
              _leitorController.syncState(leitorState);
              _atualizarAcoesDaBarraDeTitulo(context, state);
              if (leitorState.erro != null) {
                SivAviso.mostrar(context,
                    mensagem: leitorState.erro!, tipo: SivAvisoTipo.falha);
              } else if (leitorState.aviso != null) {
                SivAviso.mostrar(context,
                    mensagem: leitorState.aviso!, tipo: SivAvisoTipo.atencao);
              } else if (leitorState.ultimoProdutoLido != null) {
                _ultimaLeituraEm = DateTime.now();
              }
              _solicitarFocoLeitura();
            },
            builder: (context, leitorState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCampoDeLeitura(context, leitorState),
                  const SizedBox(height: SivDimensoes.gapCards),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: _buildTabelaDeItens(
                                context, leitorState, state),
                          ),
                        ),
                        const SizedBox(width: SivDimensoes.gapCards),
                        SizedBox(
                          width: 396,
                          child: SingleChildScrollView(
                            child: _buildPainelDireito(
                                context, state, leitorState),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCampoDeLeitura(BuildContext context, LeitorState leitorState) {
    final cores = context.sivColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            controller: _codigoController,
            focusNode: _codigoFocusNode,
            autofocus: true,
            style: context.sivTextos.secao,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.barcode_reader, size: 28),
              suffixIcon: leitorState.processando
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
              hintText: _modoRemocao
                  ? 'Bipe para remover 1 unidade do item'
                  : 'Bipe ou informe o código do produto · F2 buscar por nome',
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submeterCodigo(),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          tooltip: _modoRemocao
              ? 'Voltar ao modo leitura'
              : 'Ativar remoção por leitura',
          isSelected: _modoRemocao,
          style: IconButton.styleFrom(
            side: BorderSide(color: cores.hairline),
            minimumSize: const Size.square(SivDimensoes.alvoToqueMinimo + 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SivDimensoes.raio),
            ),
          ),
          onPressed: () {
            setState(() => _modoRemocao = !_modoRemocao);
            _solicitarFocoLeitura();
          },
          icon: Icon(
            _modoRemocao
                ? Icons.remove_circle_outline
                : Icons.add_circle_outline,
          ),
        ),
      ],
    );
  }

  Widget _buildTabelaDeItens(
    BuildContext context,
    LeitorState leitorState,
    VendaState vendaState,
  ) {
    final itensExibicao = leitorState.itens.reversed.toList(growable: false);
    final totalPecas = leitorState.quantidadeTotalLida;
    final segundos = _ultimaLeituraEm == null
        ? null
        : DateTime.now().difference(_ultimaLeituraEm!).inSeconds;
    final nomeTabela =
        vendaState.tabelaDePrecoSelecionada?.nome ?? 'não selecionada';

    return SivTabela(
      colunas: const [
        SivTabelaColuna.numerica(titulo: 'ITEM', flex: 1),
        SivTabelaColuna(titulo: 'PRODUTO', flex: 4),
        SivTabelaColuna(titulo: 'GRADE', flex: 2),
        SivTabelaColuna.numerica(titulo: 'UNITÁRIO', flex: 2),
        SivTabelaColuna.numerica(titulo: 'QTD.', flex: 1),
        SivTabelaColuna.numerica(titulo: 'TOTAL', flex: 2),
      ],
      quantidadeLinhas: itensExibicao.length,
      linhaSelecionada: (indice) => indice == 0,
      rodape: itensExibicao.isEmpty
          ? 'Sem tabela não dá pra bipar — o preço vem dela. Selecione a tabela de preço e bora vender.'
          : '${itensExibicao.length} referência${itensExibicao.length == 1 ? '' : 's'} · $totalPecas peça${totalPecas == 1 ? '' : 's'} bipada${totalPecas == 1 ? '' : 's'}  ·  '
              '${segundos == null ? 'Tudo pronto pra bipar' : 'Última leitura há ${segundos}s'}  ·  Tabela $nomeTabela',
      linhaBuilder: (context, indice) {
        final item = itensExibicao[indice];
        final numeroItem = itensExibicao.length - indice;
        // ponytail: dados['produto'] é ProdutoDoEstoque (sem marca cadastrada
        // hoje) -- REF usa referenciaIdExterno/referenciaId; marca fica TODO
        // até o modelo de produto ganhar esse campo.
        final produto = item.dados['produto'] as ProdutoDoEstoque?;
        final ref = produto?.referenciaIdExterno ??
            produto?.referenciaId.toString() ??
            '-';
        return [
          Text('#$numeroItem', style: context.sivTextos.apoio),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.descricao, style: context.sivTextos.corpo),
              // TODO: marca não existe em ProdutoDoEstoque hoje -- exibindo
              // só REF até o backend/model trazer a marca da referência.
              Text('REF $ref', style: context.sivTextos.apoio),
            ],
          ),
          Text(
            'Cor: ${item.cor.isEmpty ? '-' : item.cor}  •  Tam: ${item.tamanho.isEmpty ? '-' : item.tamanho}',
            style: context.sivTextos.apoio,
          ),
          Text(_formatarMoeda(item.valorUnitario ?? 0),
              style: context.sivTextos.corpo),
          Text('${item.quantidadeLida}', style: context.sivTextos.secao),
          Text(_formatarMoeda(item.valorTotal), style: context.sivTextos.corpo),
        ];
      },
    );
  }

  Widget _buildPainelDireito(
    BuildContext context,
    VendaState state,
    LeitorState leitorState,
  ) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final temItens = leitorState.itens.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SivCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Cliente', style: textos.rotulo),
              const SizedBox(height: 8),
              AbsorbPointer(
                absorbing: state.processando,
                child: widget.pessoaSeletor(
                  SeletorData(
                    itemsSelecionadosInicial: state.clienteSelecionado == null
                        ? null
                        : [state.clienteSelecionado!],
                    onChanged: (selecionados) {
                      context.read<VendaBloc>().add(
                            VendaClienteSelecionado(
                              clienteSelecionado: selecionados.isEmpty
                                  ? null
                                  : selecionados.first,
                            ),
                          );
                      _solicitarFocoLeitura();
                    },
                  ),
                ),
              ),
              // TODO: Pessoa (packages/pessoas/lib/domain/models/pessoa.dart)
              // não expõe cidade, limite de crédito nem situação de débito --
              // sem esses campos não dá pra montar os chips pedidos aqui.
            ],
          ),
        ),
        const SizedBox(height: SivDimensoes.gapCards),
        SivCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Vendedor', style: textos.rotulo),
              const SizedBox(height: 8),
              AbsorbPointer(
                absorbing: state.processando,
                child: widget.vendedoresSeletor(
                  SeletorData(
                    itemsSelecionadosInicial: state.vendedorSelecionado == null
                        ? null
                        : [state.vendedorSelecionado!],
                    onChanged: (selecionados) {
                      context.read<VendaBloc>().add(
                            VendaVendedorSelecionado(
                              vendedorSelecionado: selecionados.isEmpty
                                  ? null
                                  : selecionados.first,
                            ),
                          );
                      _solicitarFocoLeitura();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Tabela de preço', style: textos.rotulo),
              const SizedBox(height: 8),
              AbsorbPointer(
                absorbing: true,
                child: widget.tabelasDePrecoSeletor(
                  SeletorData(
                    itemsSelecionadosInicial:
                        state.tabelaDePrecoSelecionada == null
                            ? null
                            : [state.tabelaDePrecoSelecionada!],
                    onlyView: true,
                    onChanged: (_) {},
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: SivDimensoes.gapCards),
        SivCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _linhaResumo(context, 'Subtotal',
                  _formatarMoeda(leitorState.valorTotalLido)),
              // TODO: desconto e entrega só são decididos na tela de
              // pagamento (PagamentosRealizadosWidget, aberta em "Finalizar
              // e ir ao caixa") -- não há valor de rascunho pra mostrar aqui
              // antes disso.
              _linhaResumo(context, 'Desconto', '—'),
              _linhaResumo(context, 'Entrega', '—'),
            ],
          ),
        ),
        const SizedBox(height: SivDimensoes.gapCards),
        SivCard(
          variante: SivCardVariante.destaque,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total', style: textos.corpo.copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              Text(_formatarMoeda(leitorState.valorTotalLido),
                  style: textos.display.copyWith(color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: SivDimensoes.gapCards),
        FilledButton.icon(
          onPressed: temItens && !state.processando
              ? () => _abrirConfirmacao(context, state, _VendaAcao.finalizar)
              : null,
          icon: state.processoAtual == VendaProcesso.finalizarVenda
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.point_of_sale_outlined),
          label: Text(
            state.processoAtual == VendaProcesso.finalizarVenda
                ? 'Encaminhando...'
                : 'Finalizar e ir ao caixa',
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'F9 finalizar   ·   F4 desconto*   ·   ESC cancelar',
          textAlign: TextAlign.center,
          style: textos.apoio,
        ),
        // TODO: não existe limite de desconto por vendedor no domínio hoje
        // (nenhum campo em Funcionario) -- F4 fica só como legenda até essa
        // regra existir; o desconto real é aplicado na tela de pagamento.
      ],
    );
  }

  Widget _linhaResumo(BuildContext context, String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.sivTextos.corpo),
          Text(valor, style: context.sivTextos.corpo),
        ],
      ),
    );
  }

  Widget _buildConfiguracaoCard(BuildContext context, VendaState state) {
    final bloc = context.read<VendaBloc>();
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Iniciar venda', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            AbsorbPointer(
              absorbing: state.processando,
              child: Column(
                children: [
                  widget.pessoaSeletor(
                    SeletorData(
                      itemsSelecionadosInicial: state.clienteSelecionado == null
                          ? null
                          : [state.clienteSelecionado!],
                      onChanged: (selecionados) {
                        bloc.add(
                          VendaClienteSelecionado(
                            clienteSelecionado: selecionados.isEmpty
                                ? null
                                : selecionados.first,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  widget.vendedoresSeletor(
                    SeletorData(
                      itemsSelecionadosInicial:
                          state.vendedorSelecionado == null
                              ? null
                              : [state.vendedorSelecionado!],
                      onChanged: (selecionados) {
                        bloc.add(
                          VendaVendedorSelecionado(
                            vendedorSelecionado: selecionados.isEmpty
                                ? null
                                : selecionados.first,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  widget.tabelasDePrecoSeletor(
                    SeletorData(
                      itemsSelecionadosInicial:
                          state.tabelaDePrecoSelecionada == null
                              ? null
                              : [state.tabelaDePrecoSelecionada!],
                      onChanged: (selecionados) {
                        bloc.add(
                          VendaTabelaDePrecoSelecionada(
                            tabelaDePrecoSelecionada: selecionados.isEmpty
                                ? null
                                : selecionados.first,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: state.estadoInicial
                      ? () => _abrirOrcamentos(context)
                      : null,
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Orçamentos'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: state.podeIniciarLeitura
                      ? () => bloc.add(const VendaLeituraSolicitada())
                      : null,
                  icon: state.verificandoCaixa
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow_outlined),
                  label: Text(
                    state.verificandoCaixa
                        ? 'Verificando caixa...'
                        : 'Bora vender',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submeterCodigo() {
    final codigo = _codigoController.text.trim();
    if (codigo.isEmpty) {
      _solicitarFocoLeitura();
      return;
    }

    _codigoController.clear();
    if (_modoRemocao) {
      _leitorController.removerQuantidade(codigo);
    } else {
      _leitorController.lerCodigo(codigo);
    }
    _solicitarFocoLeitura();
  }

  Future<void> _abrirBuscaManual(BuildContext context, VendaState state) async {
    final resultado = await abrirBuscaManualDeProduto(
      context: context,
      buscaDataSource: sl<ILeitorBuscaDataDatasource>(),
      tabelaDePrecoId: state.tabelaDePrecoId,
      modoRemocao: _modoRemocao,
    );

    if (resultado == null) {
      _solicitarFocoLeitura();
      return;
    }

    if (_modoRemocao) {
      _leitorController.removerQuantidade(
        resultado.produto.codigoDeBarras,
        quantidade: resultado.quantidade,
      );
    } else {
      _leitorController.lerCodigoComQuantidade(
        resultado.produto.codigoDeBarras,
        resultado.quantidade,
      );
    }
    _solicitarFocoLeitura();
  }

  Future<void> _abrirConfirmacao(
    BuildContext context,
    VendaState state,
    _VendaAcao acao,
  ) async {
    final bloc = context.read<VendaBloc>();
    final clienteSelecionado = state.clienteSelecionado;
    final vendedorSelecionado = state.vendedorSelecionado;

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar finalização da venda'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confira o resumo antes de continuar.',
                    style: Theme.of(dialogContext).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoChip(
                    icon: Icons.person_outline,
                    label:
                        'Cliente: ${clienteSelecionado?.nome.toUpperCase() ?? '-'}',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoChip(
                    icon: Icons.badge_outlined,
                    label:
                        'Vendedor: ${vendedorSelecionado?.nome.toUpperCase() ?? '-'}',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoChip(
                    icon: Icons.numbers_outlined,
                    label:
                        'Quantidade de produtos: ${_leitorController.quantidadeTotalLida}',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoChip(
                    icon: Icons.payments_outlined,
                    label:
                        'Valor total do pedido: ${_formatarMoeda(_leitorController.valorTotalLido)}',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Voltar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Finalizar venda'),
            ),
          ],
        );
      },
    );

    if (confirmou != true) {
      _solicitarFocoLeitura();
      return;
    }

    final itens = _leitorController.itens
        .map(
          (item) => {
            'produtoId': item.id,
            'quantidade': item.quantidadeLida,
            'valorUnitario': item.valorUnitario,
            'nome': item.descricao,
            'corNome': item.cor,
            'tamanhoNome': item.tamanho,
          },
        )
        .toList(growable: false);

    final pagamentoResultado = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PagamentosRealizadosWidget(
          hashLista: state.listaCompartilhadaHash ?? '',
          resumoInicial: PagamentosRealizadosResumo(
            listaCompartilhada: null,
            produtosCompartilhados: _leitorController.itens
                .map(
                  (item) => ProdutoCompartilhado.create(
                    produtoId: item.id,
                    quantidade: item.quantidadeLida,
                    valorUnitario: item.valorUnitario ?? 0,
                    nome: item.descricao,
                    corNome: item.cor,
                    tamanhoNome: item.tamanho,
                  ),
                )
                .toList(),
            quantidadeTotalProdutos: _leitorController.quantidadeTotalLida,
            valorTotalProdutos: _leitorController.valorTotalLido,
          ),
          pessoaId: clienteSelecionado?.id,
          cpfClienteInicial: clienteSelecionado?.data['documento']?.toString(),
          clienteGenerico: clienteSelecionado?.data['generica'] == true,
          emailClienteInicial: clienteSelecionado?.data['email']?.toString(),
          enviarNotaPorEmailInicial:
              clienteSelecionado?.data['enviarNotaPorEmail'] == true,
          formasDePagamentoSeletor: widget.formasDePagamentoSeletor,
          exibirCheckboxFidelidade: true,
        );
      },
    );

    if (pagamentoResultado == null) {
      _solicitarFocoLeitura();
      return;
    }

    final formasDePagamentoRaw =
        pagamentoResultado['formasDePagamentoRealizadas'] as List<dynamic>? ??
            const [];
    final formasDePagamentoRealizadas = formasDePagamentoRaw
        .whereType<Map<String, dynamic>>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
    final valorDesconto = _toDouble(pagamentoResultado['desconto']) ?? 0;
    final descontosItensRaw =
        pagamentoResultado['descontosItens'] as List<dynamic>? ?? const [];
    final descontosItens = descontosItensRaw
        .whereType<Map<String, dynamic>>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
    final descontosPromocaoRaw =
        pagamentoResultado['descontosPromocao'] as List<dynamic>? ?? const [];
    final descontosPromocao = descontosPromocaoRaw
        .whereType<Map<String, dynamic>>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
    final cupom = pagamentoResultado['cupom'] as Map<String, dynamic>?;
    final incluirCpfNaNota =
        pagamentoResultado['incluirCpfNaNota'] as bool? ?? true;
    final cpfNaNota = pagamentoResultado['cpfNaNota']?.toString() ?? '';
    final pontuarFidelidade =
        pagamentoResultado['pontuarFidelidade'] as bool? ?? false;
    final valorTaxaEntrega =
        _toDouble(pagamentoResultado['valorTaxaEntrega']) ?? 0;
    final enviarNotaPorEmail =
        pagamentoResultado['enviarNotaPorEmail'] as bool? ?? false;
    final emailNota = pagamentoResultado['emailNota']?.toString() ?? '';

    final confirmouEmissao = await _abrirConfirmacaoEmissao(
      context,
      pagamentoResultado: pagamentoResultado,
      valorDesconto: valorDesconto,
    );

    if (confirmouEmissao != true) {
      _solicitarFocoLeitura();
      return;
    }

    bloc.add(
      VendaFinalizarSolicitada(
        itens: itens,
        formasDePagamentoRealizadas: formasDePagamentoRealizadas,
        valorDesconto: valorDesconto,
        valorTaxaEntrega: valorTaxaEntrega,
        descontosItens: descontosItens,
        descontosPromocao: descontosPromocao,
        cupom: cupom,
        incluirCpfNaNota: incluirCpfNaNota,
        cpfNaNota: cpfNaNota,
        pontuarFidelidade: pontuarFidelidade,
        enviarNotaPorEmail: enviarNotaPorEmail,
        emailNota: emailNota,
      ),
    );
  }

  Future<bool?> _abrirConfirmacaoEmissao(
    BuildContext context, {
    required Map<String, dynamic> pagamentoResultado,
    required double valorDesconto,
  }) {
    final resumoFormasRaw =
        pagamentoResultado['resumoFormasDePagamento'] as List<dynamic>? ??
            const [];
    final resumoFormas = resumoFormasRaw
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => (
            nome: item['nome']?.toString() ?? '-',
            valor: _toDouble(item['valor']) ?? 0,
          ),
        )
        .toList(growable: false);
    final valorTotalRecebido =
        _toDouble(pagamentoResultado['valorTotalRecebido']) ?? 0;
    final valorTroco = _toDouble(pagamentoResultado['valorTroco']) ?? 0;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar pagamento e emitir romaneio'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ao confirmar, o romaneio será gerado e o estoque baixado. Confira o pagamento:',
                    style: Theme.of(dialogContext).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoChip(
                    icon: Icons.receipt_long_outlined,
                    label:
                        'Valor total do pedido: ${_formatarMoeda(_leitorController.valorTotalLido)}',
                  ),
                  const SizedBox(height: 12),
                  ...resumoFormas.map(
                    (forma) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildInfoChip(
                        icon: Icons.payments_outlined,
                        label: '${forma.nome}: ${_formatarMoeda(forma.valor)}',
                      ),
                    ),
                  ),
                  if (valorDesconto > 0) ...[
                    const Divider(height: 16),
                    _buildInfoChip(
                      icon: Icons.discount_outlined,
                      label:
                          'Desconto aplicado: ${_formatarMoeda(valorDesconto)}',
                    ),
                    const SizedBox(height: 8),
                  ] else
                    const Divider(height: 16),
                  _buildInfoChip(
                    icon: Icons.account_balance_wallet_outlined,
                    label:
                        'Total recebido: ${_formatarMoeda(valorTotalRecebido)}',
                  ),
                  if (valorTroco > 0) ...[
                    const SizedBox(height: 8),
                    _buildInfoChip(
                      icon: Icons.currency_exchange_outlined,
                      label: 'Troco: ${_formatarMoeda(valorTroco)}',
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Voltar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Confirmar e emitir'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmarReinicio(BuildContext context) async {
    if (_leitorController.itens.isEmpty) {
      _solicitarFocoLeitura();
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reiniciar contagem'),
          content: const Text(
            'Deseja realmente limpar os itens lidos e reiniciar a contagem desta venda?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Reiniciar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      _leitorController.limpar();
    }
    _solicitarFocoLeitura();
  }

  void _salvarOrcamento(BuildContext context) {
    final itens = _leitorController.itens
        .map(
          (item) => {
            'produtoId': item.id,
            'quantidade': item.quantidadeLida,
            'valorUnitario': item.valorUnitario,
            'nome': item.descricao,
            'corNome': item.cor,
            'tamanhoNome': item.tamanho,
          },
        )
        .toList(growable: false);

    context.read<VendaBloc>().add(VendaOrcamentoSalvarSolicitado(itens: itens));
  }

  void _salvarComoPedido(BuildContext context) {
    final itens = _leitorController.itens
        .map(
          (item) => {
            'produtoId': item.id,
            'quantidade': item.quantidadeLida,
            'valorUnitario': item.valorUnitario,
            'nome': item.descricao,
            'corNome': item.cor,
            'tamanhoNome': item.tamanho,
          },
        )
        .toList(growable: false);

    context.read<VendaBloc>().add(
          VendaCriarPedidoSolicitado(
            itens: itens,
            quantidadeProdutos: _leitorController.quantidadeTotalLida,
            valorTotal: _leitorController.valorTotalLido,
          ),
        );
  }

  Future<void> _abrirOrcamentos(BuildContext context) async {
    final bloc = context.read<VendaBloc>();
    final hashSelecionado = await Navigator.of(context).pushNamed(
      '/orcamentos',
    );

    if (hashSelecionado is String && hashSelecionado.isNotEmpty) {
      bloc.add(VendaOrcamentoCarregarSolicitado(hash: hashSelecionado));
    }
  }

  void _reiniciarFluxo(BuildContext context) {
    _leitorController.limpar();
    _ultimoOrcamentoSalvoContador = 0;
    _ultimaLeituraEm = null;
    SivPageAcoes.limpar();
    context.read<VendaBloc>().add(const VendaResetSolicitado());
    _solicitarFocoLeitura();
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  double? _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().replaceAll(',', '.') ?? '');
  }
}
