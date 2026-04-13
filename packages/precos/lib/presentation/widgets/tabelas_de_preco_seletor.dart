import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';
import 'package:precos/models.dart';
import 'package:precos/presentation/blocs/tabelas_de_preco_bloc/tabelas_de_preco_bloc.dart';

enum TabelasDePrecoSeletorModo { unica, multipla }

// ignore: must_be_immutable
class TabelasDePrecoSeletor extends StatefulWidget implements ISeletor {
  final TabelasDePrecoSeletorModo modo;
  final List<TabelaDePreco> tabelasSelecionadasIniciais;
  final ValueChanged<List<TabelaDePreco>>? onTabelaDePrecoChanged;

  @override
  final List<SelectData>? itemsSelecionadosInicial;

  @override
  final Function(List<SelectData>)? onChanged;

  final String titulo;

  final bool onlyView;

  const TabelasDePrecoSeletor({
    super.key,
    this.modo = TabelasDePrecoSeletorModo.unica,
    this.itemsSelecionadosInicial,
    this.tabelasSelecionadasIniciais = const [],
    this.onTabelaDePrecoChanged,
    this.titulo = 'Tabelas de preço',
    this.onChanged,
    this.onlyView = false,
  });

  @override
  State<TabelasDePrecoSeletor> createState() => _TabelasDePrecoSeletorState();
}

class _TabelasDePrecoSeletorState extends State<TabelasDePrecoSeletor> {
  late final TabelasDePrecoBloc _tabelasDePrecoBloc;
  Set<int>? _idsExternosSelecionados;

  @override
  void initState() {
    super.initState();
    _tabelasDePrecoBloc = sl<TabelasDePrecoBloc>()
      ..add(
        TabelasDePrecoIniciou(
          tabelaInicialId: widget.itemsSelecionadosInicial?.isNotEmpty == true
              ? widget.itemsSelecionadosInicial!.first.id
              : null,
        ),
      );
  }

  @override
  void dispose() {
    _tabelasDePrecoBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<TabelasDePrecoBloc>.value(
      value: _tabelasDePrecoBloc,
      child: BlocBuilder<TabelasDePrecoBloc, TabelasDePrecoState>(
        builder: (context, state) {
          if (state is TabelasDePrecoCarregarEmProgresso ||
              state is TabelasDePrecoDesativarEmProgresso) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (state is TabelasDePrecoCarregarFalha ||
              state is TabelasDePrecoDesativarFalha) {
            return _mensagem(
              context,
              'Não foi possível carregar as tabelas de preço.',
              theme.colorScheme.error,
            );
          }

          final tabelasAtivas = state.tabelas
              .where((tabela) => !tabela.inativa)
              .toList();
          final idsSelecionados =
              _idsExternosSelecionados ??
              widget.tabelasSelecionadasIniciais
                  .map((tabela) => tabela.id)
                  .whereType<int>()
                  .toSet();
          final tabelasSelecionadas = [
            ...state.tabelas.where(
              (tabela) =>
                  tabela.id != null && idsSelecionados.contains(tabela.id),
            ),
            ...widget.tabelasSelecionadasIniciais.where(
              (tabelaInicial) =>
                  tabelaInicial.id == null ||
                  !state.tabelas.any(
                    (tabela) => _mesmaTabela(tabela, tabelaInicial),
                  ),
            ),
          ];
          final tabelasDisponiveis = [
            ...tabelasSelecionadas,
            ...tabelasAtivas.where(
              (tabela) =>
                  tabela.id == null || !idsSelecionados.contains(tabela.id),
            ),
          ];

          if (tabelasDisponiveis.isEmpty) {
            return _mensagem(
              context,
              'Nenhuma tabela de preço disponível para seleção.',
              theme.colorScheme.onSurfaceVariant,
            );
          }

          return SeletorGenerico<TabelaDePreco>(
            toSelectData: (item) => SelectData(
              id: item.id ?? 0,
              nome: item.nome,
              data: {
                'id': item.id,
                'nome': item.nome,
                'terminador': item.terminador,
                'inativa': item.inativa,
              },
            ),
            itens: tabelasDisponiveis,
            itemLabel: (tabela) => tabela.nome,
            onlyView: widget.onlyView,
            itemKey: (tabela) => tabela.id ?? tabela.nome,
            modo: widget.modo == TabelasDePrecoSeletorModo.unica
                ? SeletorGenericoModo.unica
                : SeletorGenericoModo.multipla,
            selecionadosIniciais: state.tabelaDePreco != null
                ? [state.tabelaDePreco!]
                : [],
            onChanged: (List<TabelaDePreco> selecionadas) {
              widget.onTabelaDePrecoChanged?.call(selecionadas);
              widget.onChanged?.call(
                selecionadas
                    .map(
                      (tabela) => SelectData(
                        id: tabela.id ?? 0,
                        nome: tabela.nome,
                        data: {
                          'id': tabela.id,
                          'nome': tabela.nome,
                          'terminador': tabela.terminador,
                          'inativa': tabela.inativa,
                        },
                      ),
                    )
                    .toList(),
              );
            },
            titulo: widget.titulo,
            hintText: 'Digite para buscar uma tabela de preço',
            maxSugestoes: 5,
            chipAvatarBuilder: (context, item) =>
                const Icon(Icons.attach_money_outlined, size: 16),
            sugestaoLeadingBuilder: (context, item) {
              final colorScheme = Theme.of(context).colorScheme;
              return CircleAvatar(
                radius: 14,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.price_change_outlined,
                  size: 14,
                  color: colorScheme.onPrimaryContainer,
                ),
              );
            },
            confirmarEmSeparadores: const [',', ';'],
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

  bool _mesmaTabela(TabelaDePreco a, TabelaDePreco b) {
    if (a.id != null && b.id != null) {
      return a.id == b.id;
    }
    return a.nome == b.nome;
  }
}
