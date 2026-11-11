import 'package:core/imagens.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/widgets/consulta/foto_associacao_form.dart';
import 'package:produtos/presentantion/widgets/cor_seletor.dart';
import 'package:produtos/presentantion/widgets/tamanho_seletor.dart';

class ReferenciaMidiaMetadados {
  final List<Imagem> imagens;

  const ReferenciaMidiaMetadados({required this.imagens});
}

class ReferenciaMidiaMetadadosModal extends StatefulWidget {
  final List<Imagem> imagens;

  /// Quando informado (tela de consulta), cor/estampa/tamanho são obrigatórios e
  /// as opções vêm só da grade da referência.
  final OpcoesAssociacaoFoto? opcoes;

  const ReferenciaMidiaMetadadosModal({
    super.key,
    required this.imagens,
    this.opcoes,
  });

  static Future<ReferenciaMidiaMetadados?> show(
    BuildContext context, {
    required List<Imagem> imagens,
    OpcoesAssociacaoFoto? opcoes,
  }) {
    return showModalBottomSheet<ReferenciaMidiaMetadados?>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          ReferenciaMidiaMetadadosModal(imagens: imagens, opcoes: opcoes),
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
  bool _mostrarErros = false;

  AssociacaoFoto _associacao(Imagem i) =>
      AssociacaoFoto(cor: i.cor, estampa: i.estampa, tamanho: i.tamanho);

  void _atualizarAssociacao(int index, AssociacaoFoto a) {
    setState(() {
      _imagens[index] = _imagens[index].copyWith(
        cor: a.cor,
        estampa: a.estampa,
        tamanho: a.tamanho,
      );
    });
  }

  void _aplicarATodas() {
    final a = _associacao(_imagens.first);
    setState(() {
      for (var i = 1; i < _imagens.length; i++) {
        _imagens[i] = _imagens[i].copyWith(
          cor: a.cor,
          estampa: a.estampa,
          tamanho: a.tamanho,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _imagens = [
      for (final i in widget.imagens)
        if (widget.opcoes == null)
          i
        else
          _comAssociacao(i, widget.opcoes!.preencher(_associacao(i))),
    ];
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

  Imagem _comAssociacao(Imagem i, AssociacaoFoto a) =>
      i.copyWith(cor: a.cor, estampa: a.estampa, tamanho: a.tamanho);

  void _confirmar() {
    final opcoes = widget.opcoes;
    if (opcoes != null && _imagens.any((i) => !opcoes.valida(_associacao(i)))) {
      setState(() => _mostrarErros = true);
      return;
    }
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
                          opcoes: widget.opcoes,
                          mostrarErros: _mostrarErros,
                          onAssociacaoChanged: (a) =>
                              _atualizarAssociacao(index, a),
                          onRemover: () => _removerImagem(index),
                          onCorChanged: (cor) =>
                              _atualizarCorImagem(index, cor),
                          onTamanhoChanged: (tamanho) =>
                              _atualizarTamanhoImagem(index, tamanho),
                        );
                      },
                    ),
            ),
            if (widget.opcoes != null && _imagens.length > 1)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _aplicarATodas,
                  icon: const Icon(Icons.copy_all_outlined),
                  label: const Text('Aplicar a todas (da primeira foto)'),
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
  final OpcoesAssociacaoFoto? opcoes;
  final bool mostrarErros;
  final ValueChanged<AssociacaoFoto> onAssociacaoChanged;

  const _ImagemPendenteCard({
    super.key,
    required this.imagem,
    required this.descricaoController,
    required this.onRemover,
    required this.onCorChanged,
    required this.onTamanhoChanged,
    required this.opcoes,
    required this.mostrarErros,
    required this.onAssociacaoChanged,
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
                        cacheWidth: 216,
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
                  if (opcoes != null)
                    FotoAssociacaoForm(
                      opcoes: opcoes!,
                      valor: AssociacaoFoto(
                        cor: imagem.cor,
                        estampa: imagem.estampa,
                        tamanho: imagem.tamanho,
                      ),
                      mostrarErros: mostrarErros,
                      onChanged: onAssociacaoChanged,
                    )
                  else ...[
                  CorSeletor(
                    modo: CorSeletorModo.unica,
                    titulo: 'Cor (opcional)',
                    coresSelecionadasIniciais: imagem.cor == null
                        ? const []
                        : [_CorTemporaria(nome: imagem.cor!)],
                    onCorChanged: (cores) {
                      onCorChanged(cores.firstOrNull?.nome);
                    },
                  ),
                  const SizedBox(height: 8),
                  TamanhoSeletor(
                    modo: TamanhoSeletorModo.unica,
                    titulo: 'Tamanho (opcional)',
                    tamanhosSelecionadosIniciais: imagem.tamanho == null
                        ? const []
                        : [_TamanhoTemporario(nome: imagem.tamanho!)],
                    onTamanhosChanged: (tamanhos) {
                      onTamanhoChanged(tamanhos.firstOrNull?.nome);
                    },
                  ),
                  ],
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

class _CorTemporaria implements Cor {
  @override
  final int? id = null;

  @override
  final bool? inativo = false;

  @override
  final String nome;

  const _CorTemporaria({required this.nome});

  @override
  List<Object?> get props => [id, nome, inativo];

  @override
  bool? get stringify => true;
}

class _TamanhoTemporario implements Tamanho {
  @override
  final int? id = null;

  @override
  final bool inativo = false;

  @override
  final String nome;

  const _TamanhoTemporario({required this.nome});

  @override
  List<Object?> get props => [id, nome, inativo];

  @override
  bool? get stringify => true;
}
