import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';

class ImportarPedidosCsvPage extends StatelessWidget {
  final SeletorWidget tabelaDePrecoSeletor;

  const ImportarPedidosCsvPage({super.key, required this.tabelaDePrecoSeletor});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ImportarPedidosCsvBloc>(
      create: (_) => sl<ImportarPedidosCsvBloc>(),
      child: BlocListener<ImportarPedidosCsvBloc, ImportarPedidosCsvState>(
        listenWhen: (previous, current) => previous.erro != current.erro,
        listener: (context, state) {
          if (state.erro != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.erro!)));
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Importar pedidos (entrada) via CSV'),
          ),
          body: BlocBuilder<ImportarPedidosCsvBloc, ImportarPedidosCsvState>(
            builder: (context, state) {
              if (state.step == ImportarPedidosCsvStep.concluido ||
                  state.step ==
                      ImportarPedidosCsvStep.processandoEmSegundoPlano) {
                return _ResultadoView(state: state);
              }

              final processando =
                  state.step == ImportarPedidosCsvStep.enviando ||
                      state.step == ImportarPedidosCsvStep.processando;

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1. Escolha a tabela de preço da entrada',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      tabelaDePrecoSeletor(
                        SeletorData(
                          onChanged: (items) => context
                              .read<ImportarPedidosCsvBloc>()
                              .add(ImportarPedidosTabelaAlterada(
                                  tabelaDePrecoId: items.first.id)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '2. Baixe o modelo e preencha os itens do pedido',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context
                            .read<ImportarPedidosCsvBloc>()
                            .add(ImportarPedidosBaixouTemplate()),
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Baixar modelo'),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '3. Selecione o CSV preenchido',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context
                            .read<ImportarPedidosCsvBloc>()
                            .add(ImportarPedidosArquivoSelecionado()),
                        icon: const Icon(Icons.attach_file),
                        label: Text(
                          state.arquivoNome ?? 'Selecionar arquivo',
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: processando || !state.podeEnviar
                            ? null
                            : () => context
                                .read<ImportarPedidosCsvBloc>()
                                .add(ImportarPedidosEnviou()),
                        icon: processando
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator.adaptive(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.upload_outlined),
                        label: Text(
                          state.step == ImportarPedidosCsvStep.enviando
                              ? 'Enviando...'
                              : state.step ==
                                      ImportarPedidosCsvStep.processando
                                  ? 'Processando...'
                                  : 'Importar',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ResultadoView extends StatelessWidget {
  final ImportarPedidosCsvState state;

  const _ResultadoView({required this.state});

  @override
  Widget build(BuildContext context) {
    final importacao = state.importacao;
    final resultado = importacao?.resultado;

    if (importacao == null ||
        state.step == ImportarPedidosCsvStep.processandoEmSegundoPlano) {
      return const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'A importação continua sendo processada em segundo plano. '
              'Confira o resultado no histórico de importações.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (importacao.situacao == ImportacaoSituacao.falha || resultado == null) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              importacao.erro ?? 'Falha ao processar a importação.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '${resultado.importados} de ${resultado.totalRecebidos} pedidos importados',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
