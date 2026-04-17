import 'package:core/imagens.dart';
import 'package:flutter/material.dart';
import 'package:produtos/presentantion/widgets/cor_seletor.dart';
import 'package:produtos/presentantion/widgets/tamanho_seletor.dart';

class ReferenciaMidiaMetadados {
  final List<Imagem> imagens;

  const ReferenciaMidiaMetadados({required this.imagens});
}

class ReferenciaMidiaMetadadosModal extends StatefulWidget {
  final List<Imagem> imagens;

  const ReferenciaMidiaMetadadosModal({super.key, required this.imagens});

  static Future<ReferenciaMidiaMetadados?> show(
    BuildContext context, {
    required List<Imagem> imagens,
  }) {
    return showModalBottomSheet<ReferenciaMidiaMetadados?>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReferenciaMidiaMetadadosModal(imagens: imagens),
    );
  }

  @override
  State<ReferenciaMidiaMetadadosModal> createState() =>
      _ReferenciaMidiaMetadadosModalState();
}

class _ReferenciaMidiaMetadadosModalState
    extends State<ReferenciaMidiaMetadadosModal> {
  late final List<TextEditingController> _descricaoControllers;
  late final List<Imagem> _imagens;

  @override
  void initState() {
    super.initState();
    _imagens = List<Imagem>.from(widget.imagens);
    _descricaoControllers = _imagens
        .map((imagem) => TextEditingController(text: imagem.descricao ?? ''))
        .toList();
  }

  @override
  void dispose() {
    for (final controller in _descricaoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _removerImagem(int index) {
    final controller = _descricaoControllers.removeAt(index);
    controller.dispose();
    setState(() {
      _imagens.removeAt(index);
    });
  }

  void _atualizarCorImagem(int index, String? cor) {
    setState(() {
      _imagens[index] = _imagens[index].copyWith(cor: cor);
    });
  }

  void _atualizarTamanhoImagem(int index, String? tamanho) {
    setState(() {
      _imagens[index] = _imagens[index].copyWith(tamanho: tamanho);
    });
  }

  void _confirmar() {
    final imagensAtualizadas = <Imagem>[];

    for (var i = 0; i < _imagens.length; i++) {
      final descricao = _descricaoControllers[i].text.trim();
      imagensAtualizadas.add(
        _imagens[i].copyWith(descricao: descricao.isEmpty ? null : descricao),
      );
    }

    Navigator.of(
      context,
    ).pop(ReferenciaMidiaMetadados(imagens: imagensAtualizadas));
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.9),
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
                    'Informações das imagens',
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
            Text(
              'Revise ${_imagens.length} imagem(ns), preencha as informações desejadas e confirme o envio.',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: _imagens.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Nenhuma imagem selecionada.'),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _imagens.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return _ImagemPendenteCard(
                          key: ValueKey(_imagens[index].path ?? index),
                          imagem: _imagens[index],
                          descricaoController: _descricaoControllers[index],
                          onRemover: () => _removerImagem(index),
                          onCorChanged: (cor) =>
                              _atualizarCorImagem(index, cor),
                          onTamanhoChanged: (tamanho) =>
                              _atualizarTamanhoImagem(index, tamanho),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _imagens.isEmpty ? null : _confirmar,
              child: const Text('Confirmar envio'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagemPendenteCard extends StatelessWidget {
  final Imagem imagem;
  final TextEditingController descricaoController;
  final VoidCallback onRemover;
  final ValueChanged<String?> onCorChanged;
  final ValueChanged<String?> onTamanhoChanged;

  const _ImagemPendenteCard({
    super.key,
    required this.imagem,
    required this.descricaoController,
    required this.onRemover,
    required this.onCorChanged,
    required this.onTamanhoChanged,
  });

  @override
  Widget build(BuildContext context) {
    final nomeArquivo = (imagem.path ?? imagem.url ?? 'Arquivo sem nome')
        .split(RegExp(r'[\\/]'))
        .last;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 72,
                height: 72,
                color: Colors.black12,
                child: imagem.bytes != null
                    ? Image.memory(
                        imagem.bytes!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image),
                      )
                    : const Icon(Icons.image),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nomeArquivo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descricaoController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição da imagem',
                      hintText: 'Ex: Vista frontal, detalhe do bordado...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  CorSeletor(
                    modo: CorSeletorModo.unica,
                    titulo: 'Cor (opcional)',
                    onCorChanged: (cores) {
                      onCorChanged(cores.firstOrNull?.nome);
                    },
                  ),
                  const SizedBox(height: 8),
                  TamanhoSeletor(
                    modo: TamanhoSeletorModo.unica,
                    titulo: 'Tamanho (opcional)',
                    onTamanhosChanged: (tamanhos) {
                      onTamanhoChanged(tamanhos.firstOrNull?.nome);
                    },
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemover,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Remover da lista',
            ),
          ],
        ),
      ),
    );
  }
}
