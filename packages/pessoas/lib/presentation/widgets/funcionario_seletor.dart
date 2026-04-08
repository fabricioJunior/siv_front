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

  FuncionarioSeletor({
    super.key,
    this.modo = FuncionarioSeletorModo.unica,
    this.funcionariosSelecionadosIniciais = const [],
    this.onFuncionarioChanged,
    this.titulo = 'Funcionários',
    this.onChanged,
  });

  @override
  State<FuncionarioSeletor> createState() => _FuncionarioSeletorState();

  @override
  List<SelectData> get itemsSelecionadosInicial =>
      funcionariosSelecionadosIniciais
          .map(
            (f) => SelectData(
              id: f.id,
              nome: f.nome,
              data: f.toJson(),
            ),
          )
          .toList();
}

class _FuncionarioSeletorState extends State<FuncionarioSeletor> {
  late final FuncionariosBloc _funcionariosBloc;

  @override
  void initState() {
    super.initState();
    _funcionariosBloc = sl<FuncionariosBloc>()..add(FuncionariosIniciou());
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

          if (state.funcionarios.isEmpty) {
            return _mensagem(
              context,
              'Nenhum funcionário disponível para seleção.',
              theme.colorScheme.onSurfaceVariant,
            );
          }

          final funcionariosAtivos =
              state.funcionarios.where((f) => !f.inativo).toList();

          return SeletorGenerico<Funcionario>(
            toSelectData: (item) => SelectData(
              id: item.id,
              nome: item.nome,
              data: item.toJson(),
            ),
            itens: funcionariosAtivos,
            itemLabel: (f) => f.nome,
            itemKey: (f) => f.id,
            modo: widget.modo == FuncionarioSeletorModo.unica
                ? SeletorGenericoModo.unica
                : SeletorGenericoModo.multipla,
            selecionadosIniciais: widget.funcionariosSelecionadosIniciais
                .where(
                  (inicial) =>
                      funcionariosAtivos.any((a) => a.id == inicial.id),
                )
                .toList(),
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
