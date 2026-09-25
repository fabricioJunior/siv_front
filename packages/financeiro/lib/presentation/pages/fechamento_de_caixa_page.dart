import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/presentation.dart';
import 'package:flutter/material.dart';

const _corEntrada = Color(0xFF2F6A3A);

class FechamentoDeCaixaPage extends StatefulWidget {
  final int caixaId;

  const FechamentoDeCaixaPage({
    super.key,
    required this.caixaId,
  });

  @override
  State<FechamentoDeCaixaPage> createState() => _FechamentoDeCaixaPageState();
}

class _FechamentoDeCaixaPageState extends State<FechamentoDeCaixaPage> {
  bool _confirmouConferencia = false;

  void _recarregarConferencia() {
    _confirmouConferencia = false;
    context.read<FechamentoDeCaixaBloc>().add(
          FechamentoDeCaixaRecarregarSolicitado(caixaId: widget.caixaId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FechamentoDeCaixaBloc>(
      create: (_) => sl<FechamentoDeCaixaBloc>()
        ..add(FechamentoDeCaixaIniciou(caixaId: widget.caixaId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Fechamento de caixa'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Recarregar valores (ex: após lançar sangria/suprimento)',
              onPressed: _recarregarConferencia,
            ),
          ],
        ),
        body: BlocBuilder<FechamentoDeCaixaBloc, FechamentoDeCaixaState>(
          builder: (context, state) {
            if (state.step == FechamentoDeCaixaStep.carregando ||
                state.step == FechamentoDeCaixaStep.inicial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.step == FechamentoDeCaixaStep.falha) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 36),
                      const SizedBox(height: 12),
                      Text(
                        state.erro ??
                            'Falha ao carregar os valores para conferencia do fechamento.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _recarregarConferencia,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final itens = state.itens;
            final totalEsperado = itens.fold<double>(
              0,
              (total, item) => total + item.valorEsperado,
            );
            final totalContado = itens.fold<double>(
              0,
              (total, item) => total + item.valorContado,
            );
            final diferencaTotal = (totalContado - totalEsperado).abs();
            final possuiDivergencia = diferencaTotal >= 0.01;
            final cores = context.sivColors;
            final textos = context.sivTextos;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'ETAPA 2 DE 3 · CONFIRMAÇÃO DOS VALORES CONTADOS',
                style: textos.rotulo.copyWith(color: cores.aco, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Text(
                'Caixa #${widget.caixaId}',
                style: textos.apoio.copyWith(color: cores.textoApoio),
              ),
              const SizedBox(height: SivDimensoes.gapCards),
              if (itens.isEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cores.selecaoFundo,
                    border: Border.all(color: cores.aco),
                    borderRadius: BorderRadius.circular(SivDimensoes.raio),
                  ),
                  child: Text(
                    'Não há itens pendentes para conferência.',
                    style: textos.corpo,
                  ),
                )
              else
                Stack(
                  children: [
                    SivTabela(
                      colunas: const [
                        SivTabelaColuna(titulo: 'FORMA', flex: 2),
                        SivTabelaColuna.numerica(titulo: 'ESPERADO', flex: 1),
                        SivTabelaColuna.numerica(titulo: 'CONTADO', flex: 1),
                        SivTabelaColuna.numerica(titulo: 'DIF.', flex: 1),
                      ],
                      quantidadeLinhas: itens.length,
                      linhaBuilder: (context, indice) =>
                          _linhaConferencia(context, itens[indice]),
                    ),
                    ...sivCantosBlueprint(cores.hairline),
                  ],
                ),
              const SizedBox(height: SivDimensoes.gapCards),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cores.superficie,
                  border: Border.all(color: cores.hairline),
                  borderRadius: BorderRadius.circular(SivDimensoes.raio),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Resumo da conferência', style: textos.secao.copyWith(fontSize: 14)),
                    const SizedBox(height: 5),
                    Text(
                      'Total esperado: ${_formatarMoeda(totalEsperado)} · Total contado: ${_formatarMoeda(totalContado)}',
                      style: textos.apoio.copyWith(color: cores.textoApoio),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Diferença: ${_formatarMoeda(diferencaTotal)}',
                      style: textos.secao.copyWith(
                        fontSize: 15,
                        color: possuiDivergencia ? cores.atencao : _corEntrada,
                      ),
                    ),
                  ],
                ),
              ),
              if (state.faturamento != null) ...[
                const SizedBox(height: SivDimensoes.gapCards),
                _CardFaturamento(faturamento: state.faturamento!),
              ],
              if (possuiDivergencia) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cores.atencaoFundo,
                    border: Border.all(color: cores.atencaoBorda),
                    borderRadius: BorderRadius.circular(SivDimensoes.raio),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: cores.atencao, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fechamento bloqueado por divergência',
                              style: textos.corpo.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'A contagem deve bater com o valor esperado para fechar o caixa.',
                              style: textos.apoio.copyWith(color: cores.textoApoio),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              CheckboxListTile(
                value: _confirmouConferencia,
                onChanged: possuiDivergencia
                    ? null
                    : (value) {
                  setState(() {
                    _confirmouConferencia = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
                title: const Text('Confirmo os valores contados e esperados'),
                subtitle: Text(
                  possuiDivergencia
                      ? 'Corrija a divergência para liberar o fechamento.'
                      : 'Ao confirmar, o fechamento concreto do caixa será executado.',
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: !_confirmouConferencia || possuiDivergencia
                      ? null
                      : () {
                          Navigator.of(context).pop(true);
                        },
                  icon: const Icon(Icons.lock_outline),
                  label: const Text('CONFIRMAR FECHAMENTO'),
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

List<Widget> _linhaConferencia(BuildContext context, ConferenciaFechamentoItem item) {
  final cores = context.sivColors;
  final textos = context.sivTextos;
  final diferenca = item.valorContado - item.valorEsperado;
  final corDiferenca = diferenca.abs() < 0.01 ? _corEntrada : cores.atencao;

  return [
    Text(_labelTipo(item.tipo), style: textos.corpo),
    Text(_formatarValor(item.valorEsperado), textAlign: TextAlign.right, style: textos.corpo),
    Text(_formatarValor(item.valorContado), textAlign: TextAlign.right, style: textos.corpo),
    Text(
      _formatarValor(diferenca.abs()),
      textAlign: TextAlign.right,
      style: textos.corpo.copyWith(color: corDiferenca, fontWeight: FontWeight.w600),
    ),
  ];
}

String _formatarValor(double valor) => valor.toStringAsFixed(2).replaceAll('.', ',');

String _labelTipo(TipoContagemDoCaixaItem tipo) {
  switch (tipo) {
    case TipoContagemDoCaixaItem.dinheiro:
      return 'Dinheiro';
    case TipoContagemDoCaixaItem.pix:
      return 'Pix';
    case TipoContagemDoCaixaItem.cartao:
      return 'Cartao';
    case TipoContagemDoCaixaItem.fatura:
      return 'Fatura';
    case TipoContagemDoCaixaItem.cheque:
      return 'Cheque';
    case TipoContagemDoCaixaItem.troco:
      return 'Troco';
    case TipoContagemDoCaixaItem.voucher:
      return 'Voucher';
    case TipoContagemDoCaixaItem.tedDoc:
      return 'TED/DOC';
    case TipoContagemDoCaixaItem.adiantamento:
      return 'Adiantamento';
    case TipoContagemDoCaixaItem.creditoDeDevolucao:
      return 'Credito de devolucao';
  }
}

String _formatarMoeda(double valor) {
  return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
}

class _CardFaturamento extends StatelessWidget {
  final FaturamentoDoCaixa faturamento;

  const _CardFaturamento({required this.faturamento});

  @override
  Widget build(BuildContext context) {
    final naoContabilizado = faturamento.naoContabilizado;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Faturamento do caixa',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(
              'Faturamento total: ${_formatarMoeda(faturamento.totalFaturamento)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              'Contabilizado na contagem: ${_formatarMoeda(faturamento.totalContabilizado)}',
            ),
            if (naoContabilizado.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Não entra na contagem (ex: pagamento online já confirmado eletronicamente): '
                '${_formatarMoeda(faturamento.totalNaoContabilizado)}',
                style: TextStyle(color: Colors.blueGrey.shade700),
              ),
              const SizedBox(height: 4),
              ...naoContabilizado.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Text(
                    '• ${_labelTipo(item.tipoDocumento)}: ${_formatarMoeda(item.valor)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
