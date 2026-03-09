import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/blocs/tamanhos_bloc/tamanhos_bloc.dart';
import 'package:produtos/presentantion/widgets/generic_seletor.dart';

enum TamanhoSeletorModo { unica, multipla }

class TamanhoSeletor extends StatefulWidget {
  final TamanhoSeletorModo modo;
  final List<Tamanho> tamanhosSelecionadosIniciais;
  final ValueChanged<List<Tamanho>>? onChanged;
  final String titulo;

  const TamanhoSeletor({
    super.key,
    this.modo = TamanhoSeletorModo.unica,
    this.tamanhosSelecionadosIniciais = const [],
    this.onChanged,
    this.titulo = 'Tamanhos',
  });

  @override
  State<TamanhoSeletor> createState() => _TamanhoSeletorState();
}

class _TamanhoSeletorState extends State<TamanhoSeletor> {
  late final TamanhosBloc _tamanhosBloc;

  @override
  void initState() {
    super.initState();
    _tamanhosBloc = sl<TamanhosBloc>()..add(TamanhosIniciou(inativo: false));
  }

  @override
  void dispose() {
    _tamanhosBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<TamanhosBloc>.value(
      value: _tamanhosBloc,
      child: BlocBuilder<TamanhosBloc, TamanhosState>(
        builder: (context, state) {
          if (state is TamanhosCarregarEmProgresso ||
              state is TamanhosDesativarEmProgresso) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (state is TamanhosCarregarFalha ||
              state is TamanhosDesativarFalha) {
            return _mensagem(
              context,
              'Não foi possível carregar os tamanhos.',
              theme.colorScheme.error,
            );
          }

          if (state.tamanhos.isEmpty) {
            return _mensagem(
              context,
              'Nenhum tamanho disponível para seleção.',
              theme.colorScheme.onSurfaceVariant,
            );
          }

          final tamanhosAtivos = state.tamanhos
              .where((tamanho) => !tamanho.inativo)
              .toList();

          return SeletorGenerico<Tamanho>(
            itens: tamanhosAtivos,
            itemLabel: (tamanho) => tamanho.nome,
            itemKey: (tamanho) => tamanho.id ?? tamanho.nome,
            modo: widget.modo == TamanhoSeletorModo.unica
                ? SeletorGenericoModo.unica
                : SeletorGenericoModo.multipla,
            selecionadosIniciais: widget.tamanhosSelecionadosIniciais
                .where(
                  (tamanhoInicial) => tamanhosAtivos.any(
                    (tamanhoAtivo) =>
                        _mesmoTamanho(tamanhoAtivo, tamanhoInicial),
                  ),
                )
                .toList(),
            onChanged: widget.onChanged,
            titulo: widget.titulo,
            hintText: 'Digite para buscar um tamanho',
            maxSugestoes: 3,
            chipAvatarBuilder: (_, __) =>
                const Icon(Icons.straighten_outlined, size: 16),
            sugestaoLeadingBuilder: (context, __) {
              final colorScheme = Theme.of(context).colorScheme;
              return CircleAvatar(
                radius: 14,
                backgroundColor: colorScheme.secondaryContainer,
                child: Icon(
                  Icons.straighten,
                  size: 14,
                  color: colorScheme.onSecondaryContainer,
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

  bool _mesmoTamanho(Tamanho a, Tamanho b) {
    if (a.id != null && b.id != null) {
      return a.id == b.id;
    }
    return a.nome == b.nome;
  }
}
