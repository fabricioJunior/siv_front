import 'package:comercial/models.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

String brl(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

/// Faixa de três valores (Total/Confirmado/Aguardando ou Previsto/Recebido/Falta).
class FaixaValores extends StatelessWidget {
  final List<(String, double)> valores;

  const FaixaValores({super.key, required this.valores});

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    return SivCard(
      child: Row(
        children: [
          for (final (rotulo, valor) in valores)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rotulo.toUpperCase(), style: textos.rotulo),
                  Text(brl(valor), style: textos.valor),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Linhas de pagamento navegáveis por ↑↓ (compartilhado por Confirmação e Acerto).
/// [acaoLinha] devolve os botões/estado da linha; Enter e Espaço chamam [onEnter]/[onEspaco].
class LinhasPagamento extends StatefulWidget {
  final List<PedidoPagamento> pagamentos;
  final Map<int, String> formas;
  final Widget Function(PedidoPagamento pagamento, bool selecionada) construirLinha;
  final void Function(PedidoPagamento pagamento)? onEnter;
  final void Function(PedidoPagamento pagamento)? onEspaco;

  const LinhasPagamento({
    super.key,
    required this.pagamentos,
    required this.formas,
    required this.construirLinha,
    this.onEnter,
    this.onEspaco,
  });

  @override
  State<LinhasPagamento> createState() => _LinhasPagamentoState();
}

class _LinhasPagamentoState extends State<LinhasPagamento> {
  int _sel = 0;
  final _foco = FocusNode(debugLabel: 'linhas_pagamento');

  // A página já tem foco (atalhos globais); a lista o toma ao montar para ↑↓/Enter/Espaço.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _foco.requestFocus();
    });
  }

  @override
  void dispose() {
    _foco.dispose();
    super.dispose();
  }

  // Lê widget/_sel na hora do evento: o onKeyEvent de um FocusNode externo não é atualizado
  // a cada build.
  KeyEventResult _tecla(KeyEvent e) {
    final lista = widget.pagamentos;
    if (e is! KeyDownEvent || lista.isEmpty) return KeyEventResult.ignored;
    final sel = _sel.clamp(0, lista.length - 1);
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.arrowDown) {
      setState(() => _sel = (sel + 1).clamp(0, lista.length - 1));
    } else if (k == LogicalKeyboardKey.arrowUp) {
      setState(() => _sel = (sel - 1).clamp(0, lista.length - 1));
    } else if (k == LogicalKeyboardKey.enter && widget.onEnter != null) {
      widget.onEnter!(lista[sel]);
    } else if (k == LogicalKeyboardKey.space && widget.onEspaco != null) {
      widget.onEspaco!(lista[sel]);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final lista = widget.pagamentos;
    final sel = lista.isEmpty ? 0 : _sel.clamp(0, lista.length - 1);
    return Focus(
      focusNode: _foco..onKeyEvent = (_, e) => _tecla(e),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < lista.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            widget.construirLinha(lista[i], i == sel),
          ],
        ],
      ),
    );
  }
}

Widget moldeLinhaPagamento(
  BuildContext context, {
  required bool selecionada,
  required Widget conteudo,
}) {
  final cores = context.sivColors;
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: cores.superficie,
      border: Border.all(color: selecionada ? cores.aco : cores.hairline, width: selecionada ? 2 : 1),
      borderRadius: BorderRadius.circular(SivDimensoes.raio),
    ),
    child: conteudo,
  );
}

/// Etapa Confirmação (T3/T4): uma linha por pagamento. Manual confirma na linha (Enter);
/// online não tem botão de confirmar -- aguarda o cliente (webhook), com copiar link e trocar forma.
class EtapaConfirmacao extends StatelessWidget {
  final List<PedidoPagamento> pagamentos;
  final Map<int, String> formas;
  final double total;
  final bool carregando;
  final void Function(PedidoPagamento) onConfirmar;
  final void Function(PedidoPagamento) onTrocarForma;
  final void Function(String link) onCopiarLink;

  const EtapaConfirmacao({
    super.key,
    required this.pagamentos,
    required this.formas,
    required this.total,
    required this.carregando,
    required this.onConfirmar,
    required this.onTrocarForma,
    required this.onCopiarLink,
  });

  static String? linkDe(PedidoPagamento p) {
    final c = p.cobranca;
    return c?.urlPagamentoAvulsoSiteEmpresa ?? c?.urlDePagamento ?? c?.chavePixCopiaECola;
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    final confirmado = pagamentos
        .where((p) => p.confirmadoEm != null)
        .fold<double>(0, (s, p) => s + (p.valorConfirmado ?? p.valorEsperado ?? 0));
    final aguardando = (total - confirmado) > 0 ? total - confirmado : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FaixaValores(valores: [
          ('Total', total),
          ('Confirmado', confirmado),
          ('Aguardando', aguardando),
        ]),
        const SizedBox(height: 12),
        LinhasPagamento(
          pagamentos: pagamentos,
          formas: formas,
          onEnter: (p) {
            if (p.confirmadoEm == null && p.tipo != 'controlado' && !carregando) {
              onConfirmar(p);
            }
          },
          construirLinha: (p, sel) {
            final ok = p.confirmadoEm != null;
            final online = p.tipo == 'controlado';
            final link = linkDe(p);
            final nome = formas[p.formaDePagamentoId] ?? 'Forma #${p.formaDePagamentoId ?? '-'}';
            return moldeLinhaPagamento(
              context,
              selecionada: sel,
              conteudo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nome, style: textos.corpo.copyWith(fontWeight: FontWeight.w600)),
                            Text(
                              ok
                                  ? 'Confirmado · ${brl(p.valorConfirmado ?? p.valorEsperado ?? 0)}'
                                  : (online
                                      ? 'Aguardando cliente · ${brl(p.valorEsperado ?? 0)}'
                                      : 'Aguardando confirmação · ${brl(p.valorEsperado ?? 0)}'),
                              style: textos.apoio,
                            ),
                          ],
                        ),
                      ),
                      if (ok) const Icon(Icons.check_circle_outline, size: 20),
                      if (!ok && !online)
                        OutlinedButton(
                          key: Key('confirmar_pagamento_${p.id}'),
                          onPressed: carregando ? null : () => onConfirmar(p),
                          child: const Text('Confirmar · Enter'),
                        ),
                      if (!ok && online && link != null && p.estoqueDisponivel != false)
                        OutlinedButton(
                          key: Key('copiar_link_${p.id}'),
                          onPressed: () => onCopiarLink(link),
                          child: const Text('Copiar link · Ctrl+L'),
                        ),
                      if (!ok) ...[
                        const SizedBox(width: 8),
                        TextButton(
                          key: Key('trocar_forma_${p.id}'),
                          onPressed: carregando ? null : () => onTrocarForma(p),
                          child: const Text('Trocar forma'),
                        ),
                      ],
                    ],
                  ),
                  if (!ok && online && p.estoqueDisponivel == false) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Sem estoque suficiente pra concluir esse pedido agora -- o link de '
                      'pagamento não foi liberado. Verifique o estoque antes de enviar ao cliente.',
                      style: textos.apoio.copyWith(color: cores.vinho),
                    ),
                  ],
                  if (!ok && online && link != null && p.estoqueDisponivel != false) ...[
                    const SizedBox(height: 6),
                    SelectableText(link, style: textos.apoio),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
