import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:comercial/presentation/widgets/lista_textos.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

enum ListasAba { catalogo, provador, grupos, vitrine }

class ListasPersonalizadasPage extends StatefulWidget {
  final ListasAba abaInicial;
  final int? ecommerceIdInicial;

  /// Permissão por componente; injetável para teste.
  final bool Function(String idComponente) temAcesso;

  const ListasPersonalizadasPage({
    super.key,
    this.abaInicial = ListasAba.catalogo,
    this.ecommerceIdInicial,
    this.temAcesso = PermissaoPorNome.acessoPermitido,
  });

  @override
  State<ListasPersonalizadasPage> createState() =>
      _ListasPersonalizadasPageState();
}

class _ListasPersonalizadasPageState extends State<ListasPersonalizadasPage>
    with SingleTickerProviderStateMixin {
  late final ListasPersonalizadasBloc _bloc;
  EcommerceVitrineBloc? _vitrineBloc;
  EcommercesBloc? _ecommercesBloc;
  late final TabController _tabs;
  late final List<ListasAba> _abas;
  final _scrollController = ScrollController();
  int? _canalId;

  @override
  void initState() {
    super.initState();
    final listas = widget.temAcesso('ECOFM004');
    _abas = [
      if (listas) ...[ListasAba.catalogo, ListasAba.provador, ListasAba.grupos],
      if (widget.temAcesso('ECOFM001')) ListasAba.vitrine,
    ];
    final inicial = _abas.indexOf(widget.abaInicial);
    _tabs = TabController(
      length: _abas.length,
      vsync: this,
      initialIndex: inicial < 0 ? 0 : inicial,
    )..addListener(_aoTrocarAba);

    _bloc = sl<ListasPersonalizadasBloc>();
    if (_abas.contains(ListasAba.vitrine)) {
      _vitrineBloc = sl<EcommerceVitrineBloc>();
      _ecommercesBloc = sl<EcommercesBloc>()
        ..add(const EcommercesCarregarSolicitado());
    }
    if (listas) _bloc.add(ListasPersonalizadasIniciou(tipo: _tipoDaAba));
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _bloc.add(ListasPersonalizadasCarregarMaisSolicitado());
      }
    });
  }

  ListasAba get _aba => _abas.isEmpty ? ListasAba.catalogo : _abas[_tabs.index];

  ListaTipo get _tipoDaAba =>
      _aba == ListasAba.provador ? ListaTipo.provador : ListaTipo.catalogo;

  void _aoTrocarAba() {
    if (_tabs.indexIsChanging) return;
    if (_aba == ListasAba.catalogo || _aba == ListasAba.provador) {
      _bloc.add(ListasPersonalizadasIniciou(tipo: _tipoDaAba));
    }
    setState(() {});
  }

  void _canaisCarregados(EcommercesState state) {
    if (state.status != EcommercesStatus.carregado || _canalId != null) return;
    final ids = state.ecommerces.map((e) => e.id).whereType<int>().toList();
    if (ids.isEmpty) return;
    _selecionarCanal(
      ids.contains(widget.ecommerceIdInicial)
          ? widget.ecommerceIdInicial!
          : ids.first,
    );
  }

  void _selecionarCanal(int id) {
    setState(() => _canalId = id);
    _vitrineBloc!.add(EcommerceVitrineIniciou(ecommerceId: id));
  }

  @override
  void dispose() {
    _tabs.dispose();
    _scrollController.dispose();
    _bloc.close();
    _vitrineBloc?.close();
    _ecommercesBloc?.close();
    super.dispose();
  }

  Future<void> _abrirNovaLista() async {
    await Navigator.pushNamed(context, '/lista_personalizada');
    if (mounted) _bloc.add(ListasPersonalizadasIniciou(tipo: _bloc.state.tipo));
  }

  Future<void> _abrirLista(int id) async {
    await Navigator.pushNamed(context, '/lista_personalizada',
        arguments: {'id': id});
    if (mounted) _bloc.add(ListasPersonalizadasIniciou(tipo: _bloc.state.tipo));
  }

  void _irParaVitrine() {
    final i = _abas.indexOf(ListasAba.vitrine);
    if (i >= 0) _tabs.animateTo(i);
  }

  static const _rotulos = {
    ListasAba.catalogo: 'Catálogo',
    ListasAba.provador: 'Provador',
    ListasAba.grupos: 'Grupos',
    ListasAba.vitrine: 'Vitrine do site',
  };

  /// Contador ao lado do rótulo. Só o que já foi carregado tem número.
  int? _contador(ListasAba aba) {
    switch (aba) {
      case ListasAba.catalogo:
      case ListasAba.provador:
        final tipo =
            aba == ListasAba.provador ? ListaTipo.provador : ListaTipo.catalogo;
        final s = _bloc.state;
        return s.tipo == tipo && s.totalItens > 0 ? s.totalItens : null;
      case ListasAba.grupos:
        final g = _vitrineBloc?.state.grupos.length ?? 0;
        return g > 0 ? g : null;
      case ListasAba.vitrine:
        return null;
    }
  }

  Widget _abaComContador(BuildContext context, ListasAba aba) {
    final n = _contador(aba);
    final cores = context.sivColors;
    return Tab(
      height: 48,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_rotulos[aba]!),
          if (n != null) ...[
            const SizedBox(width: 6),
            Text(
              '$n',
              style: context.sivTextos.apoio.copyWith(
                fontSize: 11.5,
                color: cores.tinta.withValues(alpha: 0.45),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final mostrarNovaLista =
        _aba == ListasAba.catalogo || _aba == ListasAba.provador;
    final vitrineAberta = _aba == ListasAba.vitrine;
    final canais = _ecommercesBloc?.state.ecommerces
            .where((c) => c.id != null)
            .toList() ??
        const [];

    Widget scaffold = Scaffold(
      floatingActionButton: mostrarNovaLista
          ? FloatingActionButton.extended(
              onPressed: _abrirNovaLista,
              icon: const Icon(SivIcones.adicionar,
                  size: SivIcones.tamanhoBotao),
              label: const Text('NOVA LISTA'),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: SivDimensoes.alturaBarraTitulo,
            padding: const EdgeInsets.symmetric(
              horizontal: SivDimensoes.paddingBarraTituloHorizontal,
            ),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Expanded(
                  child: Text('Listas do e-commerce',
                      style: context.sivTextos.secao, maxLines: 1),
                ),
                // No mobile quem desenha é a barra de ferramentas da aba.
                if (vitrineAberta &&
                    canais.isNotEmpty &&
                    _canalId != null &&
                    !mobile)
                  SeletorDeCanalVitrine(
                    canais: canais,
                    canalId: _canalId!,
                    onCanal: _selecionarCanal,
                  ),
              ],
            ),
          ),
          if (_abas.length > 1)
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: cores.superficie,
                border: Border(bottom: BorderSide(color: cores.hairline)),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: SivDimensoes.paddingBarraTituloHorizontal,
              ),
              child: TabBar(
                key: const Key('listas-abas'),
                controller: _tabs,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [for (final a in _abas) _abaComContador(context, a)],
              ),
            ),
          Expanded(child: _corpoDaAba(context)),
        ],
      ),
    );

    scaffold = BlocProvider<ListasPersonalizadasBloc>.value(
        value: _bloc, child: scaffold);
    final vitrine = _vitrineBloc;
    if (vitrine == null) return scaffold;
    return MultiBlocProvider(
      providers: [
        BlocProvider<EcommerceVitrineBloc>.value(value: vitrine),
        BlocProvider<EcommercesBloc>.value(value: _ecommercesBloc!),
      ],
      child: BlocListener<EcommercesBloc, EcommercesState>(
        listener: (_, state) => _canaisCarregados(state),
        child: BlocBuilder<EcommerceVitrineBloc, EcommerceVitrineState>(
          buildWhen: (a, b) =>
              (a.alteracoesPendentes > 0) != (b.alteracoesPendentes > 0),
          builder: (context, state) => PopScope(
            canPop: state.alteracoesPendentes == 0,
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop) return;
              final nav = Navigator.of(context);
              if (await confirmarSairSemPublicar(
                  context, state.alteracoesPendentes)) {
                nav.pop();
              }
            },
            child: scaffold,
          ),
        ),
      ),
    );
  }

  bool get mobile =>
      MediaQuery.sizeOf(context).width < SivDimensoes.breakpointMenuDrawer;

  Widget _corpoDaAba(BuildContext context) {
    switch (_aba) {
      case ListasAba.grupos:
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SivDimensoes.paginaHorizontal,
            vertical: 16,
          ),
          child: const GruposAba(),
        );
      case ListasAba.vitrine:
        return BlocBuilder<EcommercesBloc, EcommercesState>(
          builder: (context, state) => VitrineAba(
            canais: state.ecommerces,
            canalId: _canalId,
            // No desktop o seletor fica na barra de título.
            mostrarSeletorDeCanal: mobile,
            onCanalChanged: _selecionarCanal,
          ),
        );
      case ListasAba.catalogo:
      case ListasAba.provador:
        return BlocBuilder<ListasPersonalizadasBloc, ListasPersonalizadasState>(
          builder: (context, state) => Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SivDimensoes.paginaHorizontal,
              vertical: 16,
            ),
            child: _buildConteudo(context, state),
          ),
        );
    }
  }

  Widget _buildConteudo(BuildContext context, ListasPersonalizadasState state) {
    final textos = context.sivTextos;

    if (state.step == ListasPersonalizadasStep.carregando) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (state.step == ListasPersonalizadasStep.falha && state.itens.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.erro ?? 'Falha ao carregar as listas.',
                style: textos.corpo),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
              onPressed: () =>
                  _bloc.add(ListasPersonalizadasIniciou(tipo: state.tipo)),
            ),
          ],
        ),
      );
    }
    if (state.itens.isEmpty) {
      return Center(
        child: Text('Nenhuma lista personalizada criada ainda.',
            style: textos.apoio),
      );
    }

    final exibirLoaderFinal =
        state.step == ListasPersonalizadasStep.carregandoMais;

    return ListView.separated(
      controller: _scrollController,
      itemCount: state.itens.length + (exibirLoaderFinal ? 2 : 1),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'Vitrines do site. Aparecem no menu ou na home, direto ou dentro de um grupo.',
              style: textos.apoio,
            ),
          );
        }
        final index = i - 1;
        if (index >= state.itens.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
                child: CircularProgressIndicator.adaptive(strokeWidth: 2.5)),
          );
        }
        final lista = state.itens[index];
        final vitrineBloc = _vitrineBloc;
        if (vitrineBloc == null || lista.tipo != ListaTipo.catalogo) {
          return _card(lista, null);
        }
        return BlocBuilder<EcommerceVitrineBloc, EcommerceVitrineState>(
          bloc: vitrineBloc,
          buildWhen: (a, b) =>
              a.publicada != b.publicada ||
              a.grupos != b.grupos ||
              a.step != b.step,
          builder: (context, v) =>
              _card(lista, v.step == EcommerceVitrineStep.pronto ? v : null),
        );
      },
    );
  }

  /// [vitrine] só vem preenchido para catálogo com a vitrine do canal carregada.
  Widget _card(ListaPersonalizadaResumo lista, EcommerceVitrineState? vitrine) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    final onde = vitrine?.ondeAparece(lista.id) ?? const <String>[];
    final foraDoSite = vitrine != null && onde.isEmpty;
    final linha = linhaDoCard(lista);
    final expirada = lista.situacao == ListaPersonalizadaSituacao.expirada;
    final apoio = textos.apoio.copyWith(fontSize: 12);

    return Opacity(
      opacity: expirada ? 0.55 : 1,
      child: InkWell(
        onTap: () => _abrirLista(lista.id),
        child: SivMolduraBlueprint(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SivMiniatura(url: lista.icone, largura: 44, altura: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            nomeDaLista(lista),
                            style: textos.secao.copyWith(fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SivEtiqueta(
                          situacao: _etiquetaSituacao(lista.situacao),
                          texto: situacaoTexto(lista.situacao),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          lista.modo == ListaModo.filtro
                              ? SivIcones.porRegras
                              : SivIcones.lista,
                          size: 13,
                          color: cores.acoProfundo,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                              style: apoio,
                              children: [
                                TextSpan(text: linha.modo),
                                if (linha.contagem != null) ...[
                                  const TextSpan(text: ' · '),
                                  TextSpan(
                                    text: linha.contagem,
                                    style: apoio.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: cores.tinta,
                                    ),
                                  ),
                                ],
                                if (linha.periodo != null)
                                  TextSpan(text: ' · ${linha.periodo}'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (onde.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          onde.join(' · '),
                          style: apoio.copyWith(color: cores.acoProfundo),
                        ),
                      ),
                    if (foraDoSite)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: InkWell(
                          key: Key('lista-fora-do-site-${lista.id}'),
                          onTap: _irParaVitrine,
                          child: const SivAvisoAtencao('Não está no site'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SivEtiquetaSituacao _etiquetaSituacao(ListaPersonalizadaSituacao situacao) =>
      switch (situacao) {
        ListaPersonalizadaSituacao.ativa => SivEtiquetaSituacao.emAndamento,
        ListaPersonalizadaSituacao.agendada => SivEtiquetaSituacao.conferido,
        ListaPersonalizadaSituacao.cancelada => SivEtiquetaSituacao.cancelado,
        ListaPersonalizadaSituacao.expirada => SivEtiquetaSituacao.cancelado,
      };
}
