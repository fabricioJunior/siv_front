import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/leitor/leitor_widget.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:flutter/material.dart';

const String _resultadoStatusKey = 'status';
const String _resultadoStatusSucesso = 'sucesso';

class ConsignacaoBipagemPage extends StatefulWidget {
  final int consignacaoId;
  final int? pessoaId;
  final int? funcionarioId;
  final int? tabelaPrecoId;
  final OrigemCompartilhadaTipo origem;
  final List<int> romaneiosConsignacao;

  const ConsignacaoBipagemPage({
    super.key,
    required this.consignacaoId,
    this.pessoaId,
    this.funcionarioId,
    this.tabelaPrecoId,
    required this.origem,
    this.romaneiosConsignacao = const [],
  });

  @override
  State<ConsignacaoBipagemPage> createState() =>
      _ConsignacaoBipagemPageState();
}

class _ConsignacaoBipagemPageState extends State<ConsignacaoBipagemPage> {
  late final LeitorController _leitorController;
  late final ConsignacaoBipagemBloc _bloc;

  bool get _ehDevolucao =>
      widget.origem == OrigemCompartilhadaTipo.consignacaoDevolucao;

  @override
  void initState() {
    super.initState();
    _leitorController = LeitorController();
    _bloc = ConsignacaoBipagemBloc(
      sl(),
      origem: widget.origem,
      pessoaId: widget.pessoaId,
      funcionarioId: widget.funcionarioId,
      tabelaPrecoId: widget.tabelaPrecoId,
    );
  }

  @override
  void dispose() {
    _leitorController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConsignacaoBipagemBloc>.value(
      value: _bloc,
      child: BlocConsumer<ConsignacaoBipagemBloc, ConsignacaoBipagemState>(
        listenWhen: (previous, current) =>
            (previous.erro != current.erro && current.erro != null) ||
            (previous.listaCompartilhadaHash != current.listaCompartilhadaHash &&
                current.listaCompartilhadaHash != null),
        listener: (context, state) async {
          if (state.erro != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.erro!)),
            );
          }

          final hash = state.listaCompartilhadaHash;
          if (hash == null) return;

          final result = await Navigator.of(context).pushNamed(
            '/criar_romaneio_por_parametros',
            arguments: {
              'listaCompartilhadaHash': hash,
              'consignacaoId': widget.consignacaoId,
              'romaneiosConsignacao': widget.romaneiosConsignacao,
            },
          );

          if (!context.mounted) return;

          final sucesso = result is Map<String, dynamic> &&
              result[_resultadoStatusKey] == _resultadoStatusSucesso;

          if (sucesso) {
            Navigator.of(context).pop(true);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                _ehDevolucao
                    ? 'Registrar devolução'
                    : 'Adicionar produtos à consignação',
              ),
            ),
            floatingActionButton: AnimatedBuilder(
              animation: _leitorController,
              builder: (context, _) {
                if (_leitorController.itens.isEmpty) {
                  return const SizedBox.shrink();
                }

                return FloatingActionButton.extended(
                  onPressed: state.salvando
                      ? null
                      : () {
                          final itens = _leitorController.itens
                              .map(
                                (e) => {
                                  'produtoId': e.id,
                                  'quantidade': e.quantidadeLida,
                                  'valorUnitario': e.valorUnitario,
                                  'corNome': e.cor,
                                  'tamanhoNome': e.tamanho,
                                  'nome': e.descricao,
                                },
                              )
                              .toList();

                          context.read<ConsignacaoBipagemBloc>().add(
                                ConsignacaoBipagemSalvarSolicitado(
                                  itens: itens,
                                ),
                              );
                        },
                  icon: state.salvando
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(state.salvando ? 'Salvando...' : 'Salvar'),
                );
              },
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LeitorWidget(
                  controller: _leitorController,
                  dataSource: sl(),
                  buscaDataSource: sl(),
                  tabelaDePrecoId: widget.tabelaPrecoId,
                  aceitarApenasProdutosComPreco: false,
                  campoCodigoHint: 'Bipe ou informe o código do produto',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
