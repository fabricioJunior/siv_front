import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/widgets/cor_seletor.dart';
import 'package:produtos/presentantion/widgets/tamanho_seletor.dart';

class ReferenciaMidiaMetadados {
  final String? descricao;
  final Cor? cor;
  final Tamanho? tamanho;

  const ReferenciaMidiaMetadados({this.descricao, this.cor, this.tamanho});
}

class ReferenciaMidiaMetadadosModal extends StatefulWidget {
  const ReferenciaMidiaMetadadosModal({super.key});

  static Future<ReferenciaMidiaMetadados?> show(BuildContext context) {
    return showModalBottomSheet<ReferenciaMidiaMetadados?>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ReferenciaMidiaMetadadosModal(),
    );
  }

  @override
  State<ReferenciaMidiaMetadadosModal> createState() =>
      _ReferenciaMidiaMetadadosModalState();
}

class _ReferenciaMidiaMetadadosModalState
    extends State<ReferenciaMidiaMetadadosModal> {
  final _descricaoController = TextEditingController();
  Cor? _corSelecionada;
  Tamanho? _tamanhoSelecionado;

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  void _confirmar() {
    final descricao = _descricaoController.text.trim();
    Navigator.of(context).pop(
      ReferenciaMidiaMetadados(
        descricao: descricao.isEmpty ? null : descricao,
        cor: _corSelecionada,
        tamanho: _tamanhoSelecionado,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Informações da mídia',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Todos os campos são opcionais.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Ex: Vista frontal, detalhe do bordado...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            CorSeletor(
              modo: CorSeletorModo.unica,
              titulo: 'Cor associada (opcional)',
              coresSelecionadasIniciais: _corSelecionada != null
                  ? [_corSelecionada!]
                  : [],
              onCorChanged: (cores) {
                setState(() {
                  _corSelecionada = cores.firstOrNull;
                });
              },
            ),
            const SizedBox(height: 12),
            TamanhoSeletor(
              modo: TamanhoSeletorModo.unica,
              titulo: 'Tamanho associado (opcional)',
              tamanhosSelecionadosIniciais: _tamanhoSelecionado != null
                  ? [_tamanhoSelecionado!]
                  : [],
              onTamanhosChanged: (tamanhos) {
                setState(() {
                  _tamanhoSelecionado = tamanhos.firstOrNull;
                });
              },
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _confirmar, child: const Text('Confirmar')),
          ],
        ),
      ),
    );
  }
}
