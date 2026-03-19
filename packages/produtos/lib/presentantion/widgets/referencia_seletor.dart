import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/blocs/referencias_bloc/referencias_bloc.dart';
import 'package:produtos/presentantion/widgets/generic_seletor.dart';

enum ReferenciaSeletorModo { unica, multipla }

class ReferenciaSeletor extends StatefulWidget {
  final ReferenciaSeletorModo modo;
  final List<Referencia> referenciasSelecionadasIniciais;
  final List<int> idReferenciasSelecionadasIniciais;
  final ValueChanged<List<Referencia>>? onChanged;
  final String titulo;

  const ReferenciaSeletor({
    super.key,
    this.modo = ReferenciaSeletorModo.unica,
    this.referenciasSelecionadasIniciais = const [],
    this.idReferenciasSelecionadasIniciais = const [],
    this.onChanged,
    this.titulo = 'Referências',
  });

  @override
  State<ReferenciaSeletor> createState() => _ReferenciaSeletorState();
}

class _ReferenciaSeletorState extends State<ReferenciaSeletor> {
  late final ReferenciasBloc _referenciasBloc;

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
            selecionadosIniciais: state.referenciasSelecionadas
                .where(
                  (referenciaInicial) => state.referencias.any(
                    (referencia) =>
                        _mesmaReferencia(referencia, referenciaInicial),
                  ),
                )
                .toList(),
            onChanged: widget.onChanged,
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
