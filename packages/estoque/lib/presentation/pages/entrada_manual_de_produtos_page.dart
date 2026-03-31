import 'package:core/injecoes/injecoes.dart';
import 'package:core/leitor/leitor_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EntradaManulDeProdutosPage extends StatelessWidget {
  const EntradaManulDeProdutosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrada Manual de Produtos')),
      body: Center(child: LeitorWidget(dataSource: sl())),
    );
  }
}
