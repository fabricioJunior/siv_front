import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/presentation/widgets/lista_textos.dart';
import 'package:core/bloc.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Diálogo "Adicionar" da vitrine (multi-seleção). Bottom sheet no mobile,
/// diálogo no desktop.
Future<void> mostrarAdicionarNaVitrine(
  BuildContext context, {
  required EcommerceVitrineBloc bloc,
  required VitrineLocal local,
}) {
  final mobile =
      MediaQuery.sizeOf(context).width < SivDimensoes.breakpointMenuDrawer;
  final conteudo = BlocProvider<EcommerceVitrineBloc>.value(
    value: bloc,
    child: VitrineAdicionar(local: local),
  );
  if (mobile) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FractionallySizedBox(heightFactor: 0.85, child: conteudo),
    );
  }
  return showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: conteudo,
      ),
    ),
  );
}

class VitrineAdicionar extends StatefulWidget {
  final VitrineLocal local;

  const VitrineAdicionar({super.key, required this.local});

  @override
  State<VitrineAdicionar> createState() => _VitrineAdicionarState();
}

class _VitrineAdicionarState extends State<VitrineAdicionar> {
  VitrineItemTipo _aba = VitrineItemTipo.lista;
  bool _expiradas = false;
  String _busca = '';
  final _marcados = <VitrineItemRef>[];

  bool get _home => widget.local == VitrineLocal.home;

  void _alternar(VitrineItemRef ref) => setState(() {
        _marcados.contains(ref) ? _marcados.remove(ref) : _marcados.add(ref);
      });

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    final state = context.watch<EcommerceVitrineBloc>().state;
    final atuais = state.vitrine.doLocal(widget.local);
    bool jaTem(VitrineItemTipo t, int id) =>
        atuais.any((i) => i.tipo == t && i.itemId == id);
    final q = _busca.trim().toLowerCase();

    final linhas = <Widget>[];
    if (_aba == VitrineItemTipo.lista) {
      for (final l in state.listas) {
        if (jaTem(VitrineItemTipo.lista, l.id)) continue;
        final encerrada = l.situacao == ListaPersonalizadaSituacao.expirada ||
            l.situacao == ListaPersonalizadaSituacao.cancelada;
        if (encerrada && !_expiradas) continue;
        if (q.isNotEmpty && !nomeDaLista(l).toLowerCase().contains(q)) continue;
        final dentro = widget.local == VitrineLocal.menu
            ? state.grupoDoMenuQueContem(l.id)
            : null;
        linhas.add(
          _Linha(
            chave: Key('vitrine-add-lista-${l.id}'),
            marcado:
                _marcados.contains(VitrineItemRef(VitrineItemTipo.lista, l.id)),
            nome: nomeDaLista(l),
            meta: modoEContagem(l),
            situacao: situacaoTexto(l.situacao),
            alerta: dentro == null
                ? null
                : 'Já está dentro de $dentro: ficaria duplicada no menu',
            onTap: () => _alternar(VitrineItemRef(VitrineItemTipo.lista, l.id)),
          ),
        );
      }
    } else {
      for (final g in state.grupos) {
        if (jaTem(VitrineItemTipo.grupo, g.id)) continue;
        if (q.isNotEmpty && !g.nome.toLowerCase().contains(q)) continue;
        linhas.add(
          _Linha(
            chave: Key('vitrine-add-grupo-${g.id}'),
            marcado:
                _marcados.contains(VitrineItemRef(VitrineItemTipo.grupo, g.id)),
            nome: g.nome,
            meta: 'Grupo',
            situacao: g.ativo ? 'Ativo' : 'Inativo',
            onTap: () => _alternar(VitrineItemRef(VitrineItemTipo.grupo, g.id)),
          ),
        );
      }
    }

    final n = _marcados.length;
    final de = atuais.length + 1;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Adicionar ${_home ? 'à Home do site' : 'ao Menu do site'}',
                style: textos.secao,
              ),
              const SizedBox(height: 10),
              SegmentedButton<VitrineItemTipo>(
                showSelectedIcon: false,
                segments: [
                  const ButtonSegment(
                    value: VitrineItemTipo.lista,
                    label: Text('Listas'),
                  ),
                  ButtonSegment(
                    value: VitrineItemTipo.grupo,
                    label: const Text('Grupos'),
                    enabled: !_home,
                  ),
                ],
                selected: {_aba},
                onSelectionChanged: (s) => setState(() => _aba = s.first),
              ),
              if (_home)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('Grupos só entram no Menu.', style: textos.apoio),
                ),
              const SizedBox(height: 10),
              TextField(
                key: const Key('vitrine-add-busca'),
                onChanged: (v) => setState(() => _busca = v),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: _aba == VitrineItemTipo.lista
                      ? 'Buscar lista de catálogo'
                      : 'Buscar grupo',
                ),
              ),
              if (_aba == VitrineItemTipo.lista)
                SwitchListTile(
                  key: const Key('vitrine-add-expiradas'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Mostrar expiradas'),
                  value: _expiradas,
                  onChanged: (v) => setState(() => _expiradas = v),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              if (linhas.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Nada disponível para adicionar.',
                      style: textos.apoio),
                ),
              ...linhas,
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Provadores não aparecem aqui: não vão para o site.',
                  style: textos.apoio,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: cores.hairline)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (n > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    n == 1
                        ? 'Entra na posição $de.'
                        : 'Entram nas posições $de a ${de + n - 1}.',
                    style: textos.apoio,
                  ),
                ),
              FilledButton(
                key: const Key('vitrine-add-confirmar'),
                style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
                onPressed: n == 0
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
                child: Text(n == 0
                    ? 'ADICIONAR'
                    : 'ADICIONAR $n ${n == 1 ? 'ITEM' : 'ITENS'}'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Linha extends StatelessWidget {
  final Key chave;
  final bool marcado;
  final String nome;
  final String meta;
  final String situacao;
  final String? alerta;
  final VoidCallback onTap;

  const _Linha({
    required this.chave,
    required this.marcado,
    required this.nome,
    required this.meta,
    required this.situacao,
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
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              IgnorePointer(child: Checkbox(value: marcado, onChanged: (_) {})),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nome, style: textos.corpo),
                    Text('$meta · $situacao', style: textos.apoio),
                    if (alerta != null)
                      Text(alerta!,
                          style: textos.apoio.copyWith(color: cores.atencao)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
