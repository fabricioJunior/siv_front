import 'package:flutter/material.dart';

import '../tema.dart';

/// Uma opção de [SivComboBox]. Itens sem permissão ficam visíveis e
/// desabilitados via [habilitada] -- quem decide isso é o chamador.
class SivComboBoxItem<T> {
  final T valor;
  final String label;
  final bool habilitada;

  const SivComboBoxItem({
    required this.valor,
    required this.label,
    this.habilitada = true,
  });
}

/// Lista fechada de opções. O item selecionado é marcado por uma barra de
/// 3px à esquerda e fundo `#F0F5FA` -- nunca por um check colorido.
class SivComboBox<T> extends StatelessWidget {
  final List<SivComboBoxItem<T>> itens;
  final T? selecionado;
  final ValueChanged<T> onSelecionado;

  const SivComboBox({
    super.key,
    required this.itens,
    required this.onSelecionado,
    this.selecionado,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return Container(
      decoration: BoxDecoration(
        color: cores.superficie,
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
        border: Border.all(color: cores.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in itens)
            _SivComboBoxOpcao(
              item: item,
              selecionada: item.valor == selecionado,
              corBarra: cores.aco,
              corFundoSelecionado: cores.selecaoFundo,
              textoEstilo: textos.corpo,
              onTap: item.habilitada
                  ? () => onSelecionado(item.valor)
                  : null,
              corDesabilitada: cores.textoDesabilitado,
            ),
        ],
      ),
    );
  }
}

class _SivComboBoxOpcao<T> extends StatelessWidget {
  final SivComboBoxItem<T> item;
  final bool selecionada;
  final Color corBarra;
  final Color corFundoSelecionado;
  final TextStyle textoEstilo;
  final Color corDesabilitada;
  final VoidCallback? onTap;

  const _SivComboBoxOpcao({
    required this.item,
    required this.selecionada,
    required this.corBarra,
    required this.corFundoSelecionado,
    required this.textoEstilo,
    required this.corDesabilitada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selecionada ? corFundoSelecionado : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: SivDimensoes.alvoToqueMinimo,
          ),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: selecionada ? corBarra : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          alignment: Alignment.centerLeft,
          child: Text(
            item.label,
            style: textoEstilo.copyWith(
              color: item.habilitada ? null : corDesabilitada,
            ),
          ),
        ),
      ),
    );
  }
}
