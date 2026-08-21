import 'package:comunicados/domain/models/models.dart';
import 'package:comunicados/presentation/blocs/detalhe_comunicado_bloc/detalhe_comunicado_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:flutter/material.dart';

class DetalheComunicadoPage extends StatefulWidget {
  const DetalheComunicadoPage({super.key, required this.comunicadoId});

  final int comunicadoId;

  @override
  State<DetalheComunicadoPage> createState() => _DetalheComunicadoPageState();
}

class _DetalheComunicadoPageState extends State<DetalheComunicadoPage> {
  late final DetalheComunicadoBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<DetalheComunicadoBloc>()
      ..add(DetalheComunicadoCarregar(widget.comunicadoId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Color _corStatus(String status) => switch (status) {
    'enviado' => Colors.green,
    'enviando' => Colors.blue,
    'erro' => Colors.red,
    'pendente' => Colors.amber.shade700,
    _ => Colors.blueGrey,
  };

  String _labelStatus(String status) => switch (status) {
    'enviado' => 'Enviado',
    'enviando' => 'Enviando',
    'erro' => 'Erro',
    'pendente' => 'Pendente',
    _ => status,
  };

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DetalheComunicadoBloc>.value(
      value: _bloc,
      child: BlocConsumer<DetalheComunicadoBloc, DetalheComunicadoState>(
        listenWhen: (previous, current) => previous.erro != current.erro,
        listener: (context, state) {
          if (state.erro != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.erro!), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final comunicado = state.comunicado;
          return Scaffold(
            appBar: AppBar(title: const Text('Comunicado')),
            body: state.step == DetalheComunicadoStep.carregando ||
                    comunicado == null
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async =>
                        _bloc.add(DetalheComunicadoCarregar(widget.comunicadoId)),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _CabecalhoComunicado(
                          comunicado: comunicado,
                          cor: _corStatus(comunicado.status),
                          label: _labelStatus(comunicado.status),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Destinatários (${state.totalDestinatarios})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...state.destinatarios.map(
                          (d) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _DestinatarioTile(
                              destinatario: d,
                              cor: _corStatus(d.status),
                              label: _labelStatus(d.status),
                              reenviando: state.reenviando.contains(d.id),
                              onReenviar: d.status == 'erro'
                                  ? () => _bloc.add(DetalheComunicadoReenviar(d.id))
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _CabecalhoComunicado extends StatelessWidget {
  const _CabecalhoComunicado({
    required this.comunicado,
    required this.cor,
    required this.label,
  });

  final Comunicado comunicado;
  final Color cor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    comunicado.assunto,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: cor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: cor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              comunicado.enviadoEm != null
                  ? 'Enviado em ${formatarDataHora(comunicado.enviadoEm)}'
                  : 'Criado em ${formatarDataHora(comunicado.criadoEm)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Total de destinatários: ${comunicado.totalDestinatarios}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _DestinatarioTile extends StatelessWidget {
  const _DestinatarioTile({
    required this.destinatario,
    required this.cor,
    required this.label,
    required this.reenviando,
    required this.onReenviar,
  });

  final ComunicadoDestinatario destinatario;
  final Color cor;
  final String label;
  final bool reenviando;
  final VoidCallback? onReenviar;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destinatario.emailDestino,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (destinatario.erroMensagem != null)
                    Text(
                      destinatario.erroMensagem!,
                      style: TextStyle(fontSize: 11, color: Colors.red.shade700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: cor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                style: TextStyle(fontSize: 11, color: cor, fontWeight: FontWeight.w600),
              ),
            ),
            if (onReenviar != null) ...[
              const SizedBox(width: 8),
              reenviando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: const Icon(Icons.replay, size: 18),
                      tooltip: 'Reenviar',
                      onPressed: onReenviar,
                    ),
            ],
          ],
        ),
      ),
    );
  }
}
