import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/presentation/widgets/lista_textos.dart';
import 'package:comercial/presentation/widgets/vitrine_adicionar.dart';
import 'package:core/bloc.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Pergunta antes de perder o rascunho da vitrine. `true` = pode sair.
Future<bool> confirmarSairSemPublicar(
    BuildContext context, int pendentes) async {
  var sair = false;
  await SivDialogo.mostrar(
    context,
    titulo: 'Sair sem publicar?',
    corpo: Text(
      pendentes == 1
          ? '1 alteração não publicada será perdida.'
          : '$pendentes alterações não publicadas serão perdidas.',
    ),
    textoAcao: 'Sair',
    textoSaida: 'Voltar',
    onConfirmar: (_) => sair = true,
  );
  return sair;
}

/// Vitrine do site por canal: Menu e Home com ordem por índice/arrasto, prévia
/// ao vivo (desktop) e um único "Publicar no site". O [EcommerceVitrineBloc]
/// vem do contexto.
class VitrineAba extends StatefulWidget {
  final List<Ecommerce> canais;
  final int? canalId;
  final ValueChanged<int> onCanalChanged;

  const VitrineAba({
    super.key,
    required this.canais,
    required this.canalId,
    required this.onCanalChanged,
  });

  @override
  State<VitrineAba> createState() => _VitrineAbaState();
}

class _VitrineAbaState extends State<VitrineAba> {
  VitrineLocal _local = VitrineLocal.menu;

  Future<void> _trocarCanal(int id) async {
    final bloc = context.read<EcommerceVitrineBloc>();
    final n = bloc.state.alteracoesPendentes;
    if (n > 0 && !await confirmarSairSemPublicar(context, n)) return;
    widget.onCanalChanged(id);
  }

  @override
  Widget build(BuildContext context) {
    final mobile =
        MediaQuery.sizeOf(context).width < SivDimensoes.breakpointMenuDrawer;
    return BlocConsumer<EcommerceVitrineBloc, EcommerceVitrineState>(
      listenWhen: (a, b) => a.erro != b.erro,
      listener: (context, state) {
        if (state.erro?.isNotEmpty == true &&
            state.step != EcommerceVitrineStep.falha) {
          SivAviso.mostrar(context,
              mensagem: state.erro!, tipo: SivAvisoTipo.falha);
        }
      },
      builder: (context, state) {
        if (widget.canalId == null) {
          return Center(
            child: Text('Nenhum canal cadastrado.',
                style: context.sivTextos.apoio),
          );
        }
        if (state.step == EcommerceVitrineStep.inicial ||
            state.step == EcommerceVitrineStep.carregando) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (state.step == EcommerceVitrineStep.falha) {
          return Center(
            child: TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: Text(state.erro ?? 'Falha ao carregar.'),
              onPressed: () => context
                  .read<EcommerceVitrineBloc>()
                  .add(EcommerceVitrineIniciou(ecommerceId: widget.canalId!)),
            ),
          );
        }
        final lista =
            _ListaDoLocal(local: _local, state: state, mobile: mobile);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Cabecalho(
              canais: widget.canais,
              canalId: widget.canalId!,
              onCanal: _trocarCanal,
              local: _local,
              state: state,
              onLocal: (l) => setState(() => _local = l),
            ),
            Expanded(
              child: mobile
                  ? lista
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: lista),
                        const SizedBox(width: 24),
                        SizedBox(
                          width: 320,
                          child: SingleChildScrollView(
                            child: VitrinePrevia(local: _local, state: state),
                          ),
                        ),
                      ],
                    ),
            ),
            _Rodape(state: state, mobile: mobile),
          ],
        );
      },
    );
  }
}

class _Cabecalho extends StatelessWidget {
  final List<Ecommerce> canais;
  final int canalId;
  final ValueChanged<int> onCanal;
  final VitrineLocal local;
  final EcommerceVitrineState state;
  final ValueChanged<VitrineLocal> onLocal;

  const _Cabecalho({
    required this.canais,
    required this.canalId,
    required this.onCanal,
    required this.local,
    required this.state,
    required this.onLocal,
  });

  @override
  Widget build(BuildContext context) {
    final comId = canais.where((c) => c.id != null).toList();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (comId.length > 1)
            DropdownButton<int>(
              key: const Key('vitrine-canal'),
              value: canalId,
              items: [
                for (final c in comId)
                  DropdownMenuItem(value: c.id, child: Text(c.titulo)),
              ],
              onChanged: (v) {
                if (v != null && v != canalId) onCanal(v);
              },
            ),
          SegmentedButton<VitrineLocal>(
            showSelectedIcon: false,
            style: const ButtonStyle(
                minimumSize: WidgetStatePropertyAll(Size(0, 44))),
            segments: [
              ButtonSegment(
                value: VitrineLocal.menu,
                label: Text('Menu do site · ${state.vitrine.menu.length}'),
              ),
              ButtonSegment(
                value: VitrineLocal.home,
                label: Text('Home do site · ${state.vitrine.home.length}'),
              ),
            ],
            selected: {local},
            onSelectionChanged: (s) => onLocal(s.first),
          ),
        ],
      ),
    );
  }
}

class _ListaDoLocal extends StatelessWidget {
  final VitrineLocal local;
  final EcommerceVitrineState state;
  final bool mobile;

  const _ListaDoLocal(
      {required this.local, required this.state, required this.mobile});

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final bloc = context.read<EcommerceVitrineBloc>();
    final itens = state.vitrine.doLocal(local);
    final menu = local == VitrineLocal.menu;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                menu
                    ? 'Listas e grupos no menu lateral do site, nesta ordem.'
                    : 'Faixas de produtos na página inicial, abaixo dos banners. Só listas.',
                style: textos.apoio,
              ),
            ),
            TextButton.icon(
              key: Key('vitrine-adicionar-${local.name}'),
              style: TextButton.styleFrom(minimumSize: const Size(0, 44)),
              onPressed: () =>
                  mostrarAdicionarNaVitrine(context, bloc: bloc, local: local),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Adicionar'),
            ),
          ],
        ),
        Expanded(
          child: itens.isEmpty
              ? Center(
                  child: Text('Nada configurado ainda.', style: textos.apoio))
              : ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  itemCount: itens.length,
                  onReorderItem: (de, para) {
                    final i = itens[de];
                    bloc.add(
                      EcommerceVitrineItemMoveu(
                        local: local,
                        tipo: i.tipo,
                        itemId: i.itemId,
                        indice: para,
                      ),
                    );
                  },
                  itemBuilder: (context, index) => VitrineLinha(
                    key: ValueKey(
                        '${local.name}-${itens[index].tipo.name}-${itens[index].itemId}'),
                    index: index,
                    total: itens.length,
                    item: itens[index],
                    local: local,
                    state: state,
                    mobile: mobile,
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text('Tirar do site não apaga a lista.', style: textos.apoio),
        ),
      ],
    );
  }
}

class VitrineLinha extends StatelessWidget {
  final int index;
  final int total;
  final EcommerceVitrineItem item;
  final VitrineLocal local;
  final EcommerceVitrineState state;
  final bool mobile;

  const VitrineLinha({
    super.key,
    required this.index,
    required this.total,
    required this.item,
    required this.local,
    required this.state,
    required this.mobile,
  });

  String _meta() {
    if (item.tipo == VitrineItemTipo.grupo) {
      final g = state.grupos.where((x) => x.id == item.itemId).firstOrNull;
      return g == null || g.listas.isEmpty
          ? 'Grupo'
          : 'Grupo · ${g.listas.length} listas';
    }
    final l = state.listas.where((x) => x.id == item.itemId).firstOrNull;
    final base = l == null ? 'Lista' : 'Lista · ${modoEContagem(l)}';
    if (item.situacao == 'agendada') {
      final inicio = l?.dataInicio;
      return '$base · agendada${inicio == null ? '' : ', entra ${diaMes(inicio)}'}';
    }
    return base;
  }

  void _mover(BuildContext context, int indice) =>
      context.read<EcommerceVitrineBloc>().add(
            EcommerceVitrineItemMoveu(
              local: local,
              tipo: item.tipo,
              itemId: item.itemId,
              indice: indice,
            ),
          );

  void _remover(BuildContext context) =>
      context.read<EcommerceVitrineBloc>().add(
            EcommerceVitrineItemRemoveu(
                local: local, tipo: item.tipo, itemId: item.itemId),
          );

  Future<void> _abrirPosicao(BuildContext context) async {
    final bloc = context.read<EcommerceVitrineBloc>();
    final textos = context.sivTextos;
    final menu = local == VitrineLocal.menu;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mover "${item.nome}"', style: textos.secao),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var p = 0; p < total; p++)
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: OutlinedButton(
                        key: Key('vitrine-pos-${p + 1}'),
                        style:
                            OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: () {
                          Navigator.pop(ctx);
                          bloc.add(
                            EcommerceVitrineItemMoveu(
                              local: local,
                              tipo: item.tipo,
                              itemId: item.itemId,
                              indice: p,
                            ),
                          );
                        },
                        child: Text('${p + 1}'),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              ListTile(
                key: const Key('vitrine-topo'),
                minTileHeight: 48,
                leading: const Icon(Icons.vertical_align_top),
                title: const Text('Mandar para o topo'),
                enabled: index > 0,
                onTap: () {
                  Navigator.pop(ctx);
                  _mover(context, 0);
                },
              ),
              ListTile(
                key: const Key('vitrine-fim'),
                minTileHeight: 48,
                leading: const Icon(Icons.vertical_align_bottom),
                title: const Text('Mandar para o fim'),
                enabled: index < total - 1,
                onTap: () {
                  Navigator.pop(ctx);
                  _mover(context, total - 1);
                },
              ),
              ListTile(
                key: const Key('vitrine-tirar'),
                minTileHeight: 48,
                leading: const Icon(Icons.close),
                title: Text(menu ? 'Tirar do menu' : 'Tirar da home'),
                onTap: () {
                  Navigator.pop(ctx);
                  _remover(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    final dup = local == VitrineLocal.menu && item.tipo == VitrineItemTipo.lista
        ? state.duplicidades[item.itemId]
        : null;
    final agendada = item.situacao == 'agendada';
    return Opacity(
      opacity: agendada ? 0.6 : 1,
      child: Container(
        constraints: const BoxConstraints(minHeight: 62),
        decoration: BoxDecoration(
          color: cores.superficie,
          border: Border(bottom: BorderSide(color: cores.hairline)),
        ),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.drag_indicator),
              ),
            ),
            if (mobile)
              SizedBox(
                width: 44,
                height: 44,
                child: OutlinedButton(
                  key: Key(
                      'vitrine-posicao-${local.name}-${item.tipo.name}-${item.itemId}'),
                  style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () => _abrirPosicao(context),
                  child: Text('${index + 1}'),
                ),
              )
            else
              _CampoIndice(
                total: total,
                posicao: index + 1,
                onSubmit: (p) => _mover(context, p - 1),
                chave: Key(
                    'vitrine-indice-${local.name}-${item.tipo.name}-${item.itemId}'),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.nome, style: textos.corpo),
                    Text(_meta(), style: textos.apoio),
                    if (dup != null)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        color: cores.atencaoFundo,
                        child: Text(
                          'Também aparece dentro de $dup (duplicado no menu)',
                          key: const Key('vitrine-duplicado'),
                          style: textos.apoio.copyWith(color: cores.atencao),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: 'Remover',
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              onPressed: () => _remover(context),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampoIndice extends StatefulWidget {
  final int posicao;
  final int total;
  final ValueChanged<int> onSubmit;
  final Key chave;

  const _CampoIndice({
    required this.posicao,
    required this.total,
    required this.onSubmit,
    required this.chave,
  });

  @override
  State<_CampoIndice> createState() => _CampoIndiceState();
}

class _CampoIndiceState extends State<_CampoIndice> {
  late final TextEditingController _c =
      TextEditingController(text: '${widget.posicao}');

  @override
  void didUpdateWidget(_CampoIndice old) {
    super.didUpdateWidget(old);
    if (old.posicao != widget.posicao) _c.text = '${widget.posicao}';
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _enviar() {
    final n = int.tryParse(_c.text.trim());
    if (n == null) {
      _c.text = '${widget.posicao}';
      return;
    }
    widget.onSubmit(n.clamp(1, widget.total));
    _c.text = '${n.clamp(1, widget.total)}';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: Focus(
        onFocusChange: (f) {
          if (!f) _enviar();
        },
        child: TextField(
          key: widget.chave,
          controller: _c,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onSubmitted: (_) => _enviar(),
          decoration: const InputDecoration(isDense: true),
        ),
      ),
    );
  }
}

class _Rodape extends StatelessWidget {
  final EcommerceVitrineState state;
  final bool mobile;

  const _Rodape({required this.state, required this.mobile});

  String _hora(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    final bloc = context.read<EcommerceVitrineBloc>();
    final n = state.alteracoesPendentes;
    final status = n > 0
        ? (n == 1
            ? '1 alteração não publicada'
            : '$n alterações não publicadas')
        : state.publicadoEm != null
            ? 'Publicado no site às ${_hora(state.publicadoEm!)}'
            : 'Tudo publicado. O site está igual a esta tela.';

    final statusW = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: n > 0 ? cores.atencao : cores.aco,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
            child: Text(status,
                key: const Key('vitrine-status'), style: textos.apoio)),
      ],
    );
    final descartar = TextButton(
      key: const Key('vitrine-descartar'),
      style: TextButton.styleFrom(minimumSize: const Size(0, 44)),
      onPressed: n == 0 || state.publicando
          ? null
          : () => bloc.add(const EcommerceVitrineDescartou()),
      child: const Text('Descartar'),
    );
    final publicar = FilledButton(
      key: const Key('vitrine-publicar'),
      style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
      onPressed: n == 0 || state.publicando
          ? null
          : () => bloc.add(const EcommerceVitrinePublicou()),
      child: state.publicando
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
            )
          : const Text('Publicar no site'),
    );

    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      decoration:
          BoxDecoration(border: Border(top: BorderSide(color: cores.hairline))),
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                statusW,
                const SizedBox(height: 8),
                Row(
                  children: [
                    descartar,
                    const SizedBox(width: 8),
                    Expanded(child: publicar),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                    child:
                        Align(alignment: Alignment.centerLeft, child: statusW)),
                descartar,
                const SizedBox(width: 12),
                SizedBox(width: 220, child: publicar),
              ],
            ),
    );
  }
}

/// Prévia do site (desktop): menu lateral com grupos expandidos, ou faixas da
/// home abaixo do bloco de banners. Lista agendada aparece apagada.
class VitrinePrevia extends StatelessWidget {
  final VitrineLocal local;
  final EcommerceVitrineState state;

  const VitrinePrevia({super.key, required this.local, required this.state});

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    final itens = state.vitrine.doLocal(local);
    final filhos = <Widget>[];

    if (local == VitrineLocal.home) {
      filhos.add(
        Container(
          padding: const EdgeInsets.all(12),
          color: cores.superficieRecuada,
          child: Text('Banners da home · editar na aba Design do canal',
              style: textos.apoio),
        ),
      );
    }
    for (final i in itens) {
      final agendada = i.situacao == 'agendada';
      final dup = local == VitrineLocal.menu &&
          i.tipo == VitrineItemTipo.lista &&
          state.duplicidades.containsKey(i.itemId);
      final cor = dup ? cores.atencao : null;
      final grupo = i.tipo == VitrineItemTipo.grupo
          ? state.grupos.where((g) => g.id == i.itemId).firstOrNull
          : null;
      final inicio = i.tipo == VitrineItemTipo.lista
          ? state.listas.where((l) => l.id == i.itemId).firstOrNull?.dataInicio
          : null;
      filhos.add(
        Opacity(
          opacity: agendada ? 0.5 : 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  i.nome,
                  style: (i.tipo == VitrineItemTipo.grupo
                          ? textos.rotulo
                          : textos.corpo)
                      .copyWith(color: cor),
                ),
                if (agendada)
                  Text(
                    inicio == null
                        ? 'agendada'
                        : 'aparece a partir de ${diaMes(inicio)}',
                    style: textos.apoio,
                  ),
                if (grupo != null)
                  for (final l in ([
                    ...grupo.listas
                  ]..sort((a, b) => a.ordem.compareTo(b.ordem))))
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 2),
                      child: Text(l.nome, style: textos.apoio),
                    ),
              ],
            ),
          ),
        ),
      );
    }
    return Container(
      key: const Key('vitrine-previa'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cores.superficie,
        border: Border.all(color: cores.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            local == VitrineLocal.menu
                ? 'ASSIM APARECE NO MENU'
                : 'ASSIM APARECE NA HOME',
            style: textos.apoio,
          ),
          const SizedBox(height: 8),
          ...filhos,
        ],
      ),
    );
  }
}
