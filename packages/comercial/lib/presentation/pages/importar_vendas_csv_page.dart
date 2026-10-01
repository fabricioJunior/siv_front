import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';

class ImportarVendasCsvPage extends StatelessWidget {
  final SeletorWidget tabelaDePrecoSeletor;
  final SeletorWidget funcionarioSeletor;

  const ImportarVendasCsvPage({
    super.key,
    required this.tabelaDePrecoSeletor,
    required this.funcionarioSeletor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ImportarVendasCsvBloc>(
      create: (_) => sl<ImportarVendasCsvBloc>(),
      child: BlocListener<ImportarVendasCsvBloc, ImportarVendasCsvState>(
        listenWhen: (previous, current) => previous.erro != current.erro,
        listener: (context, state) {
          if (state.erro != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.erro!)));
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Importar vendas realizadas via CSV'),
          ),
          body: BlocBuilder<ImportarVendasCsvBloc, ImportarVendasCsvState>(
            builder: (context, state) {
              if (state.step == ImportarVendasCsvStep.concluido ||
                  state.step ==
                      ImportarVendasCsvStep.processandoEmSegundoPlano) {
                return _ResultadoView(state: state);
              }

              final processando =
                  state.step == ImportarVendasCsvStep.enviando ||
                      state.step == ImportarVendasCsvStep.processando;
              final titulo = Theme.of(context).textTheme.titleMedium;

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cada venda do arquivo vira um romaneio de venda já '
                        'encerrado. A importação não movimenta estoque, caixa '
                        'nem gera nota fiscal.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      Text('1. Escolha a tabela de preço', style: titulo),
                      const SizedBox(height: 12),
                      tabelaDePrecoSeletor(
                        SeletorData(
                          onChanged: (items) => context
                              .read<ImportarVendasCsvBloc>()
                              .add(ImportarVendasTabelaAlterada(
                                  tabelaDePrecoId: items.first.id)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('2. Escolha o funcionário (vendedor)',
                          style: titulo),
                      const SizedBox(height: 12),
                      funcionarioSeletor(
                        SeletorData(
                          onChanged: (items) => context
                              .read<ImportarVendasCsvBloc>()
                              .add(ImportarVendasFuncionarioAlterado(
                                  funcionarioId: items.first.id)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '3. Baixe o modelo e preencha os itens das vendas',
                        style: titulo,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context
                            .read<ImportarVendasCsvBloc>()
                            .add(ImportarVendasBaixouTemplate()),
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Baixar modelo'),
                      ),
                      const SizedBox(height: 24),
                      Text('4. Selecione o CSV preenchido', style: titulo),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context
                            .read<ImportarVendasCsvBloc>()
                            .add(ImportarVendasArquivoSelecionado()),
                        icon: const Icon(Icons.attach_file),
                        label: Text(state.arquivoNome ?? 'Selecionar arquivo'),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: processando || !state.podeEnviar
                            ? null
                            : () => context
                                .read<ImportarVendasCsvBloc>()
                                .add(ImportarVendasEnviou()),
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
                          state.step == ImportarVendasCsvStep.enviando
                              ? 'Enviando...'
                              : state.step == ImportarVendasCsvStep.processando
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
  final ImportarVendasCsvState state;

  const _ResultadoView({required this.state});

  @override
  Widget build(BuildContext context) {
    final importacao = state.importacao;
    final resultado = importacao?.resultado;

    if (importacao == null ||
        state.step == ImportarVendasCsvStep.processandoEmSegundoPlano) {
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
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            '${resultado.importados} de ${resultado.totalRecebidos} vendas '
            'importadas (${resultado.itensImportados} itens)',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          if (resultado.semClienteCadastrado > 0) ...[
            const SizedBox(height: 8),
            Text(
              '${resultado.semClienteCadastrado} venda(s) com documento sem '
              'cadastro foram lançadas como "Cliente não cadastrado" '
              '(documento na observação do romaneio).',
              textAlign: TextAlign.center,
            ),
          ],
          if (resultado.rejeitados.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Vendas não importadas (${resultado.rejeitados.length})',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            for (final rejeitada in resultado.rejeitados)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.error_outline, color: Colors.red),
                  title: Text('Venda ${rejeitada.numeroVendaExterno}'),
                  subtitle: Text(rejeitada.motivo),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
