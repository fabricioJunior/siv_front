import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';

class EtiquetasPromocaoPage extends StatelessWidget {
  final SeletorWidget tabelasDePrecoSeletor;

  const EtiquetasPromocaoPage({super.key, required this.tabelasDePrecoSeletor});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EtiquetasPromocaoBloc>(
      create: (_) => sl<EtiquetasPromocaoBloc>()..add(EtiquetasPromocaoIniciou()),
      child: _View(tabelasDePrecoSeletor: tabelasDePrecoSeletor),
    );
  }
}

String _moeda(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

String _data(DateTime? d) => d == null
    ? '?'
    : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

class _View extends StatelessWidget {
  final SeletorWidget tabelasDePrecoSeletor;

  const _View({required this.tabelasDePrecoSeletor});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EtiquetasPromocaoBloc, EtiquetasPromocaoState>(
      listenWhen: (a, b) => a.erro != b.erro || a.pilha != b.pilha,
      listener: (context, state) async {
        final bloc = context.read<EtiquetasPromocaoBloc>();
        final messenger = ScaffoldMessenger.of(context);
        if (state.erro != null) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(state.erro!),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.redAccent.shade700,
            ),
          );
        }
        if (state.pilha.isNotEmpty) {
          final vias = state.etiqueta?.vias.length ?? 1;
          final pilha = state.pilha;
          bloc.add(EtiquetasPromocaoPilhaConsumida());
          final impresso = await Navigator.of(context).pushNamed(
            '/impressao_progress',
            arguments: {'itens': pilha, 'quantidadeDeVias': vias},
          );
          if (impresso == true) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Etiquetas enviadas para impressao.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        final bloc = context.read<EtiquetasPromocaoBloc>();
        return Scaffold(
          appBar: AppBar(title: const Text('Etiqueta de promocao')),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _filtros(context, state, bloc),
                    const SizedBox(height: 12),
                    _corpo(context, state, bloc),
                  ],
                ),
              ),
              _rodape(state, bloc),
            ],
          ),
        );
      },
    );
  }

  Widget _filtros(
    BuildContext context,
    EtiquetasPromocaoState state,
    EtiquetasPromocaoBloc bloc,
  ) {
    final promocao = DropdownButtonFormField<PromocaoParaEtiqueta>(
      key: ValueKey('promocao_${state.apenasVigentes}_${state.promocoes.length}'),
      initialValue: state.promocao,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Promocao',
        border: const OutlineInputBorder(),
        suffixIcon: state.carregandoPromocoes
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
      ),
      items: [
        for (final p in state.promocoes)
          DropdownMenuItem(
            value: p,
            child: Text(
              '${p.nome}  (${_data(p.dataInicio)} a ${_data(p.dataFim)})',
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (p) => bloc.add(EtiquetasPromocaoSelecionada(p)),
    );
    final todas = SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Mostrar todas as promocoes'),
      subtitle: const Text('Padrao: somente vigentes'),
      value: !state.apenasVigentes,
      onChanged: (v) => bloc.add(EtiquetasPromocaoVigenteAlterado(!v)),
    );
    final modelo = EtiquetaSeletor(
      modo: EtiquetaSeletorModo.unica,
      titulo: 'Modelo de etiqueta',
      onEtiquetaChanged: (sel) => bloc.add(
        EtiquetasPromocaoModeloSelecionado(sel.isEmpty ? null : sel.first),
      ),
    );
    final tabela = tabelasDePrecoSeletor(
      SeletorData(
        onChanged: (sel) => bloc.add(
          EtiquetasPromocaoTabelaSelecionada(sel.isEmpty ? null : sel.first),
        ),
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, c) {
            final largo = c.maxWidth >= 720;
            final spacing = largo ? const SizedBox(width: 12) : null;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                promocao,
                todas,
                if (largo)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: modelo),
                      spacing!,
                      Expanded(child: tabela),
                    ],
                  )
                else ...[
                  modelo,
                  const SizedBox(height: 12),
                  tabela,
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _corpo(
    BuildContext context,
    EtiquetasPromocaoState state,
    EtiquetasPromocaoBloc bloc,
  ) {
    if (state.carregandoItens) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }
    if (state.promocao == null || state.tabela == null) {
      return const _Aviso(
        icone: Icons.local_offer_outlined,
        texto:
            'Selecione a promocao e a tabela de preco para ver os produtos que serao etiquetados.',
      );
    }
    if (state.itens.isEmpty) {
      return const _Aviso(
        icone: Icons.inventory_2_outlined,
        texto: 'Nenhum produto com estoque nesta promocao.',
      );
    }
    return Card(
      child: Column(
        children: [
          CheckboxListTile(
            key: const Key('etiquetas_promocao_todos'),
            value: state.todosSelecionados,
            onChanged: (v) =>
                bloc.add(EtiquetasPromocaoTodosAlternado(v ?? false)),
            title: Text('Selecionar todos (${state.itens.length} produtos)'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const Divider(height: 1),
          for (final item in state.itens)
            _LinhaItem(
              item: item,
              selecionado: state.selecionados.contains(item.produtoId),
              aoAlternar: () =>
                  bloc.add(EtiquetasPromocaoItemAlternado(item.produtoId)),
            ),
        ],
      ),
    );
  }

  Widget _rodape(EtiquetasPromocaoState state, EtiquetasPromocaoBloc bloc) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            key: const Key('etiquetas_promocao_imprimir'),
            onPressed: state.podeImprimir
                ? () => bloc.add(EtiquetasPromocaoImprimirSolicitado())
                : null,
            icon: state.imprimindo
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.print),
            label: Text('Imprimir ${state.totalEtiquetas} etiquetas'),
          ),
        ),
      ),
    );
  }
}

class _Aviso extends StatelessWidget {
  final IconData icone;
  final String texto;

  const _Aviso({required this.icone, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(icone, size: 40, color: Theme.of(context).disabledColor),
          const SizedBox(height: 8),
          Text(texto, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _LinhaItem extends StatelessWidget {
  final ItemEtiquetaPromocao item;
  final bool selecionado;
  final VoidCallback aoAlternar;

  const _LinhaItem({
    required this.item,
    required this.selecionado,
    required this.aoAlternar,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final promo = item.precoPromocional != null;
    return CheckboxListTile(
      key: Key('etiquetas_promocao_item_${item.produtoId}'),
      value: selecionado,
      onChanged: item.imprimivel ? (_) => aoAlternar() : null,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(item.referenciaNome),
      subtitle: Text(
        '${item.corNome ?? 'Sem cor'} · ${item.tamanhoNome ?? 'Sem tamanho'}'
        ' · ${item.saldo} etiqueta(s)',
      ),
      secondary: item.precoFinal <= 0
          ? Text(
              'sem preco na tabela',
              style: TextStyle(color: tema.colorScheme.error),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (promo && item.precoTabela > 0)
                  Text(
                    _moeda(item.precoTabela),
                    style: tema.textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                Text(
                  _moeda(item.precoFinal),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
    );
  }
}
