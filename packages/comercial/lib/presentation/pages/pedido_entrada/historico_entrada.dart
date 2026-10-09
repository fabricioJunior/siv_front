import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Histórico do pedido (5h): correções de contagem e decisões, com operador,
/// data/hora, de → para e motivo.
class HistoricoEntradaPage extends StatelessWidget {
  final EntradaResumo resumo;
  const HistoricoEntradaPage({super.key, required this.resumo});

  String _produto(int? id) {
    for (final i in resumo.conferencia.itens) {
      if (i.produtoId == id) return '${i.descricao} · ${i.grade}';
    }
    for (final c in resumo.contagens) {
      if (c.produtoId == id) {
        return '${c.referenciaNome ?? 'Produto $id'} · ${c.corNome ?? ''} ${c.tamanhoNome ?? ''}'
            .trim();
      }
    }
    return id == null ? 'Pedido' : 'Produto $id';
  }

  String _hora(DateTime? d) {
    if (d == null) return '';
    final l = d.toLocal();
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(l.day)}/${p(l.month)} ${p(l.hour)}:${p(l.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    final correcoes = resumo.correcoes;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 52,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Histórico do pedido'),
            Text('Entrada #${resumo.pedidoId}', style: textos.apoio),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('CORREÇÕES DA CONTAGEM · ${correcoes.length}',
              style: textos.rotulo.copyWith(color: cores.aco)),
          const SizedBox(height: 8),
          if (correcoes.isEmpty)
            Text(
              'Nenhuma correção ainda. Em Conferir, bipe até uma linha ficar '
              'parcial e toque em “Corrigir”.',
              key: const Key('historico_vazio'),
              style: textos.corpo,
            ),
          for (final c in correcoes)
            Container(
              key: Key('correcao_${c.id}'),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: cores.hairline)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_produto(c.produtoId),
                      style: textos.corpo.copyWith(fontWeight: FontWeight.w600)),
                  Text(
                    c.tipo == 'contagem'
                        ? 'contado ${c.de == null ? '-' : qtd(c.de!)} → ${c.para == null ? '-' : qtd(c.para!)}'
                        : 'decisão: ${c.acao ?? ''}',
                    style: textos.corpo,
                  ),
                  Text(
                    [
                      _hora(c.criadoEm),
                      if (c.operadorNome != null) c.operadorNome!,
                      c.origem,
                      if (c.motivo != null && c.motivo!.isNotEmpty) c.motivo!,
                    ].join(' · '),
                    style: textos.apoio,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Text('ETAPAS', style: textos.rotulo.copyWith(color: cores.aco)),
          const SizedBox(height: 8),
          if (resumo.etiquetas.impressasEm != null)
            Text('${_hora(resumo.etiquetas.impressasEm)} · etiquetas impressas',
                style: textos.corpo),
          if (resumo.etiquetas.puladas)
            Text('Etiquetas puladas (já etiquetado)', style: textos.corpo),
          Text('${qtd(resumo.totalContado)} peças contadas',
              style: textos.corpo),
        ],
      ),
    );
  }
}
