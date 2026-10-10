import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/presentation/widgets/lista_textos.dart';
import 'package:core/bloc.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Diálogo "Adicionar" da vitrine (3d). Bottom sheet a 85% no mobile,
/// diálogo de 640x720 no desktop.
Future<void> mostrarAdicionarNaVitrine(
  BuildContext context, {
  required EcommerceVitrineBloc bloc,
  required VitrineLocal local,
}) {
  final mobile =
      MediaQuery.sizeOf(context).width < SivDimensoes.breakpointMenuDrawer;
  final cores = context.sivColors;
  Widget conteudo(bool mobile) => BlocProvider<EcommerceVitrineBloc>.value(
        value: bloc,
        child: VitrineAdicionar(local: local, mobile: mobile),
      );
  if (mobile) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.85,
        child: conteudo(true),
      ),
    );
  }
  return showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: SizedBox(
        width: 640,
        height: 720,
        child: SivMolduraBlueprint(
          padding: 0,
          fundo: cores.superficie,
          child: conteudo(false),
        ),
      ),
    ),
  );
}

class VitrineAdicionar extends StatefulWidget {
  final VitrineLocal local;
  final bool mobile;

  const VitrineAdicionar({
    super.key,
    required this.local,
    this.mobile = false,
  });

  @override
  State<VitrineAdicionar> createState() => _VitrineAdicionarState();
}

class _VitrineAdicionarState extends State<VitrineAdicionar>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this)
    ..addListener(() {
      if (!_tabs.indexIsChanging) setState(() {});
    });
  bool _expiradas = false;
  String _busca = '';
  final _marcados = <VitrineItemRef>[];

  bool get _home => widget.local == VitrineLocal.home;

  bool get _emGrupos => _tabs.index == 1;

  String get _doLocal => _home ? 'da home' : 'do menu';

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _alternar(VitrineItemRef ref) => setState(() {
        _marcados.contains(ref) ? _marcados.remove(ref) : _marcados.add(ref);
      });

  double get _lateral => widget.mobile ? 16 : 26;

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    final state = context.watch<EcommerceVitrineBloc>().state;
    final atuais = state.vitrine.doLocal(widget.local);
    bool jaTem(VitrineItemTipo t, int id) =>
        atuais.any((i) => i.tipo == t && i.itemId == id);
    final q = _busca.trim().toLowerCase();

    // Listas disponíveis (já presentes e expiradas ficam de fora); o contador
    // da aba ignora só a busca.
    final listas = [
      for (final l in state.listas)
        if (!jaTem(VitrineItemTipo.lista, l.id) &&
            (_expiradas ||
                (l.situacao != ListaPersonalizadaSituacao.expirada &&
                    l.situacao != ListaPersonalizadaSituacao.cancelada)))
          l,
    ];
    final grupos = [
      for (final g in state.grupos)
        if (!jaTem(VitrineItemTipo.grupo, g.id)) g,
    ];

    final linhas = <Widget>[];
    if (!_emGrupos) {
      for (final l in listas) {
        if (q.isNotEmpty && !nomeDaLista(l).toLowerCase().contains(q)) continue;
        final dentro = _home ? null : state.grupoDoMenuQueContem(l.id);
        linhas.add(
          _Linha(
            chave: Key('vitrine-add-lista-${l.id}'),
            marcado:
                _marcados.contains(VitrineItemRef(VitrineItemTipo.lista, l.id)),
            nome: nomeDaLista(l),
            meta: modoEContagem(l),
            situacao: situacaoTexto(l.situacao),
            etiqueta: etiquetaDaSituacao(l.situacao),
            alerta: dentro == null
                ? null
                : 'Já está dentro de $dentro: ficaria duplicada no menu',
            onTap: () => _alternar(VitrineItemRef(VitrineItemTipo.lista, l.id)),
          ),
        );
      }
    } else {
      for (final g in grupos) {
        if (q.isNotEmpty && !g.nome.toLowerCase().contains(q)) continue;
        linhas.add(
          _Linha(
            chave: Key('vitrine-add-grupo-${g.id}'),
            marcado:
                _marcados.contains(VitrineItemRef(VitrineItemTipo.grupo, g.id)),
            nome: g.nome,
            meta: g.listas.isEmpty ? 'Grupo' : 'Grupo · ${g.listas.length} listas',
            situacao: g.ativo ? 'Ativo' : 'Inativo',
            etiqueta: g.ativo
                ? SivEtiquetaSituacao.emAndamento
                : SivEtiquetaSituacao.cancelado,
            onTap: () => _alternar(VitrineItemRef(VitrineItemTipo.grupo, g.id)),
          ),
        );
      }
    }

    final n = _marcados.length;
    final de = atuais.length + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(_lateral, widget.mobile ? 4 : 22, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Adicionar ${_home ? 'à home do site' : 'ao menu do site'}',
                  style: textos.secao.copyWith(fontSize: widget.mobile ? 21 : 24),
                ),
              ),
              IconButton(
                tooltip: 'Fechar',
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(SivIcones.remover,
                    size: SivIcones.tamanhoLinha,
                    color: cores.tinta.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _lateral),
          child: SizedBox(
            height: 44,
            child: TabBar(
              key: const Key('vitrine-add-abas'),
              controller: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelPadding: const EdgeInsets.only(right: 22),
              // Na Home só listas entram: a aba Grupos fica desabilitada.
              onTap: (i) {
                if (i == 1 && _home) _tabs.index = 0;
              },
              tabs: [
                Tab(height: 42, child: Text('Listas · ${listas.length}')),
                Tab(
                  height: 42,
                  child: Opacity(
                    opacity: _home ? 0.4 : 1,
                    child: Text('Grupos · ${grupos.length}'),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_home)
          Padding(
            padding: EdgeInsets.fromLTRB(_lateral, 8, _lateral, 0),
            child: Text('Grupos só entram no Menu.', style: textos.apoio),
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(_lateral, 14, _lateral, 10),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: TextField(
                    key: const Key('vitrine-add-busca'),
                    onChanged: (v) => setState(() => _busca = v),
                    decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: Icon(SivIcones.buscar,
                          size: SivIcones.tamanhoBotao,
                          color: cores.tinta.withValues(alpha: 0.5)),
                      hintText: _emGrupos ? 'Buscar grupo' : 'Buscar lista',
                    ),
                  ),
                ),
              ),
              if (!_emGrupos) ...[
                const SizedBox(width: 10),
                _ChipExpiradas(
                  marcado: _expiradas,
                  onTap: () => setState(() => _expiradas = !_expiradas),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: _lateral),
            children: [
              if (linhas.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Nada disponível para adicionar.',
                      style: textos.apoio),
                ),
              ...linhas,
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'Os itens já presentes ${_home ? 'na home' : 'no menu'} não '
                  'aparecem. Provadores também não, porque não vão para o site.',
                  style: textos.apoio,
                ),
              ),
            ],
          ),
        ),
        _Rodape(
          mobile: widget.mobile,
          lateral: _lateral,
          info: n == 0
              ? ''
              : n == 1
                  ? 'Entra no fim $_doLocal (posição $de)'
                  : n == 2
                      ? 'Entram no fim $_doLocal (posições $de e ${de + 1})'
                      : 'Entram no fim $_doLocal (posições $de a ${de + n - 1})',
          onConfirmar: n == 0
              ? null
              : () {
                  context.read<EcommerceVitrineBloc>().add(
                        EcommerceVitrineItensAdicionou(
                          local: widget.local,
                          itens: List.of(_marcados),
                        ),
                      );
                  Navigator.of(context).pop();
                },
          rotulo: n == 0 ? 'Adicionar' : 'Adicionar $n',
        ),
      ],
    );
  }
}

/// Chip de 44px com checkbox quadrado de 16 (não é `SwitchListTile`).
class _ChipExpiradas extends StatelessWidget {
  final bool marcado;
  final VoidCallback onTap;

  const _ChipExpiradas({required this.marcado, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    return InkWell(
      key: const Key('vitrine-add-expiradas'),
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: cores.superficie,
          border: Border.all(color: cores.hairline),
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Caixa(valor: marcado, lado: 16, onTap: onTap),
            const SizedBox(width: 2),
            Text('Mostrar expiradas', style: context.sivTextos.corpo),
          ],
        ),
      ),
    );
  }
}

/// `Checkbox` quadrado num lado exato de desenho (16 no chip, 22 nas linhas).
/// O `Checkbox` compacto mede 32 e desenha 18: a caixa é escalada por essa
/// razão para o quadrado pintado bater com o mock.
class _Caixa extends StatelessWidget {
  final bool valor;
  final double lado;
  final VoidCallback onTap;

  static const _razao = 32 / 18;

  const _Caixa({required this.valor, required this.lado, required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: lado * _razao,
        height: lado * _razao,
        child: FittedBox(
          child: Checkbox(
            value: valor,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (_) => onTap(),
          ),
        ),
      );
}

/// Linha de 66px do 3d: caixa de 22, nome, meta, aviso e etiqueta.
class _Linha extends StatelessWidget {
  final Key chave;
  final bool marcado;
  final String nome;
  final String meta;
  final String situacao;
  final SivEtiquetaSituacao etiqueta;
  final String? alerta;
  final VoidCallback onTap;

  const _Linha({
    required this.chave,
    required this.marcado,
    required this.nome,
    required this.meta,
    required this.situacao,
    required this.etiqueta,
    required this.onTap,
    this.alerta,
  });

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    return InkWell(
      key: chave,
      onTap: onTap,
      child: Container(
        height: 66,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: cores.hairline)),
        ),
        child: Row(
          children: [
            _Caixa(valor: marcado, lado: 22, onTap: onTap),
            const SizedBox(width: 2),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textos.corpo.copyWith(fontSize: 14.5),
                  ),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textos.apoio.copyWith(fontSize: 12),
                  ),
                  if (alerta != null)
                    Text(
                      alerta!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textos.apoio
                          .copyWith(fontSize: 12, color: cores.atencao),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SivEtiqueta(situacao: etiqueta, texto: situacao),
          ],
        ),
      ),
    );
  }
}

class _Rodape extends StatelessWidget {
  final bool mobile;
  final double lateral;
  final String info;
  final String rotulo;
  final VoidCallback? onConfirmar;

  const _Rodape({
    required this.mobile,
    required this.lateral,
    required this.info,
    required this.rotulo,
    required this.onConfirmar,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final texto = Text(
      info,
      style: textos.apoio.copyWith(
        fontSize: 13.5,
        color: cores.tinta.withValues(alpha: 0.6),
      ),
    );
    final primaria = FilledButton(
      key: const Key('vitrine-add-confirmar'),
      onPressed: onConfirmar,
      child: Text(rotulo),
    );

    return Container(
      padding: EdgeInsets.fromLTRB(lateral, 12, lateral, mobile ? 18 : 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: cores.hairline)),
      ),
      child: mobile
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (info.isNotEmpty) ...[texto, const SizedBox(height: 10)],
                SizedBox(height: 52, child: primaria),
              ],
            )
          : Row(
              children: [
                Expanded(child: texto),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 10),
                SizedBox(height: 44, child: primaria),
              ],
            ),
    );
  }
}
