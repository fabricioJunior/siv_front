import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';
import 'package:core/seletores.dart';

enum EstampaSeletorModo { unica, multipla }

// ignore: must_be_immutable
class EstampaSeletor extends StatefulWidget implements ISeletor {
  final EstampaSeletorModo modo;
  final List<Estampa> estampasSelecionadasIniciais;
  final ValueChanged<List<Estampa>>? onEstampasChanged;

  @override
  final Function(List<SelectData>)? onChanged;
  final String titulo;

  const EstampaSeletor({
    super.key,
    this.modo = EstampaSeletorModo.unica,
    this.estampasSelecionadasIniciais = const [],
    this.onEstampasChanged,
    this.onChanged,
    this.titulo = 'Estampas',
  });

  @override
  State<EstampaSeletor> createState() => _EstampaSeletorState();

  @override
  List<SelectData> get itemsSelecionadosInicial => estampasSelecionadasIniciais
      .map(
        (estampa) => SelectData(
          id: estampa.id ?? 0,
          nome: estampa.nome,
          data: {'estampa': estampa.toString()},
        ),
      )
      .toList();
}

class _EstampaSeletorState extends State<EstampaSeletor> {
  late final EstampasBloc _estampasBloc;
  Set<int>? _idsExternosSelecionados;

  @override
  void initState() {
    super.initState();
    _estampasBloc = sl<EstampasBloc>()..add(EstampasIniciou(inativo: false));
  }

  @override
  void dispose() {
    _estampasBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<EstampasBloc>.value(
      value: _estampasBloc,
      child: BlocBuilder<EstampasBloc, EstampasState>(
        builder: (context, state) {
          if (state is EstampasCarregarEmProgresso ||
              state is EstampasDesativarEmProgresso) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (state is EstampasCarregarFalha ||
              state is EstampasDesativarFalha) {
            return _mensagem(
              context,
              'Não foi possível carregar as estampas.',
              theme.colorScheme.error,
            );
          }

          if (state.estampas.isEmpty) {
            return _mensagem(
              context,
              'Nenhuma estampa disponível para seleção.',
              theme.colorScheme.onSurfaceVariant,
            );
          }

          final estampasAtivas = state.estampas
              .where((estampa) => !estampa.inativo)
              .toList();

          return SeletorGenerico<Estampa>(
            itens: estampasAtivas,
            itemLabel: (estampa) => estampa.nome,
            itemKey: (estampa) => estampa.id ?? estampa.nome,
            modo: widget.modo == EstampaSeletorModo.unica
                ? SeletorGenericoModo.unica
                : SeletorGenericoModo.multipla,
            selecionadosIniciais: _idsExternosSelecionados != null
                ? estampasAtivas
                      .where((t) => _idsExternosSelecionados!.contains(t.id))
                      .toList()
                : widget.estampasSelecionadasIniciais
                      .where(
                        (estampaInicial) => estampasAtivas.any(
                          (estampaAtiva) =>
                              _mesmaEstampa(estampaAtiva, estampaInicial),
                        ),
                      )
                      .toList(),
            onChanged: (dados) {
              widget.onEstampasChanged?.call(dados);
              widget.onChanged?.call(
                dados.map((t) {
                  return SelectData(
                    id: t.id ?? 0,
                    nome: t.nome,
                    data: {'estampa': t.toString()},
                  );
                }).toList(),
              );
            },
            titulo: widget.titulo,
            hintText: 'Digite para buscar uma estampa',
            maxSugestoes: 3,
            chipAvatarBuilder: (_, __) =>
                const Icon(Icons.texture_outlined, size: 16),
            sugestaoLeadingBuilder: (context, __) {
              final colorScheme = Theme.of(context).colorScheme;
              return CircleAvatar(
                radius: 14,
                backgroundColor: colorScheme.secondaryContainer,
                child: Icon(
                  Icons.texture,
                  size: 14,
                  color: colorScheme.onSecondaryContainer,
                ),
              );
            },
            confirmarEmSeparadores: const [',', ';'],
            toSelectData: (Estampa item) {
              return SelectData(
                id: item.id!,
                nome: item.nome,
                data: {'estampa': item.toString()},
              );
            },
            cadastrarLabel: 'Cadastrar estampa',
            onCadastrarPressed: () async {
              final salvou = await EstampaModal.show(context: context);
              if (salvou == true) {
                _estampasBloc.add(EstampasIniciou(inativo: false));
              }
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

  bool _mesmaEstampa(Estampa a, Estampa b) {
    if (a.id != null && b.id != null) {
      return a.id == b.id;
    }
    return a.nome == b.nome;
  }
}
