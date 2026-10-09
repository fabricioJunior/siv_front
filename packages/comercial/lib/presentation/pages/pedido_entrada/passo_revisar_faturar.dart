import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/domain/models/trilha_entrada.dart';
import 'package:comercial/presentation/blocs/pedido_entrada_bloc/pedido_entrada_bloc.dart';
import 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart';
import 'package:core/bloc.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Passo 5: cada divergência recebe uma decisão; só então fatura (só as peças
/// conferidas entram no estoque).
class PassoRevisarFaturar extends StatefulWidget {
  final EntradaResumo resumo;
  final bool salvando;
  final bool faturado;

  const PassoRevisarFaturar({
    super.key,
    required this.resumo,
    required this.salvando,
    required this.faturado,
  });

  @override
  State<PassoRevisarFaturar> createState() => _PassoRevisarFaturarState();
}

class _PassoRevisarFaturarState extends State<PassoRevisarFaturar> {
  int? _explicando;
  final _obs = TextEditingController();

  @override
  void dispose() {
    _obs.dispose();
    super.dispose();
  }

  void _decidir(EntradaDivergencia d, AcaoDivergencia a, {String? obs}) {
    context
        .read<PedidoEntradaBloc>()
        .add(PedidoEntradaDecidiuDivergencia(d.produtoId, a, observacao: obs));
    setState(() => _explicando = null);
    _obs.clear();
  }

  String _rotuloDecisao(AcaoDivergencia a, EntradaDivergencia d) => switch (a) {
        AcaoDivergencia.corrigir => 'Corrigir para ${qtd(d.lido)}',
        AcaoDivergencia.manter => 'Manter e explicar',
        AcaoDivergencia.removerLeitura => 'Bipado 2×, remover leitura',
        AcaoDivergencia.adicionarNaContagem => 'Adicionar à contagem',
        AcaoDivergencia.descartarLeitura => 'Descartar leitura',
      };

  List<AcaoDivergencia> _opcoes(TipoDivergencia t) => switch (t) {
        TipoDivergencia.falta => [AcaoDivergencia.corrigir, AcaoDivergencia.manter],
        TipoDivergencia.excede => [
            AcaoDivergencia.corrigir,
            AcaoDivergencia.removerLeitura,
          ],
        TipoDivergencia.foraDaContagem => [
            AcaoDivergencia.adicionarNaContagem,
            AcaoDivergencia.descartarLeitura,
          ],
      };

  @override
  Widget build(BuildContext context) {
    final r = widget.resumo;
    final textos = context.sivTextos;
    final cores = context.sivColors;
    final restantes = TrilhaEntrada.divergenciasSemDecisao(r);
    final pode = TrilhaEntrada.podeFaturar(r) && !widget.faturado;
    final entra = r.revisao.entraNoEstoque > 0
        ? r.revisao.entraNoEstoque
        : r.conferencia.totalLido;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (widget.faturado)
                Text('Pedido faturado.',
                    key: const Key('revisao_faturado'), style: textos.secao)
              else if (r.divergencias.isNotEmpty)
                Text(
                  '${restantes == 0 ? 'NENHUM' : restantes} ITENS PARA DECIDIR ANTES DE FATURAR',
                  key: const Key('revisao_titulo'),
                  style: textos.rotulo.copyWith(color: cores.parcialTexto),
                ),
              const SizedBox(height: 8),
              for (final d in r.divergencias) _cartao(d, textos, cores),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cores.superficie,
                  border: Border.all(color: cores.hairline),
                  borderRadius: BorderRadius.circular(SivDimensoes.raio),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _total('Contado', qtd(r.revisao.contado > 0 ? r.revisao.contado : r.totalContado), textos),
                    _total('Conferido', qtd(r.conferencia.totalLido), textos),
                    _total('Entra no estoque', '${qtd(entra)} peças', textos),
                  ],
                ),
              ),
            ],
          ),
        ),
        RodapeAcaoEntrada(
          aviso: restantes > 0
              ? Text('Decida os $restantes itens restantes para liberar.',
                  key: const Key('revisao_bloqueio'),
                  style: textos.apoio.copyWith(color: cores.parcialTexto))
              : Text('Só as peças conferidas entram no estoque.',
                  style: textos.apoio),
          acao: BotaoPrincipalEntrada(
            key: const Key('revisao_faturar'),
            rotulo: 'FATURAR ${qtd(entra)} PEÇAS',
            onPressed: pode && !widget.salvando
                ? () => context
                    .read<PedidoEntradaBloc>()
                    .add(const PedidoEntradaFaturou())
                : null,
          ),
        ),
      ],
    );
  }

  Widget _total(String t, String v, SivTextStyles textos) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.toUpperCase(), style: textos.rotulo),
          Text(v, style: textos.secao),
        ],
      );

  Widget _cartao(EntradaDivergencia d, SivTextStyles textos, SivColors cores) {
    final decididaTxt = d.decisao == null
        ? null
        : '${_rotuloDecisao(d.decisao!, d)}${d.observacao != null ? ' · ${d.observacao}' : ''}';
    return Container(
      key: Key('divergencia_${d.produtoId}'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: d.decidida ? cores.conferidoFundo : cores.parcialFundo,
        border: Border.all(
          color: d.decidida ? cores.conferidoEtiqueta : cores.parcialBorda,
        ),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${d.descricao} · ${d.grade}',
                    style: textos.corpo.copyWith(fontWeight: FontWeight.w600)),
              ),
              Text(
                d.tipo == TipoDivergencia.foraDaContagem
                    ? '${qtd(d.lido)} · não contado'
                    : '${qtd(d.lido)}/${qtd(d.contado)}',
                style: textos.secao,
              ),
            ],
          ),
          if (decididaTxt != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Decidido: $decididaTxt',
                  key: Key('decisao_${d.produtoId}'),
                  style: textos.apoio.copyWith(color: cores.conferidoTexto)),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in _opcoes(d.tipo))
                OutlinedButton(
                  key: Key('decidir_${d.produtoId}_${a.name}'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(44, 44),
                    backgroundColor:
                        d.decisao == a ? cores.conferidoEtiqueta : null,
                  ),
                  onPressed: widget.salvando || widget.faturado
                      ? null
                      : a == AcaoDivergencia.manter
                          ? () => setState(() => _explicando = d.produtoId)
                          : () => _decidir(d, a),
                  child: Text(_rotuloDecisao(a, d)),
                ),
            ],
          ),
          if (_explicando == d.produtoId) ...[
            const SizedBox(height: 8),
            TextField(
              key: Key('explicacao_${d.produtoId}'),
              controller: _obs,
              maxLength: 255,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Explicação (ex.: veio 1 a menos na caixa 2)',
                counterText: '',
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                key: Key('explicacao_confirmar_${d.produtoId}'),
                style: FilledButton.styleFrom(minimumSize: const Size(44, 44)),
                onPressed: _obs.text.trim().isEmpty
                    ? null
                    : () => _decidir(d, AcaoDivergencia.manter,
                        obs: _obs.text.trim()),
                child: const Text('Manter'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
