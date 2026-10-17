import 'package:comercial/presentation/widgets/cliente_compras_aba.dart';
import 'package:flutter/material.dart';

class ComprasDoClientePage extends StatelessWidget {
  final int pessoaId;
  final String nomeCliente;

  const ComprasDoClientePage({
    super.key,
    required this.pessoaId,
    required this.nomeCliente,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(nomeCliente)),
        body: ClienteComprasAba(pessoaId: pessoaId),
      );
}
