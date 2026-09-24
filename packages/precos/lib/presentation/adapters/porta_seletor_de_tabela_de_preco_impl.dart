import 'package:core/precos_portas.dart';
import 'package:core/seletores.dart';
import 'package:flutter/widgets.dart';
import 'package:precos/presentation/widgets/tabelas_de_preco_seletor.dart';

class PortaSeletorDeTabelaDePrecoImpl implements PortaSeletorDeTabelaDePreco {
  @override
  Widget seletorUnico({required ValueChanged<List<SelectData>> onChanged}) {
    return TabelasDePrecoSeletor(
      modo: TabelasDePrecoSeletorModo.unica,
      onChanged: onChanged,
    );
  }
}
