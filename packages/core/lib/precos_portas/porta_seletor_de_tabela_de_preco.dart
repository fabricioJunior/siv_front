import 'package:core/seletores.dart';
import 'package:flutter/widgets.dart';

abstract class PortaSeletorDeTabelaDePreco {
  Widget seletorUnico({required ValueChanged<List<SelectData>> onChanged});
}
