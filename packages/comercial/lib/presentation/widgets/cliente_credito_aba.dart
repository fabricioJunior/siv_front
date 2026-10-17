import 'package:comercial/models.dart';
import 'package:comercial/presentation/widgets/transferir_credito_dialogo.dart'
    show formatarMoedaBr;
import 'package:comercial/use_cases.dart';
import 'package:core/injecoes/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

enum _Segmento { creditos, extrato }

class _LinhaExtrato {
  final CreditoDevolucaoMovimentacao mov;
  final double saldo;
  const _LinhaExtrato(this.mov, this.saldo);
}

/// Aba Crédito de devolução (sem Scaffold; vai dentro da aba do cliente).
/// "Transferir do não cadastrado" fica no cabeçalho da tela do cliente.
class ClienteCreditoAba extends StatefulWidget {
  final int pessoaId;

  const ClienteCreditoAba({super.key, required this.pessoaId});

  @override
  State<ClienteCreditoAba> createState() => _ClienteCreditoAbaState();
}

class _ClienteCreditoAbaState extends State<ClienteCreditoAba> {
  var _segmento = _Segmento.creditos;
  var _carregando = true;
  String? _erro;
  var _saldo = 0.0;
  var _linhas = const <_LinhaExtrato>[];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final movs = await sl<BuscarCreditoDevolucaoMovimentacoes>()
          .call(pessoaId: widget.pessoaId);
      final saldo =
          await sl<BuscarSaldoCreditoDevolucao>().call(pessoaId: widget.pessoaId);
      movs.sort((a, b) => a.data.compareTo(b.data));
      var acumulado = 0.0;
      final linhas = <_LinhaExtrato>[];
      for (final m in movs) {
        if (!m.cancelado) acumulado += m.valorAssinado;
        linhas.add(_LinhaExtrato(m, acumulado));
      }
      if (!mounted) return;
      setState(() {
        _saldo = saldo;
        _linhas = linhas.reversed.toList();
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Falha ao carregar o crédito de devolução.';
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    if (_carregando) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_erro!, style: textos.apoio.copyWith(color: cores.vinho)),
            TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
              onPressed: _carregar,
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<_Segmento>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: _Segmento.creditos, label: Text('Créditos')),
              ButtonSegment(value: _Segmento.extrato, label: Text('Extrato')),
            ],
            selected: {_segmento},
            onSelectionChanged: (s) => setState(() => _segmento = s.first),
          ),
          const SizedBox(height: 16),
          if (_segmento == _Segmento.creditos)
            _Creditos(saldo: _saldo)
          else
            _Extrato(linhas: _linhas),
        ],
      ),
    );
  }
}

class _Creditos extends StatelessWidget {
  final double saldo;
  const _Creditos({required this.saldo});

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    return SivCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SALDO DISPONÍVEL', style: textos.rotulo),
          const SizedBox(height: 4),
          Text(formatarMoedaBr(saldo), style: textos.valor),
          const SizedBox(height: 12),
          Text(
            'Detalhe por crédito em breve',
            style: textos.apoio.copyWith(color: cores.textoApoio),
          ),
        ],
      ),
    );
  }
}

class _Extrato extends StatelessWidget {
  final List<_LinhaExtrato> linhas;
  const _Extrato({required this.linhas});

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    if (linhas.isEmpty) {
      return Center(
        child: Text(
          'Este cliente ainda não tem crédito de devolução.',
          style: textos.apoio.copyWith(color: cores.textoApoio),
        ),
      );
    }
    return SivTabela(
      colunas: const [
        SivTabelaColuna(titulo: 'DATA', flex: 2),
        SivTabelaColuna(titulo: 'MOVIMENTO', flex: 3),
        SivTabelaColuna(titulo: 'DOCUMENTO', flex: 2),
        SivTabelaColuna.numerica(titulo: 'VALOR'),
        SivTabelaColuna.numerica(titulo: 'SALDO'),
      ],
      quantidadeLinhas: linhas.length,
      rodape: '${linhas.length} movimentação(ões)',
      linhaBuilder: (_, i) {
        final l = linhas[i];
        final m = l.mov;
        final estilo = textos.corpo.copyWith(
          color: m.cancelado ? cores.vinho : null,
          decoration: m.cancelado ? TextDecoration.lineThrough : null,
        );
        final v = m.valorAssinado;
        return [
          Text(formatarDataHora(m.data), style: estilo),
          Text('${m.tipoDocumento} • ${m.tipoMovimento}', style: estilo),
          Text(
            m.romaneioId != null
                ? 'Romaneio ${m.romaneioId}'
                : m.faturaId != null
                    ? 'Fatura ${m.faturaId}'
                    : '-',
            style: estilo,
          ),
          Text(
            '${v < 0 ? '−' : '+'} ${formatarMoedaBr(v.abs())}',
            style: estilo.copyWith(
              fontWeight: v < 0 ? FontWeight.w400 : FontWeight.w700,
            ),
          ),
          Text(formatarMoedaBr(l.saldo), style: estilo),
        ];
      },
    );
  }
}
