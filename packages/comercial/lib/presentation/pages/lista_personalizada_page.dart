import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:produtos/presentantion/widgets/referencia_seletor.dart';

class ListaPersonalizadaPage extends StatefulWidget {
  final int? listaId;
  final ListaSeletores seletores;

  const ListaPersonalizadaPage({
    super.key,
    this.listaId,
    required this.seletores,
  });

  @override
  State<ListaPersonalizadaPage> createState() => _ListaPersonalizadaPageState();
}

class _ListaPersonalizadaPageState extends State<ListaPersonalizadaPage> {
  late final ListaPersonalizadaBloc _bloc;
  bool _editando = false;
  bool _aguardandoSalvar = false;
  ListaItensLoteResultado? _loteVisto;

  @override
  void initState() {
    super.initState();
    _bloc = sl<ListaPersonalizadaBloc>();
    if (widget.listaId != null) {
      _bloc.add(ListaPersonalizadaAbriu(id: widget.listaId!));
    }
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ListaPersonalizadaBloc>.value(
      value: _bloc,
      child: BlocConsumer<ListaPersonalizadaBloc, ListaPersonalizadaState>(
        listener: (context, state) {
          if (state.erro != null && state.erro!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.erro!)),
            );
          }
          final lote = state.ultimoLote;
          if (lote != null && !identical(lote, _loteVisto)) {
            _loteVisto = lote;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${lote.adicionadas} referência(s) adicionada(s). Total: ${lote.total}.',
                ),
              ),
            );
          }
          if (_aguardandoSalvar && !state.salvandoDados) {
            _aguardandoSalvar = false;
            if (state.erro == null || state.erro!.isEmpty) {
              setState(() => _editando = false);
            }
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SivDimensoes.paginaHorizontal,
              vertical: SivDimensoes.paginaVertical,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SivTituloPagina(titulo: 'Lista personalizada'),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: state.lista == null
                        ? (widget.listaId != null
                            ? const Center(
                                child: CircularProgressIndicator.adaptive())
                            : _buildFormulario(context, state))
                        : _editando
                            ? _buildEdicao(context, state)
                            : _buildGestao(context, state),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormulario(BuildContext context, ListaPersonalizadaState state) {
    final textos = context.sivTextos;

    return SingleChildScrollView(
      child: SivCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Nova lista', style: textos.rotulo),
            const SizedBox(height: 4),
            Text(
              'Monte uma lista de produtos: provador (link para o cliente) ou catálogo do e-commerce.',
              style: textos.apoio,
            ),
            const SizedBox(height: 16),
            ListaPersonalizadaFormulario(
              seletores: widget.seletores,
              salvando: state.step == ListaPersonalizadaStep.salvando,
              iconeNovoNome: state.iconeLocal?.nome,
              onEscolherIcone: () =>
                  _bloc.add(const ListaPersonalizadaIconeEscolheu()),
              onSalvar: (input) => _bloc.add(ListaPersonalizadaCriou(input: input)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEdicao(BuildContext context, ListaPersonalizadaState state) {
    return SingleChildScrollView(
      child: SivCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListaPersonalizadaFormulario(
              lista: state.lista,
              seletores: widget.seletores,
              salvando: state.salvandoDados,
              textoSalvar: 'Salvar alterações',
              iconeNovoNome: null,
              onEscolherIcone: () =>
                  _bloc.add(const ListaPersonalizadaIconeEscolheu()),
              onSalvar: (input) {
                _aguardandoSalvar = true;
                _bloc.add(ListaPersonalizadaAtualizou(input: input));
              },
            ),
            TextButton(
              onPressed: () => setState(() => _editando = false),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  String _rotuloSituacao(ListaPersonalizadaSituacao s) => switch (s) {
        ListaPersonalizadaSituacao.ativa => 'Ativa',
        ListaPersonalizadaSituacao.agendada => 'Agendada',
        ListaPersonalizadaSituacao.expirada => 'Expirada',
        ListaPersonalizadaSituacao.cancelada => 'Cancelada',
      };

  String _periodo(ListaPersonalizada lista) {
    final ini = lista.dataInicio;
    final fim = lista.dataExpiracao;
    if (ini == null && fim == null) return 'Sem prazo';
    if (ini != null && fim != null) {
      return '${formatarDataLista(ini)} a ${formatarDataLista(fim)}';
    }
    return ini != null
        ? 'A partir de ${formatarDataLista(ini)}'
        : 'Expira em: ${formatarDataLista(fim!)}';
  }

  Widget _buildGestao(BuildContext context, ListaPersonalizadaState state) {
    final lista = state.lista!;
    final textos = context.sivTextos;
    final link = state.link;
    final catalogo = lista.tipo == ListaTipo.catalogo;
    final filtro = lista.modo == ListaModo.filtro;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SivCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (lista.icone != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(lista.icone!),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      lista.titulo?.isNotEmpty == true ? lista.titulo! : 'Sem título',
                      style: textos.rotulo,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Editar lista',
                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                    onPressed: () => setState(() => _editando = true),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                  ),
                ],
              ),
              if (lista.descricao?.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(lista.descricao!, style: textos.corpo),
              ],
              const SizedBox(height: 8),
              Text(
                '${catalogo ? 'Catálogo' : 'Provador'} · '
                '${filtro ? 'por filtro' : 'itens avulsos'} · '
                '${_rotuloSituacao(lista.situacao)}',
                style: textos.apoio,
              ),
              const SizedBox(height: 4),
              Text(_periodo(lista), style: textos.apoio),
              if (!catalogo) ...[
                const SizedBox(height: 12),
                Text('Link para o cliente', style: textos.rotulo),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: link == null
                          ? Text('Carregando link...', style: textos.apoio)
                          : SelectableText(link, style: textos.corpo),
                    ),
                    IconButton(
                      tooltip: 'Copiar link',
                      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                      onPressed:
                          link == null ? null : () => _copiarLink(context, link),
                      icon: const Icon(Icons.copy_outlined),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: SivDimensoes.gapCards),
        if (catalogo)
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              key: const Key('lista-previa'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
              onPressed: () => _abrirPrevia(),
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: const Text('Prévia no site'),
            ),
          ),
        if (!filtro) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Referências (${lista.itens.length})',
                  style: textos.rotulo,
                ),
              ),
              if (catalogo)
                IconButton(
                  key: const Key('lista-adicionar-lote'),
                  tooltip: 'Adicionar por categoria',
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  onPressed: state.atualizandoItens ? null : _adicionarPorCategoria,
                  icon: const Icon(Icons.category_outlined),
                ),
              FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                onPressed:
                    state.atualizandoItens ? null : () => _adicionarReferencias(lista),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Adicionar'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: lista.itens.isEmpty
                ? Center(
                    child: Text('Nenhuma referência adicionada ainda.',
                        style: textos.apoio),
                  )
                : ListView.separated(
                    itemCount: lista.itens.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = lista.itens[index];
                      return ListTile(
                        leading: item.imagemUrl == null
                            ? const CircleAvatar(child: Icon(Icons.image_outlined))
                            : CircleAvatar(
                                backgroundImage: NetworkImage(item.imagemUrl!),
                              ),
                        title: Text(item.nome),
                        subtitle: Text('R\$ ${item.valor.toStringAsFixed(2)}'),
                        trailing: IconButton(
                          tooltip: 'Remover',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: state.atualizandoItens
                              ? null
                              : () => _bloc.add(
                                    ListaPersonalizadaReferenciasRemoveu(
                                      referenciaIds: [item.referenciaId],
                                    ),
                                  ),
                        ),
                      );
                    },
                  ),
          ),
        ] else
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Lista dinâmica: os produtos vêm do filtro. Use "Editar lista" para ajustar e "Prévia no site" para conferir.',
              style: textos.apoio,
            ),
          ),
      ],
    );
  }

  void _abrirPrevia() {
    _bloc.add(const ListaPersonalizadaPreviaSolicitou());
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider<ListaPersonalizadaBloc>.value(
        value: _bloc,
        child: BlocBuilder<ListaPersonalizadaBloc, ListaPersonalizadaState>(
          builder: (context, state) {
            final previa = state.previa;
            return SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.7,
              child: state.carregandoPrevia || previa == null
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            '${previa.totalItems} referência(s) — página ${previa.page}/${previa.totalPages}',
                            style: context.sivTextos.rotulo,
                          ),
                        ),
                        Expanded(
                          child: previa.items.isEmpty
                              ? Center(
                                  child: Text('Nenhuma referência disponível.',
                                      style: context.sivTextos.apoio),
                                )
                              : ListView(
                                  children: [
                                    for (final i in previa.items)
                                      ListTile(
                                        leading: i.imagemUrl == null
                                            ? const CircleAvatar(
                                                child: Icon(Icons.image_outlined))
                                            : CircleAvatar(
                                                backgroundImage:
                                                    NetworkImage(i.imagemUrl!)),
                                        title: Text(i.nome),
                                        subtitle: i.preco == null
                                            ? null
                                            : Text('R\$ ${i.preco!.toStringAsFixed(2)}'),
                                      ),
                                  ],
                                ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              tooltip: 'Página anterior',
                              onPressed: previa.page > 1
                                  ? () => _bloc.add(ListaPersonalizadaPreviaSolicitou(
                                      page: previa.page - 1))
                                  : null,
                              icon: const Icon(Icons.chevron_left),
                            ),
                            IconButton(
                              tooltip: 'Próxima página',
                              onPressed: previa.page < previa.totalPages
                                  ? () => _bloc.add(ListaPersonalizadaPreviaSolicitou(
                                      page: previa.page + 1))
                                  : null,
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _adicionarPorCategoria() async {
    var categorias = <int>[];
    var subCategorias = <int>[];
    var apenasPublicadas = false;
    final seletores = widget.seletores;

    await SivDialogo.mostrar(
      context,
      titulo: 'Adicionar por categoria',
      textoAcao: 'Adicionar',
      corpo: StatefulBuilder(
        builder: (context, setLocal) => SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              seletores.categoria(
                SeletorData(
                  onChanged: (sel) =>
                      setLocal(() => categorias = sel.map((s) => s.id).toList()),
                ),
              ),
              const SizedBox(height: 12),
              seletores.subCategoria(
                categoriaIds: categorias,
                data: SeletorData(
                  onChanged: (sel) => subCategorias = sel.map((s) => s.id).toList(),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Só publicadas no e-commerce'),
                value: apenasPublicadas,
                onChanged: (v) => setLocal(() => apenasPublicadas = v),
              ),
            ],
          ),
        ),
      ),
      onConfirmar: (_) {
        if (categorias.isEmpty && subCategorias.isEmpty) return;
        _bloc.add(
          ListaPersonalizadaItensPorFiltroAdicionou(
            lote: ListaItensLote(
              categoriaIds: categorias,
              subCategoriaIds: subCategorias,
              apenasPublicadasNoEcommerce: apenasPublicadas,
            ),
          ),
        );
      },
    );
  }

  bool get _telaDesktop =>
      MediaQuery.sizeOf(context).width >= SivDimensoes.breakpointMenuDrawer;

  Future<void> _adicionarReferencias(ListaPersonalizada lista) async {
    final idsAtuais = lista.itens.map((item) => item.referenciaId).toList();
    var selecionados = List<int>.from(idsAtuais);

    void aplicar() {
      final novos = selecionados.where((id) => !idsAtuais.contains(id)).toList();
      final removidos = idsAtuais.where((id) => !selecionados.contains(id)).toList();
      _bloc.add(
        ListaPersonalizadaItensAjustou(paraAdicionar: novos, paraRemover: removidos),
      );
    }

    final conteudo = ReferenciaSeletor(
      modo: ReferenciaSeletorModo.multipla,
      permitirCadastro: false,
      idReferenciasSelecionadasIniciais: idsAtuais,
      onReferenciaChanged: (referencias) {
        selecionados = referencias.map((r) => r.id).whereType<int>().toList();
      },
    );

    if (_telaDesktop) {
      await SivDialogo.mostrar(
        context,
        titulo: 'Adicionar referências',
        corpo: SizedBox(height: 420, child: conteudo),
        textoAcao: 'Salvar',
        onConfirmar: (_) => aplicar(),
      );
      return;
    }

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
              conteudo,
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  aplicar();
                },
                child: const Text('Salvar'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _copiarLink(BuildContext context, String link) {
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copiado.')),
    );
  }
}
