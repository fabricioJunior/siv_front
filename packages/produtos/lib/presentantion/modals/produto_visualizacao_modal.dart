import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/widgets/cor_seletor.dart';
import 'package:produtos/presentation.dart';

class ProdutoVisualizacaoModal extends StatefulWidget {
  final Produto produto;

  const ProdutoVisualizacaoModal({super.key, required this.produto});

  static Future<bool?> show({
    required BuildContext context,
    required Produto produto,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProdutoVisualizacaoModal(produto: produto),
    );
  }

  @override
  State<ProdutoVisualizacaoModal> createState() =>
      _ProdutoVisualizacaoModalState();
}

class _ProdutoVisualizacaoModalState extends State<ProdutoVisualizacaoModal> {
  late final ProdutoBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<ProdutoBloc>()..add(ProdutoIniciou(produto: widget.produto));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final produto = widget.produto;

    return BlocProvider<ProdutoBloc>.value(
      value: _bloc,
      child: BlocConsumer<ProdutoBloc, ProdutoState>(
        listenWhen: (previous, current) =>
            previous.produtoStep != current.produtoStep,
        listener: (context, state) {
          if (state.produtoStep == ProdutoStep.salvo) {
            Navigator.of(context).pop(true);
            return;
          }
        },
        builder: (context, state) {
          final carregando = state.produtoStep == ProdutoStep.carregando;
          final corAtual = state.cores
              .where((item) => item.id == state.corId)
              .firstOrNull;
          final tamanhoAtual = state.tamanhos
              .where((item) => item.id == state.tamanhoId)
              .firstOrNull;

          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.92,
            child: Material(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Detalhes do produto',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: carregando
                                ? null
                                : () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildInfo('ID', produto.id?.toString() ?? '-'),
                      _buildInfo(
                        'Referência',
                        '${produto.referencia?.id ?? produto.referenciaId} - ${produto.referencia?.nome ?? '-'}',
                      ),
                      _buildInfo(
                        'ID externo',
                        produto.idExterno.trim().isEmpty
                            ? '-'
                            : produto.idExterno,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Campos editáveis',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      CorSeletor(
                        coresSelecionadasIniciais: [produto.cor!],
                        onChanged: (value) {
                          context.read<ProdutoBloc>().add(
                            ProdutoEditou(
                              corId: value.isEmpty ? null : value.first.id,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      TamanhoSeletor(
                        tamanhosSelecionadosIniciais: [produto.tamanho!],
                        onChanged: (value) {
                          context.read<ProdutoBloc>().add(
                            ProdutoEditou(
                              tamanhoId: value.isEmpty ? null : value.first.id,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Atual: ${corAtual?.nome ?? produto.cor?.nome ?? '-'} / ${tamanhoAtual?.nome ?? produto.tamanho?.nome ?? '-'}',
                      ),
                      const Spacer(),
                      _buildError(),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: carregando || !enableButtomSalvar()
                            ? null
                            : () => _salvar(context),
                        icon: carregando
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check),
                        label: Text(
                          carregando ? 'Salvando...' : 'Salvar alterações',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    final state = _bloc.state;
    String? mensagem;
    if (state.id == null) {
      mensagem = 'Produto sem ID válido para edição.';
    }

    if (state.corId == null || state.tamanhoId == null) {
      mensagem = 'Produto sem cor ou tamanho selecionado.';
    }
    if (state.produtoStep == ProdutoStep.falha && state.erroMensagem != null) {
      mensagem = state.erroMensagem;
    }
    if (mensagem == null) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 14, color: Colors.red),
          const SizedBox(width: 8),
          Text(
            mensagem,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.red),
          ),
        ],
      ),
    );
  }

  bool enableButtomSalvar() {
    final state = _bloc.state;
    if (state.id == null) {
      return false;
    }

    if (state.corId == null || state.tamanhoId == null) {
      return false;
    }

    return true;
  }

  void _salvar(BuildContext context) {
    final state = _bloc.state;
    final id = state.id;

    if (id == null) {
      return;
    }

    if (state.corId == null || state.tamanhoId == null) {
      return;
    }

    context.read<ProdutoBloc>().add(ProdutoSalvou());
  }
}
