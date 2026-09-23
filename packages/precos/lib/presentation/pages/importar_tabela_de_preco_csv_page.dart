import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:precos/models.dart';
import 'package:precos/presentation.dart';

class ImportarTabelaDePrecoCsvPage extends StatelessWidget {
  const ImportarTabelaDePrecoCsvPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ImportarTabelaDePrecoCsvBloc>(
      create: (_) => sl<ImportarTabelaDePrecoCsvBloc>(),
      child: BlocListener<ImportarTabelaDePrecoCsvBloc,
          ImportarTabelaDePrecoCsvState>(
        listenWhen: (previous, current) => previous.erro != current.erro,
        listener: (context, state) {
          if (state.erro != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.erro!)));
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Importar preços via CSV')),
          body: BlocBuilder<ImportarTabelaDePrecoCsvBloc,
              ImportarTabelaDePrecoCsvState>(
            builder: (context, state) {
              if (state.step == ImportarTabelaDePrecoCsvStep.concluido ||
                  state.step ==
                      ImportarTabelaDePrecoCsvStep.processandoEmSegundoPlano) {
                return _ResultadoView(state: state);
              }

              final processando =
                  state.step == ImportarTabelaDePrecoCsvStep.enviando ||
                      state.step == ImportarTabelaDePrecoCsvStep.processando;

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1. Escolha a tabela de preço',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Tabela de preço',
                        ),
                        initialValue: state.tabelaDePrecoId,
                        items: [
                          for (final tabela in state.tabelas)
                            if (tabela.id != null)
                              DropdownMenuItem(
                                value: tabela.id,
                                child: Text(tabela.nome),
                              ),
                        ],
                        onChanged: (id) => context
                            .read<ImportarTabelaDePrecoCsvBloc>()
                            .add(ImportarTabelaDePrecoTabelaAlterada(
                                tabelaDePrecoId: id!)),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '2. Baixe o modelo com todas as referências',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Preencha o valor (R\$) somente nas referências que quer '
                        'atualizar e apague as linhas que não vai preencher -- '
                        'o backend rejeita a linha inteira se o valor vier vazio.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: state.tabelaDePrecoId == null
                            ? null
                            : () => context
                                .read<ImportarTabelaDePrecoCsvBloc>()
                                .add(ImportarTabelaDePrecoBaixouTemplate()),
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
                            .read<ImportarTabelaDePrecoCsvBloc>()
                            .add(ImportarTabelaDePrecoArquivoSelecionado()),
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
                                .read<ImportarTabelaDePrecoCsvBloc>()
                                .add(ImportarTabelaDePrecoEnviou()),
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
                          state.step == ImportarTabelaDePrecoCsvStep.enviando
                              ? 'Enviando...'
                              : state.step ==
                                      ImportarTabelaDePrecoCsvStep.processando
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
  final ImportarTabelaDePrecoCsvState state;

  const _ResultadoView({required this.state});

  @override
  Widget build(BuildContext context) {
    final importacao = state.importacao;
    final resultado = importacao?.resultado;

    if (importacao == null ||
        state.step == ImportarTabelaDePrecoCsvStep.processandoEmSegundoPlano) {
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
            '${resultado.importados} de ${resultado.totalRecebidos} preços atualizados',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
