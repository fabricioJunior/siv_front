import 'package:comercial/presentation/blocs/relatorio_frequencia_clientes_bloc/relatorio_frequencia_clientes_bloc.dart';
import 'package:comercial/presentation/widgets/frequencia/frequencia_formato.dart';
import 'package:core/presentation.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:empresas/presentation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pessoas/pages.dart';
import 'package:produtos/presentation.dart';

enum _Base {
  loja('Loja', 'Todas', 'Lojas', 'selecionadas'),
  vendedor('Vendedor', 'Todos', 'Vendedor', 'selecionados'),
  categoria('Categoria', 'Todas', 'Categoria', 'selecionadas');

  final String rotulo;
  final String todos;
  final String titulo;
  final String plural;
  const _Base(this.rotulo, this.todos, this.titulo, this.plural);
}

/// Busca, filtros de base (loja/vendedor/categoria), "Só atrasados" e a tag da
/// classe ativa. No mobile, os filtros de base ficam atrás do botão `Filtros`.
class FrequenciaFiltros extends StatefulWidget {
  final RelatorioFrequenciaClientesState state;
  final RelatorioFrequenciaClientesBloc bloc;
  final bool mobile;

  /// Substituem os seletores reais (testes).
  final SeletorWidget? lojaSeletor;
  final SeletorWidget? vendedorSeletor;
  final SeletorWidget? categoriaSeletor;

  const FrequenciaFiltros({
    super.key,
    required this.state,
    required this.bloc,
    required this.mobile,
    this.lojaSeletor,
    this.vendedorSeletor,
    this.categoriaSeletor,
  });

  @override
  State<FrequenciaFiltros> createState() => _FrequenciaFiltrosState();
}

class _FrequenciaFiltrosState extends State<FrequenciaFiltros> {
  late final TextEditingController _busca;
  final _debouncer = Debouncer(milliseconds: 400);
  final _sel = <_Base, List<SelectData>>{for (final b in _Base.values) b: []};

  @override
  void initState() {
    super.initState();
    _busca = TextEditingController(text: widget.state.busca);
  }

  @override
  void didUpdateWidget(FrequenciaFiltros old) {
    super.didUpdateWidget(old);
    final s = widget.state;
    if (old.state.busca.isNotEmpty && s.busca.isEmpty) _busca.clear();
    for (final b in _Base.values) {
      final ids = _ids(s, b);
      _sel[b] = _sel[b]!.where((e) => ids.contains(e.id)).toList();
    }
  }

  @override
  void dispose() {
    _debouncer.cancel();
    _busca.dispose();
    super.dispose();
  }

  List<int> _ids(RelatorioFrequenciaClientesState s, _Base b) => switch (b) {
        _Base.loja => s.empresaIds,
        _Base.vendedor => s.funcionarioIds,
        _Base.categoria => s.categoriaIds,
      };

  String _valor(_Base b) {
    final ids = _ids(widget.state, b);
    if (ids.isEmpty) return b.todos;
    if (ids.length == 1) {
      final nome = _sel[b]!.where((e) => e.id == ids.first).map((e) => e.nome);
      if (nome.isNotEmpty) return nome.first;
    }
    return '${ids.length} ${b.plural}';
  }

  Widget _seletor(_Base b, SeletorData data) {
    final w = switch (b) {
      _Base.loja => widget.lojaSeletor,
      _Base.vendedor => widget.vendedorSeletor,
      _Base.categoria => widget.categoriaSeletor,
    };
    if (w != null) return w(data);
    final ini = data.itemsSelecionadosInicial ?? const <SelectData>[];
    return switch (b) {
      _Base.loja => EmpresaSeletor(
          modo: EmpresaSeletorModo.multipla,
          itemsSelecionadosInicial: ini,
          onChanged: data.onChanged,
        ),
      _Base.vendedor => FuncionarioSeletor(
          modo: FuncionarioSeletorModo.multipla,
          itemsSelecionadosInicial: ini,
          onChanged: data.onChanged,
        ),
      _Base.categoria => CategoriaSeletor(
          modo: CategoriaSeletorModo.multipla,
          idCategoriasSelecionadasIniciais: [for (final e in ini) e.id],
          onChanged: data.onChanged,
        ),
    };
  }

  Future<void> _abrir(_Base b) async {
    var atual = List<SelectData>.of(_sel[b]!);
    await SivModal.mostrar<void>(
      context,
      titulo: b.titulo,
      larguraMaxima: 480,
      corpo: Padding(
        padding: const EdgeInsets.all(SivDimensoes.paddingCard),
        child: _seletor(
          b,
          SeletorData(
            itemsSelecionadosInicial: atual,
            onChanged: (l) => atual = l,
          ),
        ),
      ),
      acoes: [
        Builder(
          builder: (ctx) => FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Aplicar'),
          ),
        ),
      ],
    );
    if (!mounted) return;
    setState(() => _sel[b] = atual);
    final ids = [for (final e in atual) e.id];
    if (listEquals(ids, _ids(widget.state, b))) return;
    List<int> de(_Base x) => x == b ? ids : _ids(widget.state, x);
    widget.bloc.add(FrequenciaMudouFiltrosBase(
      empresaIds: de(_Base.loja),
      funcionarioIds: de(_Base.vendedor),
      categoriaIds: de(_Base.categoria),
    ));
  }

  Future<void> _abrirFiltrosMobile() => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheet) => StatefulBuilder(
          builder: (sheet, setSheet) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Filtros', style: sheet.sivTextos.secao),
                const SizedBox(height: 12),
                for (final b in _Base.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: RelatorioFiltroChip(
                        rotulo: b.rotulo,
                        valor: _valor(b),
                        onTap: () async {
                          await _abrir(b);
                          if (sheet.mounted) setSheet(() {});
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                FilledButton(
                  onPressed: () => Navigator.of(sheet).pop(),
                  child: const Text('Fechar'),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final mobile = widget.mobile;
    final c = context.sivColors;
    final busca = SizedBox(
      width: mobile ? null : 280,
      height: mobile ? 44 : null,
      child: TextField(
        key: const ValueKey('frequencia-busca'),
        controller: _busca,
        style: context.sivTextos.apoio.copyWith(color: c.tinta),
        onChanged: (v) =>
            _debouncer.run(() => widget.bloc.add(FrequenciaMudouBusca(v))),
        decoration: InputDecoration(
          isDense: true,
          hintText: mobile ? 'Nome ou telefone' : 'Nome, CPF ou telefone',
          prefixIcon: Icon(Icons.search, size: 16, color: c.textoApoio),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
            borderSide: BorderSide(color: c.hairline),
          ),
        ),
      ),
    );
    final nBase = [for (final b in _Base.values) if (_ids(s, b).isNotEmpty) b].length;
    final atrasados = _ChipAtrasados(
      marcado: s.atrasados,
      onTap: () => widget.bloc.add(const FrequenciaAlternouAtrasados()),
    );
    final classe = s.classe == null ? null : _TagClasse(classe: s.classe!, bloc: widget.bloc);
    if (mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: busca),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                key: const ValueKey('frequencia-filtros-botao'),
                onPressed: _abrirFiltrosMobile,
                icon: const Icon(Icons.tune, size: 16),
                label: Text(nBase == 0 ? 'Filtros' : 'Filtros ($nBase)'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
            atrasados,
            if (classe != null) classe,
          ]),
        ],
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        busca,
        for (final b in _Base.values)
          RelatorioFiltroChip(rotulo: b.rotulo, valor: _valor(b), onTap: () => _abrir(b)),
        atrasados,
        if (classe != null) classe,
      ],
    );
  }
}

class _ChipAtrasados extends StatelessWidget {
  final bool marcado;
  final VoidCallback onTap;
  const _ChipAtrasados({required this.marcado, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    final cor = marcado ? c.atencao : c.tinta;
    return Material(
      key: const ValueKey('frequencia-chip-atrasados'),
      color: marcado ? c.atencaoFundo : c.superficie,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
        side: BorderSide(color: marcado ? c.atencaoBorda : c.hairline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: SivDimensoes.alvoToqueMinimo),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  marcado ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 18,
                  color: marcado ? c.atencao : c.textoApoio,
                ),
                const SizedBox(width: 8),
                Text('Só atrasados', style: context.sivTextos.apoio.copyWith(color: cor)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TagClasse extends StatelessWidget {
  final String classe;
  final RelatorioFrequenciaClientesBloc bloc;
  const _TagClasse({required this.classe, required this.bloc});

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    final fg = frequenciaTagTexto(c, classe);
    return InkWell(
      key: const ValueKey('frequencia-tag-classe'),
      borderRadius: BorderRadius.circular(SivDimensoes.raio),
      onTap: () => bloc.add(FrequenciaMudouClasse(classe)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: frequenciaTagFundo(c, classe),
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Classe $classe',
              style: context.sivTextos.apoio.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.close, size: 12, color: fg),
          ],
        ),
      ),
    );
  }
}
