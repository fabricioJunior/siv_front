import 'package:comercial/presentation/blocs/pedido_entrada_bloc/pedido_entrada_bloc.dart';
import 'package:core/arquivos.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';

/// Inicia um Pedido de Entrada a partir do XML de uma NF-e recebida. Importar
/// NÃO coloca nada no estoque: só cria o pedido (e as linhas da nota) pra
/// mapear, contar e conferir.
class ImportarNfePage extends StatefulWidget {
  final SeletorWidget tabelaDePrecoSeletor;

  const ImportarNfePage({super.key, required this.tabelaDePrecoSeletor});

  @override
  State<ImportarNfePage> createState() => _ImportarNfePageState();
}

class _ImportarNfePageState extends State<ImportarNfePage> {
  late final PedidoEntradaBloc _bloc = sl<PedidoEntradaBloc>();
  int? _tabelaDePrecoId;
  String? _arquivoPath;

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _escolherArquivo() async {
    final path = await sl<ArquivoService>().selecionarArquivo(
      extensoes: ['xml'],
    );
    if (path != null) setState(() => _arquivoPath = path);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return BlocProvider<PedidoEntradaBloc>.value(
      value: _bloc,
      child: BlocConsumer<PedidoEntradaBloc, PedidoEntradaState>(
        listener: (context, state) {
          final erro = state.erro;
          if (erro != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(erro)));
          }
          final resumo = state.resumo;
          if (resumo != null && !state.salvando) {
            Navigator.of(context).pushReplacementNamed(
              '/pedido_entrada',
              arguments: {'pedidoId': resumo.pedidoId},
            );
          }
        },
        builder: (context, state) {
          final podeEnviar = _tabelaDePrecoId != null &&
              _arquivoPath != null &&
              !state.salvando;
          return Scaffold(
            appBar: AppBar(title: const Text('Entrada por NF-e')),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'O XML da nota vira um Pedido de Entrada. A nota não '
                          'coloca nada no estoque: os itens passam por '
                          'identificação, contagem física e conferência antes '
                          'da entrada.',
                          style: tema.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '1. Tabela de preço do pedido',
                          style: tema.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        widget.tabelaDePrecoSeletor(
                          SeletorData(
                            compacto: true,
                            onChanged: (itens) => setState(
                              () => _tabelaDePrecoId =
                                  itens.isEmpty ? null : itens.first.id,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '2. XML da NF-e (com ou sem protocolo)',
                          style: tema.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              onPressed:
                                  state.salvando ? null : _escolherArquivo,
                              icon: const Icon(Icons.upload_file_outlined),
                              label: const Text('Selecionar XML'),
                            ),
                            if (_arquivoPath != null)
                              Text(_arquivoPath!.split('/').last),
                          ],
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          key: const Key('importar_nfe_button'),
                          onPressed: podeEnviar
                              ? () => _bloc.add(
                                    PedidoEntradaImportouNfe(
                                      filePath: _arquivoPath!,
                                      tabelaPrecoId: _tabelaDePrecoId!,
                                    ),
                                  )
                              : null,
                          icon: state.salvando
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.receipt_long_outlined),
                          label: const Text('Importar NF-e'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
