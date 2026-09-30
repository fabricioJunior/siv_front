import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';
import 'package:produtos/domain/tamanho_grade_agrupamento.dart';

enum _OrigemCodigoBarras { siv, fornecedor }

// Etapas do wizard (navegação de UI, fica local no widget -- o bloc só
// conhece dados/passos reais de carregamento e salvamento). "Confirmação"
// mostra a revisão das combinações que vão ser criadas (cor/tamanho/estampa
// + código ou "sem código") antes do clique final disparar o salvamento --
// o listener existente fecha o diálogo quando o bloc emite `sucesso`.
enum _EtapaWizard { variacoes, origem, codigos, confirmacao }

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
  final bool mobile;

  const AdicionarVariacoesPainel({
    super.key,
    required this.referenciaId,
    required this.corIdsNaGrade,
    required this.tamanhoIdsNaGrade,
    required this.estampaIdsNaGrade,
    required this.chavesNaGrade,
    this.mobile = false,
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
          height: 820,
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

  /// Parte 2 (mobile): mesmo bloc/conteúdo, apresentado em bottom sheet
  /// full-height com abas internas (Cores/Tamanhos/Estampas) em vez das
  /// 3 colunas lado a lado do desktop.
  static Future<bool?> showMobile({
    required BuildContext context,
    required int referenciaId,
    required Set<int> corIdsNaGrade,
    required Set<int> tamanhoIdsNaGrade,
    required Set<int> estampaIdsNaGrade,
    required Set<String> chavesNaGrade,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.92,
        child: AdicionarVariacoesPainel(
          mobile: true,
          referenciaId: referenciaId,
          corIdsNaGrade: corIdsNaGrade,
          tamanhoIdsNaGrade: tamanhoIdsNaGrade,
          estampaIdsNaGrade: estampaIdsNaGrade,
          chavesNaGrade: chavesNaGrade,
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
  final _buscaCorController = TextEditingController();
  final _buscaTamanhoController = TextEditingController();
  final _buscaEstampaController = TextEditingController();
  final _buscaCorFocus = FocusNode();
  final _buscaTamanhoFocus = FocusNode();
  final _buscaEstampaFocus = FocusNode();

  // Índice do chip "destacado" por seta ↑/↓ em cada coluna -- Enter seleciona
  // esse em vez de sempre o 1º. Zerado sempre que a busca muda (lista
  // filtrada muda, destaque antigo não faz mais sentido).
  int _corDestaque = 0;
  int _tamanhoDestaque = 0;
  int _estampaDestaque = 0;

  // Id do chip recém-marcado via Enter, só pra dar um flash visual -- sem
  // isso o item selecionado pula pro fim da lista (não-selecionados vêm
  // primeiro) no mesmo instante, e some da vista sem feedback nenhum.
  int? _corRecemAdicionado;
  int? _tamanhoRecemAdicionado;
  int? _estampaRecemAdicionado;

  // Ordem "congelada" dos chips -- só recalculada quando o conjunto de ids
  // filtrados muda (busca alterou), NUNCA só porque uma seleção mudou. Sem
  // isso, marcar uma cor via Enter reordenava a lista (não selecionados
  // primeiro) na hora, e o chip pulava de posição no mesmo frame em que
  // devia só piscar -- o Wrap não anima posição, então virava um salto seco
  // e a troca de cor nem dava tempo de aparecer.
  List<int>? _corOrdemFixa;
  List<int>? _tamanhoOrdemFixa;

  static const _duracaoFlash = Duration(milliseconds: 1000);

  // --- Wizard (estado local de UI, não do bloc) ---
  _EtapaWizard _etapa = _EtapaWizard.variacoes;
  _OrigemCodigoBarras _origem = _OrigemCodigoBarras.siv;

  // Etapa 3 (bipagem): código por chave de combinação, combinações puladas
  // (ficam sem código igual as nunca tocadas, só pra andar a fila) e a
  // combinação focada manualmente (clique numa linha reabre pra rebipar).
  final Map<String, String> _codigosBipados = {};
  final Set<String> _puladas = {};
  String? _chaveAlvo;
  final _campoCodigoController = TextEditingController();
  final _campoCodigoFocus = FocusNode();
  int _proximoCodigoSimulado = 1;

  // Toggle do rodapé da etapa 3: o que ficar sem código ao confirmar vira
  // "sem código pra bipar depois" (default, já decidido antes) ou é gerado
  // pelo SIV nesse instante.
  bool _restantesGerarSiv = false;

  void _piscarRecemAdicionado(int id, ValueChanged<int?> aplicar) {
    setState(() => aplicar(id));
    Future.delayed(_duracaoFlash, () {
      if (mounted) setState(() => aplicar(null));
    });
  }

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
    _buscaCorController.dispose();
    _buscaTamanhoController.dispose();
    _buscaEstampaController.dispose();
    _buscaCorFocus.dispose();
    _buscaTamanhoFocus.dispose();
    _buscaEstampaFocus.dispose();
    _campoCodigoController.dispose();
    _campoCodigoFocus.dispose();
    super.dispose();
  }

  // Enter no campo de busca seleciona o chip destacado (setas ↑/↓ movem o
  // destaque, começa no 1º resultado). Mantém o texto digitado -- deixa o
  // usuário conferir/ajustar o filtro em vez de perder o que buscou a cada
  // seleção.
  void _selecionarDestacado({
    required List<({int? id, VoidCallback? onTap})> itens,
    required TextEditingController controller,
    required FocusNode focusNode,
    required CampoBuscaVariacoes campo,
    required int destaque,
    required ValueChanged<int> onDestaqueAlterado,
    required ValueChanged<int?> onRecemAdicionado,
  }) {
    if (destaque < 0 || destaque >= itens.length) return;
    final item = itens[destaque];
    if (item.id == null || item.onTap == null) return;

    item.onTap!();
    onDestaqueAlterado(0);
    // TextField.onSubmitted por padrão devolve o foco pro sistema (esconde
    // teclado/perde destaque) -- sem isso, cada Enter obrigava a clicar de
    // novo no campo pra continuar digitando o próximo filtro.
    focusNode.requestFocus();
    _piscarRecemAdicionado(item.id!, onRecemAdicionado);
  }

  // ↑/↓ movem o destaque dentro da lista filtrada (clampado); outras teclas
  // seguem pro TextField normalmente (edição de texto, Home/End, etc).
  KeyEventResult _navegarComSetas({
    required KeyEvent event,
    required int totalItens,
    required int destaqueAtual,
    required ValueChanged<int> onDestaqueAlterado,
    required TextEditingController controller,
  }) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (totalItens == 0) return KeyEventResult.ignored;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      onDestaqueAlterado((destaqueAtual + 1).clamp(0, totalItens - 1));
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      onDestaqueAlterado((destaqueAtual - 1).clamp(0, totalItens - 1));
      return KeyEventResult.handled;
    }

    // ←/→ só navegam os chips quando o cursor já está numa ponta do texto --
    // senão rouba a edição normal (mover o cursor dentro do que foi digitado).
    final selecao = controller.selection;
    final cursorNoInicio = selecao.isCollapsed && selecao.baseOffset == 0;
    final cursorNoFim =
        selecao.isCollapsed && selecao.baseOffset == controller.text.length;

    if (key == LogicalKeyboardKey.arrowRight && cursorNoFim) {
      onDestaqueAlterado((destaqueAtual + 1).clamp(0, totalItens - 1));
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft && cursorNoInicio) {
      onDestaqueAlterado((destaqueAtual - 1).clamp(0, totalItens - 1));
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
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

          return CallbackShortcuts(
            bindings: {
              const SingleActivator(
                LogicalKeyboardKey.enter,
                control: true,
              ): () =>
                  _acaoPrincipal(context, state),
              const SingleActivator(LogicalKeyboardKey.enter, meta: true): () =>
                  _acaoPrincipal(context, state),
              const SingleActivator(LogicalKeyboardKey.escape): () =>
                  Navigator.of(context).pop(false),
            },
            child: FocusScope(
              autofocus: true,
              child: Column(
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
                  // Wizard de passos só no desktop -- mobile continua com o
                  // fluxo antigo (Cores/Tamanhos/Estampas em abas + criar
                  // direto pelo SIV), ver decisão documentada em [_buildRodape].
                  if (!widget.mobile && !carregando)
                    _buildStepperHeader(context, state),
                  const Divider(height: 1),
                  Expanded(
                    child: carregando
                        ? const Center(
                            child: CircularProgressIndicator.adaptive(),
                          )
                        : _buildConteudo(context, state),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildFooter(context, state),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConteudo(BuildContext context, AdicionarVariacoesState state) {
    if (widget.mobile) return _buildCorpoMobile(context, state);
    switch (_etapa) {
      case _EtapaWizard.variacoes:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildColunaCores(context, state)),
              const SizedBox(width: 16),
              Expanded(child: _buildColunaTamanhos(context, state)),
              if (state.estampasAtivo) ...[
                const SizedBox(width: 16),
                Expanded(child: _buildColunaEstampas(context, state)),
              ],
            ],
          ),
        );
      case _EtapaWizard.origem:
        return _buildEtapaOrigem(context);
      case _EtapaWizard.codigos:
        return _buildEtapaCodigos(context, state);
      case _EtapaWizard.confirmacao:
        return _buildEtapaConfirmacao(context, state);
    }
  }

  Widget _buildFooter(BuildContext context, AdicionarVariacoesState state) {
    if (widget.mobile) return _buildRodape(context, state);
    switch (_etapa) {
      case _EtapaWizard.variacoes:
        return _buildRodapeVariacoes(context, state);
      case _EtapaWizard.origem:
        return _buildFooterOrigem(context, state);
      case _EtapaWizard.codigos:
        return _buildFooterCodigos(context, state);
      case _EtapaWizard.confirmacao:
        return _buildFooterConfirmacao(context, state);
    }
  }

  // Enter/atalho ctrl+enter segue a etapa atual: avança a seleção, decide a
  // origem (ou já confirma se for SIV) e confirma de vez na etapa de
  // códigos -- mesma ação do botão principal visível em cada etapa.
  void _acaoPrincipal(BuildContext context, AdicionarVariacoesState state) {
    if (widget.mobile) {
      if (state.totalCombinacoesNovas > 0 &&
          state.step != AdicionarVariacoesStep.salvando) {
        _bloc.add(AdicionarVariacoesConfirmou());
      }
      return;
    }
    switch (_etapa) {
      case _EtapaWizard.variacoes:
        if (state.totalCombinacoesNovas > 0) {
          setState(() => _etapa = _EtapaWizard.origem);
        }
        break;
      case _EtapaWizard.origem:
        _avancarDeOrigem();
        break;
      case _EtapaWizard.codigos:
        setState(() => _etapa = _EtapaWizard.confirmacao);
        break;
      case _EtapaWizard.confirmacao:
        if (state.step != AdicionarVariacoesStep.salvando) {
          _confirmarCriacao();
        }
        break;
    }
  }

  // Stepper do cabeçalho: 4 rótulos (Variações/Origem/Códigos/Confirmação).
  // Se a origem escolhida for "Gerar pelo SIV" a etapa "Códigos" nunca é
  // visitada e o stepper pula direto de Origem pra Confirmação -- decisão
  // aceitável, o mock não cobre esse caso.
  Widget _buildStepperHeader(
    BuildContext context,
    AdicionarVariacoesState state,
  ) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    const rotulos = ['Variações', 'Origem', 'Códigos', 'Confirmação'];
    final confirmando =
        state.step == AdicionarVariacoesStep.salvando ||
        state.step == AdicionarVariacoesStep.sucesso;
    final indiceAtual = confirmando ? 3 : _etapa.index;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          for (var i = 0; i < rotulos.length; i++) ...[
            _buildStepDot(
              cores,
              textos,
              indice: i,
              atual: indiceAtual,
              rotulo: rotulos[i],
            ),
            if (i != rotulos.length - 1)
              Expanded(
                child: Container(
                  height: 1,
                  color: i < indiceAtual ? cores.acoAtivo : cores.hairline,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepDot(
    SivColors cores,
    SivTextStyles textos, {
    required int indice,
    required int atual,
    required String rotulo,
  }) {
    final concluido = indice < atual;
    final ativo = indice == atual;
    final destacado = concluido || ativo;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: destacado ? cores.acoAtivo : Colors.transparent,
            border: Border.all(
              color: destacado ? cores.acoAtivo : cores.hairline,
              width: 1.5,
            ),
          ),
          child: concluido
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text(
                  '${indice + 1}',
                  style: textos.apoio.copyWith(
                    color: ativo ? Colors.white : cores.textoApoio,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
        if (ativo) ...[
          const SizedBox(width: 6),
          Text(
            rotulo,
            style: textos.apoio.copyWith(
              color: cores.acoAtivo,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCorpoMobile(
    BuildContext context,
    AdicionarVariacoesState state,
  ) {
    final abas = ['Cores', 'Tamanhos', if (state.estampasAtivo) 'Estampas'];

    return DefaultTabController(
      length: abas.length,
      child: Column(
        children: [
          TabBar(tabs: abas.map((a) => Tab(text: a)).toList()),
          Expanded(
            child: TabBarView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildColunaCores(context, state),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildColunaTamanhos(context, state),
                ),
                if (state.estampasAtivo)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildColunaEstampas(context, state),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColunaCores(
    BuildContext context,
    AdicionarVariacoesState state,
  ) {
    final itensFiltrados = state.todasCores
        .where(
          (cor) =>
              cor.nome.toLowerCase().contains(state.buscaCor.toLowerCase()),
        )
        .where((cor) => cor.id != null)
        .toList();

    // Não selecionados primeiro -- só recalcula quando a busca muda o
    // conjunto de ids filtrados (ver comentário de _corOrdemFixa).
    final idsFiltrados = itensFiltrados.map((cor) => cor.id!).toSet();
    final ordemValida =
        _corOrdemFixa != null &&
        idsFiltrados.length == _corOrdemFixa!.length &&
        idsFiltrados.containsAll(_corOrdemFixa!);
    if (!ordemValida) {
      _corOrdemFixa = [
        ...itensFiltrados
            .where((cor) => !state.coresSelecionadas.contains(cor.id))
            .map((cor) => cor.id!),
        ...itensFiltrados
            .where((cor) => state.coresSelecionadas.contains(cor.id))
            .map((cor) => cor.id!),
      ];
    }
    final porId = {for (final cor in itensFiltrados) cor.id!: cor};
    final itens = _corOrdemFixa!.map((id) => porId[id]!).toList();
    final itensParaAtalho = itens
        .map(
          (cor) => (
            id: cor.id,
            onTap: () => _bloc.add(AdicionarVariacoesCorAlternou(corId: cor.id!)),
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cores', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Focus(
          onKeyEvent: (node, event) => _navegarComSetas(
            event: event,
            totalItens: itens.length,
            destaqueAtual: _corDestaque,
            onDestaqueAlterado: (i) => setState(() => _corDestaque = i),
            controller: _buscaCorController,
          ),
          child: TextField(
            controller: _buscaCorController,
            focusNode: _buscaCorFocus,
            decoration: const InputDecoration(
              hintText: 'Buscar cor (↑↓ + Enter seleciona)',
              prefixIcon: Icon(Icons.search, size: 18),
              isDense: true,
            ),
            onChanged: (texto) {
              setState(() => _corDestaque = 0);
              _bloc.add(
                AdicionarVariacoesBuscaAlterou(
                  campo: CampoBuscaVariacoes.cor,
                  texto: texto,
                ),
              );
            },
            onSubmitted: (_) => _selecionarDestacado(
              itens: itensParaAtalho,
              controller: _buscaCorController,
              focusNode: _buscaCorFocus,
              campo: CampoBuscaVariacoes.cor,
              destaque: _corDestaque,
              onDestaqueAlterado: (i) => setState(() => _corDestaque = i),
              onRecemAdicionado: (id) => _corRecemAdicionado = id,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var i = 0; i < itens.length; i++)
                  _buildChip(
                    key: ValueKey(itens[i].id),
                    label: itens[i].nome,
                    selecionado: state.coresSelecionadas.contains(itens[i].id),
                    travado: state.corIdsNaGrade.contains(itens[i].id!),
                    destacado: i == _corDestaque,
                    recemAdicionado: itens[i].id == _corRecemAdicionado,
                    onTap: () => _bloc.add(
                      AdicionarVariacoesCorAlternou(corId: itens[i].id!),
                    ),
                  ),
              ],
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
    final itensFiltrados = state.todosTamanhos
        .where(
          (t) =>
              t.nome.toLowerCase().contains(state.buscaTamanho.toLowerCase()),
        )
        .where((t) => t.id != null)
        .toList();

    // Grupos na ordem original (estável, não mistura Letras/Numérica/etc),
    // não selecionados primeiro dentro de cada grupo -- só recalcula quando
    // a busca muda o conjunto de ids filtrados (mesmo motivo/comentário de
    // _corOrdemFixa, congela a ordem entre seleções via Enter).
    final idsFiltrados = itensFiltrados.map((t) => t.id!).toSet();
    final ordemValida =
        _tamanhoOrdemFixa != null &&
        idsFiltrados.length == _tamanhoOrdemFixa!.length &&
        idsFiltrados.containsAll(_tamanhoOrdemFixa!);
    if (!ordemValida) {
      final gruposTmp = <GradeDeTamanho, List<Tamanho>>{};
      for (final tamanho in itensFiltrados) {
        gruposTmp
            .putIfAbsent(classificarGradeDeTamanho(tamanho.nome), () => [])
            .add(tamanho);
      }
      _tamanhoOrdemFixa = gruposTmp.values
          .expand(
            (valores) => [
              ...valores.where(
                (t) => !state.tamanhosSelecionados.contains(t.id),
              ),
              ...valores.where(
                (t) => state.tamanhosSelecionados.contains(t.id),
              ),
            ],
          )
          .map((t) => t.id!)
          .toList();
    }
    final porId = {for (final t in itensFiltrados) t.id!: t};
    final itens = _tamanhoOrdemFixa!.map((id) => porId[id]!).toList();

    final grupos = <GradeDeTamanho, List<Tamanho>>{};
    for (final tamanho in itens) {
      grupos
          .putIfAbsent(classificarGradeDeTamanho(tamanho.nome), () => [])
          .add(tamanho);
    }
    final itensParaAtalho = itens
        .map(
          (tamanho) => (
            id: tamanho.id,
            onTap: () => _bloc.add(
              AdicionarVariacoesTamanhoAlternou(tamanhoId: tamanho.id!),
            ),
          ),
        )
        .toList();
    final indicePorId = {
      for (var i = 0; i < itens.length; i++) itens[i].id!: i,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Tamanhos',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              '${state.tamanhosSelecionados.length}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Focus(
          onKeyEvent: (node, event) => _navegarComSetas(
            event: event,
            totalItens: itens.length,
            destaqueAtual: _tamanhoDestaque,
            onDestaqueAlterado: (i) => setState(() => _tamanhoDestaque = i),
            controller: _buscaTamanhoController,
          ),
          child: TextField(
            controller: _buscaTamanhoController,
            focusNode: _buscaTamanhoFocus,
            decoration: const InputDecoration(
              hintText: 'Buscar tamanho (↑↓ + Enter seleciona)',
              prefixIcon: Icon(Icons.search, size: 18),
              isDense: true,
            ),
            onChanged: (texto) {
              setState(() => _tamanhoDestaque = 0);
              _bloc.add(
                AdicionarVariacoesBuscaAlterou(
                  campo: CampoBuscaVariacoes.tamanho,
                  texto: texto,
                ),
              );
            },
            onSubmitted: (_) => _selecionarDestacado(
              itens: itensParaAtalho,
              controller: _buscaTamanhoController,
              focusNode: _buscaTamanhoFocus,
              campo: CampoBuscaVariacoes.tamanho,
              destaque: _tamanhoDestaque,
              onDestaqueAlterado: (i) => setState(() => _tamanhoDestaque = i),
              onRecemAdicionado: (id) => _tamanhoRecemAdicionado = id,
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
                                key: ValueKey(tamanho.id),
                                label: tamanho.nome,
                                selecionado: state.tamanhosSelecionados
                                    .contains(tamanho.id),
                                travado: state.tamanhoIdsNaGrade.contains(
                                  tamanho.id!,
                                ),
                                destacado:
                                    indicePorId[tamanho.id!] ==
                                    _tamanhoDestaque,
                                recemAdicionado:
                                    tamanho.id == _tamanhoRecemAdicionado,
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
          (e) =>
              e.nome.toLowerCase().contains(state.buscaEstampa.toLowerCase()),
        )
        .where((e) => e.id != null)
        .toList();
    final itensParaAtalho = itens
        .map(
          (estampa) => (
            id: estampa.id,
            onTap: () => _bloc.add(
              AdicionarVariacoesEstampaAlternou(estampaId: estampa.id!),
            ),
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estampas', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Focus(
          onKeyEvent: (node, event) => _navegarComSetas(
            event: event,
            totalItens: itens.length,
            destaqueAtual: _estampaDestaque,
            onDestaqueAlterado: (i) => setState(() => _estampaDestaque = i),
            controller: _buscaEstampaController,
          ),
          child: TextField(
            controller: _buscaEstampaController,
            focusNode: _buscaEstampaFocus,
            decoration: const InputDecoration(
              hintText: 'Buscar estampa (↑↓ + Enter seleciona)',
              prefixIcon: Icon(Icons.search, size: 18),
              isDense: true,
            ),
            onChanged: (texto) {
              setState(() => _estampaDestaque = 0);
              _bloc.add(
                AdicionarVariacoesBuscaAlterou(
                  campo: CampoBuscaVariacoes.estampa,
                  texto: texto,
                ),
              );
            },
            onSubmitted: (_) => _selecionarDestacado(
              itens: itensParaAtalho,
              controller: _buscaEstampaController,
              focusNode: _buscaEstampaFocus,
              campo: CampoBuscaVariacoes.estampa,
              destaque: _estampaDestaque,
              onDestaqueAlterado: (i) => setState(() => _estampaDestaque = i),
              onRecemAdicionado: (id) => _estampaRecemAdicionado = id,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var i = 0; i < itens.length; i++)
                  _buildChip(
                    key: ValueKey(itens[i].id),
                    label: itens[i].nome,
                    selecionado: state.estampasSelecionadas.contains(
                      itens[i].id,
                    ),
                    travado: state.estampaIdsNaGrade.contains(itens[i].id!),
                    destacado: i == _estampaDestaque,
                    recemAdicionado: itens[i].id == _estampaRecemAdicionado,
                    onTap: () => _bloc.add(
                      AdicionarVariacoesEstampaAlternou(
                        estampaId: itens[i].id!,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChip({
    Key? key,
    required String label,
    required bool selecionado,
    required bool travado,
    required VoidCallback onTap,
    bool destacado = false,
    bool recemAdicionado = false,
  }) {
    final chip = FilterChip(
      label: Text(travado ? '$label · na grade' : label),
      selected: selecionado,
      onSelected: (_) => onTap(),
      backgroundColor: travado ? const Color(0xFFC9D7E4) : null,
      selectedColor: const Color(0xFFEEF3F7),
      // Destaque de navegação por teclado (↑↓) -- borda de acento pra
      // indicar qual chip o Enter vai selecionar.
      side: destacado
          ? const BorderSide(color: Color(0xFF5980A6), width: 2)
          : null,
    );

    // Flash verde de "acabou de ser marcado via Enter" -- some sozinho (ver
    // _piscarRecemAdicionado). Sem isso, o item marcado pula pro fim da
    // lista (não selecionados vêm primeiro) no mesmo frame e não dá pra
    // notar que o Enter realmente funcionou.
    return AnimatedContainer(
      key: key,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: recemAdicionado
            ? const Color(0xFF5FB37C).withValues(alpha: 0.35)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: chip,
    );
  }

  // Rodapé usado só no mobile -- fluxo antigo, sem passar pelo wizard de
  // origem/códigos (ver decisão em [_buildFooter]/[_acaoPrincipal]).
  Widget _buildRodape(BuildContext context, AdicionarVariacoesState state) {
    final n = state.totalCombinacoesNovas;
    final salvando = state.step == AdicionarVariacoesStep.salvando;

    return Row(
      children: [
        FilterChip(
          label: const Text('Incluir estampas'),
          selected: state.estampasAtivo,
          onSelected: (ativo) =>
              _bloc.add(AdicionarVariacoesEstampasAtivouAlternou(ativo: ativo)),
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

  // Rodapé da etapa 1 (desktop): mesma barra de sempre, mas o botão agora
  // avança pro wizard em vez de criar direto.
  Widget _buildRodapeVariacoes(
    BuildContext context,
    AdicionarVariacoesState state,
  ) {
    final n = state.totalCombinacoesNovas;

    return Row(
      children: [
        FilterChip(
          label: const Text('Incluir estampas'),
          selected: state.estampasAtivo,
          onSelected: (ativo) =>
              _bloc.add(AdicionarVariacoesEstampasAtivouAlternou(ativo: ativo)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Novos na grade: $n produto(s) com código de barras',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        FilledButton(
          onPressed: n == 0
              ? null
              : () => setState(() => _etapa = _EtapaWizard.origem),
          child: const Text('AVANÇAR'),
        ),
      ],
    );
  }

  // Etapa 2: SIV (padrão) ou fornecedor -- só as 2 opções que fazem sentido
  // sem um parâmetro de empresa por trás (mock original tinha uma 3ª opção
  // "perguntar sempre" + link "alterar em Parâmetros", fora de escopo aqui;
  // texto trocado por algo neutro).
  Widget _buildEtapaOrigem(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CÓDIGO DE BARRAS',
            style: textos.rotulo.copyWith(color: cores.acoAtivo),
          ),
          const SizedBox(height: 4),
          Text('Origem do código', style: textos.secao),
          const SizedBox(height: 4),
          Text(
            'Escolha aplicada só a este cadastro.',
            style: textos.apoio.copyWith(color: cores.textoApoio),
          ),
          const SizedBox(height: 16),
          RadioGroup<_OrigemCodigoBarras>(
            groupValue: _origem,
            onChanged: (v) => setState(() => _origem = v!),
            child: Column(
              children: [
                _buildOpcaoOrigem(
                  context,
                  valor: _OrigemCodigoBarras.siv,
                  titulo: 'Gerar pelo SIV',
                  subtitulo:
                      'EAN-13 interno. Pra quem fabrica ou compra sem '
                      'etiqueta.',
                ),
                const SizedBox(height: 8),
                _buildOpcaoOrigem(
                  context,
                  valor: _OrigemCodigoBarras.fornecedor,
                  titulo: 'Do fornecedor',
                  subtitulo:
                      'Bipa ou digita o código de cada combinação a '
                      'seguir. O que não for informado fica sem código '
                      'pra bipar depois.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpcaoOrigem(
    BuildContext context, {
    required _OrigemCodigoBarras valor,
    required String titulo,
    required String subtitulo,
  }) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final selecionado = _origem == valor;

    return InkWell(
      onTap: () => setState(() => _origem = valor),
      borderRadius: BorderRadius.circular(SivDimensoes.raio),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selecionado ? cores.selecaoFundo : null,
          border: Border.all(color: selecionado ? cores.aco : cores.hairline),
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
        ),
        child: Row(
          children: [
            Radio<_OrigemCodigoBarras>(value: valor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: textos.corpo.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitulo,
                    style: textos.apoio.copyWith(color: cores.textoApoio),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterOrigem(
    BuildContext context,
    AdicionarVariacoesState state,
  ) {
    final n = state.totalCombinacoesNovas;
    return Row(
      children: [
        OutlinedButton(
          onPressed: () => setState(() => _etapa = _EtapaWizard.variacoes),
          child: const Text('Voltar'),
        ),
        const Spacer(),
        FilledButton(
          onPressed: _avancarDeOrigem,
          child: Text(
            _origem == _OrigemCodigoBarras.fornecedor
                ? 'AVANÇAR'
                : 'CRIAR $n PRODUTOS',
          ),
        ),
      ],
    );
  }

  // Origem "SIV" pula a etapa de bipagem (não faz sentido) e vai direto pra
  // revisão/confirmação; "fornecedor" passa pela etapa de bipagem antes.
  void _avancarDeOrigem() {
    if (_origem == _OrigemCodigoBarras.siv) {
      setState(() => _etapa = _EtapaWizard.confirmacao);
      return;
    }
    setState(() => _etapa = _EtapaWizard.codigos);
  }

  // Etapa 3: só é alcançada quando a origem escolhida foi "Do fornecedor".
  // O toggle de origem aqui dentro permite mudar de ideia sem voltar etapa;
  // trocar pra SIV limpa os códigos já bipados e só desabilita a tabela
  // (mostra o aviso do mock) -- não navega pra lugar nenhum, mais simples
  // que pular telas.
  Widget _buildEtapaCodigos(
    BuildContext context,
    AdicionarVariacoesState state,
  ) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final combos = state.combinacoesNovas;
    final coresCount = combos.map((c) => c.corId).toSet().length;
    final tamanhosCount = combos.map((c) => c.tamanhoId).toSet().length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ADICIONAR VARIAÇÕES',
            style: textos.rotulo.copyWith(color: cores.acoAtivo),
          ),
          const SizedBox(height: 4),
          Text('Códigos de barras', style: textos.secao),
          const SizedBox(height: 4),
          Text(
            '${combos.length} produtos novos — $coresCount cores × '
            '$tamanhosCount tamanhos.',
            style: textos.apoio.copyWith(color: cores.textoApoio),
          ),
          const SizedBox(height: 12),
          SegmentedButton<_OrigemCodigoBarras>(
            segments: const [
              ButtonSegment(
                value: _OrigemCodigoBarras.fornecedor,
                label: Text('DO FORNECEDOR'),
              ),
              ButtonSegment(
                value: _OrigemCodigoBarras.siv,
                label: Text('GERAR PELO SIV'),
              ),
            ],
            selected: {_origem},
            onSelectionChanged: (selecionados) =>
                selecionados.first == _OrigemCodigoBarras.siv
                ? _trocarOrigemParaSiv(context)
                : setState(() => _origem = _OrigemCodigoBarras.fornecedor),
          ),
          const SizedBox(height: 16),
          if (_origem == _OrigemCodigoBarras.siv)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cores.superficieRecuada,
                border: Border.all(color: cores.hairline),
                borderRadius: BorderRadius.circular(SivDimensoes.raio),
              ),
              child: Text(
                'O SIV gera os códigos ao criar.',
                style: textos.corpo,
              ),
            )
          else ...[
            _buildCardBipagem(context, state),
            const SizedBox(height: 16),
            _buildTabelaBipagem(context, state),
          ],
        ],
      ),
    );
  }

  void _trocarOrigemParaSiv(BuildContext context) {
    final tinhaCodigos = _codigosBipados.isNotEmpty;
    setState(() {
      _origem = _OrigemCodigoBarras.siv;
      _codigosBipados.clear();
      _puladas.clear();
      _chaveAlvo = null;
    });
    if (tinhaCodigos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Códigos bipados descartados.')),
      );
    }
  }

  Widget _buildCardBipagem(
    BuildContext context,
    AdicionarVariacoesState state,
  ) {
    final cores = context.sivColors;
    final combos = state.combinacoesNovas;
    final alvo = _alvoAtual(combos);

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cores.superficie,
            border: Border.all(color: cores.hairline),
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
          ),
          child: alvo == null
              ? _buildTudoBipado(context)
              : _buildAlvoAtual(context, state, alvo),
        ),
        ...sivCantosBlueprint(cores.aco),
      ],
    );
  }

  Widget _buildTudoBipado(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Todos os produtos têm código', style: textos.secao),
        const SizedBox(height: 4),
        Text(
          'Clique numa linha pra rebipar.',
          style: textos.apoio.copyWith(color: cores.textoApoio),
        ),
      ],
    );
  }

  Widget _buildAlvoAtual(
    BuildContext context,
    AdicionarVariacoesState state,
    ComboDeGrade alvo,
  ) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final combos = state.combinacoesNovas;
    final restantes = combos.where((c) => _ehPendente(c)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_nomeCor(state, alvo.corId)} · ${_nomeTamanho(state, alvo.tamanhoId)}',
          style: textos.secao.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          '$restantes sem código',
          style: textos.apoio.copyWith(color: cores.textoApoio),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _campoCodigoController,
          focusNode: _campoCodigoFocus,
          autofocus: true,
          style: textos.codigo.copyWith(fontSize: 18),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.qr_code_scanner, color: cores.aco),
            hintText: 'Leitor, teclado ou cole uma coluna da planilha',
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SivDimensoes.raio),
              borderSide: BorderSide(color: cores.aco, width: 2),
            ),
          ),
          onChanged: (texto) => _tratarColagem(combos, texto),
          onSubmitted: (texto) => _atribuirCodigo(combos, texto),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            OutlinedButton(
              onPressed: () => _pularAtual(combos),
              child: const Text('Pular'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: cores.textoApoio),
              ),
              onPressed: () => _simularLeitor(combos),
              child: const Text('Simular leitor'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'O leitor digita e dá Enter — o foco pula pro próximo sem '
          'código. Colar várias linhas preenche em sequência.',
          style: textos.apoio.copyWith(color: cores.textoApoio, fontSize: 11),
        ),
      ],
    );
  }

  bool _ehPendente(ComboDeGrade c) {
    final chave = chaveComboGrade(c.corId, c.tamanhoId, c.estampaId);
    return !_codigosBipados.containsKey(chave) && !_puladas.contains(chave);
  }

  ComboDeGrade? _alvoAtual(List<ComboDeGrade> combos) {
    if (_chaveAlvo != null) {
      for (final c in combos) {
        if (chaveComboGrade(c.corId, c.tamanhoId, c.estampaId) == _chaveAlvo) {
          return c;
        }
      }
    }
    for (final c in combos) {
      if (_ehPendente(c)) return c;
    }
    return null;
  }

  void _atribuirCodigo(List<ComboDeGrade> combos, String codigo) {
    final texto = codigo.trim();
    if (texto.isEmpty) return;
    final alvo = _alvoAtual(combos);
    if (alvo == null) return;
    final chave = chaveComboGrade(alvo.corId, alvo.tamanhoId, alvo.estampaId);
    setState(() {
      _codigosBipados[chave] = texto;
      _puladas.remove(chave);
      _chaveAlvo = null;
    });
    _campoCodigoController.clear();
  }

  // Colar múltiplas linhas (planilha) distribui uma por combinação sem
  // código, na ordem da tabela.
  void _tratarColagem(List<ComboDeGrade> combos, String texto) {
    if (!texto.contains('\n')) return;
    final linhas = texto
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty);
    for (final linha in linhas) {
      _atribuirCodigo(combos, linha);
    }
    _campoCodigoController.clear();
  }

  void _pularAtual(List<ComboDeGrade> combos) {
    final alvo = _alvoAtual(combos);
    if (alvo == null) return;
    final chave = chaveComboGrade(alvo.corId, alvo.tamanhoId, alvo.estampaId);
    setState(() {
      _puladas.add(chave);
      _chaveAlvo = null;
    });
  }

  // Gera um código de teste (não realista, só pra exercitar o fluxo sem
  // leitor físico).
  void _simularLeitor(List<ComboDeGrade> combos) {
    final codigo =
        'SIM${(_proximoCodigoSimulado++).toString().padLeft(6, '0')}';
    _atribuirCodigo(combos, codigo);
  }

  void _focarLinha(String chave) {
    setState(() => _chaveAlvo = chave);
    _campoCodigoController.clear();
    _campoCodigoFocus.requestFocus();
  }

  Widget _buildTabelaBipagem(
    BuildContext context,
    AdicionarVariacoesState state,
  ) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final combos = state.combinacoesNovas;
    final rotuloColuna = textos.rotulo.copyWith(color: cores.textoApoio);
    final alvo = _alvoAtual(combos);
    final chaveAlvo = alvo == null
        ? null
        : chaveComboGrade(alvo.corId, alvo.tamanhoId, alvo.estampaId);

    return Container(
      constraints: const BoxConstraints(maxHeight: 260),
      decoration: BoxDecoration(
        border: Border.all(color: cores.hairline),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                SizedBox(width: 28, child: Text('#', style: rotuloColuna)),
                Expanded(flex: 2, child: Text('COR', style: rotuloColuna)),
                SizedBox(width: 70, child: Text('TAM.', style: rotuloColuna)),
                Expanded(flex: 2, child: Text('CÓDIGO', style: rotuloColuna)),
                SizedBox(
                  width: 90,
                  child: Text('SITUAÇÃO', style: rotuloColuna),
                ),
                const SizedBox(width: 32),
              ],
            ),
          ),
          Divider(height: 1, color: cores.hairline),
          Expanded(
            child: ListView.separated(
              itemCount: combos.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: cores.hairline),
              itemBuilder: (_, i) {
                final combo = combos[i];
                final chave = chaveComboGrade(
                  combo.corId,
                  combo.tamanhoId,
                  combo.estampaId,
                );
                final codigo = _codigosBipados[chave];
                final duplicado =
                    codigo != null &&
                    _codigosBipados.values.where((v) => v == codigo).length > 1;
                final ehAlvo = chave == chaveAlvo;

                return InkWell(
                  onTap: () => _focarLinha(chave),
                  child: Container(
                    color: ehAlvo ? cores.selecaoFundo : null,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text('${i + 1}', style: textos.apoio),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: _corDaGrade(combo.corId),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  _nomeCor(state, combo.corId),
                                  overflow: TextOverflow.ellipsis,
                                  style: textos.corpo,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          child: Text(
                            _nomeTamanho(state, combo.tamanhoId),
                            style: textos.corpo,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(codigo ?? '—', style: textos.codigo),
                        ),
                        SizedBox(
                          width: 90,
                          child: _buildSituacao(context, codigo, duplicado),
                        ),
                        SizedBox(
                          width: 32,
                          child: codigo == null
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: () => setState(
                                    () => _codigosBipados.remove(chave),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSituacao(BuildContext context, String? codigo, bool duplicado) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    if (duplicado) {
      return Text(
        'Duplicado',
        style: textos.apoio.copyWith(color: cores.vinho),
      );
    }
    if (codigo != null) {
      return Text('OK', style: textos.apoio.copyWith(color: cores.acoProfundo));
    }
    return Text(
      'Pendente',
      style: textos.apoio.copyWith(color: cores.textoApoio),
    );
  }

  Widget _buildFooterCodigos(
    BuildContext context,
    AdicionarVariacoesState state,
  ) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final total = state.combinacoesNovas.length;
    final bipados = _codigosBipados.length;
    final pendentes = total - bipados;
    final salvando = state.step == AdicionarVariacoesStep.salvando;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : bipados / total,
            minHeight: 3,
            backgroundColor: cores.hairline,
            color: cores.aco,
          ),
        ),
        const SizedBox(height: 10),
        if (pendentes > 0 && _origem == _OrigemCodigoBarras.fornecedor)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'OS QUE FICAREM SEM CÓDIGO:',
                  style: textos.rotulo.copyWith(color: cores.textoApoio),
                ),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: false,
                      label: Text('CRIAR SEM CÓDIGO'),
                    ),
                    ButtonSegment(value: true, label: Text('GERAR PELO SIV')),
                  ],
                  selected: {_restantesGerarSiv},
                  onSelectionChanged: (selecionados) =>
                      setState(() => _restantesGerarSiv = selecionados.first),
                ),
              ],
            ),
          ),
        Row(
          children: [
            Text(
              '$bipados de $total bipados',
              style: textos.apoio.copyWith(color: cores.textoApoio),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: salvando
                  ? null
                  : () => setState(() => _etapa = _EtapaWizard.origem),
              child: const Text('Voltar'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: salvando
                  ? null
                  : () => setState(() => _etapa = _EtapaWizard.confirmacao),
              child: const Text('Revisar'),
            ),
          ],
        ),
      ],
    );
  }

  // Etapa 4: lista as combinações que serão criadas (cor/tamanho/estampa +
  // código bipado, ou o que vai acontecer com quem ficou sem código) antes
  // de disparar de vez -- pedido explícito do usuário, sem isso o clique em
  // "Criar N produtos" confirmava direto sem revisão nenhuma.
  Widget _buildEtapaConfirmacao(
    BuildContext context,
    AdicionarVariacoesState state,
  ) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final combinacoes = state.combinacoesNovas;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirme as combinações',
            style: textos.secao.copyWith(color: cores.acoAtivo, fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            '${combinacoes.length} produto(s) serão criados nesta referência.',
            style: textos.apoio.copyWith(color: cores.textoApoio),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: cores.hairline),
                borderRadius: BorderRadius.circular(SivDimensoes.raio),
              ),
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
                        Expanded(
                          flex: 2,
                          child: Text('COR', style: textos.rotulo),
                        ),
                        Expanded(child: Text('TAM.', style: textos.rotulo)),
                        Expanded(
                          flex: 2,
                          child: Text('ESTAMPA', style: textos.rotulo),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('CÓDIGO', style: textos.rotulo),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: cores.hairline),
                  Expanded(
                    child: ListView.separated(
                      itemCount: combinacoes.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: cores.hairline),
                      itemBuilder: (_, i) {
                        final c = combinacoes[i];
                        final chave = chaveComboGrade(
                          c.corId,
                          c.tamanhoId,
                          c.estampaId,
                        );
                        final codigoBipado = _codigosBipados[chave];
                        final String codigoExibido;
                        if (_origem == _OrigemCodigoBarras.siv) {
                          codigoExibido = 'Gerado pelo SIV';
                        } else if (codigoBipado != null) {
                          codigoExibido = codigoBipado;
                        } else if (_restantesGerarSiv) {
                          codigoExibido = 'Gerado pelo SIV';
                        } else {
                          codigoExibido = 'Sem código';
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _corDaGrade(c.corId),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        _nomeCor(state, c.corId),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Text(_nomeTamanho(state, c.tamanhoId)),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  c.estampaId == null
                                      ? '—'
                                      : _nomeEstampa(state, c.estampaId!),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  codigoExibido,
                                  style: TextStyle(
                                    color: codigoExibido == 'Sem código'
                                        ? cores.textoApoio
                                        : cores.textoPrincipal,
                                    fontStyle: codigoExibido == 'Sem código'
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildFooterConfirmacao(
    BuildContext context,
    AdicionarVariacoesState state,
  ) {
    final salvando = state.step == AdicionarVariacoesStep.salvando;
    final total = state.combinacoesNovas.length;

    return Row(
      children: [
        const Spacer(),
        OutlinedButton(
          onPressed: salvando
              ? null
              : () => setState(
                  () => _etapa = _origem == _OrigemCodigoBarras.siv
                      ? _EtapaWizard.origem
                      : _EtapaWizard.codigos,
                ),
          child: const Text('Voltar'),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: salvando ? null : _confirmarCriacao,
          child: Text(salvando ? 'Criando...' : 'Confirmar cadastro ($total)'),
        ),
      ],
    );
  }

  String _nomeEstampa(AdicionarVariacoesState state, int id) =>
      state.todasEstampas.firstWhere((e) => e.id == id).nome;

  void _confirmarCriacao() {
    if (_origem == _OrigemCodigoBarras.siv) {
      _bloc.add(AdicionarVariacoesConfirmou());
      return;
    }
    _bloc.add(
      AdicionarVariacoesConfirmou(
        codigosManuais: Map.of(_codigosBipados),
        gerarSivParaRestantes: _restantesGerarSiv,
      ),
    );
  }

  String _nomeCor(AdicionarVariacoesState state, int id) =>
      state.todasCores.firstWhere((c) => c.id == id).nome;

  String _nomeTamanho(AdicionarVariacoesState state, int id) =>
      state.todosTamanhos.firstWhere((t) => t.id == id).nome;

  // ponytail: paleta fixa duplicada de referencia_produtos_tab.dart pra
  // bolinha da cor -- Cor não carrega um valor de cor real (só id/nome).
  // Extrair pra lugar compartilhado se aparecer uma 3ª tela precisando disso.
  static const _kPaletaCoresBipagem = [
    Color(0xFF8E735B),
    Color(0xFF5980A6),
    Color(0xFF6B8F71),
    Color(0xFFB2555A),
    Color(0xFF9B7EDE),
    Color(0xFFC9A227),
    Color(0xFF4F6D7A),
    Color(0xFFD08159),
  ];

  Color _corDaGrade(int id) =>
      _kPaletaCoresBipagem[id % _kPaletaCoresBipagem.length];

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
