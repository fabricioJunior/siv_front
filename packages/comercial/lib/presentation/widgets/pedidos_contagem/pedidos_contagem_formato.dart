import 'package:comercial/domain/models/relatorio_pedidos_contagem.dart';
import 'package:comercial/presentation/blocs/relatorio_pedidos_contagem_cubit/relatorio_pedidos_contagem_cubit.dart';
import 'package:comercial/presentation/widgets/frequencia/frequencia_formato.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

const rotulosEtapaContagem = {
  'contando': 'Contando',
  'associando': 'Associando',
  'etiquetando': 'Etiquetas',
  'conferindo': 'Conferindo',
  'faturando': 'Pronto p/ faturar',
  'faturado': 'Faturado',
};

String pcQtd(num v) =>
    v == v.roundToDouble() ? frequenciaInt(v) : frequenciaDec(v, 2);

String pcData(DateTime? d) => d == null ? '—' : frequenciaDiaAno(d);

/// 'hoje' ou 'N dias' desde a abertura.
String pcEmAbertoHa(DateTime abertoEm, DateTime hoje) {
  final n = pcDiasEmAberto(abertoEm, hoje);
  return n <= 0 ? 'hoje' : (n == 1 ? '1 dia' : '$n dias');
}

int pcDiasEmAberto(DateTime abertoEm, DateTime hoje) =>
    DateTime(hoje.year, hoje.month, hoje.day)
        .difference(DateTime(abertoEm.year, abertoEm.month, abertoEm.day))
        .inDays;

bool pcAlerta(PedidoContagemLinha l, DateTime hoje) =>
    !l.faturado &&
    l.abertoEm != null &&
    pcDiasEmAberto(l.abertoEm!, hoje) > diasAlertaContagemAberta;

/// Primeiro produto + `+N produtos`; com filtro de produto mostra cor e tamanho.
String pcPrimeiroProduto(PedidoContagemLinha l, {required bool comVariacao}) {
  final p = l.primeiroProduto;
  if (p == null) return '—';
  final extra = comVariacao
      ? [p.cor, p.tamanho].whereType<String>().where((s) => s.isNotEmpty)
      : const <String>[];
  return [p.referenciaNome, ...extra].join(' · ');
}

String pcMaisProdutos(PedidoContagemLinha l) => l.quantidadeReferencias > 1
    ? '+${l.quantidadeReferencias - 1} produtos'
    : '';

/// Texto do período (data usada + intervalo) para a base e o cartão mobile.
String pcPeriodoTexto(FiltroPedidosContagem f) {
  final data = f.situacao == SituacaoContagem.faturado
      ? 'data de faturamento'
      : 'data de abertura';
  final intervalo = f.de == null || f.ate == null
      ? 'Todo o período'
      : '${frequenciaDiaAno(f.de!)} a ${frequenciaDiaAno(f.ate!)}';
  return '$intervalo · $data';
}

/// Trilha de 5 segmentos: feitos em aço, atual em aço claro, pendentes em cinza.
class TrilhaContagem extends StatelessWidget {
  final String etapa;
  final double? largura;
  const TrilhaContagem(this.etapa, {super.key, this.largura});

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    final atual = etapasContagem.indexOf(etapa);
    final faturado = etapa == 'faturado';
    Color cor(int i) => faturado
        ? c.acoEscuro
        : i < atual
            ? c.aco
            : i == atual
                ? c.ceu
                : c.hairline;
    return SizedBox(
      width: largura,
      child: Row(
        children: [
          for (var i = 0; i < 5; i++)
            Expanded(
              child: Container(
                height: 3,
                margin: EdgeInsets.only(right: i < 4 ? 3 : 0),
                decoration: BoxDecoration(
                  color: cor(i),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class EtapaTag extends StatelessWidget {
  final String etapa;
  const EtapaTag(this.etapa, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    final (Color fundo, Color borda, Color texto) = switch (etapa) {
      'associando' => (c.atencaoFundo, c.atencaoBorda, c.atencao),
      'faturado' => (c.acoEscuro, c.acoEscuro, c.textoSobreEscuroTitulo),
      _ => (c.superficieRecuada, c.hairline, c.tinta),
    };
    return Container(
      key: Key('contagem_etapa_$etapa'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: fundo,
        border: Border.all(color: borda),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        rotulosEtapaContagem[etapa] ?? etapa,
        style: context.sivTextos.apoio.copyWith(fontSize: 11, color: texto),
      ),
    );
  }
}
