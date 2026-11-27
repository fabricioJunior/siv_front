import 'package:comercial/domain/use_cases/cancelar_pedido.dart';
import 'package:comercial/presentation/blocs/pedido_entrada_bloc/pedido_entrada_bloc.dart';
import 'package:comercial/presentation/blocs/variacoes_produto_bloc/variacoes_produto_bloc.dart';
import 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart';
import 'package:comercial/presentation/pages/pedido_entrada/historico_entrada.dart';
import 'package:comercial/presentation/pages/pedido_entrada/passo_associar.dart';
import 'package:comercial/presentation/pages/pedido_entrada/passo_conferir.dart';
import 'package:comercial/presentation/pages/pedido_entrada/passo_contar.dart';
import 'package:comercial/presentation/pages/pedido_entrada/passo_etiquetas.dart';
import 'package:comercial/presentation/pages/pedido_entrada/passo_revisar_faturar.dart';
import 'package:comercial/presentation/pages/pedido_entrada/trilha_entrada.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/leitor.dart';
import 'package:core/presentation.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

export 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart'
    show
        BuscaReferenciasParecidas,
        ReferenciaParecida,
        TamanhoOpcao;

/// Pedido de Entrada (NF-e / contagem) em 5 passos: Contar, Associar,
/// Etiquetas, Conferir e Faturar. A entrada no estoque continua sendo a do
/// pedido (só o conferido entra ao faturar).
class PedidoEntradaPage extends StatefulWidget {
  final int pedidoId;
  final SeletorWidget categoriaSeletor;
  final SeletorWidget referenciaSeletor;

  /// Referência com cadastro (wizard) -- usado na contagem sem NF-e.
  final SeletorWidget referenciaContagemSeletor;
  final SeletorWidget corSeletor;
  final SeletorWidget tamanhoSeletor;

  /// Sugestões "referências parecidas" na contagem sem referência.
  final BuscaReferenciasParecidas? buscarReferenciasParecidas;
  final SeletorWidget? estampaSeletor;

  const PedidoEntradaPage({
    super.key,
    required this.pedidoId,
    required this.categoriaSeletor,
    required this.referenciaSeletor,
    required this.referenciaContagemSeletor,
    required this.corSeletor,
    required this.tamanhoSeletor,
    this.buscarReferenciasParecidas,
    this.estampaSeletor,
  });

  @override
  State<PedidoEntradaPage> createState() => _PedidoEntradaPageState();
}

class _PedidoEntradaPageState extends State<PedidoEntradaPage> {
  late final PedidoEntradaBloc _bloc = sl<PedidoEntradaBloc>()
    ..add(PedidoEntradaCarregou(widget.pedidoId));

  // Pré-carga de cores/estampas/tamanhos; sem o bloc registrado, o painel cai
  // no fluxo legado (seletores inline).
  late final VariacoesProdutoBloc? _variacoes =
      sl.isRegistered<VariacoesProdutoBloc>()
          ? (sl<VariacoesProdutoBloc>()..add(const VariacoesCarregadas()))
          : null;

  late final _seletores = SeletoresEntrada(
    categoriaSeletor: widget.categoriaSeletor,
    referenciaSeletor: widget.referenciaSeletor,
    referenciaContagemSeletor: widget.referenciaContagemSeletor,
    corSeletor: widget.corSeletor,
    tamanhoSeletor: widget.tamanhoSeletor,
    buscarReferenciasParecidas: widget.buscarReferenciasParecidas,
    estampaSeletor: widget.estampaSeletor,
  );

  /// Envia o lote de leituras pendentes (uma chamada). true = nada ficou
  /// pendente (enviou, ou não havia nada).
  Future<bool> _enviarLeituras({bool irParaRevisar = false}) async {
    if (_bloc.state.leiturasPendentes.isEmpty) {
      if (irParaRevisar) _irParaPasso(4);
      return true;
    }
    _bloc.add(PedidoEntradaEnviouLeituras(irParaRevisar: irParaRevisar));
    final fim = await _bloc.stream.firstWhere((s) => !s.salvando);
    return fim.leiturasPendentes.isEmpty;
  }

  /// Zera as leituras (envio na hora). true = lote aceito.
  Future<bool> _zerarLeituras() async {
    _bloc.add(const PedidoEntradaZerouLeituras());
    final fim = await _bloc.stream.firstWhere((s) => !s.salvando);
    return fim.erro == null;
  }

  /// Exclui (cancela) o pedido inteiro, com motivo. Só antes de faturar.
  Future<void> _excluirPedido() async {
    final motivoController = TextEditingController();
    final motivo = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Excluir pedido #${widget.pedidoId}?'),
        content: TextField(
          key: const Key('excluir_pedido_motivo'),
          controller: motivoController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Motivo',
            helperText: 'A contagem deste pedido deixa de valer.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            key: const Key('excluir_pedido_confirmar'),
            onPressed: () {
              final m = motivoController.text.trim();
              if (m.isNotEmpty) Navigator.pop(ctx, m);
            },
            child: const Text('EXCLUIR'),
          ),
        ],
      ),
    );
    if (motivo == null || !mounted) return;
    try {
      await sl<CancelarPedido>()(widget.pedidoId, motivoCancelamento: motivo);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagemDeErroApi(e, 'Falha ao excluir o pedido.'))),
      );
    }
  }

  /// Sair do Conferir (trocar de passo ou voltar) com leituras pendentes:
  /// ENVIAR / DESCARTAR / CONTINUAR BIPANDO. true = pode sair.
  Future<bool> _confirmarSaida() async {
    final pend = _bloc.state.leiturasPendentes;
    if (pend.isEmpty) return true;
    final n = pend.values.fold<int>(0, (s, d) => s + d.abs());
    final r = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Há $n leitura(s) não enviadas'),
        content: const Text(
          'Elas só valem para a conferência depois de enviadas.',
        ),
        actions: [
          TextButton(
            key: const Key('saida_continuar'),
            onPressed: () => Navigator.pop(ctx, 'continuar'),
            child: const Text('CONTINUAR BIPANDO'),
          ),
          TextButton(
            key: const Key('saida_descartar'),
            onPressed: () => Navigator.pop(ctx, 'descartar'),
            child: const Text('DESCARTAR'),
          ),
          FilledButton(
            key: const Key('saida_enviar'),
            onPressed: () => Navigator.pop(ctx, 'enviar'),
            child: const Text('ENVIAR'),
          ),
        ],
      ),
    );
    if (r == 'descartar') {
      _bloc.add(const PedidoEntradaDescartouLeituras());
      return true;
    }
    if (r == 'enviar') return _enviarLeituras();
    return false;
  }

  Future<void> _irParaPasso(int p) async {
    if (_bloc.state.passoVisivel == 3 && p != 3 && !await _confirmarSaida()) {
      return;
    }
    _bloc.add(PedidoEntradaSelecionouPasso(p));
  }

  @override
  void dispose() {
    _bloc.close();
    _variacoes?.close();
    super.dispose();
  }

  Widget _passo(BuildContext context, PedidoEntradaState state) {
    final resumo = state.resumo!;
    switch (state.passoVisivel) {
      case 0:
        return PassoContar(
          resumo: resumo,
          salvando: state.salvando,
          seletores: _seletores,
          onIrParaPasso: _irParaPasso,
        );
      case 1:
        return PassoAssociar(
          resumo: resumo,
          salvando: state.salvando,
          seletores: _seletores,
          onIrParaPasso: _irParaPasso,
        );
      case 2:
        return PassoEtiquetas(
          resumo: resumo,
          salvando: state.salvando,
          onIrParaPasso: _irParaPasso,
        );
      case 3:
        return PassoConferir(
          resumo: resumo,
          pendentes: state.leiturasPendentes,
          salvando: state.salvando,
          buscaDataSource: sl.isRegistered<ILeitorBuscaDataDatasource>()
              ? sl<ILeitorBuscaDataDatasource>()
              : null,
          onIrParaPasso: _irParaPasso,
          onLeu: (produtoId, delta) =>
              _bloc.add(PedidoEntradaLeu(produtoId, delta)),
          onEnviar: _enviarLeituras,
          restauradaEm: state.restauradaEm,
          erroEnvio: state.erroEnvio,
          onDescartar: () =>
              _bloc.add(const PedidoEntradaDescartouLeituras()),
          onZerar: _zerarLeituras,
        );
      default:
        return PassoRevisarFaturar(
          resumo: resumo,
          salvando: state.salvando,
          faturado: state.faturado || resumo.etapa == 'faturado',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pagina = BlocProvider<PedidoEntradaBloc>.value(
      value: _bloc,
      child: BlocConsumer<PedidoEntradaBloc, PedidoEntradaState>(
        listenWhen: (a, b) =>
            a.erro != b.erro ||
            a.mensagem != b.mensagem ||
            a.referenciaCriadaId != b.referenciaCriadaId,
        listener: (context, state) {
          final messenger = ScaffoldMessenger.of(context);
          if (state.erro != null) {
            messenger.showSnackBar(SnackBar(content: Text(state.erro!)));
          } else if (state.mensagem != null) {
            final referenciaId = state.referenciaCriadaId;
            messenger.showSnackBar(
              SnackBar(
                content: Text(state.mensagem!),
                action: referenciaId == null
                    ? null
                    : SnackBarAction(
                        label: 'Abrir referência',
                        onPressed: () => Navigator.of(context).pushNamed(
                          '/referencia',
                          arguments: {'idReferencia': referenciaId},
                        ),
                      ),
              ),
            );
          }
        },
        builder: (context, state) {
          final resumo = state.resumo;
          final mobile = ehMobile(context);
          final passos = state.trilha;
          final visivel = state.passoVisivel;
          final textos = context.sivTextos;
          return PopScope(
            canPop: state.leiturasPendentes.isEmpty,
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop) return;
              if (await _confirmarSaida() && context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Scaffold(
              appBar: AppBar(
                toolbarHeight: 52,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Entrada #${widget.pedidoId}'),
                    if (resumo != null)
                      Text(
                        state.faturado || resumo.etapa == 'faturado'
                            ? 'Faturada'
                            : 'Passo ${visivel + 1} de 5 · ${passos[visivel].titulo}',
                        key: const Key('entrada_passo_x_de_5'),
                        style: textos.apoio,
                      ),
                  ],
                ),
                actions: [
                  PopupMenuButton<String>(
                    key: const Key('entrada_menu'),
                    onSelected: (v) {
                      if (v == 'historico' && resumo != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                HistoricoEntradaPage(resumo: resumo),
                          ),
                        );
                      } else if (v == 'atualizar') {
                        _bloc.add(PedidoEntradaCarregou(widget.pedidoId));
                      } else if (v == 'excluir') {
                        _excluirPedido();
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'historico',
                        child: Text('Histórico do pedido'),
                      ),
                      const PopupMenuItem(
                          value: 'atualizar', child: Text('Atualizar')),
                      if (resumo != null &&
                          !(state.faturado || resumo.etapa == 'faturado') &&
                          PermissaoPorNome.acessoPermitido('PEDFM006'))
                        const PopupMenuItem(
                          key: Key('entrada_menu_excluir'),
                          value: 'excluir',
                          child: Text('Excluir pedido'),
                        ),
                    ],
                  ),
                ],
              ),
              body: resumo == null
                  ? Center(
                      child: state.carregando
                          ? const CircularProgressIndicator()
                          : const Text('Pedido de entrada não carregado.'),
                    )
                  : Column(
                      children: [
                        if (state.salvando)
                          const LinearProgressIndicator(minHeight: 2),
                        if (mobile)
                          TrilhaSegmentos(
                            passos: passos,
                            onSelecionar: _irParaPasso,
                          )
                        else
                          TrilhaPassos(
                            passos: passos,
                            onSelecionar: _irParaPasso,
                          ),
                        Expanded(child: _passo(context, state)),
                      ],
                    ),
            ),
          );
        },
      ),
    );
    final variacoes = _variacoes;
    return variacoes == null
        ? pagina
        : BlocProvider<VariacoesProdutoBloc>.value(
            value: variacoes,
            child: pagina,
          );
  }
}
