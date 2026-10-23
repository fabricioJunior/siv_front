import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/presentation/pagamento/pagamento_contexto.dart';
import 'package:comercial/presentation/pagamento/pagamento_etapa.dart';
import 'package:comercial/presentation/relatorios/pdf/romaneio_pdf_exporter.dart';
import 'package:comercial/presentation/venda/venda_concluida_view.dart';
import 'package:comercial/presentation/venda/venda_etapa.dart';
import 'package:comercial/presentation/widgets/impressao_documento_helper.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes/injecoes.dart';
import 'package:core/leitor/data_source/i_leitor_busca_data_datasource.dart';
import 'package:core/leitor/data_source/i_leitor_data_datasource.dart';
import 'package:core/leitor/leitor_widget.dart';
import 'package:core/presentation.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VendaPage extends StatefulWidget {
  final SeletorWidget pessoaSeletor;
  final SeletorWidget vendedoresSeletor;
  final SeletorWidget tabelasDePrecoSeletor;
  final FormaPagamentoGradeWidget formaPagamentoGrade;

  const VendaPage({
    super.key,
    required this.pessoaSeletor,
    required this.vendedoresSeletor,
    required this.tabelasDePrecoSeletor,
    required this.formaPagamentoGrade,
  });

  @override
  State<VendaPage> createState() => _VendaPageState();
}

class _VendaPageState extends State<VendaPage> {
  late final LeitorController _leitorController;
  int _ultimoOrcamentoSalvoContador = 0;
  int _ultimaFinalizacao = 0;
  bool _trocandoCliente = false;
  bool _trocandoVendedor = false;
  bool _editandoDesconto = false;
  final _descontoController = TextEditingController();
  final _focoDesconto = FocusNode();

  // O pagamento e a criação do romaneio vivem na página: Esc no pagamento
  // preserva as linhas (mesmo bloc) e a Concluída/Pendência ficam na tela até
  // "Nova venda".
  PagamentosRealizadosBloc? _pagamentoBloc;
  String? _pagamentoAssinatura;
  RomaneioCriacaoBloc? _criacao;
  StreamSubscription<RomaneioCriacaoState>? _criacaoSub;
  RomaneioCriacaoState? _criacaoState;
  RomaneioCriacaoStep? _ultimoPasso;
  Map<String, dynamic> _resultado = const {};
  DateTime _concluidaEm = DateTime.now();
  bool _orcamentoExcluido = false;

  @override
  void initState() {
    super.initState();
    _leitorController = LeitorController();
  }

  @override
  void dispose() {
    SivPageFab.limpar();
    _leitorController.dispose();
    _descontoController.dispose();
    _focoDesconto.dispose();
    _pagamentoBloc?.close();
    _criacaoSub?.cancel();
    _criacao?.close();
    super.dispose();
  }

  void _solicitarFocoLeitura() {}

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VendaBloc>(
      create: (_) =>
          sl<VendaBloc>()..add(const VendaClienteNaoCadastradoSolicitado()),
      child: BlocConsumer<VendaBloc, VendaState>(
        listenWhen: (previous, current) =>
            (previous.erro != current.erro && current.erro != null) ||
            (previous.avisoNota != current.avisoNota &&
                current.avisoNota != null) ||
            previous.finalizacaoContador != current.finalizacaoContador ||
            previous.descontoContador != current.descontoContador ||
            (previous.pedidoCriadoId != current.pedidoCriadoId &&
                current.pedidoCriadoId != null) ||
            previous.orcamentoSalvoContador != current.orcamentoSalvoContador,
        listener: (context, state) async {
          final erro = state.erro;
          if (erro != null) {
            final pagamento = _pagamentoBloc;
            if (pagamento != null &&
                etapaDaVenda(state, _criacaoState) == VendaEtapa.pagamento) {
              pagamento.add(PagamentosRealizadosReaberto(erro: erro));
            } else {
              SivAviso.mostrar(context,
                  mensagem: erro, tipo: SivAvisoTipo.falha);
            }
          }

          final avisoNota = state.avisoNota;
          if (avisoNota != null) {
            SivAviso.mostrar(context, mensagem: avisoNota);
          }

          if (_editandoDesconto && state.descontoContador > 0) {
            _fecharDesconto();
          }

          if (state.orcamentoSalvoContador != _ultimoOrcamentoSalvoContador) {
            _ultimoOrcamentoSalvoContador = state.orcamentoSalvoContador;
            SivAviso.mostrar(context, mensagem: 'Orçamento salvo com sucesso.');
            _reiniciarFluxo(context);
            return;
          }

          if (state.finalizacaoContador != _ultimaFinalizacao) {
            _ultimaFinalizacao = state.finalizacaoContador;
            _iniciarCriacao(context, state);
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
        builder: (context, state) =>
            _buildEtapa(context, state, _criacaoState),
      ),
    );
  }

  // Assinado direto no stream (não por widget): o romaneio pode terminar antes
  // do primeiro frame com o bloc novo, e a transição não pode se perder. Também
  // evita um BlocProvider na árvore, que remontaria o leitor e perderia os itens.
  void _aoMudarCriacao(BuildContext context, RomaneioCriacaoState cs) {
    if (!mounted) return;
    setState(() => _criacaoState = cs);
    if (cs.step == _ultimoPasso) return;
    _ultimoPasso = cs.step;
    final venda = context.read<VendaBloc>();
    final romaneioCriado = cs.listaCompartilhada?.idLista != null;

    if (cs.step == RomaneioCriacaoStep.sucesso) {
      _concluidaEm = DateTime.now();
      if (_resultado['enviarNotaPorEmail'] != true &&
          cs.documentoFiscal?.status == 'emitida') {
        tentarImprimirNotaFiscalAutomaticamente(
          context,
          documentoFiscal: cs.documentoFiscal!,
          romaneio: cs.romaneio,
        );
      }
    } else if (cs.step == RomaneioCriacaoStep.falha && !romaneioCriado) {
      // Falha total: volta ao botão do pagamento com a mensagem ao lado.
      _pagamentoBloc?.add(PagamentosRealizadosReaberto(erro: cs.erro));
      return;
    } else if (cs.step != RomaneioCriacaoStep.falha) {
      return;
    }

    final orcamentoId = venda.state.orcamentoId;
    if (orcamentoId != null && !_orcamentoExcluido) {
      _orcamentoExcluido = true;
      venda.add(
        VendaOrcamentoExcluirAposFinalizarSolicitado(hash: orcamentoId),
      );
    }
  }

  Widget _buildEtapa(
    BuildContext context,
    VendaState state,
    RomaneioCriacaoState? cs,
  ) {
    final etapa = etapaDaVenda(state, cs);
    final venda = context.read<VendaBloc>();

    final outra = switch (etapa) {
      VendaEtapa.configuracao => _buildConfiguracaoCard(context, state),
      VendaEtapa.itens => null,
      VendaEtapa.pagamento => _buildPagamento(context, state),
      VendaEtapa.processando => const VendaProcessandoView(),
      VendaEtapa.concluida => _buildConcluida(context, state, cs!),
      VendaEtapa.pendencia => VendaPendenciaView(
          romaneioId: cs!.listaCompartilhada?.idLista,
          motivo: cs.motivoPendencia,
          onVerRomaneio: () => Navigator.of(context).pushNamed(
            '/romaneio',
            arguments: {
              'idRomaneio': cs.listaCompartilhada?.idLista,
              'permitirEdicao': false,
            },
          ),
          onNovaVenda: () => _novaVenda(venda),
          onTentarNovamente: () =>
              _criacao?.add(const RomaneioCriacaoRecebimentoReenviado()),
        ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (etapa != VendaEtapa.configuracao)
          VendaIndicadorEtapas(etapa: etapa),
        // A leitura fica montada por baixo das outras etapas: o LeitorWidget
        // recria o próprio estado ao remontar e perderia os itens lidos.
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (state.leituraIniciada)
                Offstage(
                  offstage: etapa != VendaEtapa.itens,
                  child: _buildLeituraAtiva(context, state),
                ),
              if (outra != null) outra,
            ],
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _itensDaLeitura() {
    return _leitorController.itens
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
  }

  void _irParaPagamento(BuildContext context, VendaState state) {
    if (_leitorController.itens.isEmpty || state.processando) return;
    context.read<VendaBloc>().add(
          VendaPagamentoSolicitado(subtotal: _leitorController.valorTotalLido),
        );
  }

  // Esc volta aos itens e F9 reabre com o mesmo bloc; mudou item, desconto ou
  // cliente, o resumo do bloc ficou velho e ele é recriado.
  Widget _buildPagamento(BuildContext context, VendaState state) {
    final cliente = state.clienteSelecionado;
    final assinatura = [
      for (final i in _leitorController.itens)
        '${i.id}x${i.quantidadeLida}@${i.valorUnitario}',
      state.descontoRascunho,
      cliente?.id,
    ].join('|');

    final contexto = PagamentoContexto.venda(
        hashLista: '',
        resumo: PagamentosRealizadosResumo(
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
        subtitulo: cliente?.nome,
        descontoInicial: state.descontoRascunho,
        pessoaId: cliente?.id,
        cpfInicial: cliente?.data['documento']?.toString(),
        clienteGenerico: cliente?.data['generica'] == true,
        emailInicial: cliente?.data['email']?.toString(),
        enviarNotaPorEmailInicial: cliente?.data['enviarNotaPorEmail'] == true,
    );

    if (_pagamentoBloc == null || _pagamentoAssinatura != assinatura) {
      _pagamentoBloc?.close();
      _pagamentoAssinatura = assinatura;
      _pagamentoBloc = contexto.criarBloc();
    }

    return BlocProvider.value(
      value: _pagamentoBloc!,
      child: PagamentoEtapa(
        contexto: contexto,
        formaPagamentoGrade: widget.formaPagamentoGrade,
        onConfirmado: (resultado) => _confirmarPagamento(context, resultado),
        onVoltar: () {
          if (!state.processando) {
            context.read<VendaBloc>().add(const VendaPagamentoVoltou());
            // Voltar aos itens zera o pagamento (formas, descontos, cupom).
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _pagamentoBloc?.close();
              _pagamentoBloc = null;
              _pagamentoAssinatura = null;
            });
          }
        },
      ),
    );
  }

  void _confirmarPagamento(
    BuildContext context,
    Map<String, dynamic> resultado,
  ) {
    _resultado = resultado;
    List<Map<String, dynamic>> lista(String chave) =>
        (resultado[chave] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false);

    context.read<VendaBloc>().add(
          VendaFinalizarSolicitada(
            itens: _itensDaLeitura(),
            formasDePagamentoRealizadas: lista('formasDePagamentoRealizadas'),
            valorDesconto: _toDouble(resultado['desconto']) ?? 0,
            valorTaxaEntrega: _toDouble(resultado['valorTaxaEntrega']) ?? 0,
            descontosItens: lista('descontosItens'),
            descontosPromocao: lista('descontosPromocao'),
            cupons: resultado['cupons'] as List<Map<String, dynamic>>?,
            incluirCpfNaNota: resultado['incluirCpfNaNota'] as bool? ?? true,
            cpfNaNota: resultado['cpfNaNota']?.toString() ?? '',
            pontuarFidelidade: resultado['pontuarFidelidade'] as bool? ?? false,
            enviarNotaPorEmail:
                resultado['enviarNotaPorEmail'] as bool? ?? false,
            emailNota: resultado['emailNota']?.toString() ?? '',
          ),
        );
  }

  void _iniciarCriacao(BuildContext context, VendaState s) {
    final anterior = _criacao;
    _criacaoSub?.cancel();
    _ultimoPasso = null;
    final bloc = sl<RomaneioCriacaoBloc>()
      ..add(
        RomaneioCriacaoSolicitada(
          hashLista: s.listaCompartilhadaHash!,
          formasDePagamentoRealizadas: s.formasDePagamentoRealizadas,
          desconto: s.valorDesconto,
          descontosItens: s.descontosItens,
          descontosPromocao: s.descontosPromocao,
          cupons: s.cupons,
          valorTaxaEntrega: s.valorTaxaEntrega,
          incluirCpfNaNota: s.incluirCpfNaNota,
          cpfNaNota: s.cpfNaNota,
          pontuarFidelidade: s.pontuarFidelidade,
          enviarNotaPorEmail: s.enviarNotaPorEmail,
          emailNota: s.emailNota,
        ),
      );
    _criacaoSub = bloc.stream.listen((cs) {
      if (context.mounted) _aoMudarCriacao(context, cs);
    });
    setState(() {
      _criacao = bloc;
      _criacaoState = bloc.state;
    });
    anterior?.close();
  }

  Widget _buildConcluida(
    BuildContext context,
    VendaState state,
    RomaneioCriacaoState cs,
  ) {
    final formas = (_resultado['resumoFormasDePagamento'] as List<dynamic>? ??
            const [])
        .whereType<Map<String, dynamic>>()
        .map((f) => (f['nome']?.toString() ?? '-', _toDouble(f['valor']) ?? 0))
        .toList(growable: false);
    final troco = _toDouble(_resultado['valorTroco']) ?? 0;
    final recebido = _toDouble(_resultado['valorTotalRecebido']) ?? 0;
    final documento = cs.documentoFiscal;
    final romaneio = cs.romaneio;

    return VendaConcluidaView(
      romaneioId: romaneio?.id,
      cliente: state.clienteSelecionado?.nome,
      concluidaEm: _concluidaEm,
      formas: formas,
      totalVenda: recebido - troco,
      troco: troco,
      pontuou: _resultado['pontuarFidelidade'] == true,
      documentoFiscal: documento,
      emailNota: _resultado['enviarNotaPorEmail'] == true
          ? _resultado['emailNota']?.toString()
          : null,
      onImprimir: () {
        if (romaneio == null) return;
        imprimirDocumentoPdf(
          context,
          titulo: 'Imprimir romaneio',
          nomeDocumento: 'Romaneio #${romaneio.id}',
          gerarBytes: () => RomaneioPdfExporter.gerarBytes(
            romaneio,
            cs.itensCriados,
            const [],
          ),
        );
      },
      onReenviarNota: () {
        if (documento != null) {
          context.read<VendaBloc>().add(VendaNotaReenviarSolicitada(documento));
        }
      },
      onNovaVenda: () => _novaVenda(context.read<VendaBloc>()),
    );
  }

  // Mantém vendedor e tabela; o orçamento de origem já foi excluído ao concluir.
  void _novaVenda(VendaBloc venda) {
    _leitorController.limpar();
    _pagamentoBloc?.close();
    _criacaoSub?.cancel();
    _criacao?.close();
    setState(() {
      _pagamentoBloc = null;
      _pagamentoAssinatura = null;
      _criacao = null;
      _criacaoState = null;
      _resultado = const {};
      _orcamentoExcluido = false;
      _ultimaFinalizacao = 0;
      _trocandoCliente = false;
      _trocandoVendedor = false;
      _editandoDesconto = false;
    });
    venda.add(const VendaNovaVendaSolicitada());
  }

  List<Widget> _acoesTopo(BuildContext context, VendaState state) {
    final temItens = _leitorController.itens.isNotEmpty;

    return [
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
    ];
  }

  Widget _buildLeituraAtiva(BuildContext context, VendaState state) {
    SivPageFab.limpar();
    return CallbackShortcuts(
      bindings: {
        LogicalKeySet(LogicalKeyboardKey.f2): () =>
            _abrirBuscaManual(context, state),
        LogicalKeySet(LogicalKeyboardKey.f4): () => _abrirDesconto(state),
        LogicalKeySet(LogicalKeyboardKey.f9): () =>
            _irParaPagamento(context, state),
        LogicalKeySet(LogicalKeyboardKey.escape): () =>
            _confirmarReinicio(context),
      },
      child: Focus(
        autofocus: true,
        child: ListenableBuilder(
          listenable: _leitorController,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: SivDimensoes.gapCards),
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    runSpacing: 8,
                    children: _acoesTopo(context, state),
                  ),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: LeitorWidget(
                          controller: _leitorController,
                          dataSource: sl<ILeitorDataDatasource>(),
                          controlarQuantidade: true,
                          tabelaDePrecoId: state.tabelaDePrecoId,
                          aceitarApenasProdutosComPreco: true,
                          buscaDataSource: sl<ILeitorBuscaDataDatasource>(),
                          campoCodigoHint:
                              'Bipe ou informe o código do produto',
                          nomeTabelaDePreco:
                              state.tabelaDePrecoSelecionada?.nome,
                        ),
                      ),
                      const SizedBox(width: SivDimensoes.gapCards),
                      SizedBox(
                        width: 396,
                        child: SingleChildScrollView(
                          child: _buildPainelDireito(context, state),
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
    );
  }

  void _fecharDesconto() {
    _focoDesconto.unfocus(
      disposition: UnfocusDisposition.previouslyFocusedChild,
    );
    setState(() => _editandoDesconto = false);
  }

  void _abrirDesconto(VendaState state) {
    if (_leitorController.itens.isEmpty || state.processando) return;
    if (_editandoDesconto) {
      _fecharDesconto();
      return;
    }
    _descontoController.text = state.descontoRascunho > 0
        ? state.descontoRascunho.toStringAsFixed(2).replaceAll('.', ',')
        : '';
    setState(() => _editandoDesconto = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focoDesconto.requestFocus();
    });
  }

  Widget _buildPainelDireito(BuildContext context, VendaState state) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    final bloc = context.read<VendaBloc>();
    final temItens = _leitorController.itens.isNotEmpty;
    final subtotal = _leitorController.valorTotalLido;
    final desconto = state.descontoRascunho;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SivCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Cliente', style: textos.rotulo),
                  if (state.clienteSelecionado != null && !_trocandoCliente)
                    TextButton.icon(
                      onPressed: state.processando
                          ? null
                          : () => setState(() => _trocandoCliente = true),
                      icon: const Icon(Icons.swap_horiz, size: 16),
                      label: const Text('Trocar'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (state.clienteSelecionado != null && !_trocandoCliente)
                Text(
                  state.clienteSelecionado!.nome,
                  style: textos.corpo,
                  overflow: TextOverflow.ellipsis,
                )
              else
                AbsorbPointer(
                  absorbing: state.processando,
                  child: widget.pessoaSeletor(
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
                        setState(() => _trocandoCliente = false);
                        _solicitarFocoLeitura();
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              if (_trocandoVendedor)
                AbsorbPointer(
                  absorbing: state.processando,
                  child: widget.vendedoresSeletor(
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
                        setState(() => _trocandoVendedor = false);
                        _solicitarFocoLeitura();
                      },
                    ),
                  ),
                )
              else
                _linhaResumo(
                  context,
                  'Vendedor',
                  state.vendedorSelecionado?.nome ?? '—',
                  acao: TextButton(
                    onPressed: state.processando
                        ? null
                        : () => setState(() => _trocandoVendedor = true),
                    child: const Text('trocar'),
                  ),
                ),
              _linhaResumo(
                context,
                'Tabela',
                state.tabelaDePrecoSelecionada?.nome ?? '—',
              ),
            ],
          ),
        ),
        const SizedBox(height: SivDimensoes.gapCards),
        SivCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _linhaResumo(context, 'Subtotal', _formatarMoeda(subtotal)),
              if (desconto > 0)
                _linhaResumo(
                  context,
                  'Desconto  F4',
                  '−${_formatarMoeda(desconto)}',
                ),
              if (state.valorTaxaEntrega > 0)
                _linhaResumo(
                  context,
                  'Entrega',
                  _formatarMoeda(state.valorTaxaEntrega),
                ),
              if (_editandoDesconto) ...[
                const SizedBox(height: 8),
                CallbackShortcuts(
                  bindings: {
                    const SingleActivator(LogicalKeyboardKey.escape):
                        _fecharDesconto,
                  },
                  child: TextField(
                    controller: _descontoController,
                    focusNode: _focoDesconto,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'Desconto em R\$ ou % (ex.: 20,00 ou 10%)',
                    ),
                    // onEditingComplete evita o unfocus padrão (vai pro escopo
                    // da rota): com erro o campo segue focado; aplicado, o
                    // foco volta ao campo de código (_fecharDesconto).
                    onEditingComplete: () => bloc.add(
                      VendaDescontoAlterado(
                        texto: _descontoController.text,
                        subtotal: _leitorController.valorTotalLido,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.erroDesconto ?? 'Enter aplica · Esc cancela',
                  style: textos.apoio.copyWith(
                    color: state.erroDesconto == null ? null : cores.vinho,
                  ),
                ),
              ],
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
              Text(
                _formatarMoeda((subtotal - desconto).clamp(0, double.infinity)),
                style: textos.display.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: SivDimensoes.gapCards),
        FilledButton.icon(
          onPressed: temItens && !state.processando
              ? () => _irParaPagamento(context, state)
              : null,
          icon: const Icon(Icons.point_of_sale_outlined),
          label: const Text('Ir para pagamento · F9'),
        ),
        const SizedBox(height: 10),
        Text(
          'F2 buscar · F4 desconto · F9 pagamento',
          textAlign: TextAlign.center,
          style: textos.apoio,
        ),
      ],
    );
  }

  Widget _linhaResumo(
    BuildContext context,
    String label,
    String valor, {
    Widget? acao,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: context.sivTextos.corpo),
          const Spacer(),
          Flexible(
            child: Text(
              valor,
              style: context.sivTextos.corpo,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (acao != null) acao,
        ],
      ),
    );
  }

  Widget _buildConfiguracaoCard(BuildContext context, VendaState state) {
    final bloc = context.read<VendaBloc>();
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final ehMobile =
        MediaQuery.sizeOf(context).width < SivDimensoes.breakpointMenuDrawer;

    final iconeIniciar = state.verificandoCaixa
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.play_arrow_outlined);
    final rotuloIniciar =
        state.verificandoCaixa ? 'Verificando caixa...' : 'Iniciar leitura';
    final onPressedIniciar = state.podeIniciarLeitura
        ? () => bloc.add(const VendaLeituraSolicitada())
        : null;

    // Mobile define o FAB via SivPageFab (a página não tem Scaffold próprio,
    // quem monta o Scaffold é o AppShell) -- limpo assim que sair dessa etapa
    // (ver _buildLeituraAtiva/dispose) pra não deixar o botão da configuração
    // sobrando na tela de leitura.
    if (ehMobile) {
      SivPageFab.definir(
        FloatingActionButton.extended(
          onPressed: onPressedIniciar,
          icon: iconeIniciar,
          label: Text(rotuloIniciar),
        ),
      );
    } else {
      SivPageFab.limpar();
    }

    final campos = [
      Text(
        'Iniciar venda',
        style: textos.secao.copyWith(fontSize: ehMobile ? 19 : 22),
      ),
      const SizedBox(height: 4),
      Text(
        ehMobile
            ? 'Selecione vendedor e tabela de preço pra habilitar a leitura.'
            : 'Selecione o vendedor e a tabela de preço pra habilitar a leitura. Cliente pode ser identificado depois.',
        style: textos.apoio.copyWith(color: cores.textoApoio),
      ),
      SizedBox(height: ehMobile ? 20 : 26),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('CLIENTE',
              style: textos.rotulo.copyWith(color: cores.textoApoio)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              border: Border.all(color: cores.hairline),
              borderRadius: BorderRadius.circular(SivDimensoes.raio),
            ),
            child: Text(
              'Opcional',
              style: textos.apoio.copyWith(color: cores.textoApoio),
            ),
          ),
        ],
      ),
      const SizedBox(height: 7),
      widget.pessoaSeletor(
        SeletorData(
          compacto: false,
          itemsSelecionadosInicial: state.clienteSelecionado == null
              ? null
              : [state.clienteSelecionado!],
          onChanged: (selecionados) {
            bloc.add(
              VendaClienteSelecionado(
                clienteSelecionado:
                    selecionados.isEmpty ? null : selecionados.first,
              ),
            );
          },
        ),
      ),
      SizedBox(height: ehMobile ? 16 : 18),
      Text('VENDEDOR', style: textos.rotulo.copyWith(color: cores.textoApoio)),
      const SizedBox(height: 7),
      widget.vendedoresSeletor(
        SeletorData(
          compacto: false,
          itemsSelecionadosInicial: state.vendedorSelecionado == null
              ? null
              : [state.vendedorSelecionado!],
          onChanged: (selecionados) {
            bloc.add(
              VendaVendedorSelecionado(
                vendedorSelecionado:
                    selecionados.isEmpty ? null : selecionados.first,
              ),
            );
          },
        ),
      ),
      SizedBox(height: ehMobile ? 16 : 28),
      Text(
        'TABELA DE PREÇO',
        style: textos.rotulo.copyWith(color: cores.textoApoio),
      ),
      const SizedBox(height: 7),
      widget.tabelasDePrecoSeletor(
        SeletorData(
          compacto: true,
          itemsSelecionadosInicial: state.tabelaDePrecoSelecionada == null
              ? null
              : [state.tabelaDePrecoSelecionada!],
          onChanged: (selecionados) {
            bloc.add(
              VendaTabelaDePrecoSelecionada(
                tabelaDePrecoSelecionada:
                    selecionados.isEmpty ? null : selecionados.first,
              ),
            );
          },
        ),
      ),
    ];

    if (ehMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: AbsorbPointer(
          absorbing: state.processando,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: campos,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: state.estadoInicial
                      ? () => _abrirOrcamentos(context)
                      : null,
                  icon: const Icon(Icons.description_outlined, size: 16),
                  label: const Text('Ver orçamentos salvos'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final conteudoDesktop = AbsorbPointer(
      absorbing: state.processando,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: campos,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: state.estadoInicial
                      ? () => _abrirOrcamentos(context)
                      : null,
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Orçamentos'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onPressedIniciar,
                  icon: iconeIniciar,
                  label: Text(rotuloIniciar),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(34),
              decoration: BoxDecoration(
                color: cores.superficie,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: cores.textoPrincipal.withValues(alpha: 0.06),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: conteudoDesktop,
            ),
            ...sivCantosBlueprint(cores.aco),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirBuscaManual(BuildContext context, VendaState state) async {
    final modoRemocao = _leitorController.modoRemocao;
    final resultado = await abrirBuscaManualDeProduto(
      context: context,
      buscaDataSource: sl<ILeitorBuscaDataDatasource>(),
      tabelaDePrecoId: state.tabelaDePrecoId,
      modoRemocao: modoRemocao,
    );

    if (resultado == null) {
      _solicitarFocoLeitura();
      return;
    }

    if (modoRemocao) {
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
      if (context.mounted) {
        context.read<VendaBloc>().add(
              const VendaDescontoAlterado(texto: '', subtotal: 0),
            );
      }
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
    context.read<VendaBloc>().add(const VendaResetSolicitado());
    _solicitarFocoLeitura();
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
