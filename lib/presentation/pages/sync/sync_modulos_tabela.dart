import 'package:flutter/material.dart';
import 'package:siv_front/presentation/bloc/sync_data/sync_data_bloc.dart';
import 'package:siv_front/presentation/pages/sync/sync_resumo_faixa.dart';
import 'package:siv_front/presentation/pages/sync/sync_status_icone.dart';

String syncContagem(List<SyncModuloState> mods) {
  final ok = mods.where((m) => m.status == SyncModuloStatus.concluido).length;
  final falhas = mods.where((m) => m.status == SyncModuloStatus.falha).length;
  return '$ok de ${mods.length} concluídos${falhas > 0 ? ' · $falhas com falha' : ''}';
}

String syncPaginas(SyncModuloState m) =>
    '${m.paginasSincronizadas}/${m.totalPaginas == 0 ? '—' : m.totalPaginas}';

String syncItens(SyncModuloState m) =>
    '${syncNum(m.itensSincronizados)}/${syncNum(m.totalItens)}';

String syncAtualizado(SyncModuloState m) =>
    m.status == SyncModuloStatus.sincronizando
    ? 'agora'
    : syncHora(m.atualizadoEm);

/// Tabela de módulos (desktop).
class SyncModulosTabela extends StatelessWidget {
  final List<SyncModuloState> mods;
  const SyncModulosTabela({super.key, required this.mods});

  static Widget _cols(List<Widget> c) => Row(
    children: [
      SizedBox(width: 240, child: c[0]),
      const SizedBox(width: 20),
      SizedBox(width: 140, child: c[1]),
      const SizedBox(width: 20),
      Expanded(child: c[2]),
      const SizedBox(width: 20),
      SizedBox(width: 110, child: c[3]),
      const SizedBox(width: 20),
      SizedBox(width: 150, child: c[4]),
      const SizedBox(width: 20),
      SizedBox(width: 120, child: c[5]),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final cab = syncCond(11.5, c: const Color(0x8026282A), ls: 1.15);
    Widget h(String t, {bool dir = false}) =>
        Text(t, style: cab, textAlign: dir ? TextAlign.right : TextAlign.left);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Módulos', style: syncCond(18)),
            Text(syncContagem(mods), style: syncBarlow(12, c: syncTextoSuave)),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
            border: Border.symmetric(horizontal: BorderSide(color: syncLinha)),
          ),
          child: _cols([
            h('MÓDULO'),
            h('SITUAÇÃO'),
            h('PROGRESSO'),
            h('PÁGINAS', dir: true),
            h('ITENS', dir: true),
            h('ATUALIZADO', dir: true),
          ]),
        ),
        for (final m in mods) _Linha(modulo: m),
      ],
    );
  }
}

class _Linha extends StatelessWidget {
  final SyncModuloState modulo;
  const _Linha({required this.modulo});

  @override
  Widget build(BuildContext context) {
    final m = modulo;
    final ativo = m.status == SyncModuloStatus.sincronizando;
    final pct = m.progresso == null ? '—' : '${(m.progresso! * 100).round()}%';
    final semDados = m.status == SyncModuloStatus.aguardando;

    Widget dir(String t, double s, [Color c = syncTexto]) => Text(
      t,
      textAlign: TextAlign.right,
      style: syncBarlow(s, c: c),
    );

    return AnimatedContainer(
      duration: syncDur(context, 250),
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: syncCorFundo(m.status),
        border: const Border(bottom: BorderSide(color: syncLinhaFina)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SyncModulosTabela._cols([
            Row(
              children: [
                SyncStatusIcone(status: m.status),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    m.nomeModulo,
                    style: syncBarlow(14.5, w: FontWeight.w600),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: SyncTag(status: m.status),
            ),
            Row(
              children: [
                Expanded(
                  child: SyncBarra(
                    valor: semDados ? 0 : m.progresso,
                    cor: syncCorBarra(m.status),
                    indeterminada: ativo,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 38,
                  child: Text(
                    semDados ? '—' : pct,
                    textAlign: TextAlign.right,
                    style: syncBarlow(12.5),
                  ),
                ),
              ],
            ),
            dir(syncPaginas(m), 13),
            dir(syncItens(m), 13),
            dir(syncAtualizado(m), 12.5, syncTextoSuave),
          ]),
          SyncErro(
            texto: m.erro,
            tamanho: 12.5,
            padding: const EdgeInsets.only(left: 30, top: 8),
          ),
        ],
      ),
    );
  }
}
