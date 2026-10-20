import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/presentation/widgets/lista_textos.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Edição do destino do clique no banner: bottom sheet no mobile, diálogo no
/// desktop (mesmo critério do "Adicionar" da vitrine).
Future<void> mostrarLinkDoBanner(
  BuildContext context, {
  required EcommerceBannersBloc bloc,
  required EcommerceBanner banner,
}) {
  final mobile =
      MediaQuery.sizeOf(context).width < SivDimensoes.breakpointMenuDrawer;
  final cores = context.sivColors;
  final conteudo = BannerLinkForm(
    banner: banner,
    mobile: mobile,
    onSalvar: (link) =>
        bloc.add(EcommerceBannerLinkAlterou(id: banner.id, link: link)),
  );

  if (mobile) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => FractionallySizedBox(heightFactor: 0.85, child: conteudo),
    );
  }
  return showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: SizedBox(
        width: 560,
        height: 620,
        child: SivMolduraBlueprint(
          padding: 0,
          fundo: cores.superficie,
          child: conteudo,
        ),
      ),
    ),
  );
}

enum _Opcao { semLink, endereco, lista }

class BannerLinkForm extends StatefulWidget {
  final EcommerceBanner banner;
  final bool mobile;
  final void Function(EcommerceBannerLink? link) onSalvar;

  const BannerLinkForm({
    super.key,
    required this.banner,
    required this.onSalvar,
    this.mobile = false,
  });

  @override
  State<BannerLinkForm> createState() => _BannerLinkFormState();
}

class _BannerLinkFormState extends State<BannerLinkForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _endereco;
  late _Opcao _opcao;
  int? _listaId;
  String? _listaNome;

  // ponytail: 1ª página de 100 listas de catálogo basta hoje (o acervo é de
  // dezenas); paginar se passar disso.
  late final Future<PaginaListasPersonalizadas> _listas =
      sl<ListarListasPersonalizadas>().call(limit: 100, tipo: ListaTipo.catalogo);

  @override
  void initState() {
    super.initState();
    final link = widget.banner.link;
    _opcao = switch (link?.tipo) {
      EcommerceBannerLinkTipo.url => _Opcao.endereco,
      EcommerceBannerLinkTipo.lista => _Opcao.lista,
      null => _Opcao.semLink,
    };
    _endereco = TextEditingController(text: link?.url ?? '');
    _listaId = link?.listaId;
    _listaNome = link?.listaNome;
  }

  @override
  void dispose() {
    _endereco.dispose();
    super.dispose();
  }

  void _salvar() {
    switch (_opcao) {
      case _Opcao.semLink:
        widget.onSalvar(null);
      case _Opcao.endereco:
        if (!(_formKey.currentState?.validate() ?? false)) return;
        widget.onSalvar(
          EcommerceBannerLink.endereco(_endereco.text.trim()),
        );
      case _Opcao.lista:
        final id = _listaId;
        if (id == null) {
          SivAviso.mostrar(
            context,
            mensagem: 'Escolha uma lista.',
            tipo: SivAvisoTipo.atencao,
          );
          return;
        }
        widget.onSalvar(
          EcommerceBannerLink.lista(listaId: id, listaNome: _listaNome),
        );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    final lateral = widget.mobile ? 16.0 : 26.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(lateral, widget.mobile ? 4 : 22, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Link do banner',
                  style: textos.secao.copyWith(fontSize: widget.mobile ? 21 : 24),
                ),
              ),
              IconButton(
                tooltip: 'Fechar',
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  SivIcones.remover,
                  size: SivIcones.tamanhoLinha,
                  color: cores.tinta.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(lateral, 4, lateral, 14),
          child: Text(
            'Para onde o cliente vai ao clicar neste banner.',
            style: textos.apoio,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: lateral),
          child: SizedBox(
            height: 44,
            child: SegmentedButton<_Opcao>(
              key: const Key('banner-link-opcoes'),
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: _Opcao.semLink, label: Text('Sem link')),
                ButtonSegment(value: _Opcao.endereco, label: Text('Endereço')),
                ButtonSegment(value: _Opcao.lista, label: Text('Lista')),
              ],
              selected: {_opcao},
              onSelectionChanged: (s) => setState(() => _opcao = s.first),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(lateral, 16, lateral, 0),
            child: switch (_opcao) {
              _Opcao.semLink => Text(
                  'O banner fica apenas decorativo, sem clique.',
                  style: textos.apoio,
                ),
              _Opcao.endereco => Form(
                  key: _formKey,
                  child: TextFormField(
                    key: const Key('banner-link-endereco'),
                    controller: _endereco,
                    autofocus: true,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'Endereço',
                      hintText: 'https://... ou /promocoes',
                      helperText: 'Endereço externo ou caminho do próprio site',
                      helperMaxLines: 2,
                    ),
                    validator: validarEnderecoDoBanner,
                    onFieldSubmitted: (_) => _salvar(),
                  ),
                ),
              _Opcao.lista => _SeletorDeLista(
                  listas: _listas,
                  selecionada: _listaId,
                  onSelecionou: (lista) => setState(() {
                    _listaId = lista.id;
                    _listaNome = nomeDaLista(lista);
                  }),
                ),
            },
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(lateral, 12, lateral, widget.mobile ? 16 : 22),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: cores.hairline)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 48,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: FilledButton(
                  key: const Key('banner-link-salvar'),
                  onPressed: _salvar,
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SeletorDeLista extends StatelessWidget {
  final Future<PaginaListasPersonalizadas> listas;
  final int? selecionada;
  final void Function(ListaPersonalizadaResumo lista) onSelecionou;

  const _SeletorDeLista({
    required this.listas,
    required this.selecionada,
    required this.onSelecionou,
  });

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;

    return FutureBuilder<PaginaListasPersonalizadas>(
      future: listas,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (snapshot.hasError) {
          return Text('Falha ao carregar as listas do catálogo.', style: textos.apoio);
        }
        final itens = snapshot.data?.items ?? const <ListaPersonalizadaResumo>[];
        if (itens.isEmpty) {
          return Text(
            'Nenhuma lista de catálogo cadastrada ainda.',
            style: textos.apoio,
          );
        }
        return ListView.builder(
          itemCount: itens.length,
          itemBuilder: (context, i) {
            final lista = itens[i];
            final marcada = lista.id == selecionada;
            return InkWell(
              key: Key('banner-link-lista-${lista.id}'),
              onTap: () => onSelecionou(lista),
              child: Container(
                constraints: const BoxConstraints(minHeight: 56),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: cores.hairline)),
                ),
                child: Row(
                  children: [
                    Icon(
                      marcada
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: SivIcones.tamanhoLinha,
                      color: marcada ? cores.aco : cores.textoApoio,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nomeDaLista(lista), style: textos.corpo),
                          Text(modoEContagem(lista), style: textos.apoio),
                        ],
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
}
