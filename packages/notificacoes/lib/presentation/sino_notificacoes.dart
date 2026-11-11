import 'package:core/bloc.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:notificacoes/presentation/notificacoes_bloc.dart';

/// Sino do menu lateral: badge com a contagem de não lidas; toque abre o
/// painel com a lista. [navigatorKey] porque o menu fica acima do Navigator.
/// [compacto] = só o ícone (rail).
class SinoNotificacoes extends StatelessWidget {
  final NotificacoesBloc bloc;
  final GlobalKey<NavigatorState> navigatorKey;
  final bool compacto;

  const SinoNotificacoes({
    super.key,
    required this.bloc,
    required this.navigatorKey,
    this.compacto = false,
  });

  void _abrir() {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    showDialog<void>(
      context: ctx,
      builder: (_) => _PainelNotificacoes(bloc: bloc),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    return BlocBuilder<NotificacoesBloc, NotificacoesState>(
      bloc: bloc,
      buildWhen: (a, b) => a.naoLidas != b.naoLidas,
      builder: (context, state) {
        final icone = Badge(
          isLabelVisible: state.naoLidas > 0,
          label: Text(state.naoLidas > 99 ? '99+' : '${state.naoLidas}'),
          child: Icon(
            Icons.notifications_outlined,
            size: 15,
            color: cores.textoSobreEscuroTitulo,
          ),
        );
        if (compacto) {
          return Tooltip(
            message: 'Notificações',
            child: InkWell(
              onTap: _abrir,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Center(child: icone),
              ),
            ),
          );
        }
        return Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: _abrir,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              child: Row(
                children: [
                  icone,
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Notificações',
                      overflow: TextOverflow.ellipsis,
                      style: context.sivTextos.apoio.copyWith(
                        color: cores.textoSobreEscuroTitulo,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PainelNotificacoes extends StatelessWidget {
  final NotificacoesBloc bloc;
  const _PainelNotificacoes({required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
        child: BlocBuilder<NotificacoesBloc, NotificacoesState>(
          bloc: bloc,
          builder: (context, state) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Notificações'),
                trailing: TextButton(
                  onPressed: state.lista.isEmpty
                      ? null
                      : () => bloc.add(NotificacoesMarcouTodasLidas()),
                  child: const Text('Marcar todas como lidas'),
                ),
              ),
              const Divider(height: 1),
              if (state.carregando && state.lista.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                )
              else if (state.lista.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.erro == null
                        ? 'Nenhuma notificação nova.'
                        : 'Não foi possível carregar as notificações.',
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: state.lista.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final n = state.lista[i];
                      return ListTile(
                        title: Text(n.titulo),
                        subtitle: Text(n.corpo),
                        trailing: IconButton(
                          tooltip: 'Marcar como lida',
                          icon: const Icon(Icons.done),
                          onPressed: () => bloc.add(NotificacaoMarcouLida(n.id)),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
