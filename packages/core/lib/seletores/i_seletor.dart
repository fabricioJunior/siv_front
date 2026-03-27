import 'dart:async';

import 'package:flutter/material.dart';

// ignore: must_be_immutable
abstract class ISeletor extends Widget {
  final StreamController<List<SelectData>>? controller =
      StreamController<List<SelectData>>.broadcast();

  Stream<List<SelectData>>? get onDataSelected => controller?.stream;

  final List<SelectData> itemsSelecionadosInicial;

  StreamController<List<SelectData>> get setDataController;

  void setDadosSelecionados(List<SelectData> dados);

  ISeletor({
    super.key,
    required this.itemsSelecionadosInicial,
  });
}

mixin SeletorMixin on Widget {
  final StreamController<List<SelectData>> setDataController =
      StreamController<List<SelectData>>.broadcast();

  void setDadosSelecionados(List<SelectData> dados) {
    setDataController.add(dados);
  }
}

class SelectData {
  final int id;
  final String nome;
  final Map<String, dynamic> data;

  SelectData({required this.id, required this.nome, required this.data});
}
