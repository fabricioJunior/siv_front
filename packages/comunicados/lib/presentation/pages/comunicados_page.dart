import 'package:comunicados/domain/models/models.dart';
import 'package:comunicados/presentation/blocs/comunicados_bloc/comunicados_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:flutter/material.dart';

class ComunicadosPage extends StatefulWidget {
  const ComunicadosPage({super.key});

  @override
  State<ComunicadosPage> createState() => _ComunicadosPageState();
}

class _ComunicadosPageState extends State<ComunicadosPage> {
  late final ComunicadosBloc _bloc;
  String? _statusFiltro;

  static const _statusOpcoes = [
    (null, 'Todos'),
    ('pendente', 'Pendente'),
    ('enviando', 'Enviando'),
    ('enviado', 'Enviado'),
    ('erro', 'Erro'),
  ];

  @override
  void initState() {
    super.initState();
    _bloc = sl<ComunicadosBloc>()..add(ComunicadosCarregar());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _carregar() {
    _bloc.add(ComunicadosCarregar(status: _statusFiltro));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ComunicadosBloc>.value(
      value: _bloc,
      child: BlocConsumer<ComunicadosBloc, ComunicadosState>(
        listener: (context, state) {
          if (state.step == ComunicadosStep.falha && state.erro != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.erro!), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Comunicados'),
            ),
            floatingActionButton: FloatingActionButton(
              tooltip: 'Novo comunicado',
              onPressed: () async {
                final criado = await Navigator.of(
                  context,
                ).pushNamed('/comunicados/compor');
                if (criado == true) _carregar();
              },
              child: const Icon(Icons.add),
            ),
            body: Column(
              children: [
                SizedBox(
                  height: 44,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    scrollDirection: Axis.horizontal,
                    children: _statusOpcoes.map((op) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(op.$2),
                          selected: _statusFiltro == op.$1,
                          onSelected: (_) {
                            setState(() => _statusFiltro = op.$1);
                            _carregar();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: state.step == ComunicadosStep.carregando
                      ? const Center(child: CircularProgressIndicator())
                      : state.items.isEmpty
                      ? const Center(child: Text('Nenhum comunicado encontrado.'))
                      : RefreshIndicator(
                          onRefresh: () async => _carregar(),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: state.items.length,
                            itemBuilder: (context, i) {
                              final comunicado = state.items[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _ComunicadoCard(
                                  comunicado: comunicado,
                                  onTap: () => Navigator.of(context)
                                      .pushNamed(
                                        '/comunicado',
                                        arguments: {'id': comunicado.id},
                                      )
                                      .then((_) => _carregar()),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ComunicadoCard extends StatelessWidget {
  const _ComunicadoCard({required this.comunicado, required this.onTap});

  final Comunicado comunicado;
  final VoidCallback onTap;

  Color get _corStatus => switch (comunicado.status) {
    'enviado' => Colors.green,
    'enviando' => Colors.blue,
    'erro' => Colors.red,
    'pendente' => Colors.amber.shade700,
    _ => Colors.blueGrey,
  };

  String get _labelStatus => switch (comunicado.status) {
    'enviado' => 'Enviado',
    'enviando' => 'Enviando',
    'erro' => 'Erro',
    'pendente' => 'Pendente',
    _ => comunicado.status,
  };

  @override
  Widget build(BuildContext context) {
    final cor = _corStatus;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: cor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              comunicado.assunto,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: cor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _labelStatus,
                              style: TextStyle(
                                fontSize: 11,
                                color: cor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.people_outline, size: 12, color: Colors.grey),
                          const SizedBox(width: 2),
                          Text(
                            '${comunicado.totalDestinatarios} destinatário(s)',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comunicado.enviadoEm != null
                            ? 'Enviado em ${formatarDataHora(comunicado.enviadoEm)}'
                            : 'Criado em ${formatarDataHora(comunicado.criadoEm)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.chevron_right, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
