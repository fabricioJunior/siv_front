import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/sessao.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/presentation.dart';
import 'package:flutter/material.dart';

import 'abertura_de_caixa_page.dart';
import 'fechamento_de_caixa_page.dart';

class FluxoDeCaixaPage extends StatefulWidget {
  final int? empresaId;
  final int? terminalId;

  const FluxoDeCaixaPage({
    super.key,
    required this.empresaId,
    required this.terminalId,
  });

  @override
  State<FluxoDeCaixaPage> createState() => _FluxoDeCaixaPageState();
}

class _FluxoDeCaixaPageState extends State<FluxoDeCaixaPage> {
  final _documentoController = TextEditingController();

  @override
  void dispose() {
    _documentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final empresaId = widget.empresaId;
    final terminalId = widget.terminalId;
    final sessao = sl<IAcessoGlobalSessao>();

    return BlocProvider<FluxoDeCaixaBloc>(
      create: (_) {
        final bloc = sl<FluxoDeCaixaBloc>();

        if (empresaId != null && terminalId != null) {
          bloc.add(
            FluxoDeCaixaRecuperouCaixaAberto(
              empresaId: empresaId,
              terminalId: terminalId,
            ),
          );
        }

        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Fluxo de caixa')),
        body: BlocConsumer<FluxoDeCaixaBloc, FluxoDeCaixaState>(
          listenWhen: (previous, current) =>
              previous.caixaId != current.caixaId ||
              previous.caixa?.terminalId != current.caixa?.terminalId,
          listener: (_, state) {
            if (terminalId == null) {
              return;
            }

            sessao.atualizarCaixaIdDaSessao(
              terminalId: terminalId,
              caixaId:
                  state.caixa?.terminalId == terminalId ? state.caixaId : null,
            );
          },
          builder: (context, state) {
            final carregando = state is FluxoDeCaixaCarregarEmProgresso ||
                state is FluxoDeCaixaAbrirEmProgresso ||
                state is FluxoDeCaixaFecharEmProgresso;
            final recuperandoCaixaAberto =
                state is FluxoDeCaixaCarregarEmProgresso &&
                    state.caixa == null &&
                    state.caixaId == null;
            final caixaAberto = state.caixa?.situacao == SituacaoCaixa.aberto;
            final carregandoAbertura = state is FluxoDeCaixaAbrirEmProgresso;
            final erroRecuperacaoCaixa =
                state is FluxoDeCaixaCarregarFalha && state.caixa == null
                    ? 'Falha ao recuperar o caixa aberto. Tente novamente.'
                    : null;
            final erroAbertura = state is FluxoDeCaixaAbrirFalha
                ? 'Falha ao abrir o caixa. Tente novamente.'
                : null;

            if (recuperandoCaixaAberto) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Verificando caixa aberto...'),
                  ],
                ),
              );
            }

            if (!caixaAberto) {
              return AberturaDeCaixaPage(
                empresaId: widget.empresaId,
                terminalId: widget.terminalId,
                carregando: carregandoAbertura,
                erro: erroAbertura ?? erroRecuperacaoCaixa,
                onAbrir: () {
                  context.read<FluxoDeCaixaBloc>().add(
                        FluxoDeCaixaAbriuCaixa(
                          empresaId: widget.empresaId!,
                          terminalId: widget.terminalId!,
                        ),
                      );
                },
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ResumoCaixa(caixa: state.caixa!),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _documentoController,
                        decoration: const InputDecoration(
                          labelText: 'Filtrar por documento',
                          suffixIcon: Icon(Icons.search),
                        ),
                        onSubmitted: (value) {
                          context.read<FluxoDeCaixaBloc>().add(
                                FluxoDeCaixaFiltrouDocumento(documento: value),
                              );
                        },
                      ),
                      const SizedBox(height: 8),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: TerminalDaSessaoWidget(),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonalIcon(
                          onPressed: carregando || state.caixaId == null
                              ? null
                              : () async {
                                  await Navigator.of(context).pushNamed(
                                    '/suprimentos',
                                    arguments: {'caixaId': state.caixaId},
                                  );

                                  if (!context.mounted ||
                                      state.caixaId == null) {
                                    return;
                                  }

                                  context.read<FluxoDeCaixaBloc>().add(
                                        FluxoDeCaixaIniciou(
                                          caixaId: state.caixaId!,
                                        ),
                                      );
                                },
                          icon: const Icon(Icons.savings_outlined),
                          label: const Text('Suprimentos'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: carregando || state.caixaId == null
                                  ? null
                                  : () {
                                      context.read<FluxoDeCaixaBloc>().add(
                                            FluxoDeCaixaIniciou(
                                              caixaId: state.caixaId!,
                                            ),
                                          );
                                    },
                              child: const Text('Atualizar extrato'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: carregando || state.caixaId == null
                                  ? null
                                  : () async {
                                      final confirmouFechamento =
                                          await Navigator.of(
                                        context,
                                      ).push<bool>(
                                        MaterialPageRoute(
                                          builder: (_) => FechamentoDeCaixaPage(
                                            caixaId: state.caixaId!,
                                          ),
                                        ),
                                      );

                                      if (!context.mounted ||
                                          confirmouFechamento != true) {
                                        return;
                                      }
                                    },
                              icon: const Icon(Icons.lock_outline),
                              label: const Text('Fechar caixa'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (carregando)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: LinearProgressIndicator(),
                  ),
                if (state is FluxoDeCaixaCarregarFalha ||
                    state is FluxoDeCaixaAbrirFalha ||
                    state is FluxoDeCaixaFecharFalha)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Falha ao processar fluxo de caixa.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                Expanded(
                  child: state.extratos.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Nenhum lançamento no extrato.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: state.extratos.length,
                          itemBuilder: (context, index) {
                            final item = state.extratos[index];
                            return _ExtratoTile(item: item);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ResumoCaixa extends StatelessWidget {
  final Caixa caixa;

  const _ResumoCaixa({required this.caixa});

  @override
  Widget build(BuildContext context) {
    final aberto = caixa.situacao == SituacaoCaixa.aberto;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: ListTile(
        title: Text('Caixa #${caixa.id}'),
        subtitle:
            Text('Empresa ${caixa.empresaId} | Terminal ${caixa.terminalId}'),
        trailing: Text(
          aberto ? 'Aberto' : 'Fechado',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: aberto ? Colors.green : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _ExtratoTile extends StatelessWidget {
  final ExtratoCaixa item;

  const _ExtratoTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDebito = item.tipoMovimento == TipoMovimentoExtratoCaixa.debito;
    return ListTile(
      leading: Icon(
        isDebito ? Icons.arrow_upward : Icons.arrow_downward,
        color: isDebito ? Colors.red : Colors.green,
      ),
      title: Text(item.tipoHistorico.name),
      subtitle: Text('Documento: ${item.documento}'),
      trailing: Text(
        item.valor.toStringAsFixed(2),
        style: TextStyle(
          color: isDebito ? Colors.red : Colors.green,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
