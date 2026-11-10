import 'package:comercial/models.dart';
import 'package:core/injecoes.dart';
import 'package:core/leitor/leitor_widget.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Peças ainda não lidas (solicitado − atendido, só o que falta).
double pecasFaltando(List<PedidoItem> itens) => itens.fold(0, (s, i) {
      final falta = (i.solicitado ?? 0) - (i.atendido ?? 0);
      return s + (falta > 0 ? falta : 0);
    });

/// Etapa Conferir (e-commerce): leitor sempre focado; pendentes no topo, conferidos descem e
/// esmaecem. ↑↓ escolhem a linha e `+` conta uma peça nela (sem leitor). Peça fora do pedido:
/// o backend recusa (erro sonoro na tela) e nada soma.
class EtapaConferir extends StatefulWidget {
  final List<PedidoItem> itens;
  final void Function(String codigoBarras) onLeitura;
  final void Function(PedidoItem item) onContar;

  const EtapaConferir({
    super.key,
    required this.itens,
    required this.onLeitura,
    required this.onContar,
  });

  @override
  State<EtapaConferir> createState() => _EtapaConferirState();
}

class _EtapaConferirState extends State<EtapaConferir> {
  int _sel = 0;
  final _leitor = LeitorController();

  // A página tem o foco dos atalhos; o leitor o toma ao montar (F9/F10/Esc seguem valendo).
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _leitor.solicitarFoco();
    });
  }

  @override
  void dispose() {
    _leitor.dispose();
    super.dispose();
  }

  bool _lido(PedidoItem i) => (i.atendido ?? 0) >= (i.solicitado ?? 0);

  List<PedidoItem> get _ordenados {
    final l = List.of(widget.itens);
    // sort estável não é garantido em Dart: desempata pela posição original.
    final pos = {for (var i = 0; i < l.length; i++) l[i]: i};
    l.sort((a, b) {
      final c = (_lido(a) ? 1 : 0).compareTo(_lido(b) ? 1 : 0);
      return c != 0 ? c : pos[a]!.compareTo(pos[b]!);
    });
    return l;
  }

  KeyEventResult _tecla(KeyEvent e) {
    final lista = _ordenados;
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) return KeyEventResult.ignored;
    if (lista.isEmpty) return KeyEventResult.ignored;
    final sel = _sel.clamp(0, lista.length - 1);
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.arrowDown) {
      setState(() => _sel = (sel + 1).clamp(0, lista.length - 1));
    } else if (k == LogicalKeyboardKey.arrowUp) {
      setState(() => _sel = (sel - 1).clamp(0, lista.length - 1));
    } else if (e.character == '+' || k == LogicalKeyboardKey.numpadAdd) {
      widget.onContar(lista[sel]);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final lista = _ordenados;
    final sel = lista.isEmpty ? 0 : _sel.clamp(0, lista.length - 1);
    final falta = pecasFaltando(widget.itens);

    // Os eventos sobem do campo do leitor até aqui; F9/F10/Esc não são tratados
    // aqui e seguem para os atalhos da página.
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (_, e) => _tecla(e),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LeitorWidget(
            dataSource: sl(),
            buscaDataSource: sl(),
            controller: _leitor,
            alturaLista: 0,
            campoCodigoHint: 'Bipe o código de barras da peça',
            onUltimoProdutoLido: (item) => widget.onLeitura(item.codigoDeBarras),
          ),
          const SizedBox(height: 12),
          SivCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  falta > 0
                      ? 'FALTAM ${falta.toStringAsFixed(0)} PEÇA(S) · ↑↓ escolhem · + conta uma'
                      : 'TODAS AS PEÇAS LIDAS · F9 conclui',
                  style: textos.rotulo,
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < lista.length; i++)
                  Opacity(
                    opacity: _lido(lista[i]) ? 0.5 : 1,
                    child: Container(
                      key: Key('conferir_linha_${lista[i].produtoId}_${lista[i].sequencia}'),
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: i == sel ? cores.aco : cores.hairline,
                          width: i == sel ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(SivDimensoes.raio),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _lido(lista[i]) ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              [
                                lista[i].referenciaNome?.trim().isNotEmpty == true
                                    ? lista[i].referenciaNome!
                                    : 'Produto #${lista[i].produtoId ?? '-'}',
                                if ((lista[i].corNome ?? '').isNotEmpty) lista[i].corNome!,
                                if ((lista[i].tamanhoNome ?? '').isNotEmpty) lista[i].tamanhoNome!,
                              ].join(' · '),
                              style: textos.corpo,
                            ),
                          ),
                          Text(
                            '${(lista[i].atendido ?? 0).toStringAsFixed(0)}/'
                            '${(lista[i].solicitado ?? 0).toStringAsFixed(0)}',
                            style: textos.valor.copyWith(fontSize: 16),
                          ),
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
