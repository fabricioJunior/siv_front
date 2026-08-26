import 'package:comercial/presentation/blocs/ecommerce_referencias_bloc/ecommerce_referencias_bloc.dart';
import 'package:comercial/presentation/pages/ecommerce_referencia_detalhe_page.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:produtos/presentantion/widgets/referencia_seletor.dart';

class EcommerceReferenciasPage extends StatefulWidget {
  final int ecommerceId;

  const EcommerceReferenciasPage({super.key, required this.ecommerceId});

  @override
  State<EcommerceReferenciasPage> createState() =>
      _EcommerceReferenciasPageState();
}

class _EcommerceReferenciasPageState extends State<EcommerceReferenciasPage> {
  late final EcommerceReferenciasBloc _bloc;
  final _buscaController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 350);

  @override
  void initState() {
    super.initState();
    _bloc = sl<EcommerceReferenciasBloc>()
      ..add(EcommerceReferenciasIniciou(ecommerceId: widget.ecommerceId));
  }

  @override
  void dispose() {
    _buscaController.dispose();
    _debouncer.cancel();
    _bloc.close();
    super.dispose();
  }

  void _onBuscaAlterada(String valor) {
    _debouncer.run(() {
      _bloc.add(
        EcommerceReferenciasIniciou(
          ecommerceId: widget.ecommerceId,
          busca: valor.trim().isEmpty ? null : valor.trim(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EcommerceReferenciasBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Produtos no site'),
          actions: [
            IconButton(
              icon: const Icon(Icons.visibility_off_outlined),
              tooltip: 'Despublicar todas',
              onPressed: () => _despublicarTodas(context),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _buscaController,
                onChanged: _onBuscaAlterada,
                decoration: InputDecoration(
                  hintText: 'Buscar referência...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  isDense: true,
                  suffixIcon: _buscaController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _buscaController.clear();
                            _onBuscaAlterada('');
                            setState(() {});
                          },
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: _onBuscaAlterada,
              ),
            ),
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton.extended(
            onPressed: () => _adicionarReferencias(context),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar referências'),
          ),
        ),
        body: BlocBuilder<EcommerceReferenciasBloc, EcommerceReferenciasState>(
          builder: (context, state) {
            if (state is EcommerceReferenciasCarregarEmProgresso ||
                state is EcommerceReferenciasInitial) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            if (state is EcommerceReferenciasCarregarFalha) {
              return const Center(
                child: Text('Não foi possível carregar as referências.'),
              );
            }

            if (state.referencias.isEmpty) {
              return Center(
                child: Text(
                  (state.busca ?? '').isEmpty
                      ? 'Nenhuma referência vinculada ao e-commerce.'
                      : 'Nenhuma referência encontrada pra "${state.busca}".',
                ),
              );
            }

            return Column(
              children: [
                if (state.processandoLote) const LinearProgressIndicator(),
                Expanded(child: _buildLista(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLista(BuildContext context, EcommerceReferenciasState state) {
    return ListView.builder(
      itemCount: state.referencias.length,
      itemBuilder: (context, index) {
        final referencia = state.referencias[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 48,
              height: 48,
              child: referencia.imagemUrl != null
                  ? Image.network(
                      referencia.imagemUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderImagem(context),
                    )
                  : _placeholderImagem(context),
            ),
          ),
          title: Text(
            referencia.referenciaNome ??
                'Referência #${referencia.referenciaId}',
          ),
          subtitle: Text(
            '${referencia.valor != null ? _formatarMoeda(referencia.valor!) : 'Sem preço'} • Estoque: ${referencia.saldo ?? 0}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  referencia.rascunho
                      ? Icons.publish_outlined
                      : Icons.visibility_off_outlined,
                ),
                tooltip: referencia.rascunho ? 'Publicar' : 'Despublicar',
                color: referencia.rascunho ? Colors.green : Colors.orange,
                onPressed: state.processandoLote
                    ? null
                    : () => _bloc.add(
                          EcommerceReferenciaPublicarSolicitou(
                            ecommerceId: widget.ecommerceId,
                            referenciaEcommerceId: referencia.id!,
                            rascunho: !referencia.rascunho,
                          ),
                        ),
              ),
              Chip(
                label: Text(referencia.rascunho ? 'Rascunho' : 'Publicado'),
                backgroundColor: referencia.rascunho
                    ? Colors.orange.withValues(alpha: 0.2)
                    : Colors.green.withValues(alpha: 0.2),
              ),
            ],
          ),
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => EcommerceReferenciaDetalhePage(
                  ecommerceId: widget.ecommerceId,
                  referencia: referencia,
                ),
              ),
            );
            _bloc.add(
              EcommerceReferenciasIniciou(
                ecommerceId: widget.ecommerceId,
                busca: state.busca,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _adicionarReferencias(BuildContext context) async {
    List<int> idsSelecionados = [];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (dialogContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ReferenciaSeletor(
                modo: ReferenciaSeletorModo.multipla,
                permitirCadastro: false,
                onReferenciaChanged: (selecionadas) {
                  idsSelecionados = selecionadas
                      .map((referencia) => referencia.id)
                      .whereType<int>()
                      .toList();
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  for (final referenciaId in idsSelecionados) {
                    _bloc.add(
                      EcommerceReferenciaAdicionou(
                        ecommerceId: widget.ecommerceId,
                        referenciaId: referenciaId,
                      ),
                    );
                  }
                },
                child: const Text('Adicionar'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _despublicarTodas(BuildContext context) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Despublicar todas as referências'),
          content: const Text(
            'Todas as referências publicadas deste e-commerce vão sair do '
            'site imediatamente. Essa ação pode ser desfeita depois, '
            'republicando cada referência.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Despublicar todas'),
            ),
          ],
        );
      },
    );

    if (confirmou == true) {
      _bloc.add(
        EcommerceReferenciasDespublicarTodasSolicitou(
          ecommerceId: widget.ecommerceId,
        ),
      );
    }
  }

  Widget _placeholderImagem(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}
