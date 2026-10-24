import 'package:flutter/material.dart';
import 'package:siv_front/presentation/bloc/sync_data/sync_data_bloc.dart';
import 'package:siv_front/presentation/pages/sync/sync_status_icone.dart';

List<SyncModuloState> syncModulos(SyncDataState s) =>
    s.modulos.values.toList()
      ..sort((a, b) => a.modulo.index.compareTo(b.modulo.index));

String _p2(int n) => n.toString().padLeft(2, '0');

String syncHora(DateTime? dt) {
  if (dt == null) return '—';
  final l = dt.toLocal();
  return '${_p2(l.hour)}:${_p2(l.minute)}:${_p2(l.second)}';
}

String _fmtDt(DateTime? dt, bool compacto) {
  if (dt == null) return '—';
  final l = dt.toLocal();
  final dm = '${_p2(l.day)}/${_p2(l.month)}${compacto ? '' : '/${l.year}'}';
  return '$dm ${syncHora(l)}';
}

String _origem(SyncDataOrigem? o) => switch (o) {
  SyncDataOrigem.home => 'Automática (início)',
  SyncDataOrigem.entradaDeProdutos => 'Entrada de produtos',
  SyncDataOrigem.manual => 'Manual',
  SyncDataOrigem.criarRomaneio => 'Criação de romaneio',
  SyncDataOrigem.vendas => 'Vendas',
  SyncDataOrigem.estoque => 'Estoque',
  SyncDataOrigem.tempoReal => 'Tempo real',
  null => '—',
};

/// Faixa marinho com situação, datas e progresso geral.
class SyncResumoFaixa extends StatelessWidget {
  final SyncDataState state;
  final bool compacto;
  const SyncResumoFaixa({
    super.key,
    required this.state,
    required this.compacto,
  });

  @override
  Widget build(BuildContext context) {
    final mods = syncModulos(state);
    final pagFeitas = mods.fold<int>(0, (s, m) => s + m.paginasSincronizadas);
    final pagTotal = mods.fold<int>(0, (s, m) => s + m.totalPaginas);
    final falhas = mods
        .where((m) => m.status == SyncModuloStatus.falha)
        .toList();
    final ativo = mods
        .where((m) => m.status == SyncModuloStatus.sincronizando)
        .firstOrNull;
    final fim = state.finalizadoEm;
    final pct = falhas.isEmpty && fim != null
        ? 100
        : pagTotal == 0
        ? 0
        : (pagFeitas / pagTotal * 100).round();

    final String kicker, titulo, sub;
    if (state.sincronizando) {
      kicker = 'EM ANDAMENTO';
      titulo = compacto || ativo == null
          ? 'Sincronizando'
          : 'Sincronizando ${ativo.nomeModulo.toLowerCase()}';
      sub = ativo == null
          ? ''
          : 'Módulo ${mods.indexOf(ativo) + 1} de ${mods.length}'
                '${ativo.totalPaginas == 0 ? '' : ' · página ${ativo.paginaAtual + 1} de ${ativo.totalPaginas}'}';
    } else if (fim != null && falhas.isEmpty) {
      kicker = 'ÚLTIMA SINCRONIZAÇÃO';
      titulo = 'Concluída';
      sub = 'Os ${mods.length} módulos estão atualizados neste terminal.';
    } else if (fim != null) {
      kicker = 'ÚLTIMA SINCRONIZAÇÃO';
      titulo = 'Concluída com falha';
      sub =
          '${falhas.map((m) => m.nomeModulo).join(', ')} não sincronizou. Os demais módulos estão atualizados.';
    } else {
      kicker = 'AGUARDANDO';
      titulo = compacto ? 'Nenhuma ainda' : 'Nenhuma sincronização ainda';
      sub = 'Este terminal ainda não buscou dados. Toque em Sincronizar agora.';
    }

    final inicio = _fmtDt(state.iniciadoEm, compacto);
    final fimTxt = _fmtDt(fim, compacto);
    final origem = _origem(state.origemUltimaSincronizacao);

    Widget meta(String r, String v) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          r,
          style: syncBarlow(
            compacto ? 10 : 10.5,
            c: syncRotulo,
            ls: compacto ? 1.5 : 1.9,
          ),
        ),
        const SizedBox(height: 4),
        Text(v, style: syncBarlow(compacto ? 12 : 12.5, c: Colors.white)),
      ],
    );

    Widget percentual(double grande, double pequeno) => SyncTroca(
      child: Text.rich(
        key: ValueKey(pct),
        TextSpan(
          text: '$pct',
          style: syncCond(grande, c: syncFundo, h: .9),
          children: [
            TextSpan(
              text: '%',
              style: syncCond(pequeno, c: syncRotulo),
            ),
          ],
        ),
      ),
    );

    final kickerW = Text(
      kicker,
      style: syncBarlow(compacto ? 10.5 : 11, c: syncAcentoClaro, ls: 2.2),
    );
    final tituloW = Semantics(
      liveRegion: true,
      child: SyncTroca(
        child: Text(
          titulo,
          key: ValueKey(titulo),
          style: syncCond(compacto ? 24 : 34, c: syncFundo, h: 1.05),
        ),
      ),
    );

    final Widget corpo;
    if (compacto) {
      corpo = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [kickerW, const SizedBox(height: 6), tituloW],
                ),
              ),
              percentual(40, 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: meta('INÍCIO', inicio)),
              Expanded(child: meta('FIM', fimTxt)),
            ],
          ),
          const SizedBox(height: 10),
          meta('ORIGEM', origem),
        ],
      );
    } else {
      corpo = Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                kickerW,
                const SizedBox(height: 18),
                tituloW,
                const SizedBox(height: 18),
                SyncTroca(
                  child: Text(
                    sub,
                    key: ValueKey(sub),
                    style: syncBarlow(13.5, c: syncSubtitulo),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    meta('INÍCIO', inicio),
                    const SizedBox(width: 44),
                    meta('FIM', fimTxt),
                    const SizedBox(width: 44),
                    meta('ORIGEM', origem),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 220,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                percentual(72, 32),
                const SizedBox(height: 8),
                Text(
                  '${syncNum(pagFeitas)} DE ${syncNum(pagTotal)} PÁGINAS',
                  style: syncBarlow(11, c: syncRotulo, ls: 2),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Container(
      color: syncMarinho,
      child: Stack(
        children: [
          Padding(
            padding: compacto
                ? const EdgeInsets.fromLTRB(20, 20, 20, 24)
                : const EdgeInsets.fromLTRB(32, 28, 32, 34),
            child: corpo,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SyncBarra(
              valor: pct / 100,
              altura: 3,
              trilha: const Color(0x1AFFFFFF),
              cor: falhas.isEmpty ? syncAcentoClaro : syncBarraErroGeral,
            ),
          ),
        ],
      ),
    );
  }
}
