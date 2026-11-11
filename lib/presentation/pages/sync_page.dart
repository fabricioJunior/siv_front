import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:siv_front/presentation/bloc/sync_data/sync_data_bloc.dart';
import 'package:siv_front/presentation/pages/sync/sync_confirmar_reset.dart';
import 'package:siv_front/presentation/pages/sync/sync_modulo_card.dart';
import 'package:siv_front/presentation/pages/sync/sync_modulos_tabela.dart';
import 'package:siv_front/presentation/pages/sync/sync_resumo_faixa.dart';
import 'package:siv_front/presentation/pages/sync/sync_status_icone.dart';

class SyncPage extends StatelessWidget {
  const SyncPage({super.key});

  void _sincronizar() => sl<SyncDataBloc>().add(
    const SyncDataSolicitouSincronizacao(origem: SyncDataOrigem.manual),
  );

  Widget _botaoPrimario(
    bool sincronizando, {
    double? altura,
    double padH = 16,
  }) {
    return Opacity(
      opacity: sincronizando ? .45 : 1,
      child: FilledButton.icon(
        onPressed: sincronizando ? null : _sincronizar,
        icon: const Icon(Icons.sync, size: 15),
        label: Text(
          sincronizando ? 'Sincronizando…' : 'Sincronizar agora',
          style: syncBarlow(13, w: FontWeight.w600, c: Colors.white),
        ),
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
          elevation: const WidgetStatePropertyAll(0),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          minimumSize: WidgetStatePropertyAll(Size(0, altura ?? 0)),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: padH, vertical: 9),
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.pressed)
                ? const Color(0xFF416180)
                : s.contains(WidgetState.hovered)
                ? const Color(0xFF4A6C8E)
                : syncAcento,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SyncDataBloc>.value(
      value: sl<SyncDataBloc>(),
      child: LayoutBuilder(
        builder: (context, c) {
          final desktop = c.maxWidth >= 720;
          return BlocBuilder<SyncDataBloc, SyncDataState>(
            builder: (context, state) {
              final sinc = state.sincronizando;
              final mods = syncModulos(state);
              return desktop
                  ? _desktop(context, state, mods, sinc)
                  : _mobile(context, state, mods, sinc);
            },
          );
        },
      ),
    );
  }

  Widget _desktop(
    BuildContext context,
    SyncDataState state,
    List<SyncModuloState> mods,
    bool sinc,
  ) {
    return Scaffold(
      backgroundColor: syncFundo,
      body: Column(
        children: [
          Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 34),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: syncLinhaFina)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Sincronização de dados',
                    style: syncCond(21, w: FontWeight.w500),
                  ),
                ),
                Opacity(
                  opacity: sinc ? .45 : 1,
                  child: OutlinedButton.icon(
                    onPressed: sinc
                        ? null
                        : () => syncConfirmarReset(context, desktop: true),
                    icon: const Icon(Icons.restore, size: 15),
                    label: Text('Zerar incremental', style: syncBarlow(13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: syncTexto,
                      side: const BorderSide(color: syncLinha),
                      shape: const RoundedRectangleBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _botaoPrimario(sinc),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 26),
              children: [
                SyncResumoFaixa(state: state, compacto: false),
                const SizedBox(height: 28),
                SyncModulosTabela(mods: mods),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobile(
    BuildContext context,
    SyncDataState state,
    List<SyncModuloState> mods,
    bool sinc,
  ) {
    return Scaffold(
      backgroundColor: syncFundo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 56,
        title: Text('Sincronização', style: syncCond(19)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: syncLinhaFina),
        ),
        actions: [
          IconButton(
            tooltip: 'Zerar incremental',
            constraints: const BoxConstraints.tightFor(width: 44, height: 44),
            icon: const Icon(Icons.restore, size: 19),
            onPressed: sinc
                ? null
                : () => syncConfirmarReset(context, desktop: false),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SyncResumoFaixa(state: state, compacto: true),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Módulos', style: syncCond(17)),
              Flexible(
                child: Text(
                  syncContagem(mods),
                  overflow: TextOverflow.ellipsis,
                  style: syncBarlow(11.5, c: syncTextoSuave),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < mods.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            SyncModuloCard(modulo: mods[i]),
          ],
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          20 + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: syncLinhaFina)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: _botaoPrimario(sinc, altura: 48),
        ),
      ),
    );
  }
}
