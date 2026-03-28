import 'package:core/bloc.dart';
import 'package:core/leitor/data_source/i_leitor_data_datasource.dart';
import 'package:core/leitor/leitor_bloc/leitor_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LeitorController extends ChangeNotifier {
  LeitorBloc? _bloc;
  LeitorState _state = LeitorState.initial();

  LeitorState get state => _state;
  List<LeitorItemContado> get itens => List.unmodifiable(_state.itens);
  LeitorItemContado? get ultimoProdutoLido => _state.ultimoProdutoLido;
  String? get ultimoErro => _state.erro;
  int get quantidadeTotalLida => _state.quantidadeTotalLida;
  int get quantidadeItensDistintos => _state.itens.length;
  bool get controlarQuantidade => _state.controlarQuantidade;

  List<Map<String, dynamic>> get dadosAtuais {
    return _state.itens
        .map(
          (item) => {
            'codigoDeBarras': item.codigoDeBarras,
            'descricao': item.descricao,
            'quantidadeLida': item.quantidadeLida,
            'estoqueDisponivel': item.estoqueDisponivel,
            ...item.dados,
          },
        )
        .toList(growable: false);
  }

  void bind(LeitorBloc bloc) {
    _bloc = bloc;
    syncState(bloc.state);
  }

  void unbind(LeitorBloc bloc) {
    if (identical(_bloc, bloc)) {
      _bloc = null;
    }
  }

  void syncState(LeitorState state) {
    _state = state;
    notifyListeners();
  }

  void lerCodigo(String codigo) {
    _bloc?.add(LeitorCodigoInformado(codigo));
  }

  void removerQuantidade(String codigo, {int quantidade = 1}) {
    _bloc?.add(
      LeitorQuantidadeRemovida(codigo: codigo, quantidade: quantidade),
    );
  }

  void removerItem(String codigo) {
    _bloc?.add(LeitorItemExcluido(codigo));
  }

  void limpar() {
    _bloc?.add(const LeitorReiniciado());
  }
}

class LeitorWidget extends StatefulWidget {
  final bool controlarQuantidade;
  final ILeitorDataDatasource dataSource;
  final LeitorController? controller;
  final ValueChanged<LeitorItemContado>? onUltimoProdutoLido;
  final ValueChanged<String>? onErro;
  final ValueChanged<String>? onAviso;
  final String campoCodigoHint;
  final double alturaLista;
  final bool autofocus;

  const LeitorWidget({
    super.key,
    required this.dataSource,
    this.controlarQuantidade = false,
    this.controller,
    this.onUltimoProdutoLido,
    this.onErro,
    this.onAviso,
    this.campoCodigoHint = 'Bipe ou informe o código de barras',
    this.alturaLista = 320,
    this.autofocus = true,
  });

  @override
  State<LeitorWidget> createState() => _LeitorWidgetState();
}

class _LeitorWidgetState extends State<LeitorWidget> {
  late LeitorBloc _bloc;
  late LeitorController _controller;
  late final TextEditingController _codigoController;
  late final FocusNode _codigoFocusNode;
  bool _controllerInterno = false;

  @override
  void initState() {
    super.initState();
    _codigoController = TextEditingController();
    _codigoFocusNode = FocusNode();
    _controllerInterno = widget.controller == null;
    _controller = widget.controller ?? LeitorController();
    _bloc = _criarBloc();
    _controller.bind(_bloc);
  }

  @override
  void didUpdateWidget(covariant LeitorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.dataSource != widget.dataSource ||
        oldWidget.controlarQuantidade != widget.controlarQuantidade) {
      _controller.unbind(_bloc);
      _bloc.close();
      _bloc = _criarBloc();
      _controller.bind(_bloc);
    }

    if (oldWidget.controller != widget.controller) {
      _controller.unbind(_bloc);
      if (_controllerInterno) {
        _controller.dispose();
      }

      _controllerInterno = widget.controller == null;
      _controller = widget.controller ?? LeitorController();
      _controller.bind(_bloc);
    }
  }

  @override
  void dispose() {
    _controller.unbind(_bloc);
    _bloc.close();
    _codigoController.dispose();
    _codigoFocusNode.dispose();
    if (_controllerInterno) {
      _controller.dispose();
    }
    super.dispose();
  }

  LeitorBloc _criarBloc() {
    return LeitorBloc(
      dataSource: widget.dataSource,
      controlarQuantidade: widget.controlarQuantidade,
    );
  }

  void _submeterCodigo() {
    final codigo = _codigoController.text.trim();
    _codigoController.clear();
    _controller.lerCodigo(codigo);
    _solicitarFoco();
  }

  void _solicitarFoco() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _codigoFocusNode.requestFocus();
      }
    });
  }

  void _mostrarMensagem(BuildContext context, String mensagem, Color cor) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: cor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<LeitorBloc, LeitorState>(
        listener: (context, state) {
          final previousState = _controller.state;

          if (state.tokenUltimoProduto != previousState.tokenUltimoProduto &&
              state.ultimoProdutoLido != null) {
            widget.onUltimoProdutoLido?.call(state.ultimoProdutoLido!);
          }

          if (state.tokenErro != previousState.tokenErro &&
              state.erro != null) {
            widget.onErro?.call(state.erro!);
            _mostrarMensagem(context, state.erro!, Colors.red.shade700);
            SystemSound.play(SystemSoundType.alert);
          }

          if (state.tokenAviso != previousState.tokenAviso &&
              state.aviso != null) {
            widget.onAviso?.call(state.aviso!);
            _mostrarMensagem(context, state.aviso!, Colors.orange.shade700);
            SystemSound.play(SystemSoundType.alert);
          }

          _controller.syncState(state);
          _solicitarFoco();
        },
        builder: (context, state) {
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leitor de código de barras',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _codigoController,
                          focusNode: _codigoFocusNode,
                          autofocus: widget.autofocus,
                          decoration: InputDecoration(
                            labelText: 'Código de barras',
                            hintText: widget.campoCodigoHint,
                            suffixIcon: state.processando
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submeterCodigo(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: state.processando ? null : _submeterCodigo,
                        icon: const Icon(Icons.qr_code_scanner_outlined),
                        label: const Text('Ler'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar:
                            const Icon(Icons.inventory_2_outlined, size: 18),
                        label: Text(
                          'Itens distintos: ${state.itens.length}',
                        ),
                      ),
                      Chip(
                        avatar: const Icon(Icons.numbers_outlined, size: 18),
                        label: Text(
                          'Quantidade total: ${state.quantidadeTotalLida}',
                        ),
                      ),
                      Chip(
                        avatar: Icon(
                          state.controlarQuantidade
                              ? Icons.lock_outline
                              : Icons.lock_open_outlined,
                          size: 18,
                        ),
                        label: Text(
                          state.controlarQuantidade
                              ? 'Controle por estoque ativo'
                              : 'Controle por estoque inativo',
                        ),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.refresh_outlined, size: 18),
                        label: const Text('Limpar leitura'),
                        onPressed: state.itens.isEmpty
                            ? null
                            : () => _controller.limpar(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (state.ultimoProdutoLido != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Último produto lido',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(state.ultimoProdutoLido!.descricao),
                          Text(
                            '${state.ultimoProdutoLido!.codigoDeBarras}  •  Quantidade: ${state.ultimoProdutoLido!.quantidadeLida}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: widget.alturaLista,
                    child: state.itens.isEmpty
                        ? Center(
                            child: Text(
                              'Nenhum produto lido ainda.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          )
                        : ListView.separated(
                            itemCount: state.itens.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = state.itens[index];
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(item.descricao),
                                subtitle: Text(
                                  '${item.codigoDeBarras}  •  Lidos: ${item.quantidadeLida}${state.controlarQuantidade ? '  •  Estoque: ${item.estoqueDisponivel}' : ''}',
                                ),
                                trailing: Wrap(
                                  spacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    IconButton(
                                      tooltip: 'Remover uma unidade',
                                      onPressed: () =>
                                          _controller.removerQuantidade(
                                        item.codigoDeBarras,
                                      ),
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Excluir item da contagem',
                                      onPressed: () => _controller.removerItem(
                                        item.codigoDeBarras,
                                      ),
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
