import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:empresas/domain/entities/terminal.dart';
import 'package:empresas/presentation/blocs/terminais_bloc/terminais_bloc.dart';
import 'package:flutter/material.dart';

enum TerminalSeletorModo { unica, multipla }

// ignore: must_be_immutable
class TerminalSeletor extends StatefulWidget implements ISeletor {
  final int empresaId;
  final TerminalSeletorModo modo;
  final List<Terminal> terminaisSelecionadosIniciais;
  final ValueChanged<List<Terminal>>? onTerminalChanged;
  // Backend hoje não expõe filtro de terminais por tipo via query param -- filtra client-side na
  // lista já carregada da empresa.
  final String? tipoFiltro;

  @override
  final List<SelectData>? itemsSelecionadosInicial;

  @override
  final Function(List<SelectData>)? onChanged;

  final String? titulo;
  final bool onlyView;

  const TerminalSeletor({
    super.key,
    required this.empresaId,
    this.modo = TerminalSeletorModo.unica,
    this.itemsSelecionadosInicial,
    this.terminaisSelecionadosIniciais = const [],
    this.onTerminalChanged,
    this.tipoFiltro,
    this.titulo,
    this.onChanged,
    this.onlyView = false,
  });

  @override
  State<TerminalSeletor> createState() => _TerminalSeletorState();
}

class _TerminalSeletorState extends State<TerminalSeletor> {
  late final TerminaisBloc _terminaisBloc;

  @override
  void initState() {
    super.initState();
    _terminaisBloc = sl<TerminaisBloc>()
      ..add(TerminaisIniciou(empresaId: widget.empresaId, inativo: false));
  }

  @override
  void dispose() {
    _terminaisBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<TerminaisBloc>.value(
      value: _terminaisBloc,
      child: BlocBuilder<TerminaisBloc, TerminaisState>(
        builder: (context, state) {
          if (state is TerminaisInitial ||
              state is TerminaisCarregarEmProgresso) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (state is TerminaisCarregarFalha) {
            return _mensagem(
              context,
              'Não foi possível carregar os terminais.',
              theme.colorScheme.error,
            );
          }

          final terminais = widget.tipoFiltro == null
              ? state.terminais
              : state.terminais
                  .where((terminal) => terminal.tipo == widget.tipoFiltro)
                  .toList();

          final idsIniciais = {
            ...widget.terminaisSelecionadosIniciais
                .map((terminal) => terminal.id)
                .whereType<int>(),
            ...(widget.itemsSelecionadosInicial ?? const <SelectData>[])
                .map((item) => item.id),
          };

          if (terminais.isEmpty) {
            return _mensagem(
              context,
              'Nenhum terminal disponível para seleção.',
              theme.colorScheme.onSurfaceVariant,
            );
          }

          return SeletorGenerico<Terminal>(
            toSelectData: _toSelectData,
            itens: terminais,
            itemLabel: (terminal) => terminal.nome,
            itemKey: (terminal) => terminal.id ?? terminal.nome,
            modo: widget.modo == TerminalSeletorModo.unica
                ? SeletorGenericoModo.unica
                : SeletorGenericoModo.multipla,
            selecionadosIniciais: terminais
                .where((terminal) => idsIniciais.contains(terminal.id))
                .toList(),
            onlyView: widget.onlyView,
            onChanged: (selecionadas) {
              widget.onTerminalChanged?.call(selecionadas);
              widget.onChanged?.call(
                selecionadas.map(_toSelectData).toList(),
              );
            },
            titulo: widget.titulo ??
                (widget.modo == TerminalSeletorModo.unica
                    ? 'Terminal'
                    : 'Terminais'),
            hintText: 'Digite para buscar um terminal',
            maxSugestoes: 5,
            chipAvatarBuilder: (_, __) =>
                const Icon(Icons.point_of_sale_outlined, size: 16),
            sugestaoLeadingBuilder: (context, __) {
              final colorScheme = Theme.of(context).colorScheme;
              return CircleAvatar(
                radius: 14,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.point_of_sale_outlined,
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

  SelectData _toSelectData(Terminal terminal) {
    return SelectData(
      id: terminal.id ?? 0,
      nome: terminal.nome,
      data: {'id': terminal.id, 'nome': terminal.nome, 'tipo': terminal.tipo},
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
