import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Bloco de filtro da consulta (mobile): rótulo, chips removíveis e "+ botão"
/// que abre o [SeletorTelaCheia]. Os itens vêm do bloc [B] criado via `sl` só
/// enquanto o seletor está aberto.
class FiltroVariacaoConsulta<T, B extends BlocBase<S>, S> extends StatelessWidget {
  final String chave;
  final String rotulo;
  final String botao;
  final String titulo;
  final String singular;
  final String plural;
  final bool feminino;
  final List<T> selecionados;
  final ValueChanged<List<T>> onChanged;
  final int Function(T) id;
  final String Function(T) nome;
  final void Function(B bloc) carregar;
  final List<T> Function(S) itens;
  final bool Function(S) carregando;
  final bool Function(S) falhou;

  const FiltroVariacaoConsulta({
    super.key,
    required this.chave,
    required this.rotulo,
    required this.botao,
    required this.titulo,
    required this.singular,
    required this.plural,
    required this.selecionados,
    required this.onChanged,
    required this.id,
    required this.nome,
    required this.carregar,
    required this.itens,
    required this.carregando,
    required this.falhou,
    this.feminino = true,
  });

  Future<void> _abrir(BuildContext context) async {
    final bloc = sl<B>();
    carregar(bloc);
    final r = await Navigator.of(context).push<List<T>>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _Tela<T, B, S>(filtro: this, bloc: bloc),
      ),
    );
    if (r != null) onChanged(r);
    unawaited(bloc.close());
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final n = selecionados.length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              n == 0 ? rotulo : '$rotulo ($n)',
              style: textos.rotulo.copyWith(color: cores.aco),
            ),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in selecionados)
                InputChip(
                  key: Key('chip_${chave}_${id(s)}'),
                  label: Text(nome(s)),
                  onDeleted: () => onChanged([
                    for (final o in selecionados)
                      if (id(o) != id(s)) o,
                  ]),
                ),
              OutlinedButton(
                key: Key('add_$chave'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(48, 44)),
                onPressed: () => _abrir(context),
                child: Text(botao),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tela<T, B extends BlocBase<S>, S> extends StatelessWidget {
  final FiltroVariacaoConsulta<T, B, S> filtro;
  final B bloc;

  const _Tela({required this.filtro, required this.bloc});

  @override
  Widget build(BuildContext context) => BlocBuilder<B, S>(
        bloc: bloc,
        builder: (context, s) => SeletorTelaCheia<T>(
          titulo: filtro.titulo,
          itens: filtro.itens(s),
          itemLabel: filtro.nome,
          itemKey: filtro.id,
          selecionadosIniciais: filtro.selecionados,
          nomeSingular: filtro.singular,
          nomePlural: filtro.plural,
          feminino: filtro.feminino,
          hintText: 'Buscar ${filtro.singular}',
          carregando: filtro.carregando(s),
          erro: filtro.falhou(s) ? 'Não foi possível carregar ${filtro.plural}.' : null,
          onTentarNovamente: () => filtro.carregar(bloc),
        ),
      );
}
