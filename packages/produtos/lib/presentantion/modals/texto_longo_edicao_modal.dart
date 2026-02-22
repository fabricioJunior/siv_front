import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/presentation.dart';

import '../blocs/texto_longo_edicao_bloc/texto_longo_edicao_bloc.dart';

class TextoLongoEdicaoModal extends StatefulWidget {
  final String titulo;
  final String hintText;
  final String textoInicial;

  const TextoLongoEdicaoModal({
    super.key,
    required this.titulo,
    required this.hintText,
    required this.textoInicial,
  });

  static Future<String?> show({
    required BuildContext context,
    required String titulo,
    required String hintText,
    required String textoInicial,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => TextoLongoEdicaoModal(
        titulo: titulo,
        hintText: hintText,
        textoInicial: textoInicial,
      ),
    );
  }

  @override
  State<TextoLongoEdicaoModal> createState() => _TextoLongoEdicaoModalState();
}

class _TextoLongoEdicaoModalState extends State<TextoLongoEdicaoModal> {
  late final TextEditingController _textoController;

  @override
  void initState() {
    super.initState();
    _textoController = TextEditingController(text: widget.textoInicial);
  }

  @override
  void dispose() {
    _textoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TextoLongoEdicaoBloc>(
      create: (_) => sl<TextoLongoEdicaoBloc>()
        ..add(
          TextoLongoEdicaoIniciou(
            titulo: widget.titulo,
            hintText: widget.hintText,
            textoInicial: widget.textoInicial,
          ),
        ),
      child: BlocConsumer<TextoLongoEdicaoBloc, TextoLongoEdicaoState>(
        listener: (context, state) {
          if (_textoController.text != state.texto) {
            _textoController.text = state.texto;
            _textoController.selection = TextSelection.collapsed(
              offset: _textoController.text.length,
            );
          }
        },
        builder: (context, state) {
          return AlertDialog(
            title: Text(state.titulo),
            content: SizedBox(
              width: 560,
              child: TextFormField(
                controller: _textoController,
                autofocus: true,
                minLines: 10,
                maxLines: 18,
                decoration: InputDecoration(
                  hintText: state.hintText,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  context.read<TextoLongoEdicaoBloc>().add(
                    TextoLongoEdicaoTextoAlterado(texto: value),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  context.read<TextoLongoEdicaoBloc>().add(
                    const TextoLongoEdicaoLimparSolicitado(),
                  );
                },
                child: const Text('Limpar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(state.texto);
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
