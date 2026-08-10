import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/links.dart';
import 'package:entregas/data/remote/dtos/entrega_dto.dart';
import 'package:entregas/domain/models/entrega.dart';
import 'package:entregas/presentation/blocs/chamar_entregador_bloc/chamar_entregador_bloc.dart';
import 'package:entregas/presentation/widgets/endereco_entrega_form.dart';
import 'package:flutter/material.dart';

class ChamarEntregadorPage extends StatefulWidget {
  const ChamarEntregadorPage({super.key});

  @override
  State<ChamarEntregadorPage> createState() => _ChamarEntregadorPageState();
}

class _ChamarEntregadorPageState extends State<ChamarEntregadorPage> {
  late final ChamarEntregadorBloc _bloc;
  final _formKey = GlobalKey<FormState>();

  final _destinoControllers = EnderecoEntregaControllers();
  final _nomeClienteController = TextEditingController();
  final _telefoneClienteController = TextEditingController();
  final _observacaoController = TextEditingController();
  final _valorCobrarController = TextEditingController();
  bool _defaultsCidadeAplicados = false;

  @override
  void initState() {
    super.initState();
    _bloc = sl<ChamarEntregadorBloc>()..add(ChamarEntregadorIniciou());
  }

  @override
  void dispose() {
    _destinoControllers.dispose();
    _nomeClienteController.dispose();
    _telefoneClienteController.dispose();
    _observacaoController.dispose();
    _valorCobrarController.dispose();
    _bloc.close();
    super.dispose();
  }

  double _parseDouble(String texto) => double.tryParse(texto.trim().replaceAll(',', '.')) ?? 0.0;

  EnderecoEntregaDto _construirEndereco(EnderecoEntregaControllers c) {
    return EnderecoEntregaDto(
      endereco: c.endereco.text.trim(),
      bairro: c.bairro.text.trim(),
      complemento: c.complemento.text.trim().isEmpty ? null : c.complemento.text.trim(),
      cidade: c.cidade.text.trim(),
      estado: c.estado.text.trim(),
      referencia: c.referencia.text.trim().isEmpty ? null : c.referencia.text.trim(),
      lat: _parseDouble(c.lat.text),
      lng: _parseDouble(c.lng.text),
    );
  }

  void _calcular() {
    if (!_formKey.currentState!.validate()) return;
    final partida = _bloc.state.partida;
    if (partida == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Empresa sem coordenadas cadastradas — cadastre em Configurações > Empresa.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final destino = _construirEndereco(_destinoControllers);
    final parada = ParadaEntregaDto(
      endereco: destino,
      nomeCliente: _nomeClienteController.text.trim().isEmpty
          ? null
          : _nomeClienteController.text.trim(),
      telefoneCliente: _telefoneClienteController.text.trim().isEmpty
          ? null
          : _telefoneClienteController.text.trim(),
      observacao: _observacaoController.text.trim().isEmpty
          ? null
          : _observacaoController.text.trim(),
      valorCobrar: _valorCobrarController.text.trim().isEmpty
          ? null
          : _parseDouble(_valorCobrarController.text),
    );
    _bloc.add(ChamarEntregadorEstimou(
      partida: partida,
      destino: destino,
      parada: parada,
    ));
  }

  Future<void> _confirmarCancelamento(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar entrega'),
        content: const Text(
          'Essa ação é irreversível. Deseja realmente cancelar essa entrega?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancelar entrega'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      _bloc.add(ChamarEntregadorCancelou());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChamarEntregadorBloc>.value(
      value: _bloc,
      child: BlocConsumer<ChamarEntregadorBloc, ChamarEntregadorState>(
        listener: (context, state) {
          if (state.erro != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.erro!), backgroundColor: Colors.red),
            );
          }
          final empresa = state.empresa;
          if (empresa != null && !_defaultsCidadeAplicados) {
            _defaultsCidadeAplicados = true;
            _destinoControllers.cidade.text = empresa.municipio ?? '';
            _destinoControllers.estado.text = empresa.uf ?? '';
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chamar Entregador')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSaldoCard(state.saldo),
                  const SizedBox(height: 16),
                  if (state.step == ChamarEntregadorStep.chamado ||
                      state.step == ChamarEntregadorStep.cancelado ||
                      state.step == ChamarEntregadorStep.obtendoRastreio ||
                      state.step == ChamarEntregadorStep.cancelando)
                    _buildSolicitacaoAberta(context, state)
                  else
                    _buildFormulario(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSaldoCard(double? saldo) {
    return Card(
      color: Colors.indigo.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet_outlined, color: Colors.indigo),
            const SizedBox(width: 12),
            Text(
              saldo != null
                  ? 'Saldo: R\$ ${saldo.toStringAsFixed(2)}'
                  : 'Carregando saldo...',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartidaCard(BuildContext context, ChamarEntregadorState state) {
    final empresa = state.empresa;
    if (empresa == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Carregando endereço de retirada...'),
            ],
          ),
        ),
      );
    }
    if (state.partida == null) {
      return Card(
        color: Colors.orange.shade50,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: Colors.orange),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Empresa sem coordenadas cadastradas — cadastre em '
                  'Configurações > Empresa.',
                ),
              ),
            ],
          ),
        ),
      );
    }
    final endereco = [empresa.logradouro, empresa.numero]
        .where((v) => v != null && v.isNotEmpty)
        .join(', ');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.store_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Retirada em: $endereco, ${empresa.bairro ?? ''} - '
                '${empresa.municipio ?? ''}/${empresa.uf ?? ''}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulario(BuildContext context, ChamarEntregadorState state) {
    final isEstimando = state.step == ChamarEntregadorStep.estimando;
    final isChamando = state.step == ChamarEntregadorStep.chamando;
    final temEstimativa = state.step == ChamarEntregadorStep.estimado &&
        state.estimativa != null;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPartidaCard(context, state),
          const SizedBox(height: 16),
          EnderecoEntregaForm(
            titulo: 'Endereço de destino',
            controllers: _destinoControllers,
          ),
          const SizedBox(height: 16),
          Text('Destinatário', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nomeClienteController,
            decoration: const InputDecoration(
              labelText: 'Nome',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _telefoneClienteController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Telefone',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _observacaoController,
            decoration: const InputDecoration(
              labelText: 'Observação',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _valorCobrarController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Valor a cobrar do cliente na entrega (opcional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (temEstimativa)
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('Valor estimado'),
                        Text(
                          'R\$ ${state.estimativa!.valor.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Tempo estimado'),
                        Text(
                          '~${state.estimativa!.tempoEstimadoMinutos} min',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: isEstimando ? null : _calcular,
            icon: isEstimando
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.calculate_outlined),
            label: const Text('Calcular'),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: temEstimativa && !isChamando
                ? () => _bloc.add(ChamarEntregadorChamou())
                : null,
            icon: isChamando
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.motorcycle_outlined),
            label: const Text('Chamar entregador'),
          ),
        ],
      ),
    );
  }

  Widget _buildSolicitacaoAberta(
    BuildContext context,
    ChamarEntregadorState state,
  ) {
    final solicitacao = state.solicitacao!;
    final cancelada = solicitacao.status == 'C';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entrega #${solicitacao.id}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text('Status: ${descricaoStatusEntrega(solicitacao.status)}'),
                if (solicitacao.valorEstimado != null)
                  Text(
                    'Valor: R\$ ${solicitacao.valorEstimado!.toStringAsFixed(2)}',
                  ),
                if (solicitacao.motivoCancelamento != null)
                  Text('Motivo do cancelamento: ${solicitacao.motivoCancelamento}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (state.rastreio != null) ...[
          Text('Rastreio', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...state.rastreio!.map(
            (item) => Card(
              child: ListTile(
                title: Text(item.paradaId != null
                    ? 'Parada ${item.paradaId}'
                    : 'Link de rastreio'),
                subtitle: Text(item.link),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => sl<LinkService>().abrirLink(item.link),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          onPressed: state.step == ChamarEntregadorStep.obtendoRastreio
              ? null
              : () => _bloc.add(ChamarEntregadorObterRastreio()),
          icon: const Icon(Icons.share_location_outlined),
          label: const Text('Ver rastreio'),
        ),
        const SizedBox(height: 8),
        if (!cancelada)
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: state.step == ChamarEntregadorStep.cancelando
                ? null
                : () => _confirmarCancelamento(context),
            icon: state.step == ChamarEntregadorStep.cancelando
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.cancel_outlined),
            label: const Text('Cancelar entrega'),
          ),
      ],
    );
  }
}
