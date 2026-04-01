import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'i_seletor.dart';

/// Define o comportamento de seleção do [SeletorGenerico].
enum SeletorGenericoModo { unica, multipla }

/// Campo de seleção com chips + autocomplete em overlay para qualquer tipo [T].
///
/// Exemplo:
/// ```dart
/// SeletorGenerico<Cor>(
///   itens: cores,
///   itemLabel: (cor) => cor.nome,
///   itemKey: (cor) => cor.id,
///   modo: SeletorGenericoModo.multipla,
///   selecionadosIniciais: const [],
///   onChanged: (selecionadas) {
///     // usar lista selecionada
///   },
///   titulo: 'Cores',
///   hintText: 'Digite para buscar',
///   confirmarEmSeparadores: const [',', ';'],
/// )
/// ```
class SeletorGenerico<T> extends StatefulWidget {
  /// Lista total de itens disponíveis para seleção.
  final List<T> itens;

  /// Função usada para exibir o texto de cada item.
  final String Function(T item) itemLabel;

  /// Chave estável para comparação de itens.
  ///
  /// Se não for informada, o texto retornado por [itemLabel] é usado.
  final Object? Function(T item)? itemKey;

  /// Modo de seleção (única ou múltipla).
  final SeletorGenericoModo modo;

  /// Itens já selecionados ao renderizar o widget.
  final List<T> selecionadosIniciais;

  /// Callback disparado a cada alteração da lista de seleção.
  final ValueChanged<List<T>>? onChanged;

  /// Rótulo exibido acima do campo.
  final String titulo;

  /// Texto de dica exibido no input.
  final String hintText;

  /// Quantidade máxima de sugestões exibidas no overlay.
  final int maxSugestoes;

  /// Builder opcional para avatar/ícone do chip selecionado.
  final Widget Function(BuildContext context, T item)? chipAvatarBuilder;

  /// Builder opcional para o ícone à esquerda da sugestão.
  final Widget Function(BuildContext context, T item)? sugestaoLeadingBuilder;

  /// Builder opcional para o ícone à direita da sugestão.
  final Widget Function(BuildContext context, T item)? sugestaoTrailingBuilder;

  /// Separadores que confirmam a melhor sugestão ao digitar.
  ///
  /// Exemplo comum: [',', ';'].
  final List<String> confirmarEmSeparadores;

  final SelectData Function(T item) toSelectData;
  const SeletorGenerico({
    super.key,
    required this.itens,
    required this.itemLabel,
    required this.toSelectData,
    this.itemKey,
    this.modo = SeletorGenericoModo.unica,
    this.selecionadosIniciais = const [],
    this.onChanged,
    this.titulo = 'Seleção',
    this.hintText = 'Digite para buscar',
    this.maxSugestoes = 5,
    this.chipAvatarBuilder,
    this.sugestaoLeadingBuilder,
    this.sugestaoTrailingBuilder,
    this.confirmarEmSeparadores = const [],
  });

  @override
  State<SeletorGenerico<T>> createState() => _SeletorGenericoState<T>();
}

class _SeletorGenericoState<T> extends State<SeletorGenerico<T>> {
  late List<T> _selecionados;
  late final TextEditingController _buscaController;
  late final FocusNode _buscaFocusNode;
  StreamSubscription<List<SelectData>>? _setDataSubscription;

  final LayerLink _fieldLayerLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();

  OverlayEntry? _sugestoesOverlayEntry;
  List<T> _sugestoesAtuais = const [];
  bool _deveExibirSugestoes = false;
  double _larguraCampo = 0;
  double _alturaCampo = 0;

  @override
  void initState() {
    super.initState();
    _selecionados = List<T>.from(widget.selecionadosIniciais);
    _buscaController = TextEditingController();
    _buscaFocusNode = FocusNode();

    _buscaController.addListener(() {
      setState(() {});
    });
    _buscaFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant SeletorGenerico<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final iniciaisMudaram = !_mesmaListaPorChave(
      oldWidget.selecionadosIniciais,
      widget.selecionadosIniciais,
    );

    if (iniciaisMudaram) {
      _selecionados = List<T>.from(widget.selecionadosIniciais);
    }
  }

  @override
  void dispose() {
    _setDataSubscription?.cancel();
    _removerOverlaySugestoes();
    _buscaController.dispose();
    _buscaFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final sugestoes = _filtrarSugestoes(widget.itens);
    _sugestoesAtuais = sugestoes;
    _deveExibirSugestoes = _buscaController.text.trim().isNotEmpty;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _atualizarDimensoesCampo();
      _sincronizarOverlaySugestoes(context);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(widget.titulo, style: theme.textTheme.titleMedium),
            ),
            Chip(
              label: Text(
                widget.modo == SeletorGenericoModo.unica
                    ? 'Seleção única'
                    : 'Seleção múltipla',
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 6),
        CompositedTransformTarget(
          link: _fieldLayerLink,
          child: AnimatedContainer(
            key: _fieldKey,
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _buscaFocusNode.hasFocus
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
                width: _buscaFocusNode.hasFocus ? 1.6 : 1,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ..._selecionados.map(
                      (item) => InputChip(
                        avatar: widget.chipAvatarBuilder?.call(context, item),
                        label: Text(widget.itemLabel(item)),
                        onDeleted: () => _removerItem(item),
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth,
                      child: Focus(
                        onKeyEvent: _onInputKeyEvent,
                        child: TextField(
                          controller: _buscaController,
                          focusNode: _buscaFocusNode,
                          decoration: InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            hintText: _hintText(),
                            hintStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                          onChanged: (value) {
                            final texto = value.trimRight();
                            if (texto.isEmpty) {
                              return;
                            }

                            final confirmou = widget.confirmarEmSeparadores.any(
                              (separador) =>
                                  separador.isNotEmpty &&
                                  texto.endsWith(separador),
                            );

                            if (!confirmou) {
                              return;
                            }

                            final melhor = _melhorCorrespondencia(
                              widget.itens,
                              sugestoes,
                            );
                            if (melhor != null) {
                              _selecionarItem(melhor);
                            }
                          },
                          onSubmitted: (_) {
                            final melhor = _melhorCorrespondencia(
                              widget.itens,
                              sugestoes,
                            );
                            if (melhor != null) {
                              _selecionarItem(melhor);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  KeyEventResult _onInputKeyEvent(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final isTab = event.logicalKey == LogicalKeyboardKey.tab;
    final isEnter = event.logicalKey == LogicalKeyboardKey.enter;
    final isNumpadEnter = event.logicalKey == LogicalKeyboardKey.numpadEnter;

    if (isTab || isEnter || isNumpadEnter) {
      final melhor = _melhorCorrespondencia(widget.itens, _sugestoesAtuais);
      if (melhor != null) {
        _selecionarItem(melhor);
        return KeyEventResult.handled;
      }
    }

    final isBackspace = event.logicalKey == LogicalKeyboardKey.backspace;
    final campoVazio = _buscaController.text.isEmpty;

    if (isBackspace && campoVazio && _selecionados.isNotEmpty) {
      _removerUltimoItem();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  String _hintText() {
    if (_selecionados.isEmpty) {
      return widget.hintText;
    }
    if (widget.modo == SeletorGenericoModo.unica) {
      return 'Substituir seleção';
    }
    return 'Adicionar item';
  }

  Object? _itemKey(T item) {
    return widget.itemKey?.call(item) ?? widget.itemLabel(item);
  }

  bool _mesmaListaPorChave(List<T> a, List<T> b) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }

    for (var i = 0; i < a.length; i++) {
      if (_itemKey(a[i]) != _itemKey(b[i])) {
        return false;
      }
    }

    return true;
  }

  bool _isSelecionado(T item) {
    final key = _itemKey(item);
    return _selecionados.any((selecionado) => _itemKey(selecionado) == key);
  }

  void _selecionarItem(T item) {
    final key = _itemKey(item);
    if (key == null) {
      return;
    }

    setState(() {
      if (widget.modo == SeletorGenericoModo.unica) {
        _selecionados = [item];
      } else {
        final jaSelecionado = _isSelecionado(item);
        if (jaSelecionado) {
          _selecionados = _selecionados
              .where((selecionado) => _itemKey(selecionado) != key)
              .toList();
        } else {
          _selecionados = [..._selecionados, item];
        }
      }

      _buscaController.clear();
    });

    widget.onChanged?.call(_selecionados);
    _removerOverlaySugestoes();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      FocusScope.of(context).requestFocus(_buscaFocusNode);
    });
  }

  void _removerItem(T item) {
    final key = _itemKey(item);
    setState(() {
      _selecionados = _selecionados
          .where((selecionado) => _itemKey(selecionado) != key)
          .toList();
    });

    widget.onChanged?.call(_selecionados);
  }

  void _removerUltimoItem() {
    if (_selecionados.isEmpty) {
      return;
    }

    setState(() {
      var texto = widget.itemLabel(_selecionados.last);
      _buscaController.text = texto.substring(0, texto.length - 1);
      _selecionados =
          _selecionados.sublist(0, _selecionados.length - 1).toList();
    });

    widget.onChanged?.call(_selecionados);
  }

  List<T> _filtrarSugestoes(List<T> itens) {
    final busca = _buscaController.text.trim().toLowerCase();
    if (busca.isEmpty) {
      return [];
    }

    final filtradas = itens.where((item) {
      final label = widget.itemLabel(item).toLowerCase();
      final selecionado = _isSelecionado(item);

      if (widget.modo == SeletorGenericoModo.multipla && selecionado) {
        return false;
      }

      return label.contains(busca);
    }).toList();

    filtradas.sort((a, b) {
      final aLabel = widget.itemLabel(a).toLowerCase();
      final bLabel = widget.itemLabel(b).toLowerCase();

      final aStarts = aLabel.startsWith(busca);
      final bStarts = bLabel.startsWith(busca);
      if (aStarts != bStarts) {
        return aStarts ? -1 : 1;
      }

      final aIndex = aLabel.indexOf(busca);
      final bIndex = bLabel.indexOf(busca);
      if (aIndex != bIndex) {
        return aIndex.compareTo(bIndex);
      }

      return aLabel.length.compareTo(bLabel.length);
    });

    return filtradas.take(widget.maxSugestoes).toList();
  }

  T? _melhorCorrespondencia(List<T> itens, List<T> sugestoes) {
    if (sugestoes.isNotEmpty) {
      return sugestoes.first;
    }

    final busca = _buscaController.text.trim().toLowerCase();
    if (busca.isEmpty) {
      return null;
    }

    final exata = itens.where((item) {
      final label = widget.itemLabel(item).toLowerCase();
      final selecionado = _isSelecionado(item);

      if (widget.modo == SeletorGenericoModo.multipla && selecionado) {
        return false;
      }

      return label == busca;
    });

    return exata.isNotEmpty ? exata.first : null;
  }

  void _atualizarDimensoesCampo() {
    final renderBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }

    final largura = renderBox.size.width;
    final altura = renderBox.size.height;
    if (largura != _larguraCampo || altura != _alturaCampo) {
      _larguraCampo = largura;
      _alturaCampo = altura;
      _sugestoesOverlayEntry?.markNeedsBuild();
    }
  }

  void _sincronizarOverlaySugestoes(BuildContext context) {
    if (!_deveExibirSugestoes) {
      _removerOverlaySugestoes();
      return;
    }

    if (_sugestoesOverlayEntry == null) {
      _sugestoesOverlayEntry = OverlayEntry(
        builder: (_) => _buildSugestoesOverlay(context),
      );
      Overlay.of(context, rootOverlay: true).insert(_sugestoesOverlayEntry!);
      return;
    }

    _sugestoesOverlayEntry?.markNeedsBuild();
  }

  Widget _buildSugestoesOverlay(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              _buscaFocusNode.unfocus();
              _buscaController.clear();
            },
            child: const SizedBox.expand(),
          ),
          CompositedTransformFollower(
            link: _fieldLayerLink,
            showWhenUnlinked: false,
            offset: Offset(0, _alturaCampo + 6),
            child: Material(
              elevation: 4,
              color: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 220,
                  minWidth: _larguraCampo,
                  maxWidth: _larguraCampo,
                ),
                child: _sugestoesAtuais.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Nenhum item encontrado.',
                          style: theme.textTheme.bodySmall,
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: _sugestoesAtuais.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: theme.colorScheme.outlineVariant,
                        ),
                        itemBuilder: (context, index) {
                          final item = _sugestoesAtuais[index];
                          return ListTile(
                            dense: true,
                            leading: widget.sugestaoLeadingBuilder?.call(
                              context,
                              item,
                            ),
                            trailing: widget.sugestaoTrailingBuilder?.call(
                              context,
                              item,
                            ),
                            title: Text(widget.itemLabel(item)),
                            onTap: () => _selecionarItem(item),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _removerOverlaySugestoes() {
    _sugestoesOverlayEntry?.remove();
    _sugestoesOverlayEntry = null;
  }
}
