import 'package:core/bloc.dart';
import 'package:core/tema.dart';
import 'package:core/presentation.dart';
import 'package:core/precos_portas.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';

/// Widgets da Parte 2 (mobile) de `ReferenciaPage` -- reaproveitam os
/// mesmos blocs do desktop (`ProdutosDaReferenciaBloc`,
/// `PrecosDaReferenciaBloc`), só muda a apresentação (cards + bottom
/// sheets em vez de tabela/linha inline).
class _BlueprintCard extends StatelessWidget {
  final Widget child;

  const _BlueprintCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cores.superficie,
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
            border: Border.all(color: cores.hairline),
          ),
          child: child,
        ),
        ...sivCantosBlueprint(cores.hairline),
      ],
    );
  }
}

class ReferenciaResumoMobileCard extends StatelessWidget {
  final Referencia? referencia;
  final VoidCallback onEditar;

  const ReferenciaResumoMobileCard({
    super.key,
    required this.referencia,
    required this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final categoria = referencia?.categoria?.nome;
    final subCategoria = referencia?.subCategoria?.nome;
    final linhaCategoria = [
      if (categoria != null) categoria,
      if (subCategoria != null) subCategoria,
    ].join(' › ');

    return _BlueprintCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ponytail: thumbnail sempre placeholder -- puxar a mídia
          // principal exigiria instanciar ReferenciaMidiasBloc aqui também;
          // adicionar se o resumo precisar mostrar a imagem real.
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: cores.superficieRecuada,
              borderRadius: BorderRadius.circular(SivDimensoes.raio),
              border: Border.all(color: cores.hairline),
            ),
            child: Icon(Icons.image_outlined, color: cores.textoApoio),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  linhaCategoria.isEmpty ? '-' : linhaCategoria,
                  style: textos.corpo.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'NCM ${referencia?.ncm ?? '-'} · ${referencia?.pesoGramas ?? '-'} g',
                  style: textos.apoio.copyWith(color: cores.textoApoio),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onEditar,
                  child: Text(
                    'Editar',
                    style: textos.apoio.copyWith(color: cores.acoProfundo),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReferenciaProdutosMobileTab extends StatelessWidget {
  final int referenciaId;

  const ReferenciaProdutosMobileTab({super.key, required this.referenciaId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProdutosDaReferenciaBloc, ProdutosDaReferenciaState>(
      builder: (context, state) {
        if (state.step == ProdutosDaReferenciaStep.carregando ||
            state.step == ProdutosDaReferenciaStep.inicial) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (state.step == ProdutosDaReferenciaStep.falha) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Falha ao carregar produtos da referência.'),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => context.read<ProdutosDaReferenciaBloc>().add(
                    ProdutosDaReferenciaIniciou(referenciaId: referenciaId),
                  ),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        final cores = context.sivColors;
        final textos = context.sivTextos;
        final criando = state.step == ProdutosDaReferenciaStep.criandoProdutos;
        final totalFaltantes = state.todosOsFaltantes.length;
        final linhasPorCor = <int?, List<({ItemPresente cor, EstampaPresente estampa, List<ItemPresente> faltantes})>>{};
        for (final linha in state.linhas) {
          linhasPorCor.putIfAbsent(linha.cor.id, () => []).add(linha);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Buscar por cor, estampa ou tamanho',
                prefixIcon: Icon(Icons.search, size: 18),
              ),
              onChanged: (texto) => context.read<ProdutosDaReferenciaBloc>().add(
                ProdutosDaReferenciaBuscouAlterou(busca: texto),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ChoiceChip(
                  label: const Text(rotuloFiltroTodos),
                  selected: state.filtro == FiltroProdutosDaReferencia.todos,
                  onSelected: (_) => context.read<ProdutosDaReferenciaBloc>().add(
                    ProdutosDaReferenciaFiltroAlterou(
                      filtro: FiltroProdutosDaReferencia.todos,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text(rotuloFiltroFaltando),
                  selected: state.filtro == FiltroProdutosDaReferencia.faltando,
                  onSelected: (_) => context.read<ProdutosDaReferenciaBloc>().add(
                    ProdutosDaReferenciaFiltroAlterou(
                      filtro: FiltroProdutosDaReferencia.faltando,
                    ),
                  ),
                ),
                const Spacer(),
                if (totalFaltantes > 0)
                  TextButton(
                    onPressed: criando
                        ? null
                        : () => context.read<ProdutosDaReferenciaBloc>().add(
                            ProdutosDaReferenciaCriouCombinacoes(
                              combinacoes: state.todosOsFaltantes,
                            ),
                          ),
                    child: Text('Criar todos ($totalFaltantes)'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (state.estampas.isNotEmpty) ...[
              _BlueprintCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ESTAMPAS',
                      style: textos.rotulo.copyWith(color: cores.textoApoio),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: state.estampas
                          .map((e) => Chip(label: Text(e.nome)))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (criando)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(),
              ),
            Expanded(
              child: linhasPorCor.isEmpty
                  ? const Center(child: Text('Nenhuma combinação encontrada.'))
                  : ListView.separated(
                      itemCount: linhasPorCor.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final entrada = linhasPorCor.entries.elementAt(index);
                        return _buildGrupoCor(
                          context,
                          state,
                          entrada.value,
                          criando,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGrupoCor(
    BuildContext context,
    ProdutosDaReferenciaState state,
    List<({ItemPresente cor, EstampaPresente estampa, List<ItemPresente> faltantes})> linhas,
    bool criando,
  ) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final corNome = linhas.first.cor.nome;

    return _BlueprintCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            corNome,
            style: textos.secao.copyWith(fontSize: 17, color: cores.acoEscuro),
          ),
          const SizedBox(height: 8),
          ...linhas.map((linha) => _buildLinhaEstampa(context, state, linha, criando)),
        ],
      ),
    );
  }

  Widget _buildLinhaEstampa(
    BuildContext context,
    ProdutosDaReferenciaState state,
    ({ItemPresente cor, EstampaPresente estampa, List<ItemPresente> faltantes}) linha,
    bool criando,
  ) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  linha.estampa.nome,
                  style: textos.apoio.copyWith(color: cores.textoApoio),
                ),
              ),
              if (linha.faltantes.isNotEmpty)
                TextButton(
                  onPressed: criando
                      ? null
                      : () => context.read<ProdutosDaReferenciaBloc>().add(
                          ProdutosDaReferenciaCriouCombinacoes(
                            combinacoes: linha.faltantes
                                .map(
                                  (t) => ComboDeGrade(
                                    corId: linha.cor.id,
                                    tamanhoId: t.id,
                                    estampaId: linha.estampa.id,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                  child: Text('Criar ${linha.faltantes.length}'),
                ),
            ],
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: state.tamanhos.map((tamanho) {
              final chave = chaveComboGrade(
                linha.cor.id,
                tamanho.id,
                linha.estampa.id,
              );
              final existe = state.mapaProduto.containsKey(chave);
              return existe
                  ? Chip(
                      label: Text(tamanho.nome),
                      backgroundColor: cores.selecaoFundo,
                    )
                  : ActionChip(
                      label: Text(tamanho.nome),
                      onPressed: criando
                          ? null
                          : () => context.read<ProdutosDaReferenciaBloc>().add(
                              ProdutosDaReferenciaCriouCombinacoes(
                                combinacoes: [
                                  ComboDeGrade(
                                    corId: linha.cor.id,
                                    tamanhoId: tamanho.id,
                                    estampaId: linha.estampa.id,
                                  ),
                                ],
                              ),
                            ),
                    );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class ReferenciaPrecosMobileTab extends StatelessWidget {
  final int referenciaId;

  const ReferenciaPrecosMobileTab({super.key, required this.referenciaId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrecosDaReferenciaBloc, PrecosDaReferenciaState>(
      builder: (context, state) {
        if (state.step == PrecosDaReferenciaStep.carregando ||
            state.step == PrecosDaReferenciaStep.inicial) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (state.step == PrecosDaReferenciaStep.falha) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Falha ao carregar tabelas de preço.'),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => context.read<PrecosDaReferenciaBloc>().add(
                    PrecosDaReferenciaIniciou(referenciaId: referenciaId),
                  ),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        final cores = context.sivColors;
        final textos = context.sivTextos;

        return ListView.separated(
          itemCount: state.tabelas.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final tabela = state.tabelas[index];
            return _BlueprintCard(
              child: InkWell(
                onTap: tabela.tabelaInativa
                    ? null
                    : () => _abrirEdicaoMobile(context, tabela),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  tabela.tabelaNome,
                                  style: textos.secao.copyWith(
                                    fontSize: 17,
                                    color: cores.acoEscuro,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (tabela.tabelaPadrao) ...[
                                const SizedBox(width: 6),
                                const Chip(
                                  label: Text('Padrão'),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                              if (tabela.tabelaInativa) ...[
                                const SizedBox(width: 6),
                                const Chip(
                                  label: Text('Inativa'),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Term. ${_formatarTerminador(tabela.terminador)}'
                            '${tabela.atualizadoEm == null ? '' : ' · atualizado ${_formatarData(tabela.atualizadoEm!)}'}',
                            style: textos.apoio.copyWith(color: cores.textoApoio),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      tabela.temPreco
                          ? 'R\$ ${tabela.valor!.toStringAsFixed(2).replaceAll('.', ',')}'
                          : 'Sem preço',
                      style: textos.valor.copyWith(
                        fontSize: 18,
                        color: tabela.temPreco ? cores.acoEscuro : cores.textoDesabilitado,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatarTerminador(double? terminador) {
    if (terminador == null) return '-';
    final centavos = (terminador % 1) * 100;
    return ',${centavos.round().toString().padLeft(2, '0')}';
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  Future<void> _abrirEdicaoMobile(
    BuildContext context,
    PrecoDaReferenciaPorTabela tabela,
  ) async {
    final bloc = context.read<PrecosDaReferenciaBloc>();
    bloc.add(PrecosDaReferenciaEditouLinha(tabelaDePrecoId: tabela.tabelaDePrecoId));
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: _PrecoMobileEditorSheet(tabelaNome: tabela.tabelaNome),
      ),
    );
  }
}

class _PrecoMobileEditorSheet extends StatefulWidget {
  final String tabelaNome;

  const _PrecoMobileEditorSheet({required this.tabelaNome});

  @override
  State<_PrecoMobileEditorSheet> createState() => _PrecoMobileEditorSheetState();
}

class _PrecoMobileEditorSheetState extends State<_PrecoMobileEditorSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: context.read<PrecosDaReferenciaBloc>().state.valorDigitado,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return BlocConsumer<PrecosDaReferenciaBloc, PrecosDaReferenciaState>(
      listener: (context, state) {
        if (state.tabelaEmEdicaoId == null && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final salvando = state.step == PrecosDaReferenciaStep.salvando;
        final previa = state.previaValorComTerminador;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.tabelaNome, style: textos.secao.copyWith(fontSize: 18)),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                autofocus: true,
                enabled: !salvando,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                style: textos.valor.copyWith(fontSize: 32),
                decoration: InputDecoration(
                  prefixText: 'R\$ ',
                  errorText: state.erroValidacao,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SivDimensoes.raio),
                    borderSide: BorderSide(color: cores.aco, width: 2),
                  ),
                ),
                onChanged: (texto) => context.read<PrecosDaReferenciaBloc>().add(
                  PrecosDaReferenciaValorAlterou(texto: texto),
                ),
                onSubmitted: (_) => context.read<PrecosDaReferenciaBloc>().add(
                  PrecosDaReferenciaSalvou(),
                ),
              ),
              if (previa != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Será salvo como R\$ ${previa.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: textos.apoio.copyWith(color: cores.textoApoio),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: salvando
                    ? null
                    : () => context.read<PrecosDaReferenciaBloc>().add(
                        PrecosDaReferenciaSalvou(),
                      ),
                child: Text(salvando ? 'Salvando...' : 'SALVAR PREÇO'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: salvando
                    ? null
                    : () => context.read<PrecosDaReferenciaBloc>().add(
                        PrecosDaReferenciaCancelouEdicao(),
                      ),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        );
      },
    );
  }
}
