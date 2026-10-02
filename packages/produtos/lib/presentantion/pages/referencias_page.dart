import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart' show sivCantosBlueprint;
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:produtos/domain/referencias_filtro.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';
import 'package:produtos/use_cases.dart';

// Abaixo disso a tabela de 8 colunas não cabe: a linha vira um cartão compacto.
const _larguraTabela = 900.0;

class ReferenciasPage extends StatefulWidget {
  const ReferenciasPage({super.key});

  @override
  State<ReferenciasPage> createState() => _ReferenciasPageState();
}

class _ReferenciasPageState extends State<ReferenciasPage> {
  final bloc = sl<ReferenciasBloc>();
  final _buscaController = TextEditingController();
  ReferenciasFiltro _filtro = const ReferenciasFiltro();
  Map<int, String> _marcas = const {};

  @override
  void initState() {
    super.initState();
    _carregarMarcas();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  // A referência só traz o marcaId; o nome vem do cadastro de marcas. Sem ele a coluna
  // mostra "—" em vez de derrubar a lista.
  Future<void> _carregarMarcas() async {
    try {
      final marcas = await sl<RecuperarMarcas>().call();
      if (!mounted) return;
      setState(() {
        _marcas = {
          for (final m in marcas)
            if (m.id != null) m.id!: m.nome,
        };
      });
    } catch (_) {}
  }

  void _limpar() {
    _buscaController.clear();
    setState(() => _filtro = const ReferenciasFiltro());
  }

  void _limparBusca() {
    _buscaController.clear();
    setState(() => _filtro = _filtro.copyWith(busca: ''));
  }

  Future<void> _abrir(Referencia referencia) async {
    final id = referencia.id;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Referência sem ID válido.')),
      );
      return;
    }
    await Navigator.of(context).push<Referencia>(
      MaterialPageRoute(builder: (_) => ReferenciaPage(idReferencia: id)),
    );
    bloc.add(ReferenciasIniciou(ordenacao: bloc.state.ordenacao));
  }

  Future<void> _novaReferencia() async {
    await ReferenciaCadastroModal.show(context: context);
    bloc.add(ReferenciasIniciou(ordenacao: bloc.state.ordenacao));
  }

  Future<void> _abrirOrdenacao(ReferenciasOrdenacao atual) async {
    final escolha = await showModalBottomSheet<(bool, ReferenciasOrdenacao?)>(
      context: context,
      backgroundColor: context.sivColors.superficie,
      showDragHandle: false,
      builder: (_) => _FolhaOpcoes<ReferenciasOrdenacao>(
        titulo: 'Ordenar por',
        selecionado: atual,
        opcoes: [
          for (final o in ReferenciasOrdenacao.values)
            _Opcao(valor: o, rotulo: _labelOrdenacao(o)),
        ],
      ),
    );
    final nova = escolha?.$2;
    if (nova != null) bloc.add(ReferenciasIniciou(ordenacao: nova));
  }

  Future<void> _abrirCategorias(List<Referencia> todas) async {
    final contagens = _filtro.contarPorCategoria(todas);
    final escolha = await showModalBottomSheet<(bool, int?)>(
      context: context,
      backgroundColor: context.sivColors.superficie,
      isScrollControlled: true,
      builder: (_) => _FolhaOpcoes<int>(
        titulo: 'Categoria',
        selecionado: _filtro.categoriaId,
        podeLimpar: _filtro.categoriaId != null,
        opcoes: [
          for (final c in ReferenciasFiltro.categoriasDe(todas))
            _Opcao(valor: c.id, rotulo: c.nome, contagem: contagens[c.id] ?? 0),
        ],
      ),
    );
    if (escolha == null) return;
    setState(
      () => _filtro = _filtro.copyWith(
        categoriaId: escolha.$1 ? null : escolha.$2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estreito = MediaQuery.sizeOf(context).width < _larguraTabela;
    return BlocProvider<ReferenciasBloc>(
      create: (context) => bloc..add(ReferenciasIniciou()),
      child: Scaffold(
        floatingActionButton: estreito
            ? FloatingActionButton.extended(
                onPressed: _novaReferencia,
                icon: const Icon(Icons.add),
                label: const Text('Nova referência'),
              )
            : FloatingActionButton(
                onPressed: _novaReferencia,
                child: const Icon(Icons.add),
              ),
        appBar: AppBar(title: const Text('Referências')),
        body: SafeArea(
          child: BlocBuilder<ReferenciasBloc, ReferenciasState>(
            builder: (context, state) {
              final todas = state is ReferenciasCarregarSucesso
                  ? state.referencias
                  : const <Referencia>[];
              return LayoutBuilder(
                builder: (context, constraints) =>
                    constraints.maxWidth >= _larguraTabela
                    ? _layoutDesktop(context, state, todas)
                    : _layoutMobile(context, state, todas),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _layoutDesktop(
    BuildContext context,
    ReferenciasState state,
    List<Referencia> todas,
  ) {
    final exibidas = _filtro.aplicar(todas);
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 22, 30, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _CampoBusca(
                  controller: _buscaController,
                  hint: 'Buscar por nome ou nº da referência',
                  altura: 40,
                  onBusca: (v) =>
                      setState(() => _filtro = _filtro.copyWith(busca: v)),
                  onLimpar: _limparBusca,
                ),
              ),
              const SizedBox(width: 10),
              _BotaoOrdenacao(
                ordenacao: state.ordenacao,
                onOrdenar: (o) => bloc.add(ReferenciasIniciou(ordenacao: o)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _LinhaFiltros(
            filtro: _filtro,
            todas: todas,
            onFiltro: (f) => setState(() => _filtro = f),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _Quadro(
              estado: state,
              onTentarNovamente: () =>
                  bloc.add(ReferenciasIniciou(ordenacao: state.ordenacao)),
              emTabela: true,
              exibidas: exibidas,
              marcas: _marcas,
              onAbrir: _abrir,
              onLimpar: _limpar,
            ),
          ),
          const SizedBox(height: 12),
          _Rodape(
            total: todas.length,
            exibidas: exibidas.length,
            filtrando: _filtro.ativo,
          ),
        ],
      ),
    );
  }

  Widget _layoutMobile(
    BuildContext context,
    ReferenciasState state,
    List<Referencia> todas,
  ) {
    final exibidas = _filtro.aplicar(todas);
    return Column(
      children: [
        _TopoMobile(
          controller: _buscaController,
          filtro: _filtro,
          todas: todas,
          ordenacao: state.ordenacao,
          rotuloContagem: _rotuloContagem(
            todas.length,
            exibidas.length,
            _filtro.ativo,
          ),
          onBusca: (v) => setState(() => _filtro = _filtro.copyWith(busca: v)),
          onLimparBusca: _limparBusca,
          onFiltro: (f) => setState(() => _filtro = f),
          onCategorias: () => _abrirCategorias(todas),
          onOrdenar: () => _abrirOrdenacao(state.ordenacao),
        ),
        Expanded(
          child: _Quadro(
            estado: state,
            onTentarNovamente: () =>
                bloc.add(ReferenciasIniciou(ordenacao: state.ordenacao)),
            emTabela: false,
            exibidas: exibidas,
            marcas: _marcas,
            onAbrir: _abrir,
            onLimpar: _limpar,
          ),
        ),
      ],
    );
  }
}

/// Carregando / erro / vazio / lista, em tabela (desktop) ou em linhas (mobile).
class _Quadro extends StatelessWidget {
  final ReferenciasState estado;
  final VoidCallback onTentarNovamente;
  final bool emTabela;
  final List<Referencia> exibidas;
  final Map<int, String> marcas;
  final ValueChanged<Referencia> onAbrir;
  final VoidCallback onLimpar;

  const _Quadro({
    required this.estado,
    required this.onTentarNovamente,
    required this.emTabela,
    required this.exibidas,
    required this.marcas,
    required this.onAbrir,
    required this.onLimpar,
  });

  @override
  Widget build(BuildContext context) {
    final estado = this.estado;
    if (estado is ReferenciasCarregarEmProgresso) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (estado is ReferenciasCarregarFalha) {
      return _Erro(onTentarNovamente: onTentarNovamente);
    }
    if (estado is! ReferenciasCarregarSucesso) return const SizedBox();

    final cores = context.sivColors;
    final lista = exibidas.isEmpty
        ? _Vazio(onLimpar: onLimpar)
        : Material(
            color: Colors.transparent,
            child: ListView.builder(
              // folga para o botão "Nova referência" não cobrir a última linha
              padding: EdgeInsets.only(bottom: emTabela ? 0 : 84),
              itemCount: exibidas.length,
              itemBuilder: (context, i) {
                final r = exibidas[i];
                return emTabela
                    ? _LinhaTabela(
                        referencia: r,
                        marca: marcas[r.marcaId],
                        onTap: () => onAbrir(r),
                      )
                    : _LinhaCompacta(
                        referencia: r,
                        marca: marcas[r.marcaId],
                        onTap: () => onAbrir(r),
                      );
              },
            ),
          );

    if (!emTabela) return lista;
    return Container(
      decoration: BoxDecoration(
        color: cores.superficie,
        border: Border.all(color: cores.hairline),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              const _CabecalhoTabela(),
              Expanded(child: lista),
            ],
          ),
          ...sivCantosBlueprint(cores.aco),
        ],
      ),
    );
  }
}

String _rotuloContagem(int total, int exibidas, bool filtrando) {
  String plural(int n) => n == 1 ? '1 referência' : '$n referências';
  return filtrando ? '$exibidas de ${plural(total)}' : plural(total);
}

// ---------------------------------------------------------------------------
// Busca + ordenação
// ---------------------------------------------------------------------------

String _labelOrdenacao(ReferenciasOrdenacao o) => switch (o) {
  ReferenciasOrdenacao.nomeAsc => 'Nome (A-Z)',
  ReferenciasOrdenacao.nomeDesc => 'Nome (Z-A)',
  ReferenciasOrdenacao.criadoEmAsc => 'Criado em (mais antigo)',
  ReferenciasOrdenacao.criadoEmDesc => 'Criado em (mais recente)',
  ReferenciasOrdenacao.atualizadoEmAsc => 'Atualizado em (mais antigo)',
  ReferenciasOrdenacao.atualizadoEmDesc => 'Atualizado em (mais recente)',
};

/// Versão curta para o link de ordenação do mobile.
String _labelCurto(ReferenciasOrdenacao o) => switch (o) {
  ReferenciasOrdenacao.nomeAsc => 'Nome A-Z',
  ReferenciasOrdenacao.nomeDesc => 'Nome Z-A',
  ReferenciasOrdenacao.criadoEmAsc => 'Criadas há mais tempo',
  ReferenciasOrdenacao.criadoEmDesc => 'Criadas recentemente',
  ReferenciasOrdenacao.atualizadoEmAsc => 'Atualizadas há mais tempo',
  ReferenciasOrdenacao.atualizadoEmDesc => 'Atualizadas recentemente',
};

BoxDecoration _caixa(SivColors cores) => BoxDecoration(
  color: cores.superficie,
  borderRadius: BorderRadius.circular(SivDimensoes.raio),
  border: Border.all(color: cores.tinta.withValues(alpha: 0.18)),
);

class _CampoBusca extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final double altura;
  final ValueChanged<String> onBusca;
  final VoidCallback onLimpar;

  const _CampoBusca({
    required this.controller,
    required this.hint,
    required this.altura,
    required this.onBusca,
    required this.onLimpar,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final fonte = altura >= 44 ? 15.0 : 14.0;
    return Container(
      height: altura,
      padding: EdgeInsets.symmetric(horizontal: altura >= 44 ? 12 : 14),
      decoration: _caixa(cores),
      child: Row(
        children: [
          Icon(Icons.search, size: 18, color: cores.textoApoio),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onBusca,
              style: textos.corpo.copyWith(fontSize: fonte),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: hint,
                hintStyle: textos.corpo.copyWith(
                  fontSize: fonte,
                  color: cores.textoApoio,
                ),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, valor, _) => valor.text.isEmpty
                ? const SizedBox.shrink()
                : InkWell(
                    onTap: onLimpar,
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: cores.textoApoio,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _BotaoOrdenacao extends StatelessWidget {
  final ReferenciasOrdenacao ordenacao;
  final ValueChanged<ReferenciasOrdenacao> onOrdenar;

  const _BotaoOrdenacao({required this.ordenacao, required this.onOrdenar});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return PopupMenuButton<ReferenciasOrdenacao>(
      tooltip: 'Ordenar referências',
      offset: const Offset(0, 46),
      constraints: const BoxConstraints(minWidth: 250),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
        side: BorderSide(color: cores.tinta.withValues(alpha: 0.16)),
      ),
      color: cores.superficie,
      onSelected: onOrdenar,
      itemBuilder: (context) => [
        for (final o in ReferenciasOrdenacao.values)
          PopupMenuItem<ReferenciasOrdenacao>(
            value: o,
            height: 38,
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  child: ordenacao == o
                      ? Icon(Icons.check, size: 14, color: cores.aco)
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  _labelOrdenacao(o),
                  style: textos.corpo.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: _caixa(cores),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort, size: 16),
            const SizedBox(width: 8),
            Text(
              _labelOrdenacao(ordenacao),
              style: textos.corpo.copyWith(fontSize: 13.5),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down, size: 16),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile: topo (busca, chips que rolam, contagem + ordenar) e folhas inferiores
// ---------------------------------------------------------------------------

class _TopoMobile extends StatelessWidget {
  final TextEditingController controller;
  final ReferenciasFiltro filtro;
  final List<Referencia> todas;
  final ReferenciasOrdenacao ordenacao;
  final String rotuloContagem;
  final ValueChanged<String> onBusca;
  final VoidCallback onLimparBusca;
  final ValueChanged<ReferenciasFiltro> onFiltro;
  final VoidCallback onCategorias;
  final VoidCallback onOrdenar;

  const _TopoMobile({
    required this.controller,
    required this.filtro,
    required this.todas,
    required this.ordenacao,
    required this.rotuloContagem,
    required this.onBusca,
    required this.onLimparBusca,
    required this.onFiltro,
    required this.onCategorias,
    required this.onOrdenar,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final pendencias = filtro.contar(todas);
    final apoio = textos.corpo.copyWith(
      fontSize: 12.5,
      color: cores.textoApoio,
    );
    final nomeCategoria = ReferenciasFiltro.categoriasDe(
      todas,
    ).where((c) => c.id == filtro.categoriaId).map((c) => c.nome).firstOrNull;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: cores.superficie,
        border: Border(
          bottom: BorderSide(color: cores.tinta.withValues(alpha: 0.09)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CampoBusca(
            controller: controller,
            hint: 'Nome ou nº da referência',
            altura: 44,
            onBusca: onBusca,
            onLimpar: onLimparBusca,
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _Chip(
                  rotulo: nomeCategoria ?? 'Categoria',
                  selecionado: filtro.categoriaId != null,
                  icone: Icons.keyboard_arrow_down,
                  altura: 36,
                  onTap: onCategorias,
                ),
                Container(
                  width: 1,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: cores.tinta.withValues(alpha: 0.16),
                ),
                _Chip(
                  rotulo: 'Sem NCM',
                  contagem: pendencias.semNcm,
                  selecionado: filtro.semNcm,
                  altura: 36,
                  onTap: () =>
                      onFiltro(filtro.copyWith(semNcm: !filtro.semNcm)),
                ),
                const SizedBox(width: 6),
                _Chip(
                  rotulo: 'Sem peso',
                  contagem: pendencias.semPeso,
                  selecionado: filtro.semPeso,
                  altura: 36,
                  onTap: () =>
                      onFiltro(filtro.copyWith(semPeso: !filtro.semPeso)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(rotuloContagem, style: apoio)),
              InkWell(
                onTap: onOrdenar,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 32),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sort, size: 16, color: cores.acoEscuro),
                      const SizedBox(width: 6),
                      Text(
                        _labelCurto(ordenacao),
                        style: textos.corpo.copyWith(
                          fontSize: 12.5,
                          color: cores.acoEscuro,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Opcao<T> {
  final T valor;
  final String rotulo;
  final int? contagem;

  const _Opcao({required this.valor, required this.rotulo, this.contagem});
}

/// Folha inferior de escolha única (ordenação e categoria). Fecha devolvendo
/// `(limpou, valor)`: "Limpar" devolve `(true, null)`.
class _FolhaOpcoes<T> extends StatelessWidget {
  final String titulo;
  final T? selecionado;
  final bool podeLimpar;
  final List<_Opcao<T>> opcoes;

  const _FolhaOpcoes({
    required this.titulo,
    required this.opcoes,
    this.selecionado,
    this.podeLimpar = false,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: cores.tinta.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(titulo, style: textos.secao),
                  if (podeLimpar)
                    InkWell(
                      onTap: () => Navigator.of(context).pop((true, null)),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 44),
                        child: Center(
                          child: Text(
                            'Limpar',
                            style: textos.corpo.copyWith(
                              fontSize: 14,
                              color: cores.acoEscuro,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final o in opcoes)
                      InkWell(
                        onTap: () =>
                            Navigator.of(context).pop((false, o.valor)),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 48),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Row(
                            children: [
                              _Radio(marcado: o.valor == selecionado),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  o.rotulo,
                                  style: textos.corpo.copyWith(fontSize: 15),
                                ),
                              ),
                              if (o.contagem != null)
                                Text(
                                  '${o.contagem}',
                                  style: textos.corpo.copyWith(
                                    fontSize: 13,
                                    color: cores.textoApoio,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  final bool marcado;

  const _Radio({required this.marcado});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: marcado ? cores.aco : cores.tinta.withValues(alpha: 0.3),
          width: marcado ? 2 : 1.5,
        ),
      ),
      child: marcado
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cores.aco,
              ),
            )
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Chips de categoria e pendências
// ---------------------------------------------------------------------------

class _LinhaFiltros extends StatelessWidget {
  final ReferenciasFiltro filtro;
  final List<Referencia> todas;
  final ValueChanged<ReferenciasFiltro> onFiltro;

  const _LinhaFiltros({
    required this.filtro,
    required this.todas,
    required this.onFiltro,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final categorias = ReferenciasFiltro.categoriasDe(todas);
    final pendencias = filtro.contar(todas);
    final rotulo = textos.rotulo.copyWith(color: cores.textoApoio);

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Text('CATEGORIA', style: rotulo),
        ),
        _Chip(
          rotulo: 'Todas',
          selecionado: filtro.categoriaId == null,
          onTap: () => onFiltro(filtro.copyWith(categoriaId: null)),
        ),
        for (final c in categorias)
          _Chip(
            rotulo: c.nome,
            selecionado: filtro.categoriaId == c.id,
            onTap: () => onFiltro(
              filtro.copyWith(
                categoriaId: filtro.categoriaId == c.id ? null : c.id,
              ),
            ),
          ),
        Container(
          width: 1,
          height: 20,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          color: cores.tinta.withValues(alpha: 0.16),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Text('PENDÊNCIAS', style: rotulo),
        ),
        _Chip(
          rotulo: 'Sem NCM',
          contagem: pendencias.semNcm,
          selecionado: filtro.semNcm,
          onTap: () => onFiltro(filtro.copyWith(semNcm: !filtro.semNcm)),
        ),
        _Chip(
          rotulo: 'Sem peso',
          contagem: pendencias.semPeso,
          selecionado: filtro.semPeso,
          onTap: () => onFiltro(filtro.copyWith(semPeso: !filtro.semPeso)),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String rotulo;
  final int? contagem;
  final bool selecionado;
  final VoidCallback onTap;
  final IconData? icone;
  final double altura;

  const _Chip({
    required this.rotulo,
    required this.selecionado,
    required this.onTap,
    this.contagem,
    this.icone,
    this.altura = 32,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final texto = selecionado ? Colors.white : cores.tinta;

    return Material(
      color: selecionado ? cores.acoEscuro : cores.superficie,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
        side: BorderSide(
          color: selecionado
              ? cores.acoEscuro
              : cores.tinta.withValues(alpha: 0.18),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
        onTap: onTap,
        child: Container(
          height: altura,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                rotulo,
                style: textos.corpo.copyWith(fontSize: 13, color: texto),
              ),
              if (contagem != null) ...[
                const SizedBox(width: 6),
                Text(
                  '$contagem',
                  style: textos.corpo.copyWith(
                    fontSize: 12,
                    color: texto.withValues(alpha: 0.7),
                  ),
                ),
              ],
              if (icone != null) ...[
                const SizedBox(width: 4),
                Icon(icone, size: 16, color: texto),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tabela
// ---------------------------------------------------------------------------

/// Larguras do grid (as mesmas no cabeçalho e nas linhas): avatar, nº, nome (2,4fr),
/// marca (1fr), NCM, peso, atualizado em, chevron.
Widget _grade(List<Widget> c) => Row(
  children: [
    SizedBox(width: 44, child: c[0]),
    const SizedBox(width: 14),
    SizedBox(width: 64, child: c[1]),
    const SizedBox(width: 14),
    Expanded(flex: 24, child: c[2]),
    const SizedBox(width: 14),
    Expanded(flex: 10, child: c[3]),
    const SizedBox(width: 14),
    SizedBox(width: 116, child: c[4]),
    const SizedBox(width: 14),
    SizedBox(width: 92, child: c[5]),
    const SizedBox(width: 14),
    SizedBox(width: 132, child: c[6]),
    const SizedBox(width: 14),
    SizedBox(width: 20, child: c[7]),
  ],
);

class _CabecalhoTabela extends StatelessWidget {
  const _CabecalhoTabela();

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final estilo = context.sivTextos.rotulo.copyWith(color: cores.textoApoio);
    Widget t(String s) =>
        Text(s, style: estilo, maxLines: 1, overflow: TextOverflow.ellipsis);

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: cores.tinta.withValues(alpha: 0.12)),
        ),
      ),
      child: _grade([
        const SizedBox.shrink(),
        t('Nº'),
        t('NOME'),
        t('MARCA'),
        t('NCM'),
        t('PESO'),
        t('ATUALIZADO EM'),
        const SizedBox.shrink(),
      ]),
    );
  }
}

class _Avatar extends StatelessWidget {
  final Referencia referencia;
  final double lado;
  final double fonte;

  const _Avatar(this.referencia, {this.lado = 40, this.fonte = 18});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final inicial = referencia.nome.trim().isNotEmpty
        ? referencia.nome.trim().substring(0, 1).toUpperCase()
        : '-';
    return Container(
      width: lado,
      height: lado,
      alignment: Alignment.center,
      color: cores.selecaoFundo,
      child: Text(
        inicial,
        style: context.sivTextos.secao.copyWith(
          fontSize: 18,
          color: cores.acoEscuro,
        ),
      ),
    );
  }
}

/// "Sem NCM" / "Sem peso": a pendência vira uma etiqueta no lugar do valor.
class _Pendencia extends StatelessWidget {
  final String texto;

  const _Pendencia(this.texto);

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cores.selecaoFundo,
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
        border: Border.all(color: cores.aco.withValues(alpha: 0.45)),
      ),
      child: Text(
        texto,
        maxLines: 1,
        style: context.sivTextos.corpo.copyWith(
          fontSize: 12,
          color: cores.acoEscuro,
        ),
      ),
    );
  }
}

String _subtitulo(Referencia r) {
  final categoria = r.categoria?.nome ?? '';
  final sub = r.subCategoria?.nome ?? '';
  final partes = [categoria, sub].where((s) => s.isNotEmpty).toList();
  return partes.isEmpty ? '—' : partes.join(' · ');
}

/// 8 dígitos viram 6109.10.00; qualquer outra coisa fica como veio.
String _formatarNcm(String ncm) {
  final d = ncm.replaceAll(RegExp(r'\D'), '');
  if (d.length != 8) return ncm;
  return '${d.substring(0, 4)}.${d.substring(4, 6)}.${d.substring(6)}';
}

String _formatarPeso(int gramas) {
  if (gramas < 1000) return '$gramas g';
  final kg = (gramas / 1000)
      .toStringAsFixed(2)
      .replaceAll(RegExp(r'\.?0+$'), '');
  return '${kg.replaceAll('.', ',')} kg';
}

String _formatarData(DateTime? data) {
  if (data == null) return '-';
  final local = data.toLocal();
  String d2(int v) => v.toString().padLeft(2, '0');
  return '${d2(local.day)}/${d2(local.month)}/${local.year} ${d2(local.hour)}:${d2(local.minute)}';
}

class _LinhaTabela extends StatelessWidget {
  final Referencia referencia;
  final String? marca;
  final VoidCallback onTap;

  const _LinhaTabela({
    required this.referencia,
    required this.marca,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final valor = textos.corpo.copyWith(
      fontSize: 13.5,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final semNcm = ReferenciasFiltro.semNcmDe(referencia);
    final semPeso = ReferenciasFiltro.semPesoDe(referencia);

    return InkWell(
      onTap: onTap,
      hoverColor: const Color(0xFFF7F9FB),
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: cores.tinta.withValues(alpha: 0.07)),
          ),
        ),
        child: _grade([
          _Avatar(referencia),
          Text(
            ReferenciasFiltro.numeroDe(referencia),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: valor.copyWith(color: cores.textoApoio),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                referencia.nome,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textos.corpo.copyWith(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _subtitulo(referencia),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textos.corpo.copyWith(
                  fontSize: 12.5,
                  color: cores.textoApoio,
                ),
              ),
            ],
          ),
          Text(
            marca ?? '—',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: valor,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: semNcm
                ? const _Pendencia('Sem NCM')
                : Text(_formatarNcm(referencia.ncm!), style: valor),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: semPeso
                ? const _Pendencia('Sem peso')
                : Text(_formatarPeso(referencia.pesoGramas!), style: valor),
          ),
          Text(
            _formatarData(referencia.atualizadoEm),
            maxLines: 1,
            style: valor.copyWith(fontSize: 13, color: cores.textoApoio),
          ),
          Icon(
            Icons.chevron_right,
            size: 16,
            color: cores.tinta.withValues(alpha: 0.35),
          ),
        ]),
      ),
    );
  }
}

/// Mobile: linha cheia e branca, avatar 48, nome, "categoria · marca" e "Nº" com as pendências.
class _LinhaCompacta extends StatelessWidget {
  final Referencia referencia;
  final String? marca;
  final VoidCallback onTap;

  const _LinhaCompacta({
    required this.referencia,
    required this.marca,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final apoio = textos.corpo.copyWith(
      fontSize: 12.5,
      color: cores.textoApoio,
    );
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cores.superficie,
          border: Border(
            bottom: BorderSide(color: cores.tinta.withValues(alpha: 0.07)),
          ),
        ),
        child: Row(
          children: [
            _Avatar(referencia, lado: 48, fonte: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    referencia.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textos.corpo.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${_subtitulo(referencia)} · ${marca ?? '—'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: apoio,
                  ),
                  const SizedBox(height: 3),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Nº ${ReferenciasFiltro.numeroDe(referencia)}',
                        style: apoio.copyWith(fontSize: 12),
                      ),
                      if (ReferenciasFiltro.semNcmDe(referencia))
                        const _Pendencia('Sem NCM'),
                      if (ReferenciasFiltro.semPesoDe(referencia))
                        const _Pendencia('Sem peso'),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: cores.tinta.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Rodapé e estados
// ---------------------------------------------------------------------------

class _Rodape extends StatelessWidget {
  final int total;
  final int exibidas;
  final bool filtrando;

  const _Rodape({
    required this.total,
    required this.exibidas,
    required this.filtrando,
  });

  @override
  Widget build(BuildContext context) {
    final estilo = context.sivTextos.corpo.copyWith(
      fontSize: 12.5,
      color: context.sivColors.textoApoio,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            _rotuloContagem(total, exibidas, filtrando),
            style: estilo,
          ),
        ),
        Text('Clique na linha para editar', style: estilo),
      ],
    );
  }
}

class _Vazio extends StatelessWidget {
  final VoidCallback onLimpar;

  const _Vazio({required this.onLimpar});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Nenhuma referência encontrada',
              style: textos.secao,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Confira a grafia, busque pelo nº ou limpe os filtros.',
              style: textos.corpo.copyWith(
                fontSize: 13.5,
                color: cores.textoApoio,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: onLimpar,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SivDimensoes.raio),
                ),
              ),
              child: const Text('Limpar busca e filtros'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Erro extends StatelessWidget {
  final VoidCallback onTentarNovamente;

  const _Erro({required this.onTentarNovamente});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Erro ao carregar referências'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onTentarNovamente,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
