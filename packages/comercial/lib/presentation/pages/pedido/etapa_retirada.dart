import 'package:comercial/models.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Etapa Retirada (4c): código de 4 dígitos (foco na 1ª casa, confirma sozinho no 4º) e
/// "Retirar junto" com os outros pedidos pendentes do cliente. Sem código, só o F9.
class EtapaRetirada extends StatefulWidget {
  final bool exigeCodigo;
  final List<Pedido> pendentes;
  final Set<int> marcados;

  /// Mensagem do backend da última tentativa; ao mudar, limpa as casas.
  final String? erro;
  final bool carregando;
  final ValueChanged<String> onCodigo;
  final ValueChanged<String> onCompleto;
  final ValueChanged<int> onAlternarJunto;

  const EtapaRetirada({
    super.key,
    required this.exigeCodigo,
    required this.pendentes,
    required this.marcados,
    required this.erro,
    required this.carregando,
    required this.onCodigo,
    required this.onCompleto,
    required this.onAlternarJunto,
  });

  @override
  State<EtapaRetirada> createState() => _EtapaRetiradaState();
}

class _EtapaRetiradaState extends State<EtapaRetirada> {
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _nodes = List.generate(4, (_) => FocusNode());

  String get _codigo => _controllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    if (widget.exigeCodigo) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _nodes[0].requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(EtapaRetirada old) {
    super.didUpdateWidget(old);
    if (widget.erro != null && widget.erro != old.erro) {
      for (final c in _controllers) {
        c.clear();
      }
      // didUpdateWidget roda durante o build: avisar a tela depois do frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onCodigo('');
        _nodes[0].requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _mudou(int i, String v) {
    if (v.isNotEmpty && i < 3) _nodes[i + 1].requestFocus();
    final codigo = _codigo;
    widget.onCodigo(codigo);
    if (codigo.length == 4 && !widget.carregando) widget.onCompleto(codigo);
  }

  KeyEventResult _tecla(int i, KeyEvent e) {
    if (e is KeyDownEvent &&
        e.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[i].text.isEmpty &&
        i > 0) {
      _controllers[i - 1].clear();
      _nodes[i - 1].requestFocus();
      widget.onCodigo(_codigo);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SivCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CÓDIGO DE RETIRADA', style: textos.rotulo),
              const SizedBox(height: 10),
              if (widget.exigeCodigo) ...[
                Row(
                  children: [
                    for (var i = 0; i < 4; i++)
                      Container(
                        width: 56,
                        margin: const EdgeInsets.only(right: 10),
                        child: Focus(
                          onKeyEvent: (_, e) => _tecla(i, e),
                          child: TextField(
                            key: Key('retirada_digito_$i'),
                            controller: _controllers[i],
                            focusNode: _nodes[i],
                            enabled: !widget.carregando,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: textos.valor,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(counterText: ''),
                            onChanged: (v) => _mudou(i, v),
                          ),
                        ),
                      ),
                  ],
                ),
                if (widget.erro != null) ...[
                  const SizedBox(height: 8),
                  Text(widget.erro!, style: textos.apoio.copyWith(color: cores.vinho)),
                ],
              ] else
                Text(
                  'Retirada sem código de segurança: confirme com F9.',
                  style: textos.apoio,
                ),
            ],
          ),
        ),
        if (widget.pendentes.isNotEmpty) ...[
          const SizedBox(height: 12),
          SivCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RETIRAR JUNTO', style: textos.rotulo),
                const SizedBox(height: 4),
                Text(
                  'Outros pedidos do cliente aguardando retirada. Os marcados saem '
                  'junto, sem pedir o código de novo.',
                  style: textos.apoio,
                ),
                for (final p in widget.pendentes)
                  if (p.id != null)
                    InkWell(
                      key: Key('retirar_junto_${p.id}'),
                      onTap: () => widget.onAlternarJunto(p.id!),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              widget.marcados.contains(p.id)
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text('Pedido #${p.id}', style: textos.corpo)),
                            if (p.valorTotal != null)
                              Text(
                                'R\$ ${p.valorTotal!.toStringAsFixed(2).replaceAll('.', ',')}',
                                style: textos.apoio,
                              ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
