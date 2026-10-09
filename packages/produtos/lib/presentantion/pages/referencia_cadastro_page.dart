import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/widgets/adicionar_variacoes_painel.dart';
import 'package:produtos/presentation.dart';

/// Wizard de cadastro de referência, em página inteira: categoria ->
/// (subcategoria) -> nome -> preço -> variações. Retorna `true` se a
/// referência foi criada. Retorna o `int?` id da referência criada (null se
/// saiu sem criar); a referência já existe na API mesmo se sair antes de
/// concluir as variações.
class ReferenciaCadastroPage extends StatelessWidget {
  /// Pré-preenchimento opcional: nome e cores/tamanhos que já abrem
  /// selecionados no passo de variações.
  final String? nomeInicial;
  final List<int> corIdsIniciais;
  final List<int> tamanhoIdsIniciais;

  const ReferenciaCadastroPage({
    super.key,
    this.nomeInicial,
    this.corIdsIniciais = const [],
    this.tamanhoIdsIniciais = const [],
  });

  static Future<int?> show({
    required BuildContext context,
    String? nomeInicial,
    List<int> corIdsIniciais = const [],
    List<int> tamanhoIdsIniciais = const [],
  }) {
    return Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => ReferenciaCadastroPage(
          nomeInicial: nomeInicial,
          corIdsIniciais: corIdsIniciais,
          tamanhoIdsIniciais: tamanhoIdsIniciais,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReferenciaCadastroBloc>(
      create: (_) =>
          sl<ReferenciaCadastroBloc>()
            ..add(ReferenciaCadastroIniciou(nomeInicial: nomeInicial)),
      child: BlocBuilder<ReferenciaCadastroBloc, ReferenciaCadastroState>(
        builder: (context, state) {
          final largo = MediaQuery.of(context).size.width >= 900;
          return PopScope<int>(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) Navigator.of(context).pop(state.referenciaId);
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Cabecalho(state: state),
                    const Divider(height: 1),
                    _Stepper(state: state),
                    const Divider(height: 1),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _Corpo(
                              state: state,
                              corIds: corIdsIniciais,
                              tamanhoIds: tamanhoIdsIniciais,
                            )),
                          if (largo) ...[
                            const VerticalDivider(width: 1),
                            SizedBox(width: 300, child: _Resumo(state: state)),
                          ],
                        ],
                      ),
                    ),
                    if (state.mensagem != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(36, 8, 36, 0),
                        child: Text(
                          state.mensagem!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    _Rodape(state: state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

String _tituloEtapa(ReferenciaCadastroStep step) => switch (step) {
  ReferenciaCadastroStep.categoria => 'Categoria',
  ReferenciaCadastroStep.subCategoria => 'Subcategoria',
  ReferenciaCadastroStep.nome => 'Nome',
  ReferenciaCadastroStep.preco => 'Preço',
  ReferenciaCadastroStep.variacoes => 'Variações',
  ReferenciaCadastroStep.concluido => 'Concluído',
};

class _Cabecalho extends StatelessWidget {
  final ReferenciaCadastroState state;
  const _Cabecalho({required this.state});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).pop(state.referenciaId),
                  child: Text(
                    'Produtos / Referências /',
                    style: tema.bodyMedium?.copyWith(color: Colors.black54),
                  ),
                ),
                Text('Nova referência', style: tema.titleLarge),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Fechar',
            onPressed: () => Navigator.of(context).pop(state.referenciaId),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final ReferenciaCadastroState state;
  const _Stepper({required this.state});

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.primary;
    final etapas = state.etapas;
    final atual = etapas.indexOf(state.step);
    final concluido = state.step == ReferenciaCadastroStep.concluido;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
      child: Row(
        children: [
          for (var i = 0; i < etapas.length; i++) ...[
            if (i > 0)
              Container(
                width: 28,
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: Colors.black26,
              ),
            InkWell(
              onTap: i < atual
                  ? () => context.read<ReferenciaCadastroBloc>().add(
                      ReferenciaCadastroIrPara(etapas[i]),
                    )
                  : null,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: (i <= atual || concluido)
                        ? cor
                        : Colors.black12,
                    child: (i < atual || concluido)
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              color: i == atual ? Colors.white : Colors.black54,
                            ),
                          ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _tituloEtapa(etapas[i]),
                    style: TextStyle(
                      fontWeight: i == atual ? FontWeight.w600 : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Resumo extends StatelessWidget {
  final ReferenciaCadastroState state;
  const _Resumo({required this.state});

  @override
  Widget build(BuildContext context) {
    final linhas = <(String, String?, ReferenciaCadastroStep)>[
      ('CATEGORIA', state.categoria?.nome, ReferenciaCadastroStep.categoria),
      if (state.subCategorias.isNotEmpty)
        (
          'SUBCATEGORIA',
          state.subCategoria?.nome,
          ReferenciaCadastroStep.subCategoria,
        ),
      (
        'NOME',
        state.nome.trim().isEmpty ? null : state.nome.trim(),
        ReferenciaCadastroStep.nome,
      ),
      (
        'PREÇO',
        state.preco.isEmpty ? null : 'R\$ ${state.preco}',
        ReferenciaCadastroStep.preco,
      ),
    ];

    return Container(
      color: const Color(0xFFF5F5F8),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RESUMO',
            style: TextStyle(fontSize: 11, letterSpacing: 1.6),
          ),
          const SizedBox(height: 12),
          for (final (rotulo, valor, step) in linhas)
            InkWell(
              onTap: valor == null
                  ? null
                  : () => context.read<ReferenciaCadastroBloc>().add(
                      ReferenciaCadastroIrPara(step),
                    ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rotulo,
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.6,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      valor ?? '—',
                      style: TextStyle(
                        color: valor == null ? Colors.black38 : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Corpo extends StatelessWidget {
  final ReferenciaCadastroState state;
  final List<int> corIds;
  final List<int> tamanhoIds;
  const _Corpo({
    required this.state,
    this.corIds = const [],
    this.tamanhoIds = const [],
  });

  @override
  Widget build(BuildContext context) {
    if (state.carregandoCategorias || state.carregandoSubCategorias) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    return switch (state.step) {
      ReferenciaCadastroStep.categoria => _EscolhaStep<Categoria>(
        titulo: 'Qual é a categoria?',
        subtitulo: 'Clique para escolher — o assistente avança sozinho.',
        busca: 'Buscar categoria',
        itens: state.categorias,
        nome: (c) => c.nome,
        selecionado: state.categoria,
        onPick: (c) => context.read<ReferenciaCadastroBloc>().add(
          ReferenciaCadastroCategoriaSelecionada(categoria: c),
        ),
        cadastrarLabel: 'Cadastrar categoria',
        onCadastrar: () async {
          final bloc = context.read<ReferenciaCadastroBloc>();
          final salvou = await CategoriaModal.show(context: context);
          if (salvou == true) bloc.add(ReferenciaCadastroIniciou());
        },
      ),
      ReferenciaCadastroStep.subCategoria => _EscolhaStep<SubCategoria>(
        titulo: 'Qual a subcategoria de ${state.categoria?.nome}?',
        subtitulo:
            'NCM e peso vêm da subcategoria — dá para ajustar depois na referência.',
        busca: 'Buscar subcategoria',
        itens: state.subCategorias,
        nome: (c) => c.nome,
        selecionado: state.subCategoria,
        onPick: (c) => context.read<ReferenciaCadastroBloc>().add(
          ReferenciaCadastroSubCategoriaSelecionada(subCategoria: c),
        ),
        cadastrarLabel: 'Cadastrar subcategoria',
        onCadastrar: () async {
          final bloc = context.read<ReferenciaCadastroBloc>();
          final categoria = state.categoria;
          if (categoria?.id == null) return;
          final salvou = await showDialog<bool>(
            context: context,
            builder: (_) => SubCategoriaPage(categoriaId: categoria!.id!),
          );
          // Recarrega as subcategorias da categoria atual.
          if (salvou == true) {
            bloc.add(
              ReferenciaCadastroCategoriaSelecionada(categoria: categoria!),
            );
          }
        },
      ),
      ReferenciaCadastroStep.nome => _NomeStep(state: state),
      ReferenciaCadastroStep.preco => _CampoStep(
        key: const ValueKey('preco'),
        titulo: 'Qual o preço de venda?',
        subtitulo:
            'Vale para todas as variações, na tabela padrão. Outras tabelas se ajustam depois em Preços.',
        rotulo: 'PREÇO NA TABELA PADRÃO',
        prefixo: 'R\$ ',
        hint: '0,00',
        numerico: true,
        inicial: state.preco,
        onChanged: (v) => context.read<ReferenciaCadastroBloc>().add(
          ReferenciaCadastroPrecoAlterado(preco: v),
        ),
      ),
      ReferenciaCadastroStep.variacoes => AdicionarVariacoesPainel(
        key: ValueKey(state.referenciaId),
        referenciaId: state.referenciaId!,
        corIdsNaGrade: const {},
        tamanhoIdsNaGrade: const {},
        estampaIdsNaGrade: const {},
        chavesNaGrade: const {},
        coresSelecionadasIniciais: corIds.toSet(),
        tamanhosSelecionadosIniciais: tamanhoIds.toSet(),
        mobile: MediaQuery.sizeOf(context).width < 720,
        onConcluir: (_) => context.read<ReferenciaCadastroBloc>().add(
          ReferenciaCadastroVariacoesConcluidas(),
        ),
      ),
      ReferenciaCadastroStep.concluido => _Concluido(state: state),
    };
  }
}

class _EscolhaStep<T> extends StatefulWidget {
  final String titulo;
  final String subtitulo;
  final String busca;
  final List<T> itens;
  final String Function(T) nome;
  final T? selecionado;
  final ValueChanged<T> onPick;
  final String cadastrarLabel;
  final VoidCallback onCadastrar;

  const _EscolhaStep({
    required this.titulo,
    required this.subtitulo,
    required this.busca,
    required this.itens,
    required this.nome,
    required this.selecionado,
    required this.onPick,
    required this.cadastrarLabel,
    required this.onCadastrar,
  });

  @override
  State<_EscolhaStep<T>> createState() => _EscolhaStepState<T>();
}

class _EscolhaStepState<T> extends State<_EscolhaStep<T>> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final itens = widget.itens
        .where(
          (i) => widget.nome(i).toLowerCase().contains(_q.toLowerCase().trim()),
        )
        .toList();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.titulo, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(widget.subtitulo, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 16),
          Row(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SizedBox(
                  width: 420,
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: widget.busca,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _q = v),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: widget.onCadastrar,
                icon: const Icon(Icons.add),
                label: Text(widget.cadastrarLabel),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: itens.isEmpty
                ? const Center(child: Text('Nenhum item encontrado'))
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 260,
                          mainAxisExtent: 64,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: itens.length,
                    itemBuilder: (_, i) {
                      final item = itens[i];
                      final sel = item == widget.selecionado;
                      return InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () => widget.onPick(item),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: sel
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.black26,
                            ),
                          ),
                          child: Text(
                            widget.nome(item),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
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
}

/// Etapa de um único campo (nome / preço). Enter avança.
class _CampoStep extends StatefulWidget {
  final String titulo;
  final String subtitulo;
  final String rotulo;
  final String inicial;
  final String? prefixo;
  final String? hint;
  final bool numerico;
  final ValueChanged<String> onChanged;

  const _CampoStep({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.rotulo,
    required this.inicial,
    required this.onChanged,
    this.prefixo,
    this.hint,
    this.numerico = false,
  });

  @override
  State<_CampoStep> createState() => _CampoStepState();
}

class _CampoStepState extends State<_CampoStep> {
  late final _controller = TextEditingController(text: widget.inicial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.titulo, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(widget.subtitulo, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: widget.numerico
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : null,
              inputFormatters: [
                if (widget.numerico)
                  TextInputFormatter.withFunction(
                    (old, nw) =>
                        nw.text.isEmpty || regexValorDigitando.hasMatch(nw.text)
                        ? nw
                        : old,
                  ),
              ],
              textCapitalization: widget.numerico
                  ? TextCapitalization.none
                  : TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: widget.rotulo,
                prefixText: widget.prefixo,
                hintText: widget.hint,
                border: const OutlineInputBorder(),
              ),
              style: widget.numerico
                  ? Theme.of(context).textTheme.headlineMedium
                  : null,
              onChanged: widget.onChanged,
              onSubmitted: (_) => context.read<ReferenciaCadastroBloc>().add(
                ReferenciaCadastroProximo(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nome + sugestão aleatória + campos opcionais (unidade, descrição,
/// composição, cuidados). Controllers seguem o state (o gerador de nome
/// escreve no bloc).
class _NomeStep extends StatefulWidget {
  final ReferenciaCadastroState state;
  const _NomeStep({required this.state});

  @override
  State<_NomeStep> createState() => _NomeStepState();
}

class _NomeStepState extends State<_NomeStep> {
  late final _nome = TextEditingController(text: widget.state.nome);
  late final _unidade = TextEditingController(text: widget.state.unidadeMedida);
  late final _descricao = TextEditingController(text: widget.state.descricao);
  late final _composicao = TextEditingController(text: widget.state.composicao);
  late final _cuidados = TextEditingController(text: widget.state.cuidados);

  @override
  void dispose() {
    for (final c in [_nome, _unidade, _descricao, _composicao, _cuidados]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(_NomeStep old) {
    super.didUpdateWidget(old);
    if (_nome.text != widget.state.nome) _nome.text = widget.state.nome;
  }

  Widget _campo(
    String rotulo,
    TextEditingController c,
    ReferenciaCadastroOpcionaisAlterados Function(String) evento, {
    bool longo = false,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        minLines: longo ? 2 : 1,
        maxLines: longo ? 4 : 1,
        decoration: InputDecoration(
          labelText: rotulo,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        onChanged: (v) => context.read<ReferenciaCadastroBloc>().add(evento(v)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ReferenciaCadastroBloc>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Como vai se chamar?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Começamos com ${widget.state.subCategoria == null ? 'a categoria' : 'a subcategoria'}. Complete com modelo ou coleção.',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nome,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'NOME DA REFERÊNCIA',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) =>
                    bloc.add(ReferenciaCadastroNomeAlterado(nome: v)),
                onSubmitted: (_) => bloc.add(ReferenciaCadastroProximo()),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => bloc.add(ReferenciaCadastroGerarNome()),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Sugerir nome'),
              ),
              const SizedBox(height: 24),
              Text(
                'Informações opcionais',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              _campo(
                'Unidade de medida',
                _unidade,
                (v) => ReferenciaCadastroOpcionaisAlterados(unidadeMedida: v),
                hint: 'Ex: unidade, metro, kg',
              ),
              _campo(
                'Descrição',
                _descricao,
                (v) => ReferenciaCadastroOpcionaisAlterados(descricao: v),
                longo: true,
              ),
              _campo(
                'Composição',
                _composicao,
                (v) => ReferenciaCadastroOpcionaisAlterados(composicao: v),
                longo: true,
              ),
              _campo(
                'Cuidados',
                _cuidados,
                (v) => ReferenciaCadastroOpcionaisAlterados(cuidados: v),
                longo: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Concluido extends StatelessWidget {
  final ReferenciaCadastroState state;
  const _Concluido({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ReferenciaCadastroBloc>();
    final onde = state.subCategoria?.nome ?? state.categoria?.nome ?? '';
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const CircleAvatar(radius: 26, child: Icon(Icons.check, size: 28)),
          const SizedBox(height: 16),
          Text(
            '${state.nome.trim()} criada',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton(
                onPressed: () => bloc.add(
                  const ReferenciaCadastroReiniciar(manterCategoria: true),
                ),
                child: Text('CADASTRAR OUTRA EM ${onde.toUpperCase()}'),
              ),
              OutlinedButton(
                onPressed: () => bloc.add(const ReferenciaCadastroReiniciar()),
                child: const Text('Outra categoria'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Fechar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Rodape extends StatelessWidget {
  final ReferenciaCadastroState state;
  const _Rodape({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ReferenciaCadastroBloc>();
    final step = state.step;
    final temRodape =
        step == ReferenciaCadastroStep.subCategoria ||
        step == ReferenciaCadastroStep.nome ||
        step == ReferenciaCadastroStep.preco;
    if (!temRodape) return const SizedBox.shrink();

    final avanca = step != ReferenciaCadastroStep.subCategoria;
    final podeVoltar = !state.criada;
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
      child: Row(
        children: [
          if (podeVoltar)
            TextButton(
              onPressed: () => bloc.add(ReferenciaCadastroVoltar()),
              child: const Text('‹ Voltar'),
            ),
          const Spacer(),
          if (avanca)
            FilledButton(
              onPressed: state.salvando
                  ? null
                  : () => bloc.add(ReferenciaCadastroProximo()),
              child: state.salvando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      step == ReferenciaCadastroStep.preco
                          ? 'Criar e escolher variações'
                          : 'Continuar',
                    ),
            ),
        ],
      ),
    );
  }
}
