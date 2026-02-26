import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/presentation/bloc/pessoas_bloc/pessoas_bloc.dart';

class PessoasPage extends StatefulWidget {
  const PessoasPage({super.key});

  @override
  State<PessoasPage> createState() => _PessoasPageState();
}

class _PessoasPageState extends State<PessoasPage>
    with SingleTickerProviderStateMixin {
  late final PessoasBloc bloc;
  late final Debouncer debouncer;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    bloc = sl<PessoasBloc>();
    debouncer = Debouncer(milliseconds: 400);
    _tabController = TabController(length: 4, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PessoasBloc>(
      create: (context) => bloc..add(PessoasIniciou()),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        floatingActionButton: BlocBuilder<PessoasBloc, PessoasState>(
          builder: (context, state) {
            if (state is PessoasCarregarEmProgresso) {
              return const SizedBox.shrink();
            }

            return FloatingActionButton.extended(
              icon: const Icon(Icons.person_add),
              label: const Text('Nova Pessoa'),
              onPressed: () async {
                await Navigator.of(context).pushNamed('/pessoa');

                // ignore: use_build_context_synchronously
                context.read<PessoasBloc>().add(PessoasIniciou());
              },
            );
          },
        ),
        appBar: AppBar(
          title: const Text('Pessoas'),
          elevation: 0,
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SearchBar(
                hintText: 'Pesquisar por nome ou documento',
                leading: const Icon(Icons.search),
                padding: const MaterialStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (value) {
                  debouncer.run(() {
                    bloc.add(PessoasIniciou(busca: value));
                  });
                },
                onSubmitted: (value) {
                  bloc.add(PessoasIniciou(busca: value));
                },
              ),
            ),
            Material(
              color: Theme.of(context).colorScheme.surface,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Todos'),
                  Tab(text: 'Clientes'),
                  Tab(text: 'Fornecedores'),
                  Tab(text: 'Funcionários'),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<PessoasBloc, PessoasState>(
                  builder: (context, state) {
                switch (state.runtimeType) {
                  case const (PessoasCarregarEmProgresso):
                    return _buildLoading();
                  case const (PessoasCarregarSucesso):
                    final pessoas = _filtrarPessoasPorTipo(state.pessoas);
                    if (pessoas.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildPessoasList(context, pessoas);
                  default:
                    return const SizedBox();
                }
              }),
            )
          ],
        ),
      ),
    );
  }

  List<Pessoa> _filtrarPessoasPorTipo(List<Pessoa> pessoas) {
    final filtro = TipoPessoaTab.values[_tabController.index];
    switch (filtro) {
      case TipoPessoaTab.todos:
        return pessoas;
      case TipoPessoaTab.clientes:
        return pessoas.where((pessoa) => pessoa.eCliente).toList();
      case TipoPessoaTab.fornecedores:
        return pessoas.where((pessoa) => pessoa.eFornecedor).toList();
      case TipoPessoaTab.funcionarios:
        return pessoas.where((pessoa) => pessoa.eFuncionario).toList();
    }
  }

  Widget _buildPessoasList(BuildContext context, List<Pessoa> pessoas) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: pessoas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        var pessoa = pessoas[index];
        return _buildPessoaCard(context, pessoa);
      },
    );
  }

  Widget _buildPessoaCard(BuildContext context, Pessoa pessoa) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).pushNamed(
            '/pessoa',
            arguments: {
              'idPessoa': pessoa.id,
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar com iniciais
              CircleAvatar(
                radius: 28,
                backgroundColor: _getAvatarColor(pessoa),
                child: Text(
                  _getInitials(pessoa.nome),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Informações da pessoa
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pessoa.nome,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDocument(pessoa.documento),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (pessoa.email?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.email_outlined,
                              size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              pessoa.email!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Badges de tipo de pessoa
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (pessoa.eCliente)
                          _buildBadge('Cliente', Colors.blue),
                        if (pessoa.eFornecedor)
                          _buildBadge('Fornecedor', Colors.orange),
                        if (pessoa.eFuncionario)
                          _buildBadge('Funcionário', Colors.green),
                        if (pessoa.bloqueado)
                          _buildBadge('Bloqueado', Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getInitials(String nome) {
    final parts = nome.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Color _getAvatarColor(Pessoa pessoa) {
    if (pessoa.bloqueado) return Colors.red[400]!;
    if (pessoa.eFuncionario) return Colors.green[400]!;
    if (pessoa.eFornecedor) return Colors.orange[400]!;
    if (pessoa.eCliente) return Colors.blue[400]!;
    return Colors.grey[400]!;
  }

  String _formatDocument(String documento) {
    final cleaned = documento.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 11) {
      // CPF: 000.000.000-00
      return '${cleaned.substring(0, 3)}.${cleaned.substring(3, 6)}.${cleaned.substring(6, 9)}-${cleaned.substring(9)}';
    } else if (cleaned.length == 14) {
      // CNPJ: 00.000.000/0000-00
      return '${cleaned.substring(0, 2)}.${cleaned.substring(2, 5)}.${cleaned.substring(5, 8)}/${cleaned.substring(8, 12)}-${cleaned.substring(12)}';
    }
    return documento;
  }

  Widget _buildEmptyState() {
    final filtro = TipoPessoaTab.values[_tabController.index];
    final descricao = switch (filtro) {
      TipoPessoaTab.todos => 'Tente ajustar os filtros de busca',
      TipoPessoaTab.clientes => 'Nenhum cliente encontrado para os filtros',
      TipoPessoaTab.fornecedores =>
        'Nenhum fornecedor encontrado para os filtros',
      TipoPessoaTab.funcionarios =>
        'Nenhum funcionário encontrado para os filtros',
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma pessoa encontrada',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            descricao,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }
}

enum TipoPessoaTab {
  todos,
  clientes,
  fornecedores,
  funcionarios,
}
