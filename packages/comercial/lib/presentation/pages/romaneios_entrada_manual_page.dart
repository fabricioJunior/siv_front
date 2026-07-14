import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:flutter/material.dart';

class RomaneiosEntradaManualPage extends StatefulWidget {
  const RomaneiosEntradaManualPage({super.key});

  @override
  State<RomaneiosEntradaManualPage> createState() =>
      _RomaneiosEntradaManualPageState();
}

class _RomaneiosEntradaManualPageState
    extends State<RomaneiosEntradaManualPage> {
  late final RomaneiosEntradaManualBloc _bloc;
  final Debouncer _buscaDebouncer = Debouncer(milliseconds: 350);
  final TextEditingController _buscaController = TextEditingController();
  final FocusNode _buscaFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _bloc = sl<RomaneiosEntradaManualBloc>()
      ..add(RomaneiosEntradaManualIniciou());
  }

  @override
  void dispose() {
    _buscaDebouncer.cancel();
    _buscaController.dispose();
    _buscaFocusNode.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onBuscaAlteradaComDebounce(String _) {
    setState(() {});
    _buscaDebouncer.run(() {
      if (!mounted) return;
      _bloc.add(RomaneiosEntradaManualIniciou(searchTerm: _buscaController.text));
    });
  }

  void _limparBusca() {
    _buscaDebouncer.cancel();
    _buscaController.clear();
    setState(() {});
    _bloc.add(RomaneiosEntradaManualIniciou(searchTerm: ''));
  }

  Future<void> _selecionarDataHoraInicial() async {
    final selecionada = await _selecionarDataHora(_bloc.state.dataHoraInicial);
    if (selecionada == null) return;
    _bloc.add(
      RomaneiosEntradaManualIniciou(
        dataHoraInicial: selecionada,
        dataHoraInicialInformada: true,
      ),
    );
  }

  Future<void> _selecionarDataHoraFinal() async {
    final selecionada = await _selecionarDataHora(_bloc.state.dataHoraFinal);
    if (selecionada == null) return;
    _bloc.add(
      RomaneiosEntradaManualIniciou(
        dataHoraFinal: selecionada,
        dataHoraFinalInformada: true,
      ),
    );
  }

  Future<DateTime?> _selecionarDataHora(DateTime? inicial) async {
    final agora = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: inicial ?? agora,
      firstDate: DateTime(agora.year - 5),
      lastDate: DateTime(agora.year + 1),
    );
    if (data == null || !mounted) return null;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(inicial ?? agora),
    );
    if (hora == null) return null;

    return DateTime(data.year, data.month, data.day, hora.hour, hora.minute);
  }

  void _limparDataHoraInicial() {
    _bloc.add(RomaneiosEntradaManualIniciou(dataHoraInicialInformada: true));
  }

  void _limparDataHoraFinal() {
    _bloc.add(RomaneiosEntradaManualIniciou(dataHoraFinalInformada: true));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RomaneiosEntradaManualBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Movimentações Manuais')),
        body: RefreshIndicator(
          onRefresh: () async {
            _bloc.add(
              RomaneiosEntradaManualIniciou(searchTerm: _bloc.state.searchTerm),
            );
          },
          child: BlocBuilder<RomaneiosEntradaManualBloc,
              RomaneiosEntradaManualState>(
            builder: (context, state) {
              final buscaAtiva = state.searchTerm.trim().isNotEmpty;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _EntradaManualHeader(total: state.romaneios.length),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _buscaController,
                    focusNode: _buscaFocusNode,
                    textInputAction: TextInputAction.search,
                    onChanged: _onBuscaAlteradaComDebounce,
                    decoration: InputDecoration(
                      hintText: 'Buscar por funcionário ou ID',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _buscaController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: _limparBusca,
                              icon: const Icon(Icons.close),
                              tooltip: 'Limpar busca',
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FiltroDataChip(
                        icon: Icons.event,
                        label: state.dataHoraInicial == null
                            ? 'Data/hora inicial'
                            : _formatarDataHora(state.dataHoraInicial!),
                        onTap: _selecionarDataHoraInicial,
                        onLimpar: state.dataHoraInicial == null
                            ? null
                            : _limparDataHoraInicial,
                      ),
                      _FiltroDataChip(
                        icon: Icons.event_available,
                        label: state.dataHoraFinal == null
                            ? 'Data/hora final'
                            : _formatarDataHora(state.dataHoraFinal!),
                        onTap: _selecionarDataHoraFinal,
                        onLimpar: state.dataHoraFinal == null
                            ? null
                            : _limparDataHoraFinal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (state.step == RomaneiosEntradaManualStep.carregando)
                    const _EstadoListaCard(
                      icon: Icons.hourglass_top_rounded,
                      titulo: 'Carregando romaneios',
                      descricao: 'Aguarde enquanto os dados são atualizados.',
                      child: CircularProgressIndicator.adaptive(),
                    )
                  else if (state.step == RomaneiosEntradaManualStep.falha)
                    _EstadoListaCard(
                      icon: Icons.error_outline,
                      titulo: 'Falha ao carregar',
                      descricao:
                          state.erro ?? 'Não foi possível carregar os romaneios.',
                    )
                  else if (state.romaneios.isEmpty)
                    _EstadoListaCard(
                      icon: Icons.input,
                      titulo: buscaAtiva
                          ? 'Nenhum resultado para a busca'
                          : 'Nenhuma movimentação manual encontrada',
                      descricao: 'Ajuste os filtros para encontrar romaneios.',
                    )
                  else ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'Lista de movimentações manuais',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    ...state.romaneios.map(
                      (romaneio) => _RomaneioEntradaManualCard(
                        romaneio: romaneio,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/romaneio',
                            arguments: {
                              'idRomaneio': romaneio.id,
                              'permitirEdicao': false,
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

String _formatarDataHora(DateTime data) {
  final local = data.toLocal();
  String dois(int v) => v.toString().padLeft(2, '0');
  return '${dois(local.day)}/${dois(local.month)}/${local.year} ${dois(local.hour)}:${dois(local.minute)}';
}

class _EntradaManualHeader extends StatelessWidget {
  final int total;

  const _EntradaManualHeader({required this.total});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    colorScheme.onPrimaryContainer.withValues(alpha: 0.10),
                child: Icon(
                  Icons.input,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Consulta de movimentações manuais',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Filtre por período e funcionário para consultar entradas e saídas manuais realizadas.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer
                                .withValues(alpha: 0.90),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.receipt_long_outlined, size: 16),
                label: Text('$total romaneio(s)'),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FiltroDataChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLimpar;

  const _FiltroDataChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.onLimpar,
  });

  @override
  Widget build(BuildContext context) {
    return InputChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onTap,
      onDeleted: onLimpar,
      deleteIcon: onLimpar == null ? null : const Icon(Icons.close, size: 16),
    );
  }
}

class _EstadoListaCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String descricao;
  final Widget? child;

  const _EstadoListaCard({
    required this.icon,
    required this.titulo,
    required this.descricao,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (child != null) ...[
              child!,
              const SizedBox(height: 16),
            ] else ...[
              Icon(icon, size: 42),
              const SizedBox(height: 12),
            ],
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              descricao,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _RomaneioEntradaManualCard extends StatelessWidget {
  final Romaneio romaneio;
  final VoidCallback onTap;

  const _RomaneioEntradaManualCard({required this.romaneio, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final data = romaneio.criadoEm ?? romaneio.data;
    final ehSaida = romaneio.operacao == TipoOperacao.manual_saida;
    final corTipo = ehSaida ? Colors.deepOrange : colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 5,
                height: 56,
                decoration: BoxDecoration(
                  color: corTipo,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Romaneio #${romaneio.id ?? '-'}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Chip(
                          label: Text(ehSaida ? 'Saída' : 'Entrada'),
                          labelStyle: TextStyle(color: corTipo, fontSize: 12),
                          backgroundColor: corTipo.withValues(alpha: 0.10),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          side: BorderSide.none,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      romaneio.funcionarioNome ?? 'Funcionário não informado',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(romaneio.quantidade ?? 0).toStringAsFixed(0)} produto(s)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data == null ? '-' : _formatarDataHora(data),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
