import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/presentation/blocs/formas_de_pagamento_bloc/formas_de_pagamento_bloc.dart';
import 'package:flutter/material.dart';

enum FormasDePagamentoSeletorModo { unica, multipla }

// ignore: must_be_immutable
class FormasDePagamentoSeletor extends StatefulWidget implements ISeletor {
  final FormasDePagamentoSeletorModo modo;
  final List<FormaDePagamento> formasSelecionadasIniciais;
  final ValueChanged<List<FormaDePagamento>>? onFormaDePagamentoChanged;
  final String titulo;
  final bool onlyView;

  @override
  final List<SelectData>? itemsSelecionadosInicial;

  @override
  final Function(List<SelectData>)? onChanged;

  const FormasDePagamentoSeletor({
    super.key,
    this.modo = FormasDePagamentoSeletorModo.unica,
    this.formasSelecionadasIniciais = const [],
    this.onFormaDePagamentoChanged,
    this.titulo = 'Formas de pagamento',
    this.onlyView = false,
    this.itemsSelecionadosInicial,
    this.onChanged,
  });

  @override
  State<FormasDePagamentoSeletor> createState() =>
      _FormasDePagamentoSeletorState();
}

class _FormasDePagamentoSeletorState extends State<FormasDePagamentoSeletor> {
  late final FormasDePagamentoBloc _formasBloc;

  @override
  void initState() {
    super.initState();
    _formasBloc = sl<FormasDePagamentoBloc>()..add(FormasDePagamentoIniciou());
  }

  @override
  void dispose() {
    _formasBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<FormasDePagamentoBloc>.value(
      value: _formasBloc,
      child: BlocBuilder<FormasDePagamentoBloc, FormasDePagamentoState>(
        builder: (context, state) {
          if (state is FormasDePagamentoCarregarEmProgresso ||
              state is FormasDePagamentoInitial) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (state is FormasDePagamentoCarregarFalha) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Não foi possível carregar as formas de pagamento.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            );
          }

          final formasDisponiveis = state.formasDePagamento
              .where((forma) => !forma.inativa)
              .toList(growable: false);

          if (formasDisponiveis.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Nenhuma forma de pagamento disponível para seleção.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          final selecionadosIniciais = _resolverSelecionadosIniciais(
            formasDisponiveis,
          );

          return SeletorGenerico<FormaDePagamento>(
            toSelectData: _toSelectData,
            itens: formasDisponiveis,
            itemLabel: (forma) => forma.descricao,
            itemKey: (forma) => forma.id ?? forma.descricao,
            modo: widget.modo == FormasDePagamentoSeletorModo.unica
                ? SeletorGenericoModo.unica
                : SeletorGenericoModo.multipla,
            selecionadosIniciais: selecionadosIniciais,
            onlyView: widget.onlyView,
            onChanged: (selecionadas) {
              widget.onFormaDePagamentoChanged?.call(selecionadas);
              widget.onChanged?.call(
                selecionadas.map(_toSelectData).toList(growable: false),
              );
            },
            titulo: widget.titulo,
            hintText: 'Digite para buscar uma forma de pagamento',
            // Lista de formas de pagamento normalmente é curta (poucas
            // dezenas) e agora o dropdown de sugestões rola de verdade --
            // 5 escondia opções em telas com muitas formas cadastradas.
            maxSugestoes: 30,
            chipAvatarBuilder: (_, __) =>
                const Icon(Icons.payments_outlined, size: 16),
            sugestaoLeadingBuilder: (context, __) {
              final colorScheme = Theme.of(context).colorScheme;
              return CircleAvatar(
                radius: 14,
                backgroundColor: colorScheme.secondaryContainer,
                child: Icon(
                  Icons.credit_card,
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

  List<FormaDePagamento> _resolverSelecionadosIniciais(
    List<FormaDePagamento> formasDisponiveis,
  ) {
    if (widget.formasSelecionadasIniciais.isNotEmpty) {
      return widget.formasSelecionadasIniciais;
    }

    final ids = (widget.itemsSelecionadosInicial ?? const <SelectData>[])
        .map((item) => item.id)
        .toSet();

    if (ids.isEmpty) return const [];

    return formasDisponiveis
        .where((forma) => forma.id != null && ids.contains(forma.id))
        .toList(growable: false);
  }

  SelectData _toSelectData(FormaDePagamento forma) {
    return SelectData(
      id: forma.id ?? 0,
      nome: forma.descricao,
      data: {
        'id': forma.id,
        'descricao': forma.descricao,
        'parcelas': forma.parcelas,
        'tipo': forma.tipo,
        'inicio': forma.inicio,
        'inativa': forma.inativa,
      },
    );
  }
}