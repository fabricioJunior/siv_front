import 'package:comercial/models.dart';
import 'package:comercial/presentation/pages/pedido/etapa_confirmacao.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Etapa Acerto (T5): o entregador recebeu? Marca-se cada forma prevista (Espaço/Enter); o F9
/// "Fechar acerto e faturar" confirma as marcadas, confirma a entrega e fatura.
class EtapaAcerto extends StatelessWidget {
  final List<PedidoPagamento> pagamentos;
  final Map<int, String> formas;
  final Set<int> marcados;
  final bool carregando;
  final void Function(PedidoPagamento) onAlternar;
  final VoidCallback onAlterarFormas;

  const EtapaAcerto({
    super.key,
    required this.pagamentos,
    required this.formas,
    required this.marcados,
    required this.carregando,
    required this.onAlternar,
    required this.onAlterarFormas,
  });

  static double valorRecebido(PedidoPagamento p) =>
      p.confirmadoEm != null ? (p.valorConfirmado ?? p.valorEsperado ?? 0) : (p.valorEsperado ?? 0);

  static double faltaDe(List<PedidoPagamento> pagamentos, Set<int> marcados) {
    var previsto = 0.0, recebido = 0.0;
    for (final p in pagamentos) {
      previsto += p.valorEsperado ?? 0;
      if (p.confirmadoEm != null || marcados.contains(p.id)) recebido += valorRecebido(p);
    }
    return previsto - recebido;
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final previsto = pagamentos.fold<double>(0, (s, p) => s + (p.valorEsperado ?? 0));
    final falta = faltaDe(pagamentos, marcados);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FaixaValores(valores: [
          ('Previsto', previsto),
          ('Recebido', previsto - falta),
          ('Falta', falta > 0.005 ? falta : 0),
        ]),
        const SizedBox(height: 12),
        LinhasPagamento(
          pagamentos: pagamentos,
          formas: formas,
          onEnter: (p) => p.confirmadoEm == null ? onAlternar(p) : null,
          onEspaco: (p) => p.confirmadoEm == null ? onAlternar(p) : null,
          construirLinha: (p, sel) {
            final ok = p.confirmadoEm != null || marcados.contains(p.id);
            final nome = formas[p.formaDePagamentoId] ?? 'Forma #${p.formaDePagamentoId ?? '-'}';
            return moldeLinhaPagamento(
              context,
              selecionada: sel,
              conteudo: InkWell(
                key: Key('acerto_linha_${p.id}'),
                onTap: p.confirmadoEm == null && !carregando ? () => onAlternar(p) : null,
                child: Row(
                  children: [
                    Icon(ok ? Icons.check_box : Icons.check_box_outline_blank, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nome, style: textos.corpo.copyWith(fontWeight: FontWeight.w600)),
                          Text(
                            '${brl(p.valorEsperado ?? 0)}'
                            '${p.valorParaTroco != null ? ' · troco para ${brl(p.valorParaTroco!)}' : ''}',
                            style: textos.apoio,
                          ),
                        ],
                      ),
                    ),
                    Text(p.confirmadoEm != null ? 'Recebido' : (ok ? 'Recebido · Espaço' : 'Receber · Espaço'),
                        style: textos.rotulo),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: Text('Cliente pagou de outro jeito?', style: textos.apoio)),
            TextButton(
              key: const Key('acerto_alterar_formas'),
              onPressed: carregando ? null : onAlterarFormas,
              child: const Text('Alterar formas · F6'),
            ),
          ],
        ),
      ],
    );
  }
}
