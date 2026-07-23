import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/blocs/etiquetas_bloc/etiquetas_bloc.dart';

enum EtiquetaSeletorModo { unica, multipla }

// ignore: must_be_immutable
class EtiquetaSeletor extends StatefulWidget implements ISeletor {
  final EtiquetaSeletorModo modo;
  final List<Etiqueta> etiquetasSelecionadasIniciais;
  final List<int> idEtiquetasSelecionadasIniciais;
  final ValueChanged<List<Etiqueta>>? onEtiquetaChanged;

  @override
  final Function(List<SelectData>)? onChanged;

  final String titulo;

  const EtiquetaSeletor({
    super.key,
    this.modo = EtiquetaSeletorModo.unica,
    this.etiquetasSelecionadasIniciais = const [],
    this.idEtiquetasSelecionadasIniciais = const [],
    this.onEtiquetaChanged,
    this.onChanged,
    this.titulo = 'Etiquetas',
  });

  @override
  State<EtiquetaSeletor> createState() => _EtiquetaSeletorState();

  @override
  List<SelectData> get itemsSelecionadosInicial => etiquetasSelecionadasIniciais
      .map(
        (etiqueta) => SelectData(
          id: etiqueta.id ?? 0,
          nome: etiqueta.nome,
          data: {
            'etiqueta': etiqueta.toString(),
            'vias': etiqueta.vias
                .map((item) => item.zpl)
                .toList(growable: false),
          },
        ),
      )
      .toList();
}

class _EtiquetaSeletorState extends State<EtiquetaSeletor> {
  late final EtiquetasBloc _etiquetasBloc;
  Set<int>? _idsExternosSelecionados;

  @override
  void initState() {
    super.initState();
    _idsExternosSelecionados = widget.idEtiquetasSelecionadasIniciais.isEmpty
        ? null
        : widget.idEtiquetasSelecionadasIniciais.toSet();
    _etiquetasBloc = sl<EtiquetasBloc>()..add(EtiquetasIniciou());
  }

  @override
  void dispose() {
    _etiquetasBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<EtiquetasBloc>.value(
      value: _etiquetasBloc,
      child: BlocBuilder<EtiquetasBloc, EtiquetasState>(
        builder: (context, state) {
          if (state is EtiquetasCarregarEmProgresso &&
              state.etiquetas.isEmpty) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (state is EtiquetasCarregarFalha && state.etiquetas.isEmpty) {
            return _mensagem(
              context,
              'Não foi possível carregar as etiquetas.',
              theme.colorScheme.error,
            );
          }

          if (state.etiquetas.isEmpty) {
            return _mensagem(
              context,
              'Nenhuma etiqueta disponível para seleção.',
              theme.colorScheme.onSurfaceVariant,
            );
          }

          return SeletorGenerico<Etiqueta>(
            itens: state.etiquetas,
            itemLabel: _itemLabel,
            itemKey: (etiqueta) => etiqueta.id ?? etiqueta.nome,
            modo: widget.modo == EtiquetaSeletorModo.unica
                ? SeletorGenericoModo.unica
                : SeletorGenericoModo.multipla,
            selecionadosIniciais: _idsExternosSelecionados != null
                ? state.etiquetas
                      .where((e) => _idsExternosSelecionados!.contains(e.id))
                      .toList()
                : widget.etiquetasSelecionadasIniciais
                      .where(
                        (etiquetaInicial) => state.etiquetas.any(
                          (etiqueta) =>
                              _mesmaEtiqueta(etiqueta, etiquetaInicial),
                        ),
                      )
                      .toList(),
            onChanged: (selecionadas) {
              widget.onEtiquetaChanged?.call(selecionadas);
              widget.onChanged?.call(
                selecionadas
                    .map(
                      (etiqueta) => SelectData(
                        id: etiqueta.id ?? 0,
                        nome: etiqueta.nome,
                        data: {
                          'etiqueta': etiqueta.toString(),
                          'vias': etiqueta.vias
                              .map((item) => item.zpl)
                              .toList(growable: false),
                        },
                      ),
                    )
                    .toList(),
              );
            },
            titulo: widget.titulo,
            hintText: 'Digite para buscar uma etiqueta',
            maxSugestoes: 5,
            chipAvatarBuilder: (_, __) =>
                const Icon(Icons.print_outlined, size: 16),
            sugestaoLeadingBuilder: (context, __) {
              final colorScheme = Theme.of(context).colorScheme;
              return CircleAvatar(
                radius: 14,
                backgroundColor: colorScheme.secondaryContainer,
                child: Icon(
                  Icons.qr_code_2_outlined,
                  size: 14,
                  color: colorScheme.onSecondaryContainer,
                ),
              );
            },
            confirmarEmSeparadores: const [',', ';'],
            toSelectData: (Etiqueta item) {
              return SelectData(
                id: item.id!,
                nome: item.nome,
                data: {
                  'etiqueta': item.toString(),
                  'vias': item.vias
                      .map((via) => via.zpl)
                      .toList(growable: false),
                },
              );
            },
          );
        },
      ),
    );
  }

  String _itemLabel(Etiqueta etiqueta) {
    final id = etiqueta.id == null ? 'sem ID' : etiqueta.id.toString();
    final largura = etiqueta.largura.toStringAsFixed(0);
    final altura = etiqueta.altura.toStringAsFixed(0);
    return '($id) ${etiqueta.nome} - ${etiqueta.vias.length} via(s) - ${largura}x$altura mm - ${etiqueta.dpi.valor} DPI';
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

  bool _mesmaEtiqueta(Etiqueta a, Etiqueta b) {
    if (a.id != null && b.id != null) {
      return a.id == b.id;
    }
    return a.nome == b.nome &&
        a.largura == b.largura &&
        a.altura == b.altura &&
        a.dpi == b.dpi &&
        a.vias.length == b.vias.length;
  }
}
