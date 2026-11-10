import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:siv_front/presentation/bloc/sync_data/sync_data_bloc.dart';
import 'package:siv_front/presentation/pages/sync/sync_status_icone.dart'
    show syncDur;

enum _Fase { ocioso, sincronizando, concluido, falha }

/// Botão "Sincronizar" da barra lateral: ícone gira durante o sync, vira check
/// ao concluir (volta ao normal em 2,5 s) e vira alerta se algum módulo falhar.
/// [compacto] = só o ícone com tooltip (rail de 72 px).
class BotaoSincronizarMenu extends StatefulWidget {
  final bool compacto;
  const BotaoSincronizarMenu({super.key, this.compacto = false});

  @override
  State<BotaoSincronizarMenu> createState() => _BotaoSincronizarMenuState();
}

class _BotaoSincronizarMenuState extends State<BotaoSincronizarMenu>
    with SingleTickerProviderStateMixin {
  final _bloc = sl<SyncDataBloc>();
  late final _giro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  Timer? _volta;
  late _Fase _fase = _faseDe(_bloc.state) ?? _Fase.ocioso;

  _Fase? _faseDe(SyncDataState s) {
    if (s.sincronizando) return _Fase.sincronizando;
    if (s.modulos.values.any((m) => m.status == SyncModuloStatus.falha)) {
      return _Fase.falha;
    }
    return null;
  }

  void _aoMudar(SyncDataState s) {
    final nova = _faseDe(s) ??
        (_fase == _Fase.sincronizando ? _Fase.concluido : _fase);
    if (nova == _fase) return;
    _volta?.cancel();
    if (nova == _Fase.concluido) {
      _volta = Timer(const Duration(milliseconds: 2500), () {
        if (mounted) setState(() => _fase = _Fase.ocioso);
      });
    }
    setState(() => _fase = nova);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animar =
        _fase == _Fase.sincronizando && !MediaQuery.disableAnimationsOf(context);
    if (animar && !_giro.isAnimating) {
      _giro.repeat();
    } else if (!animar) {
      _giro.stop();
    }
  }

  @override
  void dispose() {
    _volta?.cancel();
    _giro.dispose();
    super.dispose();
  }

  void _sincronizar() {
    if (_fase == _Fase.sincronizando) return;
    _bloc.add(
      const SyncDataSolicitouSincronizacao(origem: SyncDataOrigem.manual),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    return BlocListener<SyncDataBloc, SyncDataState>(
      bloc: _bloc,
      listener: (_, s) {
        _aoMudar(s);
        didChangeDependencies();
      },
      child: Builder(
        builder: (context) {
          final (rotulo, cor, icone) = switch (_fase) {
            _Fase.ocioso => (
              'Sincronizar',
              cores.textoSobreEscuroTitulo,
              Icons.sync,
            ),
            _Fase.sincronizando => (
              'Sincronizando…',
              cores.ceu,
              Icons.sync,
            ),
            _Fase.concluido => (
              'Sincronizado',
              const Color(0xFF5FB37C),
              Icons.check_circle_outline,
            ),
            _Fase.falha => (
              'Falha · tentar de novo',
              const Color(0xFFE08A8A),
              Icons.sync_problem,
            ),
          };
          final iconeAnimado = AnimatedSwitcher(
            duration: syncDur(context, 200),
            transitionBuilder: (c, a) => FadeTransition(
              opacity: a,
              child: ScaleTransition(
                scale: Tween(begin: .6, end: 1.0).animate(a),
                child: c,
              ),
            ),
            child: RotationTransition(
              key: ValueKey(icone),
              // sync gira no sentido anti-horário (seta do Material)
              turns: Tween(begin: 1.0, end: 0.0).animate(_giro),
              child: Icon(icone, size: 15, color: cor),
            ),
          );

          if (widget.compacto) {
            return Tooltip(
              message: rotulo,
              child: InkWell(
                onTap: _sincronizar,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Center(child: iconeAnimado),
                ),
              ),
            );
          }

          return Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: _sincronizar,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                child: Row(
                  children: [
                    iconeAnimado,
                    const SizedBox(width: 10),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: syncDur(context, 200),
                        layoutBuilder: (atual, antigos) => Stack(
                          alignment: Alignment.centerLeft,
                          children: [...antigos, ?atual],
                        ),
                        child: Text(
                          rotulo,
                          key: ValueKey(rotulo),
                          overflow: TextOverflow.ellipsis,
                          style: context.sivTextos.apoio.copyWith(color: cor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
