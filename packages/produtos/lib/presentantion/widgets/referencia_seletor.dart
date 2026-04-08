import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/blocs/referencias_bloc/referencias_bloc.dart';

enum ReferenciaSeletorModo { unica, multipla }

// ignore: must_be_immutable
class ReferenciaSeletor extends StatefulWidget implements ISeletor {
  final ReferenciaSeletorModo modo;
  final List<Referencia> referenciasSelecionadasIniciais;
  final List<int> idReferenciasSelecionadasIniciais;
  final ValueChanged<List<Referencia>>? onReferenciaChanged;

  @override
  final Function(List<SelectData>)? onChanged;
  final String titulo;

  const ReferenciaSeletor({
    super.key,
    this.modo = ReferenciaSeletorModo.unica,
    this.referenciasSelecionadasIniciais = const [],
    this.idReferenciasSelecionadasIniciais = const [],
    this.onReferenciaChanged,
    this.onChanged,
    this.titulo = 'Referências',
  });

  @override
  State<ReferenciaSeletor> createState() => _ReferenciaSeletorState();

  @override
  List<SelectData> get itemsSelecionadosInicial =>
      referenciasSelecionadasIniciais
          .map(
            (referencia) => DadoInicial(
              id: referencia.id ?? 0,
              nome: referencia.nome,
              data: {'referencia': referencia.toString()},
            ),
          )
          .toList();
}

class _ReferenciaSeletorState extends State<ReferenciaSeletor> {
  late final ReferenciasBloc _referenciasBloc;
  Set<int>? _idsExternosSelecionados;

  @override
  void initState() {
    super.initState();
    _referenciasBloc = sl<ReferenciasBloc>()
      ..add(
        ReferenciasIniciou(
          inativo: false,
          idsReferenciasSelecionadasIniciais:
              widget.idReferenciasSelecionadasIniciais,
        ),
      );
  }

  @override
  void dispose() {
    _referenciasBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<ReferenciasBloc>.value(
      value: _referenciasBloc,
      child: BlocBuilder<ReferenciasBloc, ReferenciasState>(
        builder: (context, state) {
          if (state is ReferenciasCarregarEmProgresso) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (state is ReferenciasCarregarFalha) {
            return _mensagem(
              context,
              'Não foi possível carregar as referências.',
              theme.colorScheme.error,
            );
          }

          if (state.referencias.isEmpty) {
            return _mensagem(
              context,
              'Nenhuma referência disponível para seleção.',
              theme.colorScheme.onSurfaceVariant,
            );
          }

          return SeletorGenerico<Referencia>(
            itens: state.referencias,
            itemLabel: (referencia) =>
                '(${referencia.id ?? 'sem ID'}) ${referencia.nome} ',
            itemKey: (referencia) => referencia.id ?? referencia.nome,
            modo: widget.modo == ReferenciaSeletorModo.unica
                ? SeletorGenericoModo.unica
                : SeletorGenericoModo.multipla,
            selecionadosIniciais: _idsExternosSelecionados != null
                ? state.referencias
                      .where((r) => _idsExternosSelecionados!.contains(r.id))
                      .toList()
                : state.referenciasSelecionadas
                      .where(
                        (referenciaInicial) => state.referencias.any(
                          (referencia) =>
                              _mesmaReferencia(referencia, referenciaInicial),
                        ),
                      )
                      .toList(),
            onChanged: (selecionadas) {
              final dados = selecionadas
                  .where((item) => item.id != null)
                  .map(
                    (item) => SelectData(
                      id: item.id!,
                      nome: item.nome,
                      data: {'referencia': item.toString()},
                    ),
                  )
                  .toList();
              widget.onReferenciaChanged?.call(selecionadas);
              widget.onChanged?.call(dados);
            },
            titulo: widget.titulo,
            hintText: 'Digite para buscar uma referência',
            maxSugestoes: 5,
            chipAvatarBuilder: (_, __) =>
                const Icon(Icons.tag_outlined, size: 16),

            sugestaoLeadingBuilder: (context, __) {
              final colorScheme = Theme.of(context).colorScheme;
              return CircleAvatar(
                radius: 14,
                backgroundColor: colorScheme.tertiaryContainer,
                child: Icon(
                  Icons.sell_outlined,
                  size: 14,
                  color: colorScheme.onTertiaryContainer,
                ),
              );
            },
            confirmarEmSeparadores: const [',', ';'],
            toSelectData: (Referencia item) {
              return SelectData(
                id: item.id!,
                nome: item.nome,
                data: {'referencia': item.toString()},
              );
            },
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

  bool _mesmaReferencia(Referencia a, Referencia b) {
    if (a.id != null && b.id != null) {
      return a.id == b.id;
    }
    return a.nome == b.nome;
  }
}
