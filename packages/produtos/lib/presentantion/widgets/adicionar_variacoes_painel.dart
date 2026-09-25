import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';
import 'package:produtos/domain/tamanho_grade_agrupamento.dart';

/// Painel "Adicionar variações" (Cores | Tamanhos | Estampas), com
/// travamento do que já está na grade. Abre como diálogo de 920px no
/// desktop (Parte 1); a Parte 2 (mobile) reaproveita o mesmo
/// [AdicionarVariacoesBloc] numa folha de baixo pra cima.
class AdicionarVariacoesPainel extends StatefulWidget {
  final int referenciaId;
  final Set<int> corIdsNaGrade;
  final Set<int> tamanhoIdsNaGrade;
  final Set<int> estampaIdsNaGrade;
  final Set<String> chavesNaGrade;

  const AdicionarVariacoesPainel({
    super.key,
    required this.referenciaId,
    required this.corIdsNaGrade,
    required this.tamanhoIdsNaGrade,
    required this.estampaIdsNaGrade,
    required this.chavesNaGrade,
  });

  static Future<bool?> show({
    required BuildContext context,
    required int referenciaId,
    required Set<int> corIdsNaGrade,
    required Set<int> tamanhoIdsNaGrade,
    required Set<int> estampaIdsNaGrade,
    required Set<String> chavesNaGrade,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(
          width: 920,
          height: 640,
          child: AdicionarVariacoesPainel(
            referenciaId: referenciaId,
            corIdsNaGrade: corIdsNaGrade,
            tamanhoIdsNaGrade: tamanhoIdsNaGrade,
            estampaIdsNaGrade: estampaIdsNaGrade,
            chavesNaGrade: chavesNaGrade,
          ),
        ),
      ),
    );
  }

  @override
  State<AdicionarVariacoesPainel> createState() =>
      _AdicionarVariacoesPainelState();
}

class _AdicionarVariacoesPainelState extends State<AdicionarVariacoesPainel> {
  late final AdicionarVariacoesBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<AdicionarVariacoesBloc>()
      ..add(
        AdicionarVariacoesIniciou(
          referenciaId: widget.referenciaId,
          corIdsNaGrade: widget.corIdsNaGrade,
          tamanhoIdsNaGrade: widget.tamanhoIdsNaGrade,
          estampaIdsNaGrade: widget.estampaIdsNaGrade,
          chavesNaGrade: widget.chavesNaGrade,
        ),
      );
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdicionarVariacoesBloc>.value(
      value: _bloc,
      child: BlocConsumer<AdicionarVariacoesBloc, AdicionarVariacoesState>(
        listener: (context, state) {
          if (state.step == AdicionarVariacoesStep.sucesso) {
            Navigator.of(context).pop(true);
          }
        },
        builder: (context, state) {
          final carregando =
              state.step == AdicionarVariacoesStep.carregando ||
              state.step == AdicionarVariacoesStep.inicial;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Adicionar variações',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: carregando
                    ? const Center(child: CircularProgressIndicator.adaptive())
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildColunaCores(context, state)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildColunaTamanhos(context, state),
                            ),
                            if (state.estampasAtivo) ...[
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildColunaEstampas(context, state),
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildRodape(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildColunaCores(BuildContext context, AdicionarVariacoesState state) {
    final itens = state.todasCores
        .where(
          (cor) => cor.nome.toLowerCase().contains(
            state.buscaCor.toLowerCase(),
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cores', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Buscar cor',
            prefixIcon: Icon(Icons.search, size: 18),
            isDense: true,
          ),
          onChanged: (texto) => _bloc.add(
            AdicionarVariacoesBuscaAlterou(
              campo: CampoBuscaVariacoes.cor,
              texto: texto,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: itens
                  .where((cor) => cor.id != null)
                  .map(
                    (cor) => _buildChip(
                      label: cor.nome,
                      selecionado: state.coresSelecionadas.contains(cor.id),
                      travado: !state.podeDesmarcarCor(cor.id!),
                      onTap: () => _bloc.add(
                        AdicionarVariacoesCorAlternou(corId: cor.id!),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: () async {
            final salvou = await CorModal.show(context: context);
            if (salvou == true) {
              _bloc.add(
                AdicionarVariacoesIniciou(
                  referenciaId: widget.referenciaId,
                  corIdsNaGrade: widget.corIdsNaGrade,
                  tamanhoIdsNaGrade: widget.tamanhoIdsNaGrade,
                  estampaIdsNaGrade: widget.estampaIdsNaGrade,
                  chavesNaGrade: widget.chavesNaGrade,
                ),
              );
            }
          },
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Criar cor'),
        ),
      ],
    );
  }

  Widget _buildColunaTamanhos(
    BuildContext context,
    AdicionarVariacoesState state,
  ) {
    final itens = state.todosTamanhos
        .where(
          (t) => t.nome.toLowerCase().contains(state.buscaTamanho.toLowerCase()),
        )
        .toList();

    final grupos = <GradeDeTamanho, List<Tamanho>>{};
    for (final tamanho in itens) {
      if (tamanho.id == null) continue;
      grupos
          .putIfAbsent(classificarGradeDeTamanho(tamanho.nome), () => [])
          .add(tamanho);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Tamanhos', style: Theme.of(context).textTheme.titleMedium),
            ),
            Text(
              '${state.tamanhosSelecionados.length}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Buscar tamanho',
            prefixIcon: Icon(Icons.search, size: 18),
            isDense: true,
          ),
          onChanged: (texto) => _bloc.add(
            AdicionarVariacoesBuscaAlterou(
              campo: CampoBuscaVariacoes.tamanho,
              texto: texto,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: grupos.entries.map((entrada) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _rotuloGrade(entrada.key),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: entrada.value
                            .map(
                              (tamanho) => _buildChip(
                                label: tamanho.nome,
                                selecionado: state.tamanhosSelecionados
                                    .contains(tamanho.id),
                                travado: !state.podeDesmarcarTamanho(
                                  tamanho.id!,
                                ),
                                onTap: () => _bloc.add(
                                  AdicionarVariacoesTamanhoAlternou(
                                    tamanhoId: tamanho.id!,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: () async {
            final salvou = await TamanhoModal.show(context: context);
            if (salvou == true) {
              _bloc.add(
                AdicionarVariacoesIniciou(
                  referenciaId: widget.referenciaId,
                  corIdsNaGrade: widget.corIdsNaGrade,
                  tamanhoIdsNaGrade: widget.tamanhoIdsNaGrade,
                  estampaIdsNaGrade: widget.estampaIdsNaGrade,
                  chavesNaGrade: widget.chavesNaGrade,
                ),
              );
            }
          },
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Criar tamanho'),
        ),
      ],
    );
  }

  Widget _buildColunaEstampas(
    BuildContext context,
    AdicionarVariacoesState state,
  ) {
    final itens = state.todasEstampas
        .where(
          (e) => e.nome.toLowerCase().contains(state.buscaEstampa.toLowerCase()),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estampas', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Buscar estampa',
            prefixIcon: Icon(Icons.search, size: 18),
            isDense: true,
          ),
          onChanged: (texto) => _bloc.add(
            AdicionarVariacoesBuscaAlterou(
              campo: CampoBuscaVariacoes.estampa,
              texto: texto,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: itens
                  .where((e) => e.id != null)
                  .map(
                    (estampa) => _buildChip(
                      label: estampa.nome,
                      selecionado: state.estampasSelecionadas.contains(
                        estampa.id,
                      ),
                      travado: !state.podeDesmarcarEstampa(estampa.id!),
                      onTap: () => _bloc.add(
                        AdicionarVariacoesEstampaAlternou(
                          estampaId: estampa.id!,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required bool selecionado,
    required bool travado,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(travado ? '$label · na grade' : label),
      selected: selecionado,
      onSelected: travado ? null : (_) => onTap(),
      backgroundColor: travado ? const Color(0xFFC9D7E4) : null,
      selectedColor: const Color(0xFFEEF3F7),
    );
  }

  Widget _buildRodape(BuildContext context, AdicionarVariacoesState state) {
    final n = state.totalCombinacoesNovas;
    final salvando = state.step == AdicionarVariacoesStep.salvando;

    return Row(
      children: [
        FilterChip(
          label: const Text('Incluir estampas'),
          selected: state.estampasAtivo,
          onSelected: (ativo) => _bloc.add(
            AdicionarVariacoesEstampasAtivouAlternou(ativo: ativo),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Novos na grade: $n produto(s) com código de barras',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        FilledButton(
          onPressed: (n == 0 || salvando)
              ? null
              : () => _bloc.add(AdicionarVariacoesConfirmou()),
          child: Text(salvando ? 'Criando...' : 'CRIAR $n PRODUTOS'),
        ),
      ],
    );
  }

  String _rotuloGrade(GradeDeTamanho grade) {
    switch (grade) {
      case GradeDeTamanho.letras:
        return 'Letras';
      case GradeDeTamanho.numerica:
        return 'Numérica';
      case GradeDeTamanho.sutia:
        return 'Sutiã';
      case GradeDeTamanho.infantil:
        return 'Infantil';
      case GradeDeTamanho.unico:
        return 'Único';
    }
  }
}
