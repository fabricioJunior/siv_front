import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

/// Carrega as subcategorias ativas das [categoriaIds] informadas.
class SubCategoriasDasCategoriasCubit extends Cubit<List<SubCategoria>> {
  final RecuperarSubCategorias _recuperar;

  SubCategoriasDasCategoriasCubit(this._recuperar) : super(const []);

  Future<void> carregar(List<int> categoriaIds) async {
    try {
      final listas = await Future.wait(
        categoriaIds.map((id) => _recuperar.call(id, inativa: false)),
      );
      emit([for (final l in listas) ...l.where((s) => s.id != null)]);
    } catch (e, s) {
      emit(const []);
      addError(e, s);
    }
  }
}

/// Seleção múltipla de subcategorias das categorias escolhidas; recarrega
/// quando [categoriaIds] muda.
// ignore: must_be_immutable
class SubCategoriaSeletor extends StatefulWidget implements ISeletor {
  final List<int> categoriaIds;
  final List<int> idsSelecionadosIniciais;
  final String titulo;

  @override
  final Function(List<SelectData>)? onChanged;

  const SubCategoriaSeletor({
    super.key,
    required this.categoriaIds,
    this.idsSelecionadosIniciais = const [],
    this.onChanged,
    this.titulo = 'Subcategorias',
  });

  @override
  State<SubCategoriaSeletor> createState() => _SubCategoriaSeletorState();

  @override
  List<SelectData> get itemsSelecionadosInicial => const [];
}

class _SubCategoriaSeletorState extends State<SubCategoriaSeletor> {
  late final SubCategoriasDasCategoriasCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = SubCategoriasDasCategoriasCubit(sl<RecuperarSubCategorias>())
      ..carregar(widget.categoriaIds);
  }

  @override
  void didUpdateWidget(covariant SubCategoriaSeletor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_mesmos(oldWidget.categoriaIds, widget.categoriaIds)) {
      _cubit.carregar(widget.categoriaIds);
    }
  }

  bool _mesmos(List<int> a, List<int> b) =>
      a.length == b.length && a.toSet().containsAll(b);

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categoriaIds.isEmpty) {
      return Text(
        'Escolha categorias para filtrar por subcategoria.',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    return BlocBuilder<SubCategoriasDasCategoriasCubit, List<SubCategoria>>(
      bloc: _cubit,
      builder: (context, subs) {
        if (subs.isEmpty) {
          return Text(
            'Nenhuma subcategoria nas categorias escolhidas.',
            style: Theme.of(context).textTheme.bodySmall,
          );
        }
        return SeletorGenerico<SubCategoria>(
          key: ValueKey(subs.map((s) => s.id).join(',')),
          itens: subs,
          itemLabel: (s) => s.nome,
          itemKey: (s) => s.id,
          modo: SeletorGenericoModo.multipla,
          selecionadosIniciais: subs
              .where((s) => widget.idsSelecionadosIniciais.contains(s.id))
              .toList(),
          onChanged: (sel) => widget.onChanged?.call(
            sel
                .map((s) => SelectData(id: s.id!, nome: s.nome, data: const {}))
                .toList(),
          ),
          titulo: widget.titulo,
          hintText: 'Digite para buscar uma subcategoria',
          maxSugestoes: 5,
          chipAvatarBuilder: (_, __) =>
              const Icon(Icons.category_outlined, size: 16),
          confirmarEmSeparadores: const [',', ';'],
          toSelectData: (s) =>
              SelectData(id: s.id!, nome: s.nome, data: const {}),
        );
      },
    );
  }
}
