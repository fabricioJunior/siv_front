import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';

class CategoriasPage extends StatelessWidget {
  final bloc = sl<CategoriasBloc>();
  final debouncer = Debouncer(milliseconds: 400);

  CategoriasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CategoriasBloc>(
      create: (context) => bloc..add(CategoriasIniciou()),
      child: Scaffold(
        floatingActionButton: BlocBuilder<CategoriasBloc, CategoriasState>(
          builder: (context, state) {
            if (state is CategoriasCarregarEmProgresso) {
              return const FloatingActionButton(
                onPressed: null,
                child: CircularProgressIndicator.adaptive(),
              );
            }

            return FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                final result = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (context) => const CategoriaFormPage(),
                  ),
                );

                if (result == true) {
                  // ignore: use_build_context_synchronously
                  context.read<CategoriasBloc>().add(CategoriasIniciou());
                }
              },
            );
          },
        ),
        appBar: AppBar(title: const Text('Categorias')),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gerencie suas categorias',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SearchBar(
                      autoFocus: false,
                      hintText: 'Buscar categoria por nome',
                      onChanged: (value) {
                        debouncer.run(() {
                          bloc.add(CategoriasIniciou(busca: value));
                        });
                      },
                      onSubmitted: (value) {
                        bloc.add(CategoriasIniciou(busca: value));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<CategoriasBloc, CategoriasState>(
                  builder: (context, state) {
                    if (state is CategoriasCarregarEmProgresso ||
                        state is CategoriasDesativarEmProgresso) {
                      return _buildLoading();
                    }

                    if (state is CategoriasCarregarFalha ||
                        state is CategoriasDesativarFalha) {
                      return _buildError();
                    }

                    if (state is CategoriasCarregarSucesso ||
                        state is CategoriasDesativarSucesso) {
                      if (state.categorias.isEmpty) {
                        return _buildEmpty();
                      }

                      return ListView.builder(
                        itemCount: state.categorias.length,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemBuilder: (context, index) {
                          final categoria = state.categorias[index];
                          return _buildCategoriaCard(context, categoria);
                        },
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriaCard(BuildContext context, Categoria categoria) {
    final avatarColor = categoria.inativa
        ? Colors.grey.shade300
        : _categoriaColor(categoria.nome);
    final iconColor = categoria.inativa
        ? Colors.grey.shade700
        : _contrastColor(avatarColor);
    final iconData = _categoriaIcon(categoria.nome);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: avatarColor,
          child: Icon(iconData, color: iconColor),
        ),
        onTap: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) =>
                  CategoriaFormPage(idCategoria: categoria.id),
            ),
          );

          if (result == true) {
            // ignore: use_build_context_synchronously
            context.read<CategoriasBloc>().add(CategoriasIniciou());
          }
        },
        title: Text(
          categoria.nome,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          categoria.inativa ? 'Inativa' : 'Ativa',
          style: TextStyle(
            color: categoria.inativa ? Colors.grey : Colors.teal,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            _showDeleteConfirmation(context, categoria);
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Categoria categoria) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Desativar Categoria'),
        content: Text('Deseja desativar a categoria "${categoria.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<CategoriasBloc>().add(
                CategoriasDesativar(id: categoria.id!),
              );
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Desativar'),
          ),
        ],
      ),
    );
  }

  Color _contrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  IconData _categoriaIcon(String nome) {
    final normalized = nome.trim().toLowerCase();

    if (normalized.contains('camisa') ||
        normalized.contains('camiseta') ||
        normalized.contains('blusa') ||
        normalized.contains('polo')) {
      return Icons.checkroom;
    }
    if (normalized.contains('calca') ||
        normalized.contains('bermuda') ||
        normalized.contains('short') ||
        normalized.contains('jeans')) {
      return Icons.checkroom;
    }
    if (normalized.contains('calcado') ||
        normalized.contains('tenis') ||
        normalized.contains('sapato') ||
        normalized.contains('sandalia') ||
        normalized.contains('chinelo')) {
      return Icons.directions_walk;
    }
    if (normalized.contains('bolsa') ||
        normalized.contains('mochila') ||
        normalized.contains('carteira')) {
      return Icons.work_outline;
    }
    if (normalized.contains('oculos')) {
      return Icons.visibility;
    }
    if (normalized.contains('relogio')) {
      return Icons.watch;
    }
    if (normalized.contains('anel') ||
        normalized.contains('brinco') ||
        normalized.contains('colar') ||
        normalized.contains('joia')) {
      return Icons.auto_awesome;
    }
    if (normalized.contains('cinto')) {
      return Icons.horizontal_rule;
    }
    if (normalized.contains('bone') || normalized.contains('chapeu')) {
      return Icons.sports_baseball;
    }
    if (normalized.contains('meia') || normalized.contains('intima')) {
      return Icons.favorite_border;
    }
    if (normalized.contains('acessorio')) {
      return Icons.style;
    }
    if (normalized.contains('infantil') || normalized.contains('crianca')) {
      return Icons.child_care;
    }
    if (normalized.contains('feminino')) {
      return Icons.female;
    }
    if (normalized.contains('masculino')) {
      return Icons.male;
    }
    if (normalized.contains('esportivo')) {
      return Icons.sports;
    }
    if (normalized.contains('praia')) {
      return Icons.beach_access;
    }
    if (normalized.contains('inverno')) {
      return Icons.ac_unit;
    }
    if (normalized.contains('verao')) {
      return Icons.wb_sunny;
    }
    if (normalized.contains('uniforme')) {
      return Icons.badge;
    }

    return Icons.category;
  }

  Color _categoriaColor(String nome) {
    final normalized = nome.trim().toLowerCase();

    if (normalized.contains('calcado') ||
        normalized.contains('tenis') ||
        normalized.contains('sapato')) {
      return Colors.indigo.shade400;
    }
    if (normalized.contains('bolsa') || normalized.contains('mochila')) {
      return Colors.brown.shade400;
    }
    if (normalized.contains('oculos') || normalized.contains('relogio')) {
      return Colors.blueGrey.shade400;
    }
    if (normalized.contains('joia') ||
        normalized.contains('anel') ||
        normalized.contains('brinco') ||
        normalized.contains('colar')) {
      return Colors.amber.shade400;
    }
    if (normalized.contains('camisa') ||
        normalized.contains('camiseta') ||
        normalized.contains('blusa') ||
        normalized.contains('vestido')) {
      return Colors.pink.shade300;
    }
    if (normalized.contains('calca') ||
        normalized.contains('jeans') ||
        normalized.contains('bermuda')) {
      return Colors.blue.shade400;
    }
    if (normalized.contains('acessorio')) {
      return Colors.deepPurple.shade300;
    }
    if (normalized.contains('infantil') || normalized.contains('crianca')) {
      return Colors.lightGreen.shade400;
    }

    return Colors.teal.shade400;
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator.adaptive());
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.error_outline, color: Colors.red, size: 40),
            SizedBox(height: 12),
            Text(
              'Falha ao carregar categorias',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.category_outlined, size: 44, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Nenhuma categoria cadastrada.\nToque no botao + para criar uma nova categoria.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
