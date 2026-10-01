import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/permissoes/componente_controlado_wiget.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:importacao/domain/models/importacao_guiada.dart';
import 'package:importacao/presentation/blocs/importacao_guiada_bloc/importacao_guiada_bloc.dart';

/// Assistente de importação: clientes -> produtos -> estoque -> vendas, cada
/// etapa com modelo, envio, andamento em tempo real e resultado.
class ImportacaoGuiadaPage extends StatelessWidget {
  // Só a etapa de vendas escolhe tabela de preço e funcionário; os seletores
  // vêm de fora porque os dois pertencem a outros packages.
  final SeletorWidget tabelaDePrecoSeletor;
  final SeletorWidget funcionarioSeletor;

  const ImportacaoGuiadaPage({
    super.key,
    required this.tabelaDePrecoSeletor,
    required this.funcionarioSeletor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ImportacaoGuiadaBloc>(
      create: (_) =>
          sl<ImportacaoGuiadaBloc>()..add(const ImportacaoGuiadaIniciou()),
      child: BlocListener<ImportacaoGuiadaBloc, ImportacaoGuiadaState>(
        listenWhen: (anterior, atual) =>
            anterior.erro != atual.erro || anterior.mensagem != atual.mensagem,
        listener: (context, state) {
          final texto = state.erro ?? state.mensagem;
          if (texto == null) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(texto)));
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Importação guiada')),
          body: BlocBuilder<ImportacaoGuiadaBloc, ImportacaoGuiadaState>(
            builder: (context, state) {
              if (state.carregando) {
                return const Center(child: CircularProgressIndicator());
              }
              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Passos(state: state),
                          const SizedBox(height: 16),
                          _PainelEtapa(
                            etapa: state.etapaAtual,
                            tabelaDePrecoSeletor: tabelaDePrecoSeletor,
                            funcionarioSeletor: funcionarioSeletor,
                          ),
                        ],
                      ),
                    ),
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

enum _StatusEtapa {
  bloqueada,
  aguardando,
  enviando,
  processando,
  concluida,
  concluidaComProblemas,
  falha;

  String get rotulo => switch (this) {
    bloqueada => 'Bloqueada',
    aguardando => 'A importar',
    enviando => 'Enviando',
    processando => 'Processando',
    concluida => 'Concluída',
    concluidaComProblemas => 'Com problemas',
    falha => 'Falhou',
  };

  Color get cor => switch (this) {
    bloqueada => Colors.grey,
    aguardando => Colors.blueGrey,
    enviando || processando => Colors.blue,
    concluida => Colors.green,
    concluidaComProblemas => Colors.orange,
    falha => Colors.red,
  };

  IconData get icone => switch (this) {
    bloqueada => Icons.lock_outline,
    aguardando => Icons.upload_file_outlined,
    enviando || processando => Icons.sync,
    concluida => Icons.check,
    concluidaComProblemas => Icons.warning_amber_rounded,
    falha => Icons.error_outline,
  };
}

_StatusEtapa _statusDe(ImportacaoGuiadaState state, ImportacaoEtapa etapa) {
  final dados = state[etapa];
  final importacao = dados.importacao;
  if (dados.enviando) return _StatusEtapa.enviando;
  if (importacao != null) {
    switch (importacao.situacao) {
      case ImportacaoSituacao.pendente:
      case ImportacaoSituacao.processando:
        return _StatusEtapa.processando;
      case ImportacaoSituacao.concluida:
        return importacao.rejeitados > 0
            ? _StatusEtapa.concluidaComProblemas
            : _StatusEtapa.concluida;
      case ImportacaoSituacao.falha:
        return _StatusEtapa.falha;
      case ImportacaoSituacao.cancelada:
        break;
    }
  }
  return state.liberada(etapa)
      ? _StatusEtapa.aguardando
      : _StatusEtapa.bloqueada;
}

class _Passos extends StatelessWidget {
  final ImportacaoGuiadaState state;

  const _Passos({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final etapa in ImportacaoEtapa.values)
          Expanded(
            child: _Passo(
              numero: etapa.index + 1,
              etapa: etapa,
              status: _statusDe(state, etapa),
              selecionada: state.etapaAtual == etapa,
            ),
          ),
      ],
    );
  }
}

class _Passo extends StatelessWidget {
  final int numero;
  final ImportacaoEtapa etapa;
  final _StatusEtapa status;
  final bool selecionada;

  const _Passo({
    required this.numero,
    required this.etapa,
    required this.status,
    required this.selecionada,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final emAndamento =
        status == _StatusEtapa.enviando || status == _StatusEtapa.processando;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => context.read<ImportacaoGuiadaBloc>().add(
        ImportacaoGuiadaEtapaSelecionada(etapa),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: selecionada ? status.cor.withValues(alpha: 0.08) : null,
          border: Border(
            bottom: BorderSide(
              width: 3,
              color: selecionada ? status.cor : Colors.transparent,
            ),
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: status.cor,
              child: emAndamento
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(status.icone, size: 18, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              '$numero. ${etapa.titulo}',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: tema.textTheme.labelLarge,
            ),
            Text(
              status.rotulo,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: tema.textTheme.bodySmall?.copyWith(color: status.cor),
            ),
          ],
        ),
      ),
    );
  }
}

class _PainelEtapa extends StatelessWidget {
  final ImportacaoEtapa etapa;
  final SeletorWidget tabelaDePrecoSeletor;
  final SeletorWidget funcionarioSeletor;

  const _PainelEtapa({
    required this.etapa,
    required this.tabelaDePrecoSeletor,
    required this.funcionarioSeletor,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final bloc = context.read<ImportacaoGuiadaBloc>();

    return BlocBuilder<ImportacaoGuiadaBloc, ImportacaoGuiadaState>(
      buildWhen: (anterior, atual) =>
          anterior[etapa] != atual[etapa] ||
          anterior.liberada(etapa) != atual.liberada(etapa),
      builder: (context, state) {
        final dados = state[etapa];
        final importacao = dados.importacao;
        final liberada = state.liberada(etapa);
        final permitido = PermissaoPorNome.acessoPermitido(etapa.permissao);
        final trabalhando = dados.enviando || dados.emAndamento;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${etapa.index + 1}. ${etapa.titulo}',
                  style: tema.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(etapa.descricao, style: tema.textTheme.bodyMedium),
                const SizedBox(height: 16),
                if (!liberada)
                  _Aviso(
                    icone: Icons.lock_outline,
                    cor: Colors.grey,
                    texto:
                        'Conclua a etapa "${etapa.anterior!.titulo}" antes '
                        'de importar esta.',
                    acao: TextButton(
                      onPressed: () => bloc.add(
                        ImportacaoGuiadaEtapaSelecionada(etapa.anterior!),
                      ),
                      child: Text('Ir para ${etapa.anterior!.titulo}'),
                    ),
                  )
                else if (!permitido)
                  const _Aviso(
                    icone: Icons.block,
                    cor: Colors.red,
                    texto:
                        'Seu usuário não tem permissão para importar esta etapa.',
                  )
                else ...[
                  _BotaoModelo(etapa: etapa),
                  if (etapa == ImportacaoEtapa.vendas) ...[
                    const SizedBox(height: 16),
                    Text('Tabela de preço', style: tema.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    tabelaDePrecoSeletor(
                      SeletorData(
                        compacto: true,
                        onChanged: (itens) => bloc.add(
                          ImportacaoGuiadaTabelaDePrecoAlterada(
                            itens.isEmpty ? null : itens.first.id,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Funcionário (vendedor)',
                      style: tema.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    funcionarioSeletor(
                      SeletorData(
                        compacto: true,
                        onChanged: (itens) => bloc.add(
                          ImportacaoGuiadaFuncionarioAlterado(
                            itens.isEmpty ? null : itens.first.id,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _PassoArquivo(
                    etapa: etapa,
                    dados: dados,
                    bloqueado: trabalhando,
                  ),
                ],
                if (importacao != null) ...[
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  _Andamento(importacao: importacao),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BotaoModelo extends StatelessWidget {
  final ImportacaoEtapa etapa;

  const _BotaoModelo({required this.etapa});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: () => context.read<ImportacaoGuiadaBloc>().add(
            ImportacaoGuiadaModeloBaixado(etapa),
          ),
          icon: const Icon(Icons.download_outlined),
          label: const Text('Baixar modelo'),
        ),
        Text(
          'Preencha o modelo, salve como CSV e envie abaixo.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _PassoArquivo extends StatelessWidget {
  final ImportacaoEtapa etapa;
  final EtapaImportacaoState dados;
  final bool bloqueado;

  const _PassoArquivo({
    required this.etapa,
    required this.dados,
    required this.bloqueado,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ImportacaoGuiadaBloc>();
    final jaImportou = dados.importacao != null;
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: bloqueado
              ? null
              : () => bloc.add(ImportacaoGuiadaArquivoSelecionado(etapa)),
          icon: const Icon(Icons.attach_file),
          label: Text(dados.arquivoNome ?? 'Selecionar CSV'),
        ),
        FilledButton.icon(
          onPressed: bloqueado || dados.arquivoNome == null
              ? null
              : () => bloc.add(ImportacaoGuiadaEnviou(etapa)),
          icon: dados.enviando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.cloud_upload_outlined),
          label: Text(
            dados.enviando
                ? 'Enviando...'
                : jaImportou
                ? 'Importar novamente'
                : 'Importar',
          ),
        ),
      ],
    );
  }
}

class _Andamento extends StatelessWidget {
  final ImportacaoGuiada importacao;

  const _Andamento({required this.importacao});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    switch (importacao.situacao) {
      case ImportacaoSituacao.pendente:
      case ImportacaoSituacao.processando:
        final fracao = importacao.fracao;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              importacao.situacao == ImportacaoSituacao.pendente
                  ? 'Na fila para processar...'
                  : fracao == null
                  ? 'Processando...'
                  : 'Processando: ${importacao.processados} de '
                        '${importacao.totalRegistros} '
                        '(${(fracao * 100).floor()}%)',
              style: tema.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: fracao),
            const SizedBox(height: 12),
            _Contadores(importacao: importacao),
            const SizedBox(height: 8),
            Text(
              'Pode sair desta tela: a importação continua no servidor.',
              style: tema.textTheme.bodySmall,
            ),
          ],
        );
      case ImportacaoSituacao.falha:
        return _Aviso(
          icone: Icons.error_outline,
          cor: Colors.red,
          texto:
              'A importação falhou e nada foi gravado: '
              '${importacao.erro ?? 'erro desconhecido'}',
        );
      case ImportacaoSituacao.cancelada:
        return const _Aviso(
          icone: Icons.cancel_outlined,
          cor: Colors.grey,
          texto: 'A importação foi cancelada.',
        );
      case ImportacaoSituacao.concluida:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Contadores(importacao: importacao),
            for (final aviso in importacao.avisos) ...[
              const SizedBox(height: 12),
              _Aviso(
                icone: Icons.info_outline,
                cor: Colors.blueGrey,
                texto: aviso,
              ),
            ],
            if (importacao.rejeitados > 0) ...[
              const SizedBox(height: 16),
              _ListaProblemas(importacao: importacao),
            ],
          ],
        );
    }
  }
}

class _Contadores extends StatelessWidget {
  final ImportacaoGuiada importacao;

  const _Contadores({required this.importacao});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _Contador(
          rotulo: 'Importados',
          valor: importacao.importados,
          cor: Colors.green,
        ),
        _Contador(
          rotulo: 'Com problema',
          valor: importacao.rejeitados,
          cor: importacao.rejeitados > 0 ? Colors.orange : Colors.grey,
        ),
        if (importacao.totalRegistros > 0)
          _Contador(
            rotulo: 'Total no arquivo',
            valor: importacao.totalRegistros,
            cor: Colors.blueGrey,
          ),
      ],
    );
  }
}

class _Contador extends StatelessWidget {
  final String rotulo;
  final int valor;
  final Color cor;

  const _Contador({
    required this.rotulo,
    required this.valor,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$valor',
            style: tema.textTheme.headlineSmall?.copyWith(
              color: cor,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(rotulo, style: tema.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ListaProblemas extends StatelessWidget {
  final ImportacaoGuiada importacao;

  const _ListaProblemas({required this.importacao});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final problemas = importacao.problemas;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Registros que não foram importados (${importacao.rejeitados})',
                style: tema.textTheme.titleSmall,
              ),
            ),
            if (problemas.isNotEmpty)
              TextButton.icon(
                onPressed: () async {
                  final mensagens = ScaffoldMessenger.of(context);
                  await Clipboard.setData(
                    ClipboardData(
                      text: problemas
                          .map(
                            (p) =>
                                '${p.titulo}: ${p.motivo}'
                                '${p.conteudo == null ? '' : ' [${p.conteudo}]'}',
                          )
                          .join('\n'),
                    ),
                  );
                  mensagens.showSnackBar(
                    const SnackBar(content: Text('Lista copiada.')),
                  );
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copiar'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (problemas.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(),
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 360),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: problemas.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, indice) {
                  final problema = problemas[indice];
                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    title: Text(problema.titulo),
                    subtitle: Text(
                      problema.conteudo == null
                          ? problema.motivo
                          : '${problema.motivo}\n${problema.conteudo}',
                    ),
                    isThreeLine: problema.conteudo != null,
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _Aviso extends StatelessWidget {
  final IconData icone;
  final Color cor;
  final String texto;
  final Widget? acao;

  const _Aviso({
    required this.icone,
    required this.cor,
    required this.texto,
    this.acao,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icone, color: cor),
          const SizedBox(width: 12),
          Expanded(child: Text(texto)),
          ?acao,
        ],
      ),
    );
  }
}
