import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:siv_front/presentation/bloc/sync_data/sync_data_bloc.dart';
import 'package:siv_front/presentation/pages/sync/sync_status_icone.dart';

const _titulo = 'Zerar sincronização incremental?';
const _corpo =
    'Isso apagará o histórico de sincronização e o app buscará todos os dados novamente como se fosse a primeira vez. O processo pode ser mais demorado.';

/// Dialog no desktop, bottom sheet no mobile.
void syncConfirmarReset(BuildContext context, {required bool desktop}) {
  void confirmar(BuildContext ctx) {
    Navigator.of(ctx).pop();
    sl<SyncDataBloc>().add(const SyncDataSolicitouResetIncremental());
  }

  const quadrado = RoundedRectangleBorder();

  Widget confirmarBtn(BuildContext ctx, double altura) => FilledButton(
    onPressed: () => confirmar(ctx),
    style: FilledButton.styleFrom(
      backgroundColor: syncErro,
      shape: quadrado,
      minimumSize: Size(0, altura),
      padding: const EdgeInsets.symmetric(horizontal: 18),
    ),
    child: Text(
      'Zerar e sincronizar',
      style: syncBarlow(13, w: FontWeight.w600, c: Colors.white),
    ),
  );

  Widget cancelarBtn(BuildContext ctx, double altura) => OutlinedButton(
    onPressed: () => Navigator.of(ctx).pop(),
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: syncLinha),
      shape: quadrado,
      minimumSize: Size(0, altura),
      padding: const EdgeInsets.symmetric(horizontal: 18),
    ),
    child: Text('Cancelar', style: syncBarlow(13)),
  );

  if (desktop) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: quadrado,
        elevation: 24,
        child: SizedBox(
          width: 480,
          child: SyncMarcasRegistro(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_titulo, style: syncCond(24)),
                  const SizedBox(height: 14),
                  Text(
                    _corpo,
                    style: syncBarlow(14, c: const Color(0xBF26282A), h: 1.55),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      cancelarBtn(ctx, 40),
                      const SizedBox(width: 10),
                      confirmarBtn(ctx, 40),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  } else {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: quadrado,
      showDragHandle: false,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_titulo, style: syncCond(22)),
              const SizedBox(height: 12),
              Text(
                _corpo,
                style: syncBarlow(13.5, c: const Color(0xBF26282A), h: 1.55),
              ),
              const SizedBox(height: 20),
              confirmarBtn(ctx, 48),
              const SizedBox(height: 10),
              cancelarBtn(ctx, 44),
            ],
          ),
        ),
      ),
    );
  }
}
