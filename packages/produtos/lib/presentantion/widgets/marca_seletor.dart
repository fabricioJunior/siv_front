import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';

/// Seletor múltiplo de marcas (mesmo molde do [CategoriaSeletor]).
// ignore: must_be_immutable
class MarcaSeletor extends StatefulWidget implements ISeletor {
  final List<int> idMarcasSelecionadasIniciais;

  @override
  final Function(List<SelectData>)? onChanged;
  final String titulo;

  const MarcaSeletor({
    super.key,
    this.idMarcasSelecionadasIniciais = const [],
    this.onChanged,
    this.titulo = 'Marcas',
  });

  @override
  State<MarcaSeletor> createState() => _MarcaSeletorState();

  @override
  List<SelectData> get itemsSelecionadosInicial => const [];
}

class _MarcaSeletorState extends State<MarcaSeletor> {
  late final MarcasBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<MarcasBloc>()..add(MarcasIniciou(inativa: false));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider<MarcasBloc>.value(
        value: _bloc,
        child: BlocBuilder<MarcasBloc, MarcasState>(
          builder: (context, state) {
            if (state is MarcasCarregarEmProgresso) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            if (state is MarcasCarregarFalha || state.marcas.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Nenhuma marca disponível para seleção.'),
              );
            }
            SelectData dado(Marca m) =>
                SelectData(id: m.id!, nome: m.nome, data: const {});
            return SeletorGenerico<Marca>(
              itens: state.marcas,
              itemLabel: (m) => m.nome,
              itemKey: (m) => m.id ?? m.nome,
              modo: SeletorGenericoModo.multipla,
              selecionadosIniciais: state.marcas
                  .where((m) => widget.idMarcasSelecionadasIniciais.contains(m.id))
                  .toList(),
              onChanged: (sel) => widget.onChanged
                  ?.call(sel.where((m) => m.id != null).map(dado).toList()),
              titulo: widget.titulo,
              hintText: 'Digite para buscar uma marca',
              maxSugestoes: 5,
              chipAvatarBuilder: (_, __) =>
                  const Icon(Icons.sell_outlined, size: 16),
              confirmarEmSeparadores: const [',', ';'],
              toSelectData: dado,
            );
          },
        ),
      );
}
