import 'package:flutter/material.dart';

import '../tema.dart';

enum SivDialogoVariante { confirmacao, destrutivo, autorizacao }

/// Diálogo do design system: largura máxima 460px, backdrop aço escuro a
/// 35%, título, corpo, botão de saída à esquerda e ação primária à
/// direita.
class SivDialogo extends StatefulWidget {
  final String titulo;
  final Widget corpo;
  final SivDialogoVariante variante;
  final String textoSaida;
  final String textoAcao;

  /// Código do componente de permissão exigido -- só usado para exibição
  /// na variante [SivDialogoVariante.autorizacao]; a validação em si é
  /// responsabilidade de quem chama.
  final String? codigoPermissao;

  /// Chamado ao confirmar. Recebe o motivo (variante destrutivo) ou a
  /// senha do gerente (variante autorização); `null` nas demais.
  final void Function(String? valor) onConfirmar;
  final VoidCallback? onSair;

  const SivDialogo({
    super.key,
    required this.titulo,
    required this.corpo,
    required this.onConfirmar,
    this.variante = SivDialogoVariante.confirmacao,
    this.textoSaida = 'Cancelar',
    this.textoAcao = 'Confirmar',
    this.codigoPermissao,
    this.onSair,
  });

  /// Abre o diálogo sobre o backdrop aço escuro a 35% (nunca preto puro).
  static Future<void> mostrar(
    BuildContext context, {
    required String titulo,
    required Widget corpo,
    required void Function(String? valor) onConfirmar,
    SivDialogoVariante variante = SivDialogoVariante.confirmacao,
    String textoSaida = 'Cancelar',
    String textoAcao = 'Confirmar',
    String? codigoPermissao,
    VoidCallback? onSair,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: context.sivColors.acoEscuro.withValues(alpha: 0.35),
      builder: (_) => SivDialogo(
        titulo: titulo,
        corpo: corpo,
        onConfirmar: onConfirmar,
        variante: variante,
        textoSaida: textoSaida,
        textoAcao: textoAcao,
        codigoPermissao: codigoPermissao,
        onSair: onSair,
      ),
    );
  }

  @override
  State<SivDialogo> createState() => _SivDialogoState();
}

class _SivDialogoState extends State<SivDialogo> {
  final _motivoController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _motivoController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final destrutivo = widget.variante == SivDialogoVariante.destrutivo;
    final autorizacao = widget.variante == SivDialogoVariante.autorizacao;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(SivDimensoes.paddingCard),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.titulo, style: textos.secao),
              const SizedBox(height: 12),
              widget.corpo,
              if (destrutivo) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _motivoController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Motivo (obrigatório)',
                  ),
                ),
              ],
              if (autorizacao) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _senhaController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha do gerente',
                    helperText: widget.codigoPermissao != null
                        ? 'Permissão exigida: ${widget.codigoPermissao}'
                        : null,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      widget.onSair?.call();
                      Navigator.of(context).pop();
                    },
                    child: Text(widget.textoSaida),
                  ),
                  const Spacer(),
                  destrutivo
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cores.vinho,
                          ),
                          onPressed: _motivoController.text.trim().isEmpty
                              ? null
                              : () => _confirmar(context),
                          child: Text(widget.textoAcao),
                        )
                      : ElevatedButton(
                          onPressed: () => _confirmar(context),
                          child: Text(widget.textoAcao),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmar(BuildContext context) {
    final valor = switch (widget.variante) {
      SivDialogoVariante.destrutivo => _motivoController.text.trim(),
      SivDialogoVariante.autorizacao => _senhaController.text,
      SivDialogoVariante.confirmacao => null,
    };
    widget.onConfirmar(valor);
    Navigator.of(context).pop();
  }
}
