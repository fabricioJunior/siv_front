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
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonalIcon(
                          onPressed: carregando || state.caixaId == null
                              ? null
                              : () {
                                  Navigator.of(context).pushNamed(
                                    '/contagem_do_caixa',
                                    arguments: {'caixaId': state.caixaId},
                                  );
                                },
                          icon: const Icon(Icons.calculate_outlined),
                          label: const Text('Contagem do caixa'),
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
                                      final caixaId = state.caixaId;
                                      if (caixaId == null) {
                                        return;
                                      }

                                      final confirmouFechamento =
                                          await Navigator.of(
                                        context,
                                      ).push<bool>(
                                        MaterialPageRoute(
                                          builder: (_) => FechamentoDeCaixaPage(
                                            caixaId: caixaId,
                                          ),
                                        ),
                                      );

                                      if (!context.mounted ||
                                          confirmouFechamento != true) {
                                        return;
                                      }

                                      context.read<FluxoDeCaixaBloc>().add(
                                            FluxoDeCaixaFechouCaixa(
                                              caixaId: caixaId,
                                            ),
                                          );
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
                if (state.extratos.isNotEmpty)
                  _ResumoMovimentacoesExtrato(extratos: state.extratos),
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
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                          itemCount: state.extratos.length,
                          itemBuilder: (context, index) {
                            final item = state.extratos[index];
                            return _ExtratoTile(item: item);
                          },
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
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

String _rotuloTipoDocumento(TipoDocumentoExtratoCaixa tipo) {
  switch (tipo) {
    case TipoDocumentoExtratoCaixa.dinheiro:
      return 'Dinheiro';
    case TipoDocumentoExtratoCaixa.pix:
      return 'Pix';
    case TipoDocumentoExtratoCaixa.cartao:
      return 'Cartao';
    case TipoDocumentoExtratoCaixa.cheque:
      return 'Cheque';
    case TipoDocumentoExtratoCaixa.fatura:
      return 'Fatura';
    case TipoDocumentoExtratoCaixa.troco:
      return 'Troco';
    case TipoDocumentoExtratoCaixa.voucher:
      return 'Voucher';
    case TipoDocumentoExtratoCaixa.tedDoc:
      return 'TED/DOC';
    case TipoDocumentoExtratoCaixa.adiantamento:
      return 'Adiantamento';
    case TipoDocumentoExtratoCaixa.creditoDeDevolucao:
      return 'Credito de devolucao';
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
    final color = isDebito ? Colors.red : Colors.green;
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isDebito ? Icons.arrow_upward : Icons.arrow_downward,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _rotuloHistorico(item.tipoHistorico),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.tipoDocumento.name,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _rotuloTipoDocumento(item.tipoDocumento),
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Documento: ${item.documento}  •  ${_formatarDataHora(item.data)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (item.observacao?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.observacao!.trim(),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                  if (item.cancelado) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Lancamento cancelado${item.motivoCancelamento?.trim().isNotEmpty == true ? ': ${item.motivoCancelamento!.trim()}' : ''}',
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isDebito ? 'Saida' : 'Entrada',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${isDebito ? '-' : '+'} ${_formatarMoeda(item.valor)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumoMovimentacoesExtrato extends StatelessWidget {
  final List<ExtratoCaixa> extratos;

  const _ResumoMovimentacoesExtrato({required this.extratos});

  @override
  Widget build(BuildContext context) {
    final totalEntradas = extratos
        .where(
            (item) => item.tipoMovimento == TipoMovimentoExtratoCaixa.credito)
        .fold<double>(0, (total, item) => total + item.valor);
    final totalSaidas = extratos
        .where((item) => item.tipoMovimento == TipoMovimentoExtratoCaixa.debito)
        .fold<double>(0, (total, item) => total + item.valor);
    final saldo = totalEntradas - totalSaidas;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ResumoValorChip(
                titulo: 'Entradas',
                valor: _formatarMoeda(totalEntradas),
                color: Colors.green,
              ),
              _ResumoValorChip(
                titulo: 'Saidas',
                valor: _formatarMoeda(totalSaidas),
                color: Colors.red,
              ),
              _ResumoValorChip(
                titulo: 'Saldo do periodo',
                valor: _formatarMoeda(saldo),
                color: saldo < 0 ? Colors.red : Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResumoValorChip extends StatelessWidget {
  final String titulo;
  final String valor;
  final Color color;

  const _ResumoValorChip({
    required this.titulo,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

String _rotuloHistorico(TipoHistoricoExtratoCaixa tipo) {
  switch (tipo) {
    case TipoHistoricoExtratoCaixa.aberturaDeCaixa:
      return 'Abertura de caixa';
  }
}

String _formatarDataHora(DateTime data) {
  final local = data.toLocal();
  final dia = local.day.toString().padLeft(2, '0');
  final mes = local.month.toString().padLeft(2, '0');
  final ano = local.year.toString();
  final hora = local.hour.toString().padLeft(2, '0');
  final minuto = local.minute.toString().padLeft(2, '0');
  return '$dia/$mes/$ano $hora:$minuto';
}

String _formatarMoeda(double valor) {
  return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
}
