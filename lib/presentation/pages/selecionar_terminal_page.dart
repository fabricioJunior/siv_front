import 'package:autenticacao/models.dart';
import 'package:flutter/material.dart';

class SelecionarTerminalPage extends StatefulWidget {
  final List<TerminalDoUsuario> terminais;

  const SelecionarTerminalPage({super.key, required this.terminais});

  @override
  State<SelecionarTerminalPage> createState() => _SelecionarTerminalPageState();
}

class _SelecionarTerminalPageState extends State<SelecionarTerminalPage> {
  final TextEditingController _buscaController = TextEditingController();
  String _busca = '';

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final terminaisFiltrados = _filtrarTerminais(widget.terminais);

    return Scaffold(
      appBar: AppBar(title: const Text('Selecionar terminal')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Escolha o terminal para continuar',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SearchBar(
                controller: _buscaController,
                hintText: 'Buscar por nome ou ID',
                leading: const Icon(Icons.search),
                onChanged: (value) {
                  setState(() {
                    _busca = value.trim();
                  });
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: terminaisFiltrados.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum terminal disponível para seleção.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        itemCount: terminaisFiltrados.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final terminal = terminaisFiltrados[index];
                          return Card(
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.point_of_sale_outlined),
                              ),
                              title: Text(terminal.nome),
                              subtitle: Text('ID: ${terminal.id}'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.of(context).pop({
                                  'idTerminal': terminal.id,
                                  'idEmpresa': terminal.idEmpresa,
                                  'nomeTerminal': terminal.nome,
                                });
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<TerminalDoUsuario> _filtrarTerminais(List<TerminalDoUsuario> terminais) {
    final termo = _busca.toLowerCase();
    if (termo.isEmpty) {
      return terminais;
    }

    return terminais.where((terminal) {
      final nome = terminal.nome.toLowerCase();
      final id = terminal.id.toString();
      return nome.contains(termo) || id.contains(termo);
    }).toList();
  }
}
