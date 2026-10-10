import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/presentation/widgets/lista_textos.dart';
import 'package:comercial/presentation/widgets/vitrine_adicionar.dart';
import 'package:core/bloc.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

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

  /// Quando `true`, o seletor de canal é desenhado aqui (fallback). Na página
  /// ele mora na barra de título, à direita.
  final bool mostrarSeletorDeCanal;

  const VitrineAba({
    super.key,
    required this.canais,
    required this.canalId,
    required this.onCanalChanged,
    this.mostrarSeletorDeCanal = false,
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

  /// O backend não guarda o endereço do site: usa o subtítulo do canal quando
  /// houver, senão o título.
  String get _url {
    final c = widget.canais.where((e) => e.id == widget.canalId).firstOrNull;
    final s = c?.subtitulo;
    return s != null && s.isNotEmpty ? s : (c?.titulo ?? '');
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
            _BarraFerramentas(
              canais: widget.mostrarSeletorDeCanal ? widget.canais : const [],
              canalId: widget.canalId!,
              onCanal: _trocarCanal,
              local: _local,
              state: state,
              onLocal: (l) => setState(() => _local = l),
              mobile: mobile,
            ),
            Expanded(
              child: mobile
                  ? lista
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SivDimensoes.paddingBarraTituloHorizontal,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: lista),
                          const SizedBox(width: 24),
                          Expanded(
                            child: VitrinePrevia(
                              local: _local,
                              state: state,
                              url: _url,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            _Rodape(state: state, mobile: mobile),
          ],
        );
      },
    );
  }
}

/// Segmento Menu/Home, texto de apoio do local e "+ Adicionar".
class _BarraFerramentas extends StatelessWidget {
  final List<Ecommerce> canais;
  final int canalId;
  final ValueChanged<int> onCanal;
  final VitrineLocal local;
  final EcommerceVitrineState state;
  final ValueChanged<VitrineLocal> onLocal;
  final bool mobile;

  const _BarraFerramentas({
    required this.canais,
    required this.canalId,
    required this.onCanal,
    required this.local,
    required this.state,
    required this.onLocal,
    required this.mobile,
  });

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    final comId = canais.where((c) => c.id != null).toList();
    final segmento = SegmentedButton<VitrineLocal>(
      showSelectedIcon: false,
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
    );
    final apoio = Text(
      local == VitrineLocal.menu
          ? 'Listas e grupos no menu lateral do site, nesta ordem.'
          : 'Faixas de produtos na página inicial, abaixo dos banners. Só listas.',
      style: textos.apoio.copyWith(
        fontSize: mobile ? 12 : 13,
        color: cores.tinta.withValues(alpha: 0.6),
      ),
    );

    if (mobile) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (comId.isNotEmpty) _SeletorDeCanal(canais: comId, canalId: canalId, onCanal: onCanal),
            SizedBox(height: 46, child: segmento),
            const SizedBox(height: 8),
            apoio,
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SivDimensoes.paddingBarraTituloHorizontal,
        vertical: 16,
      ),
      child: Row(
        children: [
          if (comId.isNotEmpty) ...[
            _SeletorDeCanal(canais: comId, canalId: canalId, onCanal: onCanal),
            const SizedBox(width: 16),
          ],
          segmento,
          const SizedBox(width: 20),
          Expanded(child: apoio),
          const SizedBox(width: 20),
          OutlinedButton.icon(
            key: Key('vitrine-adicionar-${local.name}'),
            onPressed: () => mostrarAdicionarNaVitrine(
                context,
                bloc: context.read<EcommerceVitrineBloc>(),
                local: local),
            icon: const Icon(SivIcones.adicionar, size: SivIcones.tamanhoBotao),
            label: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}

/// Caixa de 44px "Canal **Nome** ▾". Usada na barra de título (desktop).
class SeletorDeCanalVitrine extends StatelessWidget {
  final List<Ecommerce> canais;
  final int canalId;
  final ValueChanged<int> onCanal;

  const SeletorDeCanalVitrine({
    super.key,
    required this.canais,
    required this.canalId,
    required this.onCanal,
  });

  @override
  Widget build(BuildContext context) => _SeletorDeCanal(
        canais: canais,
        canalId: canalId,
        onCanal: onCanal,
      );
}

class _SeletorDeCanal extends StatelessWidget {
  final List<Ecommerce> canais;
  final int canalId;
  final ValueChanged<int> onCanal;

  const _SeletorDeCanal({
    required this.canais,
    required this.canalId,
    required this.onCanal,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return Container(
      height: SivDimensoes.alvoToqueMinimo,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: cores.superficie,
        border: Border.all(color: cores.hairline),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Canal',
              style: textos.apoio.copyWith(color: cores.textoApoio)),
          const SizedBox(width: 10),
          // Com um canal só não há o que escolher: mostra só o nome, para a
          // tela sempre dizer de qual e-commerce é esta vitrine.
          if (canais.length <= 1)
            Text(
              canais.firstOrNull?.titulo ?? '',
              key: const Key('vitrine-canal'),
              style: textos.corpo.copyWith(fontWeight: FontWeight.w600),
            )
          else
            DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              key: const Key('vitrine-canal'),
              value: canalId,
              isDense: true,
              style: textos.corpo.copyWith(fontWeight: FontWeight.w600),
              items: [
                for (final c in canais)
                  DropdownMenuItem(value: c.id, child: Text(c.titulo)),
              ],
              onChanged: (v) {
                if (v != null && v != canalId) onCanal(v);
              },
            ),
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
    final cores = context.sivColors;
    final bloc = context.read<EcommerceVitrineBloc>();
    final itens = state.vitrine.doLocal(local);

    final linhas = itens.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
                child:
                    Text('Nada configurado ainda.', style: textos.apoio)),
          )
        : ReorderableListView.builder(
            buildDefaultDragHandles: false,
            shrinkWrap: !mobile,
            physics: mobile ? null : const NeverScrollableScrollPhysics(),
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
          );

    if (mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: linhas),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              key: Key('vitrine-adicionar-${local.name}'),
              style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
              onPressed: () =>
                  mostrarAdicionarNaVitrine(context, bloc: bloc, local: local),
              icon: const Icon(SivIcones.adicionar,
                  size: SivIcones.tamanhoBotao),
              label: const Text('Adicionar'),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 6),
            child: Row(
              children: [
                const SizedBox(width: 34),
                SizedBox(width: 56, child: Text('POSIÇÃO', style: textos.rotulo)),
                const SizedBox(width: 10),
                Text('ITEM', style: textos.rotulo),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: cores.superficie,
              border: Border.all(color: cores.hairline),
            ),
            child: linhas,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              'Arraste pela alça ou digite a posição. Tirar do site não apaga a lista.',
              style: textos.apoio,
            ),
          ),
        ],
      ),
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
                leading: const Icon(SivIcones.remover),
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
    final chaveBase = '${local.name}-${item.tipo.name}-${item.itemId}';

    return Opacity(
      opacity: agendada ? 0.6 : 1,
      child: Container(
        constraints: BoxConstraints(minHeight: mobile ? 68 : 64),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: cores.superficie,
          border: Border(bottom: BorderSide(color: cores.hairline)),
        ),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: SizedBox(
                width: mobile ? 28 : 24,
                height: SivDimensoes.alvoToqueMinimo,
                child: Icon(
                  SivIcones.alcaArrastar,
                  size: SivIcones.tamanhoLinha,
                  color: cores.tinta.withValues(alpha: 0.4),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SivCampoPosicao(
              key: Key(mobile
                  ? 'vitrine-posicao-$chaveBase'
                  : 'vitrine-indice-$chaveBase'),
              posicao: index + 1,
              total: total,
              onMover: (p) => _mover(context, p - 1),
              aoAbrir: mobile ? () => _abrirPosicao(context) : null,
            ),
            const SizedBox(width: 10),
            if (!mobile) ...[
              Icon(
                item.tipo == VitrineItemTipo.grupo
                    ? SivIcones.grupo
                    : SivIcones.lista,
                size: 20,
                color: cores.aco,
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.nome,
                      style: textos.corpo.copyWith(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      _meta(),
                      style: textos.apoio
                          .copyWith(fontSize: mobile ? 11.5 : 12),
                    ),
                    if (dup != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: SivAvisoAtencao(
                          'Também aparece dentro de $dup (duplicado no menu)',
                          key: const Key('vitrine-duplicado'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: 'Remover',
              constraints: const BoxConstraints(
                minWidth: SivDimensoes.alvoToqueMinimo,
                minHeight: SivDimensoes.alvoToqueMinimo,
              ),
              onPressed: () => _remover(context),
              icon: Icon(
                SivIcones.remover,
                size: SivIcones.tamanhoLinha,
                color: cores.tinta.withValues(alpha: 0.55),
              ),
            ),
          ],
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

    return SivRodapeAcoes(
      key: const Key('vitrine-status'),
      mobile: mobile,
      status: status,
      corStatus: n > 0 ? cores.atencao : cores.aco,
      secundaria: TextButton(
        key: const Key('vitrine-descartar'),
        onPressed: n == 0 || state.publicando
            ? null
            : () => bloc.add(const EcommerceVitrineDescartou()),
        child: const Text('Descartar'),
      ),
      primaria: FilledButton(
        key: const Key('vitrine-publicar'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 26),
        ),
        onPressed: n == 0 || state.publicando
            ? null
            : () => bloc.add(const EcommerceVitrinePublicou()),
        child: state.publicando
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              )
            : Text(mobile ? 'PUBLICAR NO SITE' : 'Publicar no site'),
      ),
    );
  }
}

/// Prévia do site (desktop) dentro de uma moldura de navegador: menu lateral
/// com os grupos expandidos, ou as faixas da home abaixo dos banners.
class VitrinePrevia extends StatelessWidget {
  final VitrineLocal local;
  final EcommerceVitrineState state;
  final String url;

  const VitrinePrevia({
    super.key,
    required this.local,
    required this.state,
    this.url = '',
  });

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            local == VitrineLocal.menu
                ? 'ASSIM FICA NO SITE · MENU'
                : 'ASSIM FICA NO SITE · HOME',
            style: textos.rotulo,
          ),
        ),
        Expanded(
          child: SivMolduraNavegador(
            key: const Key('vitrine-previa'),
            url: url,
            child: local == VitrineLocal.menu
                ? _PreviaMenu(state: state)
                : _PreviaHome(state: state),
          ),
        ),
      ],
    );
  }
}

class _PreviaMenu extends StatelessWidget {
  final EcommerceVitrineState state;

  const _PreviaMenu({required this.state});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final itens = state.vitrine.menu;
    final linhas = <Widget>[];

    for (final i in itens) {
      final agendada = i.situacao == 'agendada';
      final dup = i.tipo == VitrineItemTipo.lista &&
          state.duplicidades.containsKey(i.itemId);
      final grupo = i.tipo == VitrineItemTipo.grupo
          ? state.grupos.where((g) => g.id == i.itemId).firstOrNull
          : null;
      linhas.add(
        Opacity(
          opacity: agendada ? 0.45 : 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    i.nome,
                    style: textos.corpo.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: dup ? cores.atencao : null,
                    ),
                  ),
                ),
                if (grupo != null) ...[
                  const SizedBox(width: 6),
                  Icon(SivIcones.expandir, size: 12, color: cores.textoApoio),
                ],
              ],
            ),
          ),
        ),
      );
      if (grupo != null) {
        for (final l in [...grupo.listas]
          ..sort((a, b) => a.ordem.compareTo(b.ordem))) {
          linhas.add(
            Padding(
              padding: const EdgeInsets.only(left: 28, right: 16, bottom: 9),
              child: Text(
                l.nome,
                style: textos.corpo.copyWith(
                  fontSize: 12.5,
                  color: cores.tinta.withValues(alpha: 0.65),
                ),
              ),
            ),
          );
        }
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 220,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: cores.hairline)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: linhas,
            ),
          ),
        ),
        Expanded(
          child: GridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 4 / 5,
            children: [
              for (var i = 0; i < 6; i++)
                const SivMiniatura(
                    largura: double.infinity, altura: double.infinity),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviaHome extends StatelessWidget {
  final EcommerceVitrineState state;

  const _PreviaHome({required this.state});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          height: 90,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // ponytail: borda sólida no lugar da tracejada do mock -- tracejado
            // exigiria um CustomPainter só para isso.
            border: Border.all(color: cores.atencaoBorda),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Banners da home', style: textos.corpo),
              Text('editar na aba Design do canal',
                  style: textos.apoio.copyWith(color: cores.acoProfundo)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final i in state.vitrine.home)
          _FaixaHome(
            item: i,
            inicio: state.listas
                .where((l) => l.id == i.itemId)
                .firstOrNull
                ?.dataInicio,
          ),
      ],
    );
  }
}

class _FaixaHome extends StatelessWidget {
  final EcommerceVitrineItem item;
  final DateTime? inicio;

  const _FaixaHome({required this.item, this.inicio});

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final agendada = item.situacao == 'agendada';
    return Opacity(
      opacity: agendada ? 0.45 : 1,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.nome,
              style: textos.secao.copyWith(fontSize: 15),
            ),
            if (agendada)
              Text(
                inicio == null
                    ? 'agendada'
                    : 'aparece a partir de ${diaMes(inicio!)}',
                style: textos.apoio.copyWith(fontSize: 11.5),
              ),
            const SizedBox(height: 6),
            Row(
              children: [
                for (var n = 0; n < 5; n++)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: SivMiniatura(largura: 42, altura: 52),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
