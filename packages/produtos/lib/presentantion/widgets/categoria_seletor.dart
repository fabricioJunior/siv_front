import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';

enum CategoriaSeletorModo { unica, multipla }

// ignore: must_be_immutable
class CategoriaSeletor extends StatefulWidget implements ISeletor {
  final CategoriaSeletorModo modo;
  final List<int> idCategoriasSelecionadasIniciais;
  final ValueChanged<List<Categoria>>? onCategoriaChanged;

  @override
  final Function(List<SelectData>)? onChanged;
  final String titulo;

  const CategoriaSeletor({
    super.key,
    this.modo = CategoriaSeletorModo.unica,
    this.idCategoriasSelecionadasIniciais = const [],
    this.onCategoriaChanged,
    this.onChanged,
    this.titulo = 'Categorias',
  });

  @override
  State<CategoriaSeletor> createState() => _CategoriaSeletorState();

  @override
  List<SelectData> get itemsSelecionadosInicial => const [];
}

class _CategoriaSeletorState extends State<CategoriaSeletor> {
  late final CategoriasBloc _categoriasBloc;

  @override
  void initState() {
    super.initState();
    _categoriasBloc = sl<CategoriasBloc>()
      ..add(CategoriasIniciou(inativa: false));
  }

  @override
  void dispose() {
    _categoriasBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<CategoriasBloc>.value(
      value: _categoriasBloc,
      child: BlocBuilder<CategoriasBloc, CategoriasState>(
        builder: (context, state) {
          if (state is CategoriasCarregarEmProgresso) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (state is CategoriasCarregarFalha) {
            return _mensagem(
              context,
              'Não foi possível carregar as categorias.',
              theme.colorScheme.error,
            );
          }

          if (state.categorias.isEmpty) {
            return _mensagem(
              context,
              'Nenhuma categoria disponível para seleção.',
              theme.colorScheme.onSurfaceVariant,
            );
          }

          return SeletorGenerico<Categoria>(
            itens: state.categorias,
            itemLabel: (categoria) => categoria.nome,
            itemKey: (categoria) => categoria.id ?? categoria.nome,
            modo: widget.modo == CategoriaSeletorModo.unica
                ? SeletorGenericoModo.unica
                : SeletorGenericoModo.multipla,
            selecionadosIniciais: state.categorias
                .where(
                  (categoria) => widget.idCategoriasSelecionadasIniciais
                      .contains(categoria.id),
                )
                .toList(),
            onChanged: (selecionadas) {
              final dados = selecionadas
                  .where((item) => item.id != null)
                  .map(
                    (item) => SelectData(
                      id: item.id!,
                      nome: item.nome,
                      data: const {},
                    ),
                  )
                  .toList();
              widget.onCategoriaChanged?.call(selecionadas);
              widget.onChanged?.call(dados);
            },
            titulo: widget.titulo,
            hintText: 'Digite para buscar uma categoria',
            maxSugestoes: 5,
            chipAvatarBuilder: (_, __) =>
                const Icon(Icons.category_outlined, size: 16),
            sugestaoLeadingBuilder: (context, __) {
              final colorScheme = Theme.of(context).colorScheme;
              return CircleAvatar(
                radius: 14,
                backgroundColor: colorScheme.tertiaryContainer,
                child: Icon(
                  Icons.category_outlined,
                  size: 14,
                  color: colorScheme.onTertiaryContainer,
                ),
              );
            },
            confirmarEmSeparadores: const [',', ';'],
            toSelectData: (Categoria item) =>
                SelectData(id: item.id!, nome: item.nome, data: const {}),
          );
        },
      ),
    );
  }

  Widget _mensagem(BuildContext context, String texto, Color cor) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        texto,
        style: theme.textTheme.bodyMedium?.copyWith(color: cor),
      ),
    );
  }
}
