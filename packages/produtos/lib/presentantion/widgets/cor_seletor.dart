import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/blocs/cores_bloc/cores_bloc.dart';
import 'package:produtos/presentantion/widgets/generic_seletor.dart';

enum CorSeletorModo { unica, multipla }

class CorSeletor extends StatefulWidget {
  final CorSeletorModo modo;
  final List<Cor> coresSelecionadasIniciais;
  final ValueChanged<List<Cor>>? onChanged;
  final String titulo;

  const CorSeletor({
    super.key,
    this.modo = CorSeletorModo.unica,
    this.coresSelecionadasIniciais = const [],
    this.onChanged,
    this.titulo = 'Cores',
  });

  @override
  State<CorSeletor> createState() => _CorSeletorState();
}

class _CorSeletorState extends State<CorSeletor> {
  late final CoresBloc _coresBloc;

  @override
  void initState() {
    super.initState();
    _coresBloc = sl<CoresBloc>()..add(CoresIniciou());
  }

  @override
  void dispose() {
    _coresBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<CoresBloc>.value(
      value: _coresBloc,
      child: BlocBuilder<CoresBloc, CoresState>(
        builder: (context, state) {
          if (state is CoresCarregarEmProgresso ||
              state is CoresDesativarEmProgresso) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (state is CoresCarregarFalha || state is CoresDesativarFalha) {
            return _mensagem(
              context,
              'Não foi possível carregar as cores.',
              theme.colorScheme.error,
            );
          }

          if (state.cores.isEmpty) {
            return _mensagem(
              context,
              'Nenhuma cor disponível para seleção.',
              theme.colorScheme.onSurfaceVariant,
            );
          }

          final coresAtivas = state.cores
              .where((cor) => !(cor.inativo ?? false))
              .toList();

          return SeletorGenerico<Cor>(
            itens: coresAtivas,
            itemLabel: (cor) => cor.nome,
            itemKey: (cor) => cor.id ?? cor.nome,
            modo: widget.modo == CorSeletorModo.unica
                ? SeletorGenericoModo.unica
                : SeletorGenericoModo.multipla,
            selecionadosIniciais: widget.coresSelecionadasIniciais
                .where(
                  (corInicial) => coresAtivas.any(
                    (corAtiva) => _mesmaCor(corAtiva, corInicial),
                  ),
                )
                .toList(),
            onChanged: widget.onChanged,
            titulo: widget.titulo,
            hintText: 'Digite para buscar uma cor',
            maxSugestoes: 3,
            chipAvatarBuilder: (_, __) =>
                const Icon(Icons.palette_outlined, size: 16),
            sugestaoLeadingBuilder: (context, __) {
              final colorScheme = Theme.of(context).colorScheme;
              return CircleAvatar(
                radius: 14,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.palette,
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

  bool _mesmaCor(Cor a, Cor b) {
    if (a.id != null && b.id != null) {
      return a.id == b.id;
    }
    return a.nome == b.nome;
  }
}
