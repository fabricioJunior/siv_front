import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/seletores.dart';
import 'package:core/sessao.dart';
import 'package:financeiro/domain/use_cases/recuperar_caixa_aberto.dart';
import 'package:financeiro/presentation/widgets/seletor_caixa.dart';
import 'package:flutter/material.dart';

class VendasPage extends StatefulWidget {
  const VendasPage({super.key});

  @override
  State<VendasPage> createState() => _VendasPageState();
}

class _VendasPageState extends State<VendasPage> {
  late final VendasBloc _vendasBloc;
  final Debouncer _buscaDebouncer = Debouncer(milliseconds: 350);
  final TextEditingController _buscaController = TextEditingController();
  final FocusNode _buscaFocusNode = FocusNode();
  List<SelectData>? _caixaSelecionadoInicial;

  @override
  void initState() {
    super.initState();
    _vendasBloc = sl<VendasBloc>()..add(VendasIniciou());
    _carregarCaixaAberto();
  }

  Future<void> _carregarCaixaAberto() async {
    final sessao = sl<IAcessoGlobalSessao>();
    final empresaId = sessao.empresaIdDaSessao;
    final terminalId = sessao.terminalIdDaSessao;
    if (empresaId == null || terminalId == null) return;

    try {
      final caixaAberto = await sl<RecuperarCaixaAberto>().call(
        idEmpresa: empresaId,
        idTerminal: terminalId,
      );
      if (caixaAberto == null || !mounted) return;

      final selecionado = [
        SelectData(
          id: caixaAberto.id,
          nome: 'Caixa #${caixaAberto.id}',
          data: const {},
        ),
      ];
      setState(() => _caixaSelecionadoInicial = selecionado);
      _vendasBloc.add(
        VendasIniciou(caixaId: caixaAberto.id, caixaIdInformado: true),
      );
    } catch (_) {
      // Sem caixa aberto no momento -- mantém filtro sem caixa selecionado.
    }
  }

  @override
  void dispose() {
    _buscaDebouncer.cancel();
    _buscaController.dispose();
    _buscaFocusNode.dispose();
    _vendasBloc.close();
    super.dispose();
  }

  void _onBuscaAlteradaComDebounce(String _) {
    setState(() {});
    _buscaDebouncer.run(() {
      if (!mounted) return;
      _vendasBloc.add(VendasIniciou(searchTerm: _buscaController.text));
    });
  }

  void _limparBusca() {
    _buscaDebouncer.cancel();
    _buscaController.clear();
    setState(() {});
    _vendasBloc.add(VendasIniciou(searchTerm: ''));
  }

  Future<void> _selecionarDataHoraInicial() async {
    final selecionada = await _selecionarDataHora(
      _vendasBloc.state.dataHoraInicial,
    );
    if (selecionada == null) return;
    _vendasBloc.add(
      VendasIniciou(
        dataHoraInicial: selecionada,
        dataHoraInicialInformada: true,
      ),
    );
  }

  Future<void> _selecionarDataHoraFinal() async {
    final selecionada = await _selecionarDataHora(
      _vendasBloc.state.dataHoraFinal,
    );
    if (selecionada == null) return;
    _vendasBloc.add(
      VendasIniciou(
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
    _vendasBloc.add(VendasIniciou(dataHoraInicialInformada: true));
  }

  void _limparDataHoraFinal() {
    _vendasBloc.add(VendasIniciou(dataHoraFinalInformada: true));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VendasBloc>.value(
      value: _vendasBloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Vendas')),
        body: RefreshIndicator(
          onRefresh: () async {
            _vendasBloc.add(VendasIniciou(searchTerm: _vendasBloc.state.searchTerm));
          },
          child: BlocBuilder<VendasBloc, VendasState>(
            builder: (context, state) {
              final buscaAtiva = state.searchTerm.trim().isNotEmpty;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _VendasHeader(
                    totalVendas: state.vendas.length,
                    valorTotal: state.valorTotal,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _buscaController,
                    focusNode: _buscaFocusNode,
                    textInputAction: TextInputAction.search,
                    onChanged: _onBuscaAlteradaComDebounce,
                    decoration: InputDecoration(
                      hintText: 'Buscar por cliente, funcionário ou ID',
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
                  SeletorCaixa(
                    titulo: 'Caixa',
                    itemsSelecionadosInicial: _caixaSelecionadoInicial,
                    onChanged: (selecionados) {
                      final caixaId = selecionados.firstOrNull?.id;
                      _vendasBloc.add(
                        VendasIniciou(
                          caixaId: caixaId,
                          caixaIdInformado: true,
                        ),
                      );
                    },
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
                  if (state.step == VendasStep.carregando)
                    const _EstadoListaCard(
                      icon: Icons.hourglass_top_rounded,
                      titulo: 'Carregando vendas',
                      descricao: 'Aguarde enquanto os dados são atualizados.',
                      child: CircularProgressIndicator.adaptive(),
                    )
                  else if (state.step == VendasStep.falha)
                    _EstadoListaCard(
                      icon: Icons.error_outline,
                      titulo: 'Falha ao carregar',
                      descricao: state.erro ?? 'Não foi possível carregar as vendas.',
                    )
                  else if (state.vendas.isEmpty)
                    _EstadoListaCard(
                      icon: Icons.point_of_sale_outlined,
                      titulo: buscaAtiva
                          ? 'Nenhum resultado para a busca'
                          : 'Nenhuma venda encontrada',
                      descricao: 'Ajuste os filtros para encontrar vendas.',
                    )
                  else ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'Lista de vendas',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    ...state.vendas.map(
                      (venda) => _VendaCard(
                        venda: venda,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/romaneio',
                            arguments: {
                              'idRomaneio': venda.id,
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

String _formatarValor(double? valor) {
  final numero = (valor ?? 0).toStringAsFixed(2).replaceAll('.', ',');
  return 'R\$ $numero';
}

class _VendasHeader extends StatelessWidget {
  final int totalVendas;
  final double valorTotal;

  const _VendasHeader({required this.totalVendas, required this.valorTotal});

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
                  Icons.point_of_sale_outlined,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Consulta de vendas',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Filtre por caixa, período e cliente para consultar vendas realizadas.',
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
                label: Text('$totalVendas venda(s)'),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Chip(
                avatar: const Icon(Icons.attach_money, size: 16),
                label: Text('Total: ${_formatarValor(valorTotal)}'),
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

class _VendaCard extends StatelessWidget {
  final Romaneio venda;
  final VoidCallback onTap;

  const _VendaCard({required this.venda, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dataVenda = venda.criadoEm ?? venda.data;

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
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatarValor(venda.valorLiquido),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      venda.pessoaNome ?? 'Cliente não informado',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dataVenda == null ? '-' : _formatarDataHora(dataVenda),
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
