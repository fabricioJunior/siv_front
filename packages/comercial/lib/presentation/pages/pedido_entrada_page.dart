import 'dart:async';

import 'package:comercial/presentation/blocs/pedido_bloc/pedido_bloc.dart';
import 'package:comercial/presentation/blocs/pedido_entrada_bloc/pedido_entrada_bloc.dart';
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
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

export 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart'
    show BuscaReferenciasParecidas, ReferenciaParecida;

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

  const PedidoEntradaPage({
    super.key,
    required this.pedidoId,
    required this.categoriaSeletor,
    required this.referenciaSeletor,
    required this.referenciaContagemSeletor,
    required this.corSeletor,
    required this.tamanhoSeletor,
    this.buscarReferenciasParecidas,
  });

  @override
  State<PedidoEntradaPage> createState() => _PedidoEntradaPageState();
}

class _PedidoEntradaPageState extends State<PedidoEntradaPage> {
  late final PedidoEntradaBloc _bloc = sl<PedidoEntradaBloc>()
    ..add(PedidoEntradaCarregou(widget.pedidoId));

  late final _seletores = SeletoresEntrada(
    categoriaSeletor: widget.categoriaSeletor,
    referenciaSeletor: widget.referenciaSeletor,
    referenciaContagemSeletor: widget.referenciaContagemSeletor,
    corSeletor: widget.corSeletor,
    tamanhoSeletor: widget.tamanhoSeletor,
    buscarReferenciasParecidas: widget.buscarReferenciasParecidas,
  );

  // Cada bipe vai ao servidor pelo PedidoBloc (PedidoItemConferiuPorCodigo);
  // depois recarrega a entrada para atualizar lido × contado.
  PedidoBloc? _pedidoBloc;
  StreamSubscription<PedidoState>? _sub;

  PedidoBloc get _pedido {
    final existente = _pedidoBloc;
    if (existente != null) return existente;
    final b = _pedidoBloc = sl<PedidoBloc>()
      ..add(PedidoIniciou(idPedido: widget.pedidoId));
    _sub = b.stream.listen((s) {
      if (s.step == PedidoStep.itemConferido) {
        _bloc.add(PedidoEntradaCarregou(widget.pedidoId));
      } else if (s.step == PedidoStep.falha && s.erro != null && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(s.erro!)));
      }
    });
    return b;
  }

  void _irParaPasso(int p) => _bloc.add(PedidoEntradaSelecionouPasso(p));

  @override
  void dispose() {
    _sub?.cancel();
    _pedidoBloc?.close();
    _bloc.close();
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
          dataSource: sl<ILeitorDataDatasource>(),
          buscaDataSource: sl<ILeitorBuscaDataDatasource>(),
          onIrParaPasso: _irParaPasso,
          onConferirCodigo: (codigo, q) => _pedido.add(
            PedidoItemConferiuPorCodigo(
              codigoBarras: codigo,
              quantidade: q.toDouble(),
            ),
          ),
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
    return BlocProvider<PedidoEntradaBloc>.value(
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
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 52,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Entrada #${widget.pedidoId}'),
                  if (resumo != null)
                    Text(
                      'Passo ${visivel + 1} de 5 · ${passos[visivel].titulo}',
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
                          builder: (_) => HistoricoEntradaPage(resumo: resumo),
                        ),
                      );
                    } else if (v == 'pedido') {
                      Navigator.of(context).pushNamed(
                        '/pedido',
                        arguments: {'idPedido': widget.pedidoId},
                      );
                    } else if (v == 'atualizar') {
                      _bloc.add(PedidoEntradaCarregou(widget.pedidoId));
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'historico',
                      child: Text('Histórico do pedido'),
                    ),
                    PopupMenuItem(value: 'pedido', child: Text('Abrir pedido')),
                    PopupMenuItem(value: 'atualizar', child: Text('Atualizar')),
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
          );
        },
      ),
    );
  }
}
