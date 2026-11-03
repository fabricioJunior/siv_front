import 'package:core/bloc.dart';
import 'package:flutter/material.dart';
import 'package:leitor_camera/leitor_camera.dart';
import 'package:produtos/presentantion/blocs/consultar_produto_bloc/consultar_produto_bloc.dart';

/// Diálogo desktop "Ler código de barras": leitor USB/teclado ou câmera.
class LerCodigoDialog extends StatefulWidget {
  const LerCodigoDialog({super.key});

  static Future<void> show(BuildContext context) {
    final bloc = context.read<ConsultarProdutoBloc>()..add(ConsultarProdutoLeituraReiniciada());
    return showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(value: bloc, child: const LerCodigoDialog()),
    );
  }

  @override
  State<LerCodigoDialog> createState() => _LerCodigoDialogState();
}

class _LerCodigoDialogState extends State<LerCodigoDialog> {
  final _controller = TextEditingController();
  final _foco = FocusNode();
  bool _camera = false;
  String? _aviso;

  @override
  void dispose() {
    _controller.dispose();
    _foco.dispose();
    super.dispose();
  }

  void _enviar() {
    final codigo = _controller.text.trim();
    final leitura = context.read<ConsultarProdutoBloc>().state.leitura;
    if (codigo.isEmpty) {
      if (leitura?.encontrada == true) Navigator.of(context).pop();
    } else {
      context.read<ConsultarProdutoBloc>().add(ConsultarProdutoCodigoLido(codigo));
      _controller.clear();
    }
    _foco.requestFocus();
  }

  void _lidoPelaCamera(String codigo) {
    context.read<ConsultarProdutoBloc>().add(ConsultarProdutoCodigoLido(codigo));
    setState(() => _camera = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final leitura = context.watch<ConsultarProdutoBloc>().state.leitura;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Ler código de barras', style: theme.textTheme.titleMedium)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const SizedBox(height: 8),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, icon: Icon(Icons.keyboard_outlined), label: Text('Leitor USB / teclado')),
                  ButtonSegment(value: true, icon: Icon(Icons.photo_camera_outlined), label: Text('Câmera')),
                ],
                selected: {_camera},
                onSelectionChanged: (v) => setState(() {
                  _camera = v.first;
                  _aviso = null;
                }),
              ),
              const SizedBox(height: 16),
              if (_aviso != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_aviso!, style: TextStyle(color: theme.colorScheme.error)),
                ),
              if (_camera)
                SizedBox(
                  height: 280,
                  child: LeitorCameraView(
                    onCodigo: _lidoPelaCamera,
                    onPermissaoNegada: () => setState(() {
                      _camera = false;
                      _aviso = mensagemPermissaoNegada;
                    }),
                  ),
                )
              else ...[
                TextField(
                  controller: _controller,
                  focusNode: _foco,
                  autofocus: true,
                  style: theme.textTheme.headlineSmall,
                  decoration: const InputDecoration(
                    hintText: 'Bipe o código e tecle Enter',
                    prefixIcon: Icon(Icons.qr_code_scanner),
                  ),
                  onSubmitted: (_) => _enviar(),
                ),
                const SizedBox(height: 16),
                _Status(leitura: leitura, onAbrir: () => Navigator.of(context).pop()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Status extends StatelessWidget {
  final LeituraCodigo? leitura;
  final VoidCallback onAbrir;

  const _Status({required this.leitura, required this.onAbrir});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = leitura;
    if (l == null) {
      return Text('Aguardando leitura…', style: theme.textTheme.bodyMedium);
    }
    if (!l.encontrada) {
      return Text(
        'Código "${l.codigo}" não encontrado.',
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
      );
    }
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.descricao, style: theme.textTheme.titleSmall),
              Text('Saldo: ${l.saldo}', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
        FilledButton(onPressed: onAbrir, child: const Text('Abrir produto')),
      ],
    );
  }
}
