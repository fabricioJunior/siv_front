import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/presentation/bloc/funcionarios_bloc/funcionarios_bloc.dart';

enum FuncionarioSeletorModo { unica, multipla }

// ignore: must_be_immutable
class FuncionarioSeletor extends StatefulWidget implements ISeletor {
  final FuncionarioSeletorModo modo;
  final List<Funcionario> funcionariosSelecionadosIniciais;
  final ValueChanged<List<Funcionario>>? onFuncionarioChanged;

  @override
  final Function(List<SelectData>)? onChanged;

  final String titulo;

  final bool onlyView;

  const FuncionarioSeletor({
    super.key,
    this.modo = FuncionarioSeletorModo.unica,
    this.funcionariosSelecionadosIniciais = const [],
    required this.itemsSelecionadosInicial,
    this.onFuncionarioChanged,
    this.titulo = 'Funcionários',
    this.onChanged,
    this.onlyView = false,
  });

  @override
  State<FuncionarioSeletor> createState() => _FuncionarioSeletorState();

  @override
  final List<SelectData>? itemsSelecionadosInicial;
}

class _FuncionarioSeletorState extends State<FuncionarioSeletor> {
  late final FuncionariosBloc _funcionariosBloc;

  @override
  void initState() {
    super.initState();
    _funcionariosBloc = sl<FuncionariosBloc>()
      ..add(FuncionariosIniciou(
          idFuncionarioSelecionado:
              widget.itemsSelecionadosInicial?.firstOrNull?.id));
  }

  @override
  void dispose() {
    _funcionariosBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<FuncionariosBloc>.value(
      value: _funcionariosBloc,
      child: BlocBuilder<FuncionariosBloc, FuncionariosState>(
        builder: (context, state) {
          if (state is FuncionariosCarregarEmProgresso) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (state is FuncionariosCarregarFalha) {
            return _mensagem(
              context,
              'Não foi possível carregar os funcionários.',
              theme.colorScheme.error,
            );
          }

          final funcionariosAtivos =
              state.funcionarios.where((f) => !f.inativo).toList();
          final idsSelecionadosIniciais = widget
              .funcionariosSelecionadosIniciais
              .map((funcionario) => funcionario.id)
              .toSet();
          final funcionariosSelecionados =
              widget.funcionariosSelecionadosIniciais
                  .map(
                    (funcionarioInicial) => state.funcionarios.firstWhere(
                      (funcionario) => funcionario.id == funcionarioInicial.id,
                      orElse: () => funcionarioInicial,
                    ),
                  )
                  .toList();
          final funcionariosDisponiveis = [
            ...funcionariosSelecionados,
            ...funcionariosAtivos.where(
              (funcionario) =>
                  !idsSelecionadosIniciais.contains(funcionario.id),
            ),
          ];

          if (funcionariosDisponiveis.isEmpty) {
            return _mensagem(
              context,
              'Nenhum funcionário disponível para seleção.',
              theme.colorScheme.onSurfaceVariant,
            );
          }

          return SeletorGenerico<Funcionario>(
            toSelectData: (item) => SelectData(
              id: item.id,
              nome: item.nome,
              data: item.toJson(),
            ),
            itens: funcionariosDisponiveis,
            itemLabel: (f) => f.nome,
            itemKey: (f) => f.id,
            onlyView: widget.onlyView,
            modo: widget.modo == FuncionarioSeletorModo.unica
                ? SeletorGenericoModo.unica
                : SeletorGenericoModo.multipla,
            selecionadosIniciais: state.funcionarioSelecionado != null
                ? [state.funcionarioSelecionado!]
                : widget.funcionariosSelecionadosIniciais,
            onChanged: (List<Funcionario> selecionados) {
              widget.onFuncionarioChanged?.call(selecionados);
              widget.onChanged?.call(
                selecionados
                    .map(
                      (f) => SelectData(
                        id: f.id,
                        nome: f.nome,
                        data: f.toJson(),
                      ),
                    )
                    .toList(),
              );
            },
            titulo: widget.titulo,
            hintText: 'Digite para buscar um funcionário',
            sugestaoLeadingBuilder: (context, _) {
              final colorScheme = Theme.of(context).colorScheme;
              return CircleAvatar(
                radius: 14,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
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
}
