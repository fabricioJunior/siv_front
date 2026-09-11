import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/leitor/data_source/i_leitor_busca_data_datasource.dart';
import 'package:core/leitor/icone_codigo_de_barras.dart';
import 'package:core/leitor/data_source/i_leitor_data_datasource.dart';
import 'package:core/leitor/leitor_bloc/leitor_bloc.dart';
import 'package:core/leitor/leitor_busca_bloc/leitor_busca_bloc.dart';
import 'package:core/leitor/leitor_data.dart';
import 'package:core/services/camera_scanner_service.dart';
import 'package:core/sessao.dart';
import 'package:core/tema.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LeitorWidget extends StatefulWidget {
  final bool controlarQuantidade;
  final bool desativado;
  final ILeitorDataDatasource dataSource;
  final LeitorController? controller;
  final List<ProdutosPreCarregado>? produtosPreCarregados;
  final ValueChanged<LeitorItemContado>? onUltimoProdutoLido;
  final ValueChanged<String>? onErro;
  final ValueChanged<String>? onAviso;
  final String campoCodigoHint;
  final double alturaLista;
  final bool autofocus;
  final int? tabelaDePrecoId;
  final bool aceitarApenasProdutosComPreco;
  final ILeitorBuscaDataDatasource? buscaDataSource;
  final String rotuloQuantidadeDisponivel;
  final String Function(String descricao)? mensagemQuantidadeIndisponivel;
  final bool avisarCodigoDuplicado;
  final String? nomeTabelaDePreco;

  const LeitorWidget({
    super.key,
    required this.dataSource,
    this.controlarQuantidade = false,
    this.desativado = false,
    this.controller,
    this.produtosPreCarregados,
    this.onUltimoProdutoLido,
    this.onErro,
    this.onAviso,
    this.campoCodigoHint = 'Bipe ou informe o código de barras',
    this.alturaLista = 320,
    this.autofocus = true,
    this.tabelaDePrecoId,
    this.aceitarApenasProdutosComPreco = false,
    this.buscaDataSource,
    this.rotuloQuantidadeDisponivel = 'Estoque',
    this.mensagemQuantidadeIndisponivel,
    this.avisarCodigoDuplicado = true,
    this.nomeTabelaDePreco,
  });

  @override
  State<LeitorWidget> createState() => _LeitorWidgetState();
}

enum _LeitorVisualizacao { porProduto, historico, grade }

class _ReferenciaAgrupada {
  final int referencia;
  final String nome;
  final List<String> cores;
  final List<String> tamanhos;
  final Map<String, Map<String, int>> gradeQuantidade;
  final int quantidadeTotal;
  final double valorTotal;

  _ReferenciaAgrupada({
    required this.referencia,
    required this.nome,
    required this.cores,
    required this.tamanhos,
    required this.gradeQuantidade,
    required this.quantidadeTotal,
    required this.valorTotal,
  });

  bool get temGradeDeTamanho =>
      tamanhos.length > 1 || (tamanhos.length == 1 && tamanhos.first != '-');
}

class _LeitorWidgetState extends State<LeitorWidget> {
  late LeitorBloc _bloc;
  late LeitorController _controller;
  late final TextEditingController _codigoController;
  late final FocusNode _codigoFocusNode;
  bool _controllerInterno = false;
  bool _modoRemocao = false;
  _LeitorVisualizacao _visualizacao = _LeitorVisualizacao.historico;
  bool _sincronizando = sl<IAcessoGlobalSessao>().dadosSincronizados;
  StreamSubscription<bool>? _sincronizacaoSubscription;
  int? _assinaturaPreCargaAplicada;

  @override
  void initState() {
    super.initState();
    _codigoController = TextEditingController();
    _codigoFocusNode = FocusNode();
    _controllerInterno = widget.controller == null;
    _controller = widget.controller ?? LeitorController();
    _bloc = _criarBloc();
    _controller.bind(_bloc);
    _aplicarProdutosPreCarregados();
    final sessao = sl<IAcessoGlobalSessao>();
    _sincronizando = !sessao.dadosSincronizados;
    _sincronizacaoSubscription =
        sessao.sincronizandoDados.listen((sincronizando) {
      if (mounted) setState(() => _sincronizando = sincronizando);
    });
  }

  @override
  void didUpdateWidget(covariant LeitorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final mudouDataSource =
        oldWidget.dataSource.runtimeType != widget.dataSource.runtimeType;
    final mudouConfiguracao =
        oldWidget.controlarQuantidade != widget.controlarQuantidade ||
            oldWidget.tabelaDePrecoId != widget.tabelaDePrecoId ||
            oldWidget.aceitarApenasProdutosComPreco !=
                widget.aceitarApenasProdutosComPreco;

    if (mudouDataSource || mudouConfiguracao) {
      final estadoAtual = _bloc.state;
      _controller.unbind(_bloc);
      _bloc.close();
      _bloc = _criarBloc(estadoInicial: estadoAtual);
      _controller.bind(_bloc);
      _aplicarProdutosPreCarregados();
    }

    if (oldWidget.controller != widget.controller) {
      _controller.unbind(_bloc);
      if (_controllerInterno) {
        _controller.dispose();
      }

      _controllerInterno = widget.controller == null;
      _controller = widget.controller ?? LeitorController();
      _controller.bind(_bloc);
      _aplicarProdutosPreCarregados();
    }

    if (oldWidget.produtosPreCarregados != widget.produtosPreCarregados) {
      _aplicarProdutosPreCarregados();
    }
  }

  @override
  void dispose() {
    _sincronizacaoSubscription?.cancel();
    _controller.unbind(_bloc);
    _bloc.close();
    _codigoController.dispose();
    _codigoFocusNode.dispose();
    if (_controllerInterno) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();

    // Durante o hot reload, mantenha o estado atual do leitor ao religar o bloc.
    if (_bloc.isClosed) {
      _bloc = _criarBloc(estadoInicial: _controller.state);
    }
    _controller.bind(_bloc);
    _controller.syncState(_bloc.state);
  }

  LeitorBloc _criarBloc({LeitorState? estadoInicial}) {
    return LeitorBloc(
      dataSource: widget.dataSource,
      controlarQuantidade: widget.controlarQuantidade,
      tabelaDePrecoId: widget.tabelaDePrecoId,
      aceitarApenasProdutosComPreco: widget.aceitarApenasProdutosComPreco,
      mensagemQuantidadeIndisponivel: widget.mensagemQuantidadeIndisponivel,
      estadoInicial: estadoInicial,
    );
  }

  void _aplicarProdutosPreCarregados() {
    final produtos = widget.produtosPreCarregados;
    if (produtos == null || produtos.isEmpty) {
      return;
    }

    final assinaturaAtual = Object.hashAll(
      produtos.map((item) => Object.hash(item.id, item.quantidade)),
    );
    if (_assinaturaPreCargaAplicada == assinaturaAtual) {
      return;
    }

    _assinaturaPreCargaAplicada = assinaturaAtual;

    _controller.preCarregarProdutos(produtos);
  }

  void _submeterCodigo() {
    if (widget.desativado) {
      return;
    }

    final codigo = _codigoController.text.trim();
    if (codigo.isEmpty) {
      _solicitarFoco();
      return;
    }

    _codigoController.clear();
    if (_modoRemocao) {
      _controller.removerQuantidade(codigo);
    } else {
      _controller.lerCodigo(codigo);
    }

    _solicitarFoco();
  }

  void _solicitarFoco() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _codigoFocusNode.requestFocus();
      }
    });
  }

  void _mostrarMensagem(BuildContext context, String mensagem, Color cor) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: cor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _exibirErro(String texto) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: _modoRemocao
              ? const Text('Erro ao remover item')
              : const Text('Erro ao ler item'),
          content: Text(texto),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String _formatarDataHora(DateTime dataHora) {
    final dia = dataHora.day.toString().padLeft(2, '0');
    final mes = dataHora.month.toString().padLeft(2, '0');
    final hora = dataHora.hour.toString().padLeft(2, '0');
    final minuto = dataHora.minute.toString().padLeft(2, '0');
    final segundo = dataHora.second.toString().padLeft(2, '0');
    return '$dia/$mes $hora:$minuto:$segundo';
  }

  String _formatarHora(DateTime dataHora) {
    final hora = dataHora.hour.toString().padLeft(2, '0');
    final minuto = dataHora.minute.toString().padLeft(2, '0');
    final segundo = dataHora.second.toString().padLeft(2, '0');
    return '$hora:$minuto:$segundo';
  }

  String _rotuloTamanhoCor({required String tamanho, required String cor}) {
    final tamanhoNormalizado = tamanho.trim().isEmpty ? '-' : tamanho.trim();
    final corNormalizada = cor.trim().isEmpty ? '-' : cor.trim();
    return 'Cor: $corNormalizada  •  Tam: $tamanhoNormalizado';
  }

  String _rotuloTamanhoCorCompacto({required String tamanho, required String cor}) {
    final tamanhoNormalizado = tamanho.trim().isEmpty ? '-' : tamanho.trim();
    final corNormalizada = cor.trim().isEmpty ? '-' : cor.trim();
    return '$corNormalizada · $tamanhoNormalizado';
  }

  String _normalizarRotuloGrade(String valor, {String fallback = '-'}) {
    final normalizado = valor.trim();
    return normalizado.isEmpty ? fallback : normalizado;
  }

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _descricaoPreco(LeitorItemContado item) {
    final valorUnitario = item.valorUnitario;
    if (valorUnitario == null || valorUnitario <= 0) {
      return 'Preço não cadastrado';
    }

    return 'Preço: ${_formatarMoeda(valorUnitario)}  •  Total: ${_formatarMoeda(item.valorTotal)}';
  }

  String _nomeReferencia(List<LeitorItemContado> itensReferencia) {
    for (final item in itensReferencia) {
      final descricao = item.descricao.trim();
      if (descricao.isNotEmpty) {
        return descricao;
      }
    }
    return 'Sem descricao';
  }

  Future<void> _abrirBuscaManual() async {
    if (widget.desativado) return;

    final buscaDataSource = widget.buscaDataSource;
    if (buscaDataSource == null) return;

    final resultado = await showDialog<({LeitorData produto, int quantidade})>(
      context: context,
      builder: (dialogContext) => _BuscaProdutoDialog(
        buscaDataSource: buscaDataSource,
        tabelaDePrecoId: widget.tabelaDePrecoId,
        modoRemocao: _modoRemocao,
        rotuloQuantidadeDisponivel: widget.rotuloQuantidadeDisponivel,
      ),
    );

    if (resultado == null) {
      _solicitarFoco();
      return;
    }

    final codigo = resultado.produto.codigoDeBarras;
    final quantidade = resultado.quantidade;

    if (_modoRemocao) {
      _controller.removerQuantidade(codigo, quantidade: quantidade);
    } else {
      _controller.lerCodigoComQuantidade(codigo, quantidade);
    }

    _solicitarFoco();
  }

  Future<void> _escanearComCamera() async {
    if (widget.desativado) return;

    final codigo =
        await CameraScannerService().escanearCodigoDeBarras(context);
    if (codigo == null || !mounted) {
      _solicitarFoco();
      return;
    }

    if (_modoRemocao) {
      _controller.removerQuantidade(codigo);
    } else {
      _controller.lerCodigo(codigo);
    }
  }

  LeitorItemContado? _itemPorCodigo(LeitorState state, String codigo) {
    for (final item in state.itens) {
      if (item.codigoDeBarras == codigo) return item;
    }
    return null;
  }

  List<_ReferenciaAgrupada> _agruparPorReferencia(LeitorState state) {
    final itensPorReferencia = <int, List<LeitorItemContado>>{};
    for (final item in state.itens) {
      itensPorReferencia.putIfAbsent(item.idReferencia, () => []).add(item);
    }

    final referenciasOrdenadas = itensPorReferencia.keys.toList()..sort();

    return referenciasOrdenadas.map((referencia) {
      final itensReferencia = itensPorReferencia[referencia]!;
      final cores = itensReferencia
          .map((item) => _normalizarRotuloGrade(item.cor))
          .toSet()
          .toList()
        ..sort();
      final tamanhos = itensReferencia
          .map((item) => _normalizarRotuloGrade(item.tamanho))
          .toSet()
          .toList()
        ..sort();

      final gradeQuantidade = <String, Map<String, int>>{};
      var quantidadeTotal = 0;
      var valorTotal = 0.0;
      for (final item in itensReferencia) {
        final cor = _normalizarRotuloGrade(item.cor);
        final tamanho = _normalizarRotuloGrade(item.tamanho);
        final linha = gradeQuantidade.putIfAbsent(cor, () => {});
        linha[tamanho] = (linha[tamanho] ?? 0) + item.quantidadeLida;
        quantidadeTotal += item.quantidadeLida;
        valorTotal += item.valorTotal;
      }

      return _ReferenciaAgrupada(
        referencia: referencia,
        nome: _nomeReferencia(itensReferencia),
        cores: cores,
        tamanhos: tamanhos,
        gradeQuantidade: gradeQuantidade,
        quantidadeTotal: quantidadeTotal,
        valorTotal: valorTotal,
      );
    }).toList();
  }

  Widget _gradePorReferencia(LeitorState state) {
    if (state.itens.isEmpty) {
      return Center(
        child: Text(
          'Nenhum produto lido ainda.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final referenciasAgrupadas = _agruparPorReferencia(state);

    return ListView.separated(
      itemCount: referenciasAgrupadas.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final referencia = referenciasAgrupadas[index];
        final cores = referencia.cores;
        final tamanhos = referencia.tamanhos;
        final gradeQuantidade = referencia.gradeQuantidade;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Referência ${referencia.referencia}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 2),
              Text(
                referencia.nome,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  border: TableBorder.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 0.8,
                  ),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'Cor \\ Tam',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        ...tamanhos.map(
                          (tamanho) => Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              tamanho,
                              textAlign: TextAlign.center,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ...cores.map(
                      (cor) => TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(cor),
                          ),
                          ...tamanhos.map(
                            (tamanho) => Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                '${gradeQuantidade[cor]?[tamanho] ?? 0}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _construirAreaDeBipagem(BuildContext context, LeitorState state) {
    final ehMobile =
        MediaQuery.sizeOf(context).width < SivDimensoes.breakpointMenuDrawer;

    if (!ehMobile) {
      final cores = context.sivColors;
      final textos = context.sivTextos;

      return Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: cores.superficie,
              border: Border.all(color: cores.aco),
              borderRadius: BorderRadius.circular(SivDimensoes.raio),
              boxShadow: [
                BoxShadow(
                  color: cores.textoPrincipal.withValues(alpha: 0.06),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
                BoxShadow(
                  color: cores.aco.withValues(alpha: 0.1),
                  blurRadius: 0,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Row(
              children: [
                IconeCodigoDeBarras(cor: cores.aco, tamanho: 26),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _modoRemocao ? 'CÓDIGO PARA REMOVER' : 'BIPE O PRODUTO',
                        style: textos.rotulo.copyWith(color: cores.aco),
                      ),
                      TextField(
                        controller: _codigoController,
                        focusNode: _codigoFocusNode,
                        autofocus: widget.desativado ? false : widget.autofocus,
                        enabled: !widget.desativado,
                        style: textos.secao.copyWith(
                          fontSize: 24,
                          color: cores.textoPrincipal,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          isCollapsed: true,
                          // Tema global (InputDecorationTheme) define
                          // contentPadding horizontal:14 -- isCollapsed
                          // deveria anular, mas força explícito pra garantir
                          // que o texto alinha exatamente com o rótulo
                          // "BIPE O PRODUTO" acima (mesma margem esquerda).
                          contentPadding: EdgeInsets.zero,
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: _modoRemocao
                              ? 'Bipe para remover 1 unidade do item'
                              : widget.campoCodigoHint,
                          hintStyle: textos.secao.copyWith(
                            fontSize: 24,
                            color: cores.textoDesabilitado,
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submeterCodigo(),
                      ),
                    ],
                  ),
                ),
                // Sem botão de submit -- confirma só por onSubmitted (Enter),
                // igual ao mock (só ícone+campo, sem seta). Spinner de
                // processando continua, não é um botão, é feedback de estado.
                if (state.processando) ...[
                  const SizedBox(width: 12),
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ],
              ],
            ),
          ),
          ..._cantosBlueprint(cores.aco),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: state.processando || widget.desativado
                ? null
                : _escanearComCamera,
            icon: const Icon(Icons.qr_code_scanner_outlined),
            label: const Text('Escanear código'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: widget.buscaDataSource == null ||
                    state.processando ||
                    widget.desativado
                ? null
                : _abrirBuscaManual,
            icon: const Icon(Icons.search_outlined),
            label: const Text('Buscar'),
          ),
        ),
      ],
    );
  }

  List<Widget> _cantosBlueprint(Color cor) {
    const tamanho = 8.0;
    Widget canto({required bool top, required bool left}) {
      return Positioned(
        top: top ? 0 : null,
        bottom: top ? null : 0,
        left: left ? 0 : null,
        right: left ? null : 0,
        child: Container(
          width: tamanho,
          height: tamanho,
          decoration: BoxDecoration(
            border: Border(
              top: top ? BorderSide(color: cor) : BorderSide.none,
              bottom: !top ? BorderSide(color: cor) : BorderSide.none,
              left: left ? BorderSide(color: cor) : BorderSide.none,
              right: !left ? BorderSide(color: cor) : BorderSide.none,
            ),
          ),
        ),
      );
    }

    return [
      canto(top: true, left: true),
      canto(top: true, left: false),
      canto(top: false, left: true),
      canto(top: false, left: false),
    ];
  }

  Widget _seletorVisualizacaoDesktop(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    const segmentos = [
      (_LeitorVisualizacao.historico, Icons.view_list_outlined, 'LISTA'),
      (_LeitorVisualizacao.grade, Icons.grid_view_outlined, 'GRADE'),
      (_LeitorVisualizacao.porProduto, Icons.bar_chart_outlined, 'QUANTIDADES'),
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: cores.hairline),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < segmentos.length; i++)
            _segmentoDesktop(
              cores: cores,
              textos: textos,
              valor: segmentos[i].$1,
              icone: segmentos[i].$2,
              rotulo: segmentos[i].$3,
              comBordaEsquerda: i > 0,
            ),
        ],
      ),
    );
  }

  Widget _segmentoDesktop({
    required SivColors cores,
    required SivTextStyles textos,
    required _LeitorVisualizacao valor,
    required IconData icone,
    required String rotulo,
    required bool comBordaEsquerda,
  }) {
    final selecionado = _visualizacao == valor;
    return Container(
      decoration: BoxDecoration(
        color: selecionado ? cores.aco : Colors.transparent,
        border: comBordaEsquerda
            ? Border(left: BorderSide(color: cores.hairline))
            : null,
      ),
      child: InkWell(
        onTap: () => setState(() => _visualizacao = valor),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icone,
                size: 16,
                color: selecionado
                    ? cores.textoSobreEscuroTitulo
                    : cores.textoApoio,
              ),
              const SizedBox(width: 7),
              Text(
                rotulo,
                style: textos.rotulo.copyWith(
                  color: selecionado
                      ? cores.textoSobreEscuroTitulo
                      : cores.textoApoio,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rodapeResumo(BuildContext context, LeitorState state) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    final referencias = state.itens.map((item) => item.idReferencia).toSet().length;
    final pecas = state.quantidadeTotalLida;

    final partesDireita = <String>[];
    if (state.historico.isNotEmpty) {
      final segundos =
          DateTime.now().difference(state.historico.last.dataHora).inSeconds;
      partesDireita.add('Última leitura há ${segundos}s');
    }
    if (widget.nomeTabelaDePreco != null) {
      partesDireita.add('Tabela ${widget.nomeTabelaDePreco}');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: cores.hairline)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$referencias referências · $pecas peças bipadas',
            style: textos.apoio.copyWith(color: cores.textoApoio),
          ),
          if (partesDireita.isNotEmpty)
            Text(
              partesDireita.join(' · '),
              style: textos.apoio.copyWith(color: cores.textoApoio),
            ),
        ],
      ),
    );
  }

  Widget _celulaCabecalho(
    SivTextStyles textos,
    SivColors cores,
    String texto, {
    double? largura,
    TextAlign align = TextAlign.left,
  }) {
    final texto0 = Text(
      texto,
      textAlign: align,
      style: textos.rotulo.copyWith(color: cores.textoApoio),
    );
    return largura == null ? Expanded(child: texto0) : SizedBox(width: largura, child: texto0);
  }

  Widget _listaDesktop(BuildContext context, LeitorState state) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    if (state.historico.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma movimentação registrada ainda.',
          style: textos.corpo,
        ),
      );
    }

    final registros = state.historico.reversed.toList();

    return Container(
      decoration: BoxDecoration(
        color: cores.superficie,
        border: Border.all(color: cores.hairline),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: cores.hairline)),
            ),
            child: Row(
              children: [
                _celulaCabecalho(textos, cores, 'HORA', largura: 70),
                _celulaCabecalho(textos, cores, 'PRODUTO'),
                _celulaCabecalho(textos, cores, 'GRADE', largura: 110),
                _celulaCabecalho(textos, cores, 'UNIT.',
                    largura: 70, align: TextAlign.right),
                _celulaCabecalho(textos, cores, 'QTD',
                    largura: 50, align: TextAlign.center),
                _celulaCabecalho(textos, cores, 'TOTAL',
                    largura: 90, align: TextAlign.right),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: registros.length,
              itemBuilder: (context, index) {
                final registro = registros[index];
                final item = _itemPorCodigo(state, registro.codigoDeBarras);
                final valorUnitario = item?.valorUnitario;
                final total = valorUnitario != null
                    ? valorUnitario * registro.quantidade
                    : null;

                return Container(
                  color: index == 0
                      ? cores.selecaoFundo
                      : (index.isOdd
                          ? cores.superficieRecuada
                          : cores.superficie),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 70,
                        child: Text(
                          _formatarHora(registro.dataHora),
                          style: textos.codigo.copyWith(color: cores.acoAtivo),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              registro.descricao,
                              style: textos.corpo.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              registro.codigoDeBarras,
                              style:
                                  textos.apoio.copyWith(color: cores.textoApoio),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 110,
                        child: Text(
                          _rotuloTamanhoCorCompacto(
                            tamanho: registro.tamanho,
                            cor: registro.cor,
                          ),
                          style: textos.apoio,
                        ),
                      ),
                      SizedBox(
                        width: 70,
                        child: Text(
                          valorUnitario != null
                              ? _formatarMoeda(valorUnitario)
                              : '—',
                          textAlign: TextAlign.right,
                          style: textos.apoio,
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: Text(
                          '${registro.quantidade}',
                          textAlign: TextAlign.center,
                          style: textos.secao.copyWith(fontSize: 16),
                        ),
                      ),
                      SizedBox(
                        width: 90,
                        child: Text(
                          total != null ? _formatarMoeda(total) : '—',
                          textAlign: TextAlign.right,
                          style:
                              textos.corpo.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _rodapeResumo(context, state),
        ],
      ),
    );
  }

  Widget _celulaGrade(SivColors cores, SivTextStyles textos, int quantidade) {
    final lida = quantidade > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: lida ? cores.selecaoFundo : null,
          border: Border.all(color: lida ? cores.aco : cores.hairline),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          lida ? '$quantidade' : '—',
          style: (lida ? textos.secao : textos.apoio).copyWith(
            fontSize: lida ? 15 : 13,
            color: lida ? cores.acoAtivo : cores.textoDesabilitado,
          ),
        ),
      ),
    );
  }

  Widget _cardReferenciaDesktop(
    BuildContext context,
    _ReferenciaAgrupada referencia, {
    required bool destacado,
  }) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cores.superficie,
            border: Border.all(color: destacado ? cores.aco : cores.hairline),
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                referencia.nome,
                style: textos.secao.copyWith(fontSize: 15),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'REF ${referencia.referencia}',
                style: textos.apoio.copyWith(color: cores.textoApoio),
              ),
              const SizedBox(height: 10),
              if (!referencia.temGradeDeTamanho)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      horizontal: BorderSide(color: cores.hairline),
                    ),
                  ),
                  child: Text.rich(
                    TextSpan(
                      style: textos.apoio.copyWith(color: cores.textoApoio),
                      children: [
                        const TextSpan(text: 'Sem grade de tamanho'),
                        if (referencia.cores.length == 1)
                          TextSpan(
                            text: ' — cor única ${referencia.cores.first}',
                            style: TextStyle(
                              color: cores.textoPrincipal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              else
                Table(
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  children: [
                    TableRow(
                      children: [
                        const SizedBox(),
                        ...referencia.tamanhos.map(
                          (tamanho) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 3, vertical: 4),
                            child: Text(
                              tamanho,
                              textAlign: TextAlign.center,
                              style: textos.rotulo
                                  .copyWith(color: cores.textoApoio),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ...referencia.cores.map(
                      (cor) => TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(cor, style: textos.apoio),
                          ),
                          ...referencia.tamanhos.map(
                            (tamanho) => _celulaGrade(
                              cores,
                              textos,
                              referencia.gradeQuantidade[cor]?[tamanho] ?? 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: cores.hairline)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${referencia.quantidadeTotal} peças lidas',
                      style: textos.apoio.copyWith(color: cores.textoApoio),
                    ),
                    Text(
                      _formatarMoeda(referencia.valorTotal),
                      style:
                          textos.corpo.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (destacado) ..._cantosBlueprint(cores.aco),
      ],
    );
  }

  Widget _gradeDesktop(BuildContext context, LeitorState state) {
    if (state.itens.isEmpty) {
      return Center(
        child: Text(
          'Nenhum produto lido ainda.',
          style: context.sivTextos.corpo,
        ),
      );
    }

    final referenciasAgrupadas = _agruparPorReferencia(state);
    int? referenciaRecente;
    if (state.historico.isNotEmpty) {
      referenciaRecente =
          _itemPorCodigo(state, state.historico.last.codigoDeBarras)
              ?.idReferencia;
    }

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.15,
            ),
            itemCount: referenciasAgrupadas.length,
            itemBuilder: (context, index) => _cardReferenciaDesktop(
              context,
              referenciasAgrupadas[index],
              destacado:
                  referenciasAgrupadas[index].referencia == referenciaRecente,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _rodapeResumo(context, state),
      ],
    );
  }

  Widget _quantidadesDesktop(BuildContext context, LeitorState state) {
    if (state.itens.isEmpty) {
      return Center(
        child: Text(
          'Nenhum produto lido ainda.',
          style: context.sivTextos.corpo,
        ),
      );
    }

    final cores = context.sivColors;
    final textos = context.sivTextos;
    final itensOrdenados = [...state.itens]
      ..sort((a, b) => b.quantidadeLida.compareTo(a.quantidadeLida));

    return Container(
      decoration: BoxDecoration(
        color: cores.superficie,
        border: Border.all(color: cores.hairline),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: itensOrdenados.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: cores.hairline),
              itemBuilder: (context, index) {
                final item = itensOrdenados[index];
                return Container(
                  color: index == 0
                      ? cores.selecaoFundo
                      : (index.isOdd
                          ? cores.superficieRecuada
                          : cores.superficie),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: Text(
                          '×${item.quantidadeLida}',
                          textAlign: TextAlign.center,
                          style: textos.secao.copyWith(
                            fontSize: 26,
                            color: cores.acoAtivo,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.descricao,
                              style: textos.corpo
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '${_rotuloTamanhoCorCompacto(tamanho: item.tamanho, cor: item.cor)} · Cód: ${item.codigoDeBarras}',
                              style: textos.apoio
                                  .copyWith(color: cores.textoApoio),
                            ),
                          ],
                        ),
                      ),
                      if (widget.tabelaDePrecoId != null) ...[
                        Text(
                          _formatarMoeda(item.valorTotal),
                          style: textos.corpo
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 4),
                      ],
                      IconButton(
                        tooltip: 'Remover uma unidade',
                        onPressed: widget.desativado
                            ? null
                            : () => _controller
                                .removerQuantidade(item.codigoDeBarras),
                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                      ),
                      IconButton(
                        tooltip: 'Excluir item da contagem',
                        onPressed: widget.desativado
                            ? null
                            : () =>
                                _controller.removerItem(item.codigoDeBarras),
                        icon: const Icon(Icons.delete_outline, size: 20),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _rodapeResumo(context, state),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_sincronizando) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sincronizando as informações, por favor aguarde',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<LeitorBloc, LeitorState>(
        bloc: _bloc,
        listener: (context, state) {
          _onBlocChangeState(state, context);
        },
        builder: (context, state) {
          final ehMobile = MediaQuery.sizeOf(context).width <
              SivDimensoes.breakpointMenuDrawer;

          return Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leitor de código de barras',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _construirAreaDeBipagem(context, state),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        avatar: Icon(
                          _modoRemocao
                              ? Icons.remove_circle_outline
                              : Icons.add_circle_outline,
                          size: 18,
                        ),
                        tooltip: _modoRemocao
                            ? 'Toque para voltar ao modo leitura'
                            : 'Toque para ativar remoção por leitura',
                        label: Text(
                          _modoRemocao
                              ? 'Removendo por leitura (toque para desativar)'
                              : 'Ativar remoção por leitura',
                        ),
                        selected: _modoRemocao,
                        onSelected: widget.desativado
                            ? null
                            : (_) {
                                setState(() {
                                  _modoRemocao = !_modoRemocao;
                                });
                                _solicitarFoco();
                              },
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.refresh_outlined, size: 18),
                        label: const Text('Limpar leitura'),
                        onPressed: state.itens.isEmpty || widget.desativado
                            ? null
                            : () => _controller.limpar(),
                      ),
                      if (widget.buscaDataSource != null)
                        ActionChip(
                          avatar: const Icon(Icons.search_outlined, size: 18),
                          label: const Text('Busca manual'),
                          onPressed: state.processando || widget.desativado
                              ? null
                              : _abrirBuscaManual,
                        ),
                    ],
                  ),
                  const Divider(),
                  if (ehMobile)
                    // Em telas estreitas os 3 segmentos (ícone+texto) somam mais
                    // largura que a disponível -- estourava RenderFlex bem em
                    // cima da lista, corrompendo visualmente o resto da tela.
                    // Scroll horizontal cobre qualquer largura sem precisar
                    // truncar rótulo nem quebrar layout.
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SegmentedButton<_LeitorVisualizacao>(
                        segments: const [
                          ButtonSegment<_LeitorVisualizacao>(
                            value: _LeitorVisualizacao.porProduto,
                            icon: Icon(Icons.inventory_2_outlined),
                            label: Text('Por produto'),
                          ),
                          ButtonSegment<_LeitorVisualizacao>(
                            value: _LeitorVisualizacao.grade,
                            icon: Icon(Icons.grid_view_outlined),
                            label: Text('Grade'),
                          ),
                          ButtonSegment<_LeitorVisualizacao>(
                            value: _LeitorVisualizacao.historico,
                            icon: Icon(Icons.history_outlined),
                            label: Text('Histórico'),
                          ),
                        ],
                        selected: {_visualizacao},
                        onSelectionChanged: (selection) {
                          setState(() {
                            _visualizacao = selection.first;
                          });
                        },
                      ),
                    )
                  else
                    _seletorVisualizacaoDesktop(context),
                  const Divider(),
                  if (state.ultimoProdutoLido != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Último produto lido',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(state.ultimoProdutoLido!.descricao),
                          Text(
                            '${state.ultimoProdutoLido!.codigoDeBarras}  •  Quantidade: ${state.ultimoProdutoLido!.quantidadeLida}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            _rotuloTamanhoCor(
                              tamanho: state.ultimoProdutoLido!.tamanho,
                              cor: state.ultimoProdutoLido!.cor,
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (widget.tabelaDePrecoId != null)
                            Text(
                              _descricaoPreco(state.ultimoProdutoLido!),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: widget.alturaLista,
                    child: !ehMobile
                        ? switch (_visualizacao) {
                            _LeitorVisualizacao.historico =>
                              _listaDesktop(context, state),
                            _LeitorVisualizacao.grade =>
                              _gradeDesktop(context, state),
                            _LeitorVisualizacao.porProduto =>
                              _quantidadesDesktop(context, state),
                          }
                        : switch (_visualizacao) {
                      _LeitorVisualizacao.porProduto => state.itens.isEmpty
                          ? Center(
                              child: Text(
                                'Nenhum produto lido ainda.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            )
                          : ListView.separated(
                              itemCount: state.itens.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final item = state.itens[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    item.descricao,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  subtitle: Text(
                                    '${item.codigoDeBarras}  •  ${_rotuloTamanhoCor(tamanho: item.tamanho, cor: item.cor)}\nLidos: ${item.quantidadeLida}${state.controlarQuantidade ? '  •  ${widget.rotuloQuantidadeDisponivel}: ${item.estoqueDisponivel}' : ''}${widget.tabelaDePrecoId != null ? '\n${_descricaoPreco(item)}' : ''}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  trailing: Wrap(
                                    spacing: 4,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      IconButton(
                                        tooltip: 'Remover uma unidade',
                                        onPressed: widget.desativado
                                            ? null
                                            : () =>
                                                _controller.removerQuantidade(
                                                  item.codigoDeBarras,
                                                ),
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Excluir item da contagem',
                                        onPressed: widget.desativado
                                            ? null
                                            : () => _controller.removerItem(
                                                  item.codigoDeBarras,
                                                ),
                                        icon: const Icon(Icons.delete_outline),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                      _LeitorVisualizacao.historico => state.historico.isEmpty
                          ? Center(
                              child: Text(
                                'Nenhuma movimentação registrada ainda.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            )
                          : ListView.separated(
                              itemCount: state.historico.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final registro = state.historico[
                                    state.historico.length - 1 - index];
                                final foiAdicao =
                                    registro.tipo == LeitorHistoricoTipo.adicao;
                                return ListTile(
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    '${foiAdicao ? 'Adicionado' : 'Removido'} ${registro.quantidade} un. - ${registro.descricao}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  subtitle: Text(
                                    '${registro.codigoDeBarras}  •  ${_rotuloTamanhoCor(tamanho: registro.tamanho, cor: registro.cor)}\n${_formatarDataHora(registro.dataHora)}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                );
                              },
                            ),
                      _LeitorVisualizacao.grade => _gradePorReferencia(state),
                          },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onBlocChangeState(LeitorState state, BuildContext context) {
    final previousState = _controller.state;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (state.tokenUltimoProduto != previousState.tokenUltimoProduto &&
          state.ultimoProdutoLido != null) {
        widget.onUltimoProdutoLido?.call(state.ultimoProdutoLido!);
      }

      if (state.tokenErro != previousState.tokenErro && state.erro != null) {
        widget.onErro?.call(state.erro!);
        _exibirErro(state.erro!);
        SystemSound.play(SystemSoundType.alert);
      }

      if (state.tokenAviso != previousState.tokenAviso &&
          state.aviso != null &&
          (widget.avisarCodigoDuplicado ||
              state.avisoTipo != LeitorAvisoTipo.codigoDuplicado)) {
        widget.onAviso?.call(state.aviso!);
        _mostrarMensagem(context, state.aviso!, Colors.orange.shade700);
        SystemSound.play(SystemSoundType.alert);
      }

      _controller.syncState(state);
      if (!widget.desativado) {
        _solicitarFoco();
      }
    });
  }
}

/// Abre o mesmo diálogo de busca manual de produto usado internamente pelo
/// [LeitorWidget] (por texto, com filtro de tamanho/cor), sem exigir que o
/// leitor completo esteja montado -- usado por telas que constroem sua
/// própria UI de leitura em cima de um [LeitorBloc] próprio.
Future<({LeitorData produto, int quantidade})?> abrirBuscaManualDeProduto({
  required BuildContext context,
  required ILeitorBuscaDataDatasource buscaDataSource,
  int? tabelaDePrecoId,
  bool modoRemocao = false,
  String rotuloQuantidadeDisponivel = 'Estoque',
}) {
  return showDialog<({LeitorData produto, int quantidade})>(
    context: context,
    builder: (dialogContext) => _BuscaProdutoDialog(
      buscaDataSource: buscaDataSource,
      tabelaDePrecoId: tabelaDePrecoId,
      modoRemocao: modoRemocao,
      rotuloQuantidadeDisponivel: rotuloQuantidadeDisponivel,
    ),
  );
}

class _BuscaProdutoDialog extends StatefulWidget {
  final ILeitorBuscaDataDatasource buscaDataSource;
  final int? tabelaDePrecoId;
  final bool modoRemocao;
  final String rotuloQuantidadeDisponivel;

  const _BuscaProdutoDialog({
    required this.buscaDataSource,
    this.tabelaDePrecoId,
    required this.modoRemocao,
    this.rotuloQuantidadeDisponivel = 'Estoque',
  });

  @override
  State<_BuscaProdutoDialog> createState() => _BuscaProdutoDialogState();
}

class _BuscaProdutoDialogState extends State<_BuscaProdutoDialog> {
  late final LeitorBuscaBloc _buscaBloc;
  final _textoController = TextEditingController();
  final _textoFocusNode = FocusNode();
  final _filtrosScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _buscaBloc = LeitorBuscaBloc(
      dataSource: widget.buscaDataSource,
      tabelaDePrecoId: widget.tabelaDePrecoId,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textoFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _buscaBloc.close();
    _textoController.dispose();
    _textoFocusNode.dispose();
    _filtrosScrollController.dispose();
    super.dispose();
  }

  void _rolarFiltros(double offset) {
    final destino = (_filtrosScrollController.offset + offset).clamp(
      0.0,
      _filtrosScrollController.position.maxScrollExtent,
    );
    _filtrosScrollController.animateTo(
      destino,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _selecionarProduto(LeitorData produto) async {
    final quantidade = await showDialog<int>(
      context: context,
      builder: (ctx) => _QuantidadeDialog(
        produto: produto,
        modoRemocao: widget.modoRemocao,
      ),
    );
    if (quantidade == null || quantidade <= 0) return;
    if (!mounted) return;
    Navigator.of(context).pop((produto: produto, quantidade: quantidade));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _buscaBloc,
      child: BlocBuilder<LeitorBuscaBloc, LeitorBuscaState>(
        builder: (context, state) {
          final resultadosFiltrados = [...state.resultadosFiltrados]
            ..sort((a, b) => b.quantidade.compareTo(a.quantidade));

          return Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.modoRemocao
                                ? 'Busca manual — Remover produto'
                                : 'Busca manual de produto',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _textoController,
                      focusNode: _textoFocusNode,
                      decoration: InputDecoration(
                        labelText: 'Buscar produto',
                        hintText: 'Digite o nome ou código da referência',
                        suffixIcon: state.processando
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : const Icon(Icons.search_outlined),
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (v) =>
                          _buscaBloc.add(LeitorBuscaTextoBuscado(v)),
                      onChanged: (v) =>
                          _buscaBloc.add(LeitorBuscaTextoBuscado(v)),
                    ),
                    if (state.tamanhosDisponiveis.isNotEmpty ||
                        state.coresDisponiveis.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () => _rolarFiltros(-120),
                          ),
                          Expanded(
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(dragDevices: {
                                PointerDeviceKind.touch,
                                PointerDeviceKind.mouse,
                              }),
                              child: SingleChildScrollView(
                                controller: _filtrosScrollController,
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    if (state
                                        .tamanhosDisponiveis.isNotEmpty) ...[
                                      Text(
                                        'Tam:',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall,
                                      ),
                                      const SizedBox(width: 4),
                                      ...state.tamanhosDisponiveis.map(
                                        (t) => Padding(
                                          padding:
                                              const EdgeInsets.only(right: 4),
                                          child: FilterChip(
                                            label: Text(t),
                                            selected: state.tamanhoFiltro == t,
                                            onSelected: (sel) => _buscaBloc.add(
                                              LeitorBuscaTamanhoFiltrado(
                                                  sel ? t : null),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (state.coresDisponiveis.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        'Cor:',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall,
                                      ),
                                      const SizedBox(width: 4),
                                      ...state.coresDisponiveis.map(
                                        (c) => Padding(
                                          padding:
                                              const EdgeInsets.only(right: 4),
                                          child: FilterChip(
                                            label: Text(c),
                                            selected: state.corFiltro == c,
                                            onSelected: (sel) => _buscaBloc.add(
                                              LeitorBuscaCorFiltrada(
                                                  sel ? c : null),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () => _rolarFiltros(120),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (state.erro != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          state.erro!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    Flexible(
                      child: _textoController.text.trim().isEmpty
                          ? Center(
                              child: Text(
                                'Digite para buscar produtos.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            )
                          : resultadosFiltrados.isEmpty && !state.processando
                              ? Center(
                                  child: Text(
                                    'Nenhum produto encontrado.',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: resultadosFiltrados.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final produto = resultadosFiltrados[index];
                                    final tamanho = produto.tamanho.trim();
                                    final cor = produto.cor.trim();
                                    final subtitulo = [
                                      if (cor.isNotEmpty) 'Cor: $cor',
                                      if (tamanho.isNotEmpty) 'Tam: $tamanho',
                                      'Cód: ${produto.codigoDeBarras}',
                                      '${widget.rotuloQuantidadeDisponivel}: ${produto.quantidade}',
                                    ].join('  •  ');
                                    return ListTile(
                                      title: Text(produto.descricao),
                                      subtitle: Text(subtitulo),
                                      trailing: const Icon(
                                        Icons.chevron_right_outlined,
                                      ),
                                      onTap: () => _selecionarProduto(produto),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuantidadeDialog extends StatefulWidget {
  final LeitorData produto;
  final bool modoRemocao;

  const _QuantidadeDialog({
    required this.produto,
    required this.modoRemocao,
  });

  @override
  State<_QuantidadeDialog> createState() => _QuantidadeDialogState();
}

class _QuantidadeDialogState extends State<_QuantidadeDialog> {
  final _quantidadeController = TextEditingController(text: '1');
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _quantidadeController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _quantidadeController.text.length,
      );
    });
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _confirmar() {
    final quantidade = int.tryParse(_quantidadeController.text.trim()) ?? 0;
    if (quantidade <= 0) return;
    Navigator.of(context).pop(quantidade);
  }

  @override
  Widget build(BuildContext context) {
    final tamanho = widget.produto.tamanho.trim();
    final cor = widget.produto.cor.trim();
    final rotulo = [
      if (cor.isNotEmpty) 'Cor: $cor',
      if (tamanho.isNotEmpty) 'Tam: $tamanho',
    ].join('  •  ');

    return AlertDialog(
      title: Text(
        widget.modoRemocao ? 'Quantidade a remover' : 'Quantidade a adicionar',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.produto.descricao,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (rotulo.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              rotulo,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _quantidadeController,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Quantidade',
              hintText: 'Informe a quantidade',
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _confirmar(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _confirmar,
          child: Text(widget.modoRemocao ? 'Remover' : 'Adicionar'),
        ),
      ],
    );
  }
}

class LeitorController extends ChangeNotifier {
  LeitorBloc? _bloc;
  LeitorState _state = LeitorState.initial();

  LeitorState get state => _state;
  List<LeitorItemContado> get itens => List.unmodifiable(_state.itens);
  List<LeitorHistoricoRegistro> get historico =>
      List.unmodifiable(_state.historico);
  LeitorItemContado? get ultimoProdutoLido => _state.ultimoProdutoLido;
  String? get ultimoErro => _state.erro;
  int get quantidadeTotalLida => _state.quantidadeTotalLida;
  double get valorTotalLido => _state.valorTotalLido;
  int get quantidadeItensDistintos => _state.itens.length;
  bool get controlarQuantidade => _state.controlarQuantidade;

  List<Map<String, dynamic>> get dadosAtuais {
    return _state.itens
        .map(
          (item) => {
            'codigoDeBarras': item.codigoDeBarras,
            'descricao': item.descricao,
            'idReferencia': item.idReferencia,
            'tamanho': item.tamanho,
            'cor': item.cor,
            'quantidadeLida': item.quantidadeLida,
            'estoqueDisponivel': item.estoqueDisponivel,
            'valorUnitario': item.valorUnitario,
            'valorTotal': item.valorTotal,
            ...item.dados,
          },
        )
        .toList(growable: false);
  }

  void bind(LeitorBloc bloc) {
    _bloc = bloc;
    syncState(bloc.state);
  }

  void unbind(LeitorBloc bloc) {
    if (identical(_bloc, bloc)) {
      _bloc = null;
    }
  }

  void syncState(LeitorState state) {
    _state = state;
    notifyListeners();
  }

  void lerCodigo(String codigo) {
    _bloc?.add(LeitorCodigoInformado(codigo));
  }

  void lerCodigoComQuantidade(String codigo, int quantidade) {
    _bloc?.add(LeitorCodigoInformado(codigo, quantidade: quantidade));
  }

  void removerQuantidade(String codigo, {int quantidade = 1}) {
    _bloc?.add(
      LeitorQuantidadeRemovida(codigo: codigo, quantidade: quantidade),
    );
  }

  void removerItem(String codigo) {
    _bloc?.add(LeitorItemExcluido(codigo));
  }

  void limpar() {
    _bloc?.add(const LeitorReiniciado());
  }

  void preCarregarProdutos(List<ProdutosPreCarregado> produtos) {
    _bloc?.add(
      LeitorProdutosPreCarregadosInformados(
        produtos
            .map(
              (produto) => LeitorProdutoPreCarregado(
                produtoId: produto.id,
                quantidade: produto.quantidade,
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class ProdutosPreCarregado {
  final int id;
  final int quantidade;

  const ProdutosPreCarregado({required this.id, required this.quantidade});
}
