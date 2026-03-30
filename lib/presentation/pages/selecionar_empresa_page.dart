import 'package:core/injecoes.dart';
import 'package:core/bloc.dart';
import 'package:empresas/domain/entities/empresa.dart';
import 'package:empresas/presentation/blocs/empresas_bloc/empresas_bloc.dart';
import 'package:flutter/material.dart';

class SelecionarEmpresaPage extends StatefulWidget {
  const SelecionarEmpresaPage({super.key});

  @override
  State<SelecionarEmpresaPage> createState() => _SelecionarEmpresaPageState();
}

class _SelecionarEmpresaPageState extends State<SelecionarEmpresaPage> {
  final EmpresasBloc _bloc = sl<EmpresasBloc>();
  final TextEditingController _buscaController = TextEditingController();
  String _busca = '';

  @override
  void initState() {
    super.initState();
    _bloc.add(EmpresasIniciou());
  }

  @override
  void dispose() {
    _buscaController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EmpresasBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Selecionar empresa'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Escolha a empresa para continuar',
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
                  child: BlocBuilder<EmpresasBloc, EmpresasState>(
                    builder: (context, state) {
                      if (state is EmpresasCarregarEmProgresso ||
                          state is EmpresasNaoInicializado) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }

                      if (state is EmpresasCarregarFalha) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Falha ao carregar empresas.'),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: () {
                                  _bloc.add(EmpresasIniciou());
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        );
                      }

                      final empresas = state is EmpresasCarregarSucesso
                          ? state.empresas
                          : <Empresa>[];
                      final empresasFiltradas = _filtrarEmpresas(empresas);

                      if (empresasFiltradas.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Nenhuma empresa disponível para seleção.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                key: const Key(
                                    'selecionar_empresa_cadastrar_button'),
                                onPressed: () async {
                                  await Navigator.of(context)
                                      .pushNamed('/empresa');
                                  _bloc.add(EmpresasIniciou());
                                },
                                icon: const Icon(Icons.add_business_outlined),
                                label: const Text('Cadastrar empresa'),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: empresasFiltradas.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final empresa = empresasFiltradas[index];
                          return Card(
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.business_outlined),
                              ),
                              title: Text(empresa.nome),
                              subtitle: Text('ID: ${empresa.id ?? '-'}'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.of(context).pop({
                                  'idEmpresa': empresa.id,
                                  'nomeEmpresa': empresa.nome,
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Empresa> _filtrarEmpresas(List<Empresa> empresas) {
    final termo = _busca.toLowerCase();
    if (termo.isEmpty) return empresas;

    return empresas.where((empresa) {
      final nome = empresa.nome.toLowerCase();
      final id = (empresa.id ?? 0).toString();
      return nome.contains(termo) || id.contains(termo);
    }).toList();
  }
}
