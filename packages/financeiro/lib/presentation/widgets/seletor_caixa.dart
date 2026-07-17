import 'package:core/seletores.dart';
import 'package:financeiro/domain/models/caixa_do_historico.dart';
import 'package:financeiro/presentation/pages/selecionar_caixa_page.dart';
import 'package:flutter/material.dart';

/// Seletor de caixa reutilizável. Ao ser tocado abre [SelecionarCaixaPage]
/// (caixas do dia atual por padrão, com opção de outro período) e devolve
/// a seleção via [ISeletor.onChanged] -- segue o mesmo contrato usado por
/// `FuncionarioSeletor`/`SeletorWidget`, permitindo injeção por qualquer
/// módulo sem depender diretamente do `financeiro`.
// ignore: must_be_immutable
class SeletorCaixa extends StatefulWidget implements ISeletor {
  final String titulo;
  final bool onlyView;

  @override
  final List<SelectData>? itemsSelecionadosInicial;

  @override
  final Function(List<SelectData>)? onChanged;

  const SeletorCaixa({
    super.key,
    this.itemsSelecionadosInicial,
    this.onChanged,
    this.titulo = 'Caixa',
    this.onlyView = false,
  });

  @override
  State<SeletorCaixa> createState() => _SeletorCaixaState();
}

class _SeletorCaixaState extends State<SeletorCaixa> {
  SelectData? _selecionado;

  @override
  void initState() {
    super.initState();
    _selecionado = widget.itemsSelecionadosInicial?.firstOrNull;
  }

  @override
  void didUpdateWidget(covariant SeletorCaixa oldWidget) {
    super.didUpdateWidget(oldWidget);
    final novoInicial = widget.itemsSelecionadosInicial?.firstOrNull;
    final atualId = oldWidget.itemsSelecionadosInicial?.firstOrNull?.id;
    if (novoInicial?.id != atualId) {
      setState(() => _selecionado = novoInicial);
    }
  }

  Future<void> _abrirSelecao() async {
    if (widget.onlyView) return;

    final caixa = await Navigator.of(context).push<CaixaDoHistorico>(
      MaterialPageRoute(builder: (_) => const SelecionarCaixaPage()),
    );
    if (caixa == null || !mounted) return;

    final selectData = _toSelectData(caixa);
    setState(() => _selecionado = selectData);
    widget.onChanged?.call([selectData]);
  }

  void _limpar() {
    setState(() => _selecionado = null);
    widget.onChanged?.call(const []);
  }

  SelectData _toSelectData(CaixaDoHistorico caixa) {
    return SelectData(
      id: caixa.id,
      nome: 'Caixa #${caixa.id}',
      data: {
        'terminalId': caixa.terminalId,
        'situacao': caixa.situacao.name,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.titulo, style: theme.textTheme.titleMedium),
        const SizedBox(height: 6),
        InkWell(
          onTap: widget.onlyView ? null : _abrirSelecao,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.point_of_sale_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selecionado?.nome ?? 'Selecionar caixa',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _selecionado == null
                          ? theme.colorScheme.onSurfaceVariant
                          : null,
                    ),
                  ),
                ),
                if (_selecionado != null && !widget.onlyView)
                  IconButton(
                    onPressed: _limpar,
                    icon: const Icon(Icons.close, size: 18),
                    tooltip: 'Limpar filtro de caixa',
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
