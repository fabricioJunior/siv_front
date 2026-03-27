import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/blocs/tamanhos_bloc/tamanhos_bloc.dart';
import 'package:core/seletores.dart';

enum TamanhoSeletorModo { unica, multipla }

// ignore: must_be_immutable
class TamanhoSeletor extends StatefulWidget
    with SeletorMixin
    implements ISeletor {
  final TamanhoSeletorModo modo;
  final List<Tamanho> tamanhosSelecionadosIniciais;
  final ValueChanged<List<Tamanho>>? onChanged;
  final String titulo;

  TamanhoSeletor({
    super.key,
    this.modo = TamanhoSeletorModo.unica,
    this.tamanhosSelecionadosIniciais = const [],
    this.onChanged,
    this.titulo = 'Tamanhos',
  });

  @override
  State<TamanhoSeletor> createState() => _TamanhoSeletorState();

  @override
  List<SelectData> get itemsSelecionadosInicial => tamanhosSelecionadosIniciais
      .map(
        (tamanho) => SelectData(
          id: tamanho.id ?? 0,
          nome: tamanho.nome,
          data: {'tamanho': tamanho.toString()},
        ),
      )
      .toList();

  @override
  StreamController<List<SelectData>>? controller = StreamController.broadcast();

  @override
  Stream<List<SelectData>>? get onDataSelected => controller?.stream;
}

class _TamanhoSeletorState extends State<TamanhoSeletor> {
  late final TamanhosBloc _tamanhosBloc;
  StreamSubscription<List<SelectData>>? _setDataSubscription;
  Set<int>? _idsExternosSelecionados;

  @override
  void initState() {
    super.initState();
    _tamanhosBloc = sl<TamanhosBloc>()..add(TamanhosIniciou(inativo: false));

    _setDataSubscription = widget.setDataController.stream.listen((dados) {
      setState(() {
        _idsExternosSelecionados = dados.map((d) => d.id).toSet();
      });
    });
  }

  @override
  void dispose() {
    _setDataSubscription?.cancel();
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
            selecionadosIniciais: _idsExternosSelecionados != null
                ? tamanhosAtivos
                      .where((t) => _idsExternosSelecionados!.contains(t.id))
                      .toList()
                : widget.tamanhosSelecionadosIniciais
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
            toSelectData: (Tamanho item) {
              return SelectData(
                id: item.id!,
                nome: item.nome,
                data: {'tamanho': item.toString()},
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

  bool _mesmoTamanho(Tamanho a, Tamanho b) {
    if (a.id != null && b.id != null) {
      return a.id == b.id;
    }
    return a.nome == b.nome;
  }
}
