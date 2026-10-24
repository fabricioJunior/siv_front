import 'package:flutter/material.dart';
import 'package:siv_front/presentation/bloc/sync_data/sync_data_bloc.dart';
import 'package:siv_front/presentation/pages/sync/sync_modulos_tabela.dart';
import 'package:siv_front/presentation/pages/sync/sync_status_icone.dart';

/// Card do módulo (mobile).
class SyncModuloCard extends StatelessWidget {
  final SyncModuloState modulo;
  const SyncModuloCard({super.key, required this.modulo});

  @override
  Widget build(BuildContext context) {
    final m = modulo;
    final info = syncBarlow(12, c: const Color(0xA626282A));

    return SyncMarcasRegistro(
      child: AnimatedContainer(
        duration: syncDur(context, 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: syncCorFundo(m.status),
          border: Border.all(color: syncLinha),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SyncStatusIcone(status: m.status, caixa: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    m.nomeModulo,
                    style: syncBarlow(14.5, w: FontWeight.w600),
                  ),
                ),
                SyncTag(status: m.status),
              ],
            ),
            const SizedBox(height: 10),
            SyncBarra(
              valor: m.status == SyncModuloStatus.aguardando ? 0 : m.progresso,
              cor: syncCorBarra(m.status),
              indeterminada: m.status == SyncModuloStatus.sincronizando,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${syncPaginas(m)} pág. · ${syncItens(m)} itens',
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: info,
                  ),
                ),
                Text(syncAtualizado(m), style: info),
              ],
            ),
            SyncErro(
              texto: m.erro,
              tamanho: 12,
              padding: const EdgeInsets.only(top: 10),
            ),
          ],
        ),
      ),
    );
  }
}
