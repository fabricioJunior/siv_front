import 'package:core/bloc.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:produtos/domain/models/produto_da_grade.dart';
import 'package:produtos/presentation.dart';
import 'package:produtos/presentantion/widgets/adicionar_variacoes_painel.dart';

const _kLarguraCor = 170.0;
const _kLarguraEstampa = 130.0;
const _kLarguraTamanho = 84.0;
const _kLarguraAcao = 110.0;

// ponytail: paleta fixa pra bolinha da cor, já que ItemPresente não carrega
// um valor de cor real (só id/nome). Se o backend passar a expor a cor
// (hex), trocar por Color(int.parse(...)).
const _kPaletaCores = [
  Color(0xFF8E735B),
  Color(0xFF5980A6),
  Color(0xFF6B8F71),
  Color(0xFFB2555A),
  Color(0xFF9B7EDE),
  Color(0xFFC9A227),
  Color(0xFF4F6D7A),
  Color(0xFFD08159),
];

Color _corParaItem(int id) => _kPaletaCores[id % _kPaletaCores.length];

class ReferenciaProdutosTab extends StatefulWidget {
  final int referenciaId;

  const ReferenciaProdutosTab({super.key, required this.referenciaId});

  @override
  State<ReferenciaProdutosTab> createState() => _ReferenciaProdutosTabState();
}

class _ReferenciaProdutosTabState extends State<ReferenciaProdutosTab> {
  final _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  Future<void> _abrirAdicionarVariacoes(
    BuildContext context,
    ProdutosDaReferenciaState state,
  ) async {
    final bloc = context.read<ProdutosDaReferenciaBloc>();
    final criouAlgo = await AdicionarVariacoesPainel.show(
      context: context,
      referenciaId: widget.referenciaId,
      corIdsNaGrade: state.cores.map((c) => c.id).toSet(),
      tamanhoIdsNaGrade: state.tamanhos.map((t) => t.id).toSet(),
      estampaIdsNaGrade: state.estampas
          .where((e) => e.id != null)
          .map((e) => e.id!)
          .toSet(),
      chavesNaGrade: state.mapaProduto.keys.toSet(),
    );
    if (criouAlgo == true && context.mounted) {
      bloc.add(ProdutosDaReferenciaIniciou(referenciaId: widget.referenciaId));
    }
  }

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
                    ProdutosDaReferenciaIniciou(
                      referenciaId: widget.referenciaId,
                    ),
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
        final linhas = state.linhas;
        final totalFaltantes = state.todosOsFaltantes.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCabecalho(context, cores, textos, state, criando),
            const SizedBox(height: 12),
            _buildTiraEstampas(context, cores, textos, state),
            const SizedBox(height: 12),
            _buildBarra(context, state, totalFaltantes, criando),
            const SizedBox(height: 12),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: cores.superficie,
                        borderRadius: BorderRadius.circular(SivDimensoes.raio),
                        border: Border.all(color: cores.hairline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: linhas.isEmpty
                                ? const Center(
                                    child: Text(
                                      'Nada encontrado com esse filtro.',
                                    ),
                                  )
                                : _buildTabela(
                                    context,
                                    cores,
                                    textos,
                                    state,
                                    linhas,
                                    criando,
                                  ),
                          ),
                          Divider(height: 1, color: cores.hairline),
                          _buildLegenda(context, cores, textos),
                        ],
                      ),
                    ),
                  ),
                  ...sivCantosBlueprint(cores.hairline),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCabecalho(
    BuildContext context,
    SivColors cores,
    SivTextStyles textos,
    ProdutosDaReferenciaState state,
    bool criando,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PRODUTOS DA REFERÊNCIA',
                style: textos.secao.copyWith(color: cores.acoAtivo),
              ),
              const SizedBox(height: 2),
              Text(
                '${state.totalCombinacoesComProduto}/${state.totalCombinacoesDaGrade} combinações criadas',
                style: textos.apoio.copyWith(color: cores.textoApoio),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => _abrirAdicionarVariacoes(context, state),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Adicionar variações'),
        ),
      ],
    );
  }

  Widget _buildTiraEstampas(
    BuildContext context,
    SivColors cores,
    SivTextStyles textos,
    ProdutosDaReferenciaState state,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cores.superficie,
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
        border: Border.all(color: cores.hairline),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ESTAMPAS',
                style: textos.rotulo.copyWith(color: cores.acoAtivo),
              ),
              SizedBox(width: 16),
              if (state.estampas.isEmpty)
                Text(
                  'Sem estampa — opcional. Ao adicionar, cada estampa gera os '
                  'produtos de cor × tamanho, e os lisos continuam.',
                  style: textos.apoio.copyWith(color: cores.textoApoio),
                )
              else
                ...state.estampas.map((e) => _ChipEstampa(nome: e.nome)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarra(
    BuildContext context,
    ProdutosDaReferenciaState state,
    int totalFaltantes,
    bool criando,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'Filtrar por cor, estampa ou tamanho',
                  prefixIcon: Icon(Icons.search, size: 18),
                ),
                onChanged: (texto) => context
                    .read<ProdutosDaReferenciaBloc>()
                    .add(ProdutosDaReferenciaBuscouAlterou(busca: texto)),
              ),
            ),
          ],
        ),
        SegmentedButton<FiltroProdutosDaReferencia>(
          segments: const [
            ButtonSegment(
              value: FiltroProdutosDaReferencia.todos,
              label: Text(rotuloFiltroTodos),
            ),
            ButtonSegment(
              value: FiltroProdutosDaReferencia.faltando,
              label: Text(rotuloFiltroFaltando),
            ),
          ],
          selected: {state.filtro},
          onSelectionChanged: (selecionados) =>
              context.read<ProdutosDaReferenciaBloc>().add(
                ProdutosDaReferenciaFiltroAlterou(filtro: selecionados.first),
              ),
        ),
        if (state.filtro == FiltroProdutosDaReferencia.faltando &&
            totalFaltantes > 0)
          TextButton(
            onPressed: criando
                ? null
                : () => context.read<ProdutosDaReferenciaBloc>().add(
                    ProdutosDaReferenciaCriouCombinacoes(
                      combinacoes: state.todosOsFaltantes,
                    ),
                  ),
            child: Text('Criar $totalFaltantes faltantes'),
          ),
        if (criando)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }

  Widget _buildTabela(
    BuildContext context,
    SivColors cores,
    SivTextStyles textos,
    ProdutosDaReferenciaState state,
    List<
      ({
        ItemPresente cor,
        EstampaPresente estampa,
        List<ItemPresente> faltantes,
      })
    >
    linhas,
    bool criando,
  ) {
    final rotuloColuna = textos.rotulo.copyWith(color: cores.textoApoio);
    // Largura fixa explícita (colunas + os 32px de padding horizontal que
    // cabeçalho/linhas aplicam): sem ela, o SingleChildScrollView horizontal
    // dá largura irrestrita pro filho, e um ListView vertical dentro disso
    // não consegue resolver layout (crashava o hit-test dos cantos do
    // blueprint card, que nunca terminavam de desenhar).
    final larguraColunas =
        _kLarguraCor +
        _kLarguraEstampa +
        (_kLarguraTamanho * state.tamanhos.length) +
        _kLarguraAcao;
    final larguraConteudo = larguraColunas + 32;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Preenche a largura disponível (não fica encolhido quando a área é
        // mais larga que o conteúdo) mas ainda permite rolar quando é mais
        // estreita.
        final largura = larguraConteudo < constraints.maxWidth
            ? constraints.maxWidth
            : larguraConteudo;

        return Scrollbar(
          controller: _horizontalController,
          thumbVisibility: true,
          child: ScrollConfiguration(
            behavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
            ),
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: largura,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: _kLarguraCor,
                            child: Text('COR', style: rotuloColuna),
                          ),
                          SizedBox(
                            width: _kLarguraEstampa,
                            child: Text('ESTAMPA', style: rotuloColuna),
                          ),
                          ...state.tamanhos.map(
                            (t) => SizedBox(
                              width: _kLarguraTamanho,
                              child: Text(
                                t.nome,
                                textAlign: TextAlign.center,
                                style: rotuloColuna,
                              ),
                            ),
                          ),
                          SizedBox(width: _kLarguraAcao),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: cores.hairline),
                    Expanded(
                      child: ListView.builder(
                        itemCount: linhas.length,
                        itemBuilder: (_, i) => _LinhaGrade(
                          linha: linhas[i],
                          tamanhos: state.tamanhos,
                          mapaProduto: state.mapaProduto,
                          criando: criando,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegenda(
    BuildContext context,
    SivColors cores,
    SivTextStyles textos,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Wrap(
        spacing: 16,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _LegendaItem(
            texto:
                'Quantidade em estoque — passe o mouse para ver o '
                'código de barras',
            cores: cores,
            textos: textos,
            child: _CelulaProduto(saldo: 12, codigo: '1234', cores: cores),
          ),
          _LegendaItem(
            texto: 'Faltando — clique para criar',
            cores: cores,
            textos: textos,
            child: _CelulaFaltando(cores: cores, onTap: null),
          ),
          Text(
            'Cada linha = cor × estampa · cada coluna = tamanho',
            style: textos.apoio.copyWith(color: cores.textoApoio),
          ),
        ],
      ),
    );
  }
}

class _LegendaItem extends StatelessWidget {
  final Widget child;
  final String texto;
  final SivColors cores;
  final SivTextStyles textos;

  const _LegendaItem({
    required this.child,
    required this.texto,
    required this.cores,
    required this.textos,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(width: 6),
        Text(texto, style: textos.apoio.copyWith(color: cores.textoApoio)),
      ],
    );
  }
}

class _ChipEstampa extends StatelessWidget {
  final String nome;

  const _ChipEstampa({required this.nome});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: cores.selecaoFundo,
        border: Border.all(color: cores.acoProfundo.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ponytail: ícone simples representa "padrão" ao invés de gerar
          // uma textura diagonal customizada — não vale o esforço aqui.
          Icon(Icons.texture, size: 12, color: cores.acoProfundo),
          const SizedBox(width: 6),
          Text(nome, style: TextStyle(fontSize: 12.5, color: cores.acoEscuro)),
        ],
      ),
    );
  }
}

class _LinhaGrade extends StatelessWidget {
  final ({
    ItemPresente cor,
    EstampaPresente estampa,
    List<ItemPresente> faltantes,
  })
  linha;
  final List<ItemPresente> tamanhos;
  final Map<String, ProdutoDaGrade> mapaProduto;
  final bool criando;

  const _LinhaGrade({
    required this.linha,
    required this.tamanhos,
    required this.mapaProduto,
    required this.criando,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final ehLiso = linha.estampa.id == null;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: _kLarguraCor,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _corParaItem(linha.cor.id),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        linha.cor.nome,
                        overflow: TextOverflow.ellipsis,
                        style: textos.corpo.copyWith(color: cores.acoEscuro),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: _kLarguraEstampa,
                child: Text(
                  linha.estampa.nome,
                  overflow: TextOverflow.ellipsis,
                  style: textos.corpo.copyWith(
                    color: ehLiso ? cores.textoDesabilitado : cores.acoEscuro,
                  ),
                ),
              ),
              ...tamanhos.map((tamanho) {
                final produto =
                    mapaProduto[chaveComboGrade(
                      linha.cor.id,
                      tamanho.id,
                      linha.estampa.id,
                    )];
                return SizedBox(
                  width: _kLarguraTamanho,
                  child: Center(
                    child: produto != null
                        ? _CelulaProduto(
                            saldo: produto.saldo,
                            codigo: produto.codigosBarras.isNotEmpty
                                ? produto.codigosBarras.first
                                : '',
                            cores: cores,
                          )
                        : _CelulaFaltando(
                            cores: cores,
                            onTap: criando
                                ? null
                                : () => context
                                      .read<ProdutosDaReferenciaBloc>()
                                      .add(
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
                          ),
                  ),
                );
              }),
              SizedBox(
                width: _kLarguraAcao,
                child: linha.faltantes.isEmpty
                    ? null
                    : Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: cores.acoProfundo,
                          ),
                          onPressed: criando
                              ? null
                              : () => context
                                    .read<ProdutosDaReferenciaBloc>()
                                    .add(
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
                      ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: cores.hairline),
      ],
    );
  }
}

class _CelulaProduto extends StatelessWidget {
  final int saldo;
  final String codigo;
  final SivColors cores;

  const _CelulaProduto({
    required this.saldo,
    required this.codigo,
    required this.cores,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: codigo.isEmpty
          ? 'Sem código de barras'
          : 'Código de barras: $codigo',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: cores.selecaoFundo,
          border: Border.all(color: cores.acoProfundo.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
        ),
        child: Text(
          '$saldo',
          style: TextStyle(fontSize: 12.5, color: cores.acoEscuro),
        ),
      ),
    );
  }
}

class _CelulaFaltando extends StatelessWidget {
  final SivColors cores;
  final VoidCallback? onTap;

  const _CelulaFaltando({required this.cores, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SivDimensoes.raio),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: cores.textoApoio),
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
        ),
        child: Icon(Icons.add, size: 14, color: cores.textoApoio),
      ),
    );
  }
}
