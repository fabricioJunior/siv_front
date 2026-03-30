import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:siv_front/presentation/bloc/sync_data/sync_data_bloc.dart';

class EntradaDeProdutosPage extends StatefulWidget {
  const EntradaDeProdutosPage({super.key});

  @override
  State<EntradaDeProdutosPage> createState() => _EntradaDeProdutosPageState();
}

class _EntradaDeProdutosPageState extends State<EntradaDeProdutosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sl<SyncDataBloc>().add(
        const SyncDataSolicitouSincronizacao(
          origem: SyncDataOrigem.entradaDeProdutos,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrada de produtos')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tela de entrada de produtos em construcao.'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/sincronizacao'),
              icon: const Icon(Icons.sync),
              label: const Text('Ver sincronizacao'),
            ),
          ],
        ),
      ),
    );
  }
}
