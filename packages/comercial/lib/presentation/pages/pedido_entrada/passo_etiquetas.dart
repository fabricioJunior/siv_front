import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/domain/models/trilha_entrada.dart';
import 'package:comercial/presentation/blocs/pedido_entrada_bloc/pedido_entrada_bloc.dart';
import 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart';
import 'package:core/bloc.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Passo 3: uma etiqueta por peça. Quantidade editável por linha; depois de
/// impressas, uma edição da contagem mostra só a diferença (imprimir/descartar).
class PassoEtiquetas extends StatefulWidget {
  final EntradaResumo resumo;
  final bool salvando;
  final ValueChanged<int> onIrParaPasso;

  const PassoEtiquetas({
    super.key,
    required this.resumo,
    required this.salvando,
    required this.onIrParaPasso,
  });

  @override
  State<PassoEtiquetas> createState() => _PassoEtiquetasState();
}

class _PassoEtiquetasState extends State<PassoEtiquetas> {
  final _ajustes = <int, double>{};

  EntradaResumo get _r => widget.resumo;
  bool get _modoDiferenca => _r.etiquetas.impressasPorProduto.isNotEmpty;

  /// (produtoId, descricao, grade, quantidade padrão)
  List<(int, String, String, double)> get _linhas {
    if (_modoDiferenca) {
      return [
        for (final i in TrilhaEntrada.diffEtiquetas(_r).imprimir)
          (i.produtoId, i.descricao, i.grade, i.quantidade),
      ];
    }
    return [
      for (final c in _r.contagens)
        if (c.referenciaId != null && c.quantidade > 0)
          (
            c.produtoId,
            c.referenciaNome ?? '',
            [c.corNome, c.tamanhoNome]
                .whereType<String>()
                .where((e) => e.isNotEmpty)
                .join(' · '),
            c.quantidade,
          ),
    ];
  }

  double _q(int produtoId, double padrao) => _ajustes[produtoId] ?? padrao;

  double get _total =>
      _linhas.fold(0, (s, l) => s + _q(l.$1, l.$4));

  Future<void> _imprimir() async {
    final bloc = context.read<PedidoEntradaBloc>();
    final itens = <Map<String, dynamic>>[];
    final registro = <int, double>{};
    for (final l in _linhas) {
      final q = _q(l.$1, l.$4);
      if (q <= 0) continue;
      final c = _r.contagens.firstWhere((c) => c.produtoId == l.$1);
      itens.add({
        'referenciaId': c.referenciaId,
        'referenciaNome': c.referenciaNome ?? '',
        'produtoId': c.produtoId,
        'quantidade': q,
      });
      registro[l.$1] = q;
    }
    await Navigator.of(context).pushNamed(
      '/impressao_etiquetas',
      arguments: {'itens': itens},
    );
    // Soma ao já impresso: o registro guarda a quantidade desta impressão.
    if (mounted) bloc.add(PedidoEntradaImprimiuEtiquetas(registro));
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final bloqueado = TrilhaEntrada.etiquetasBloqueadas(_r);
    final linhas = _linhas;
    final diff = TrilhaEntrada.diffEtiquetas(_r);
    final emDia = _modoDiferenca && diff.vazio;
    final n = _total;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (bloqueado)
                Text(
                  'As etiquetas liberam quando todos estiverem associados.',
                  key: const Key('etiquetas_bloqueio'),
                  style: textos.corpo.copyWith(color: cores.parcialTexto),
                )
              else ...[
                Text(
                  _modoDiferenca
                      ? 'Etiquetas já impressas. Ao salvar, o app mostra só a diferença: quantas imprimir a mais e quantas descartar. As leituras continuam valendo.'
                      : 'Uma por peça. Ajuste se alguma já veio etiquetada.',
                  style: textos.apoio,
                ),
                const SizedBox(height: 12),
                if (emDia)
                  Text('Etiquetas em dia com a contagem.',
                      key: const Key('etiquetas_em_dia'), style: textos.corpo),
                for (final l in linhas) _linha(l, textos, cores),
                if (diff.descartar.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('DESCARTAR',
                      style: textos.rotulo.copyWith(color: cores.vinho)),
                  for (final d in diff.descartar)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('${qtd(d.quantidade)} · ${d.descricao} ${d.grade}',
                          key: Key('descartar_${d.produtoId}'),
                          style: textos.corpo),
                    ),
                ],
              ],
            ],
          ),
        ),
        RodapeAcaoEntrada(
          resumo: bloqueado || emDia
              ? null
              : TextButton(
                  key: const Key('etiquetas_pular'),
                  style: TextButton.styleFrom(minimumSize: const Size(44, 48)),
                  onPressed: widget.salvando
                      ? null
                      : () => context
                          .read<PedidoEntradaBloc>()
                          .add(const PedidoEntradaPulouEtiquetas()),
                  child: const Text('Já etiquetado · pular'),
                ),
          acao: BotaoPrincipalEntrada(
            key: const Key('etiquetas_imprimir'),
            rotulo: emDia ? 'CONFERIR' : 'IMPRIMIR ${qtd(n)} E CONFERIR',
            onPressed: bloqueado || widget.salvando
                ? null
                : emDia
                    ? () => widget.onIrParaPasso(3)
                    : n > 0
                        ? _imprimir
                        : null,
          ),
        ),
      ],
    );
  }

  Widget _linha(
    (int, String, String, double) l,
    SivTextStyles textos,
    SivColors cores,
  ) {
    final q = _q(l.$1, l.$4);
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cores.hairline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.$2,
                    style: textos.corpo.copyWith(fontWeight: FontWeight.w600)),
                Text(l.$3, style: textos.apoio),
              ],
            ),
          ),
          IconButton(
            key: Key('etiqueta_menos_${l.$1}'),
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            onPressed:
                q > 0 ? () => setState(() => _ajustes[l.$1] = q - 1) : null,
            icon: const Icon(Icons.remove),
          ),
          SizedBox(
            width: 32,
            child: Text(qtd(q),
                key: Key('etiqueta_qtd_${l.$1}'),
                textAlign: TextAlign.center,
                style: textos.secao),
          ),
          IconButton(
            key: Key('etiqueta_mais_${l.$1}'),
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            onPressed: () => setState(() => _ajustes[l.$1] = q + 1),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
