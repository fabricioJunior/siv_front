import 'package:flutter/material.dart';

import '../tema.dart';
import 'generic_seletor.dart';

/// Campo "fechado" (ícone + valor selecionado + chevron) que abre a busca
/// real -- o [SeletorGenerico] passado em [seletor] -- num
/// `showModalBottomSheet` ao ser tocado. Não reimplementa busca/filtro:
/// [seletor] já traz toda a configuração (itens, callbacks, labels); esse
/// widget só decide como/quando exibi-lo.
class SeletorGenericoCompacto<T> extends StatefulWidget {
  final SeletorGenerico<T> seletor;

  const SeletorGenericoCompacto({super.key, required this.seletor});

  @override
  State<SeletorGenericoCompacto<T>> createState() =>
      _SeletorGenericoCompactoState<T>();
}

class _SeletorGenericoCompactoState<T>
    extends State<SeletorGenericoCompacto<T>> {
  late List<T> _selecionados;

  @override
  void initState() {
    super.initState();
    _selecionados = List<T>.from(widget.seletor.selecionadosIniciais);
  }

  @override
  void didUpdateWidget(covariant SeletorGenericoCompacto<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_mesmaListaPorChave(
      oldWidget.seletor.selecionadosIniciais,
      widget.seletor.selecionadosIniciais,
    )) {
      setState(() {
        _selecionados = List<T>.from(widget.seletor.selecionadosIniciais);
      });
    }
  }

  Object? _itemKey(T item) =>
      widget.seletor.itemKey?.call(item) ?? widget.seletor.itemLabel(item);

  bool _mesmaListaPorChave(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (_itemKey(a[i]) != _itemKey(b[i])) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final seletor = widget.seletor;
    final emErro = seletor.mensagemErro != null;
    final selecionado = _selecionados.isEmpty ? null : _selecionados.first;
    final temSelecao = selecionado != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: seletor.onlyView ? null : () => _abrirSeletor(context),
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: temSelecao ? cores.selecaoFundo : cores.superficie,
              borderRadius: BorderRadius.circular(SivDimensoes.raio),
              border: Border.all(
                color: emErro
                    ? cores.vinho
                    : temSelecao
                        ? cores.aco
                        : cores.hairline,
                width: temSelecao || emErro ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                IconTheme(
                  data: IconThemeData(
                    size: 17,
                    color: temSelecao ? cores.aco : cores.textoDesabilitado,
                  ),
                  child: selecionado != null
                      ? (seletor.chipAvatarBuilder?.call(
                            context,
                            selecionado,
                          ) ??
                          const Icon(Icons.check_circle_outline))
                      : const Icon(Icons.search),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    temSelecao
                        ? seletor.itemLabel(selecionado)
                        : seletor.hintText,
                    style: temSelecao
                        ? textos.corpo.copyWith(fontWeight: FontWeight.w600)
                        : textos.corpo.copyWith(color: cores.textoDesabilitado),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!seletor.onlyView)
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 15,
                    color: cores.textoDesabilitado,
                  ),
              ],
            ),
          ),
        ),
        if (emErro) ...[
          const SizedBox(height: 4),
          Text(
            seletor.mensagemErro!,
            style: textos.apoio.copyWith(color: cores.vinho),
          ),
        ],
      ],
    );
  }

  Future<void> _abrirSeletor(BuildContext context) {
    final seletor = widget.seletor;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalContext).viewInsets.bottom,
          ),
          child: FractionallySizedBox(
            heightFactor: 0.85,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SeletorGenerico<T>(
                  itens: seletor.itens,
                  itemLabel: seletor.itemLabel,
                  toSelectData: seletor.toSelectData,
                  itemKey: seletor.itemKey,
                  modo: seletor.modo,
                  selecionadosIniciais: _selecionados,
                  onChanged: (selecionados) {
                    setState(() => _selecionados = selecionados);
                    seletor.onChanged?.call(selecionados);
                    if (seletor.modo == SeletorGenericoModo.unica) {
                      Navigator.of(modalContext).pop();
                    }
                  },
                  titulo: seletor.titulo,
                  hintText: seletor.hintText,
                  maxSugestoes: seletor.maxSugestoes,
                  chipAvatarBuilder: seletor.chipAvatarBuilder,
                  sugestaoLeadingBuilder: seletor.sugestaoLeadingBuilder,
                  sugestaoTrailingBuilder: seletor.sugestaoTrailingBuilder,
                  confirmarEmSeparadores: seletor.confirmarEmSeparadores,
                  onCadastrarPressed: seletor.onCadastrarPressed,
                  cadastrarLabel: seletor.cadastrarLabel,
                  onBuscaChanged: seletor.onBuscaChanged,
                  mensagemErro: seletor.mensagemErro,
                  onlyView: seletor.onlyView,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
