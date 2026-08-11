import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:empresas/domain/entities/empresa.dart';
import 'package:empresas/presentation/blocs/empresas_bloc/empresas_bloc.dart';
import 'package:flutter/material.dart';

enum EmpresaSeletorModo { unica, multipla }

// ignore: must_be_immutable
class EmpresaSeletor extends StatefulWidget implements ISeletor {
  final EmpresaSeletorModo modo;
  final List<Empresa> empresasSelecionadasIniciais;
  final ValueChanged<List<Empresa>>? onEmpresaChanged;

  @override
  final List<SelectData>? itemsSelecionadosInicial;

  @override
  final Function(List<SelectData>)? onChanged;

  final String? titulo;
  final bool onlyView;

  const EmpresaSeletor({
    super.key,
    this.modo = EmpresaSeletorModo.unica,
    this.itemsSelecionadosInicial,
    this.empresasSelecionadasIniciais = const [],
    this.onEmpresaChanged,
    this.titulo,
    this.onChanged,
    this.onlyView = false,
  });

  @override
  State<EmpresaSeletor> createState() => _EmpresaSeletorState();
}

class _EmpresaSeletorState extends State<EmpresaSeletor> {
  late final EmpresasBloc _empresasBloc;

  @override
  void initState() {
    super.initState();
    _empresasBloc = sl<EmpresasBloc>()..add(EmpresasIniciou());
  }

  @override
  void dispose() {
    _empresasBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<EmpresasBloc>.value(
      value: _empresasBloc,
      child: BlocBuilder<EmpresasBloc, EmpresasState>(
        builder: (context, state) {
          if (state is EmpresasCarregarEmProgresso ||
              state is EmpresasNaoInicializado) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (state is EmpresasCarregarFalha) {
            return _mensagem(
              context,
              'Não foi possível carregar as empresas.',
              theme.colorScheme.error,
            );
          }

          final empresas = (state as EmpresasCarregarSucesso).empresas;
          final idsIniciais = {
            ...widget.empresasSelecionadasIniciais
                .map((empresa) => empresa.id)
                .whereType<int>(),
            ...(widget.itemsSelecionadosInicial ?? const <SelectData>[])
                .map((item) => item.id),
          };

          if (empresas.isEmpty) {
            return _mensagem(
              context,
              'Nenhuma empresa disponível para seleção.',
              theme.colorScheme.onSurfaceVariant,
            );
          }

          return SeletorGenerico<Empresa>(
            toSelectData: _toSelectData,
            itens: empresas,
            itemLabel: (empresa) => empresa.nomeFantasia,
            itemKey: (empresa) => empresa.id ?? empresa.nomeFantasia,
            modo: widget.modo == EmpresaSeletorModo.unica
                ? SeletorGenericoModo.unica
                : SeletorGenericoModo.multipla,
            selecionadosIniciais: empresas
                .where((empresa) => idsIniciais.contains(empresa.id))
                .toList(),
            onlyView: widget.onlyView,
            onChanged: (selecionadas) {
              widget.onEmpresaChanged?.call(selecionadas);
              widget.onChanged?.call(
                selecionadas.map(_toSelectData).toList(),
              );
            },
            titulo: widget.titulo ??
                (widget.modo == EmpresaSeletorModo.unica
                    ? 'Empresa'
                    : 'Empresas'),
            hintText: 'Digite para buscar uma empresa',
            maxSugestoes: 5,
            chipAvatarBuilder: (_, __) =>
                const Icon(Icons.store_outlined, size: 16),
            sugestaoLeadingBuilder: (context, __) {
              final colorScheme = Theme.of(context).colorScheme;
              return CircleAvatar(
                radius: 14,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.store_outlined,
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

  SelectData _toSelectData(Empresa empresa) {
    return SelectData(
      id: empresa.id ?? 0,
      nome: empresa.nomeFantasia,
      data: {'id': empresa.id, 'nomeFantasia': empresa.nomeFantasia},
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
