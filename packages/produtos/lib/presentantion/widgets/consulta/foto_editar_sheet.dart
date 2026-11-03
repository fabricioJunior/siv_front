import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/widgets/consulta/foto_associacao_form.dart';

enum FotoEdicaoAcao { salvar, excluir }

class FotoEdicao {
  final FotoEdicaoAcao acao;
  final AssociacaoFoto associacao;
  final String? descricao;

  const FotoEdicao(this.acao, this.associacao, this.descricao);
}

/// Folha de edição de uma foto: cor, estampa, tamanho, descrição e excluir
/// (dois toques para confirmar).
class FotoEditarSheet extends StatefulWidget {
  final ReferenciaMidia midia;
  final OpcoesAssociacaoFoto opcoes;

  const FotoEditarSheet({super.key, required this.midia, required this.opcoes});

  static Future<FotoEdicao?> show(
    BuildContext context, {
    required ReferenciaMidia midia,
    required OpcoesAssociacaoFoto opcoes,
  }) => showModalBottomSheet<FotoEdicao>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => FotoEditarSheet(midia: midia, opcoes: opcoes),
  );

  @override
  State<FotoEditarSheet> createState() => _FotoEditarSheetState();
}

class _FotoEditarSheetState extends State<FotoEditarSheet> {
  late AssociacaoFoto _a = widget.opcoes.preencher(widget.midia.associacao);
  late final _descricao = TextEditingController(text: widget.midia.descricao);
  bool _confirmaExcluir = false;
  bool _erros = false;

  @override
  void dispose() {
    _descricao.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!widget.opcoes.valida(_a)) {
      setState(() => _erros = true);
      return;
    }
    final d = _descricao.text.trim();
    Navigator.of(context).pop(
      FotoEdicao(FotoEdicaoAcao.salvar, _a, d.isEmpty ? null : d),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16, 16, 16, 16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Editar foto', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            FotoAssociacaoForm(
              opcoes: widget.opcoes,
              valor: _a,
              mostrarErros: _erros,
              onChanged: (v) => setState(() => _a = v),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descricao,
              decoration: const InputDecoration(labelText: 'Descrição', isDense: true),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: cs.error),
                  onPressed: _confirmaExcluir
                      ? () => Navigator.of(context).pop(
                          FotoEdicao(FotoEdicaoAcao.excluir, _a, null),
                        )
                      : () => setState(() => _confirmaExcluir = true),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(_confirmaExcluir ? 'Toque de novo para excluir' : 'Excluir foto'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _salvar, child: const Text('Salvar')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
