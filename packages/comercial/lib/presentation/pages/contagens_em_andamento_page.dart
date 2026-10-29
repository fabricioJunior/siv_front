import 'dart:async';

import 'package:comercial/domain/models/contagem_em_andamento.dart';
import 'package:comercial/presentation/blocs/contagens_em_andamento_cubit/contagens_em_andamento_cubit.dart';
import 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/preferencia_local.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Chave da preferência local com o último funcionário escolhido ao iniciar uma
/// contagem; é quem o filtro "Minhas" considera "eu".
const chaveFuncionarioDaContagem = 'contagem_funcionario_id';

String _dois(int n) => n.toString().padLeft(2, '0');

/// Mobile: "hoje, 09:02", "ontem, 16:40" ou "25/10, 14:08". Desktop: dd/MM/aaaa HH:mm.
String formatarCriadoEm(DateTime d, {required bool mobile, DateTime? agora}) {
  final hora = '${_dois(d.hour)}:${_dois(d.minute)}';
  if (!mobile) {
    return '${_dois(d.day)}/${_dois(d.month)}/${d.year} $hora';
  }
  final hoje = DateUtils.dateOnly(agora ?? DateTime.now());
  final dias = hoje.difference(DateUtils.dateOnly(d)).inDays;
  if (dias == 0) return 'hoje, $hora';
  if (dias == 1) return 'ontem, $hora';
  return '${_dois(d.day)}/${_dois(d.month)}, $hora';
}

class ContagensEmAndamentoPage extends StatefulWidget {
  final ContagensEmAndamentoCubit? cubit;

  const ContagensEmAndamentoPage({super.key, this.cubit});

  @override
  State<ContagensEmAndamentoPage> createState() =>
      _ContagensEmAndamentoPageState();
}

class _ContagensEmAndamentoPageState extends State<ContagensEmAndamentoPage> {
  late final ContagensEmAndamentoCubit _cubit =
      widget.cubit ?? ContagensEmAndamentoCubit(sl());
  final _scroll = ScrollController();
  final _busca = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 300) _cubit.maisItens();
    });
    _iniciar();
  }

  Future<void> _iniciar() async {
    _cubit.funcionarioId ??= await PreferenciaLocal.lerInt(
      chaveFuncionarioDaContagem,
    );
    if (mounted) await _cubit.carregar();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _busca.dispose();
    if (widget.cubit == null) _cubit.close();
    super.dispose();
  }

  void _aoDigitar(String termo) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => _cubit.buscar(termo),
    );
  }

  // Sem type arg: o onGenerateRoute cria MaterialPageRoute<dynamic>.
  Future<void> _abrir(ContagemEmAndamento c) async {
    await Navigator.of(
      context,
    ).pushNamed('/pedido_entrada', arguments: {'pedidoId': c.pedidoId});
    if (mounted) await _cubit.carregar();
  }

  Future<void> _nova() async {
    await Navigator.of(context).pushNamed('/entrada_contagem/nova');
    if (mounted) await _cubit.carregar();
  }

  @override
  Widget build(BuildContext context) {
    final mobile = ehMobile(context);
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(title: const Text('Contagens em andamento')),
        body: BlocBuilder<ContagensEmAndamentoCubit, ContagensEmAndamentoState>(
          builder: (context, state) => Column(
            children: [
              _Cabecalho(
                state: state,
                mobile: mobile,
                busca: _busca,
                podeMinhas: _cubit.funcionarioId != null,
                onBusca: _aoDigitar,
                onFiltro: (minhas) => _cubit.filtrar(minhas: minhas),
                onNova: _nova,
              ),
              Expanded(child: _corpo(context, state, mobile)),
              if (mobile)
                RodapeAcaoEntrada(
                  acao: BotaoPrincipalEntrada(
                    key: const Key('contagens_nova'),
                    rotulo: 'NOVA CONTAGEM',
                    icone: Icons.add,
                    onPressed: _nova,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _corpo(
    BuildContext context,
    ContagensEmAndamentoState state,
    bool mobile,
  ) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    if (state.carregando && state.itens.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (state.erro != null && state.itens.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Não foi possível carregar as contagens.',
              key: const Key('contagens_erro'),
              style: textos.corpo,
            ),
            TextButton(
              key: const Key('contagens_tentar_de_novo'),
              onPressed: _cubit.carregar,
              child: const Text('Tentar de novo'),
            ),
          ],
        ),
      );
    }
    if (state.itens.isEmpty) {
      final termo = state.busca;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              termo.isEmpty
                  ? 'Nenhuma contagem em andamento'
                  : 'Nenhuma contagem para “$termo”',
              key: const Key('contagens_vazio'),
              style: textos.corpo.copyWith(color: cores.textoApoio),
            ),
            if (termo.isEmpty && !mobile) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _nova,
                child: const Text('Nova contagem'),
              ),
            ],
          ],
        ),
      );
    }
    return ListView.builder(
      controller: _scroll,
      itemCount: state.itens.length + 1,
      itemBuilder: (context, i) {
        if (i == state.itens.length) {
          return SizedBox(
            height: 56,
            child: state.carregandoMais
                ? const Center(child: CircularProgressIndicator.adaptive())
                : null,
          );
        }
        final c = state.itens[i];
        return mobile
            ? _LinhaMobile(contagem: c, onTap: () => _abrir(c))
            : _LinhaDesktop(contagem: c, onTap: () => _abrir(c));
      },
    );
  }
}

class _Cabecalho extends StatelessWidget {
  final ContagensEmAndamentoState state;
  final bool mobile;
  final TextEditingController busca;
  final bool podeMinhas;
  final ValueChanged<String> onBusca;
  final ValueChanged<bool> onFiltro;
  final VoidCallback onNova;

  const _Cabecalho({
    required this.state,
    required this.mobile,
    required this.busca,
    required this.podeMinhas,
    required this.onBusca,
    required this.onFiltro,
    required this.onNova,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final campo = SizedBox(
      height: 48,
      child: TextField(
        key: const Key('contagens_busca'),
        controller: busca,
        onChanged: onBusca,
        decoration: const InputDecoration(
          hintText: 'Fornecedor, referência, contador ou nº',
          prefixIcon: Icon(Icons.search),
          isDense: true,
        ),
      ),
    );
    final filtros = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Filtro(
          chave: const Key('contagens_filtro_todas'),
          rotulo: 'Todas · ${state.total}',
          ativo: !state.minhas,
          onTap: () => onFiltro(false),
        ),
        const SizedBox(width: 8),
        _Filtro(
          chave: const Key('contagens_filtro_minhas'),
          rotulo: 'Minhas · ${state.totalDoFuncionario}',
          ativo: state.minhas,
          onTap: podeMinhas ? () => onFiltro(true) : null,
        ),
      ],
    );
    return Container(
      decoration: BoxDecoration(
        color: cores.superficie,
        border: Border(bottom: BorderSide(color: cores.hairline)),
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, mobile ? 10 : 12),
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                campo,
                const SizedBox(height: 10),
                Align(alignment: Alignment.centerLeft, child: filtros),
              ],
            )
          : Row(
              children: [
                SizedBox(width: 360, child: campo),
                const SizedBox(width: 16),
                filtros,
                const Spacer(),
                FilledButton.icon(
                  key: const Key('contagens_nova'),
                  onPressed: onNova,
                  icon: const Icon(Icons.add),
                  label: const Text('Nova contagem'),
                ),
              ],
            ),
    );
  }
}

class _Filtro extends StatelessWidget {
  final Key chave;
  final String rotulo;
  final bool ativo;
  final VoidCallback? onTap;

  const _Filtro({
    required this.chave,
    required this.rotulo,
    required this.ativo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    return SizedBox(
      height: 36,
      child: TextButton(
        key: chave,
        onPressed: onTap,
        style: TextButton.styleFrom(
          minimumSize: const Size(44, 36),
          backgroundColor: ativo ? cores.acoEscuro : null,
          foregroundColor: ativo ? cores.textoSobreEscuroTitulo : cores.tinta,
          side: ativo ? null : BorderSide(color: cores.hairline),
        ),
        child: Text(rotulo),
      ),
    );
  }
}

/// Nomes das referências e, em âmbar, as descrições livres; "+N" no resto.
Widget _itens(
  BuildContext context,
  ContagemEmAndamento c, {
  required int max,
}) {
  final cores = context.sivColors;
  final textos = context.sivTextos;
  if (c.itens.isEmpty) {
    return Text(
      'Nenhum item contado',
      style: textos.apoio.copyWith(
        fontStyle: FontStyle.italic,
        color: cores.textoApoio,
      ),
    );
  }
  final mostrados = c.itens.take(max).toList();
  final resto = c.totalItens - mostrados.length;
  return Text.rich(
    TextSpan(
      children: [
        for (var i = 0; i < mostrados.length; i++) ...[
          if (i > 0) const TextSpan(text: ' · '),
          TextSpan(
            text: mostrados[i].nome,
            style: mostrados[i].semReferencia
                ? TextStyle(color: cores.parcialTexto)
                : null,
          ),
        ],
        if (resto > 0) TextSpan(text: '  +$resto'),
      ],
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: textos.corpo,
  );
}

class _LinhaMobile extends StatelessWidget {
  final ContagemEmAndamento contagem;
  final VoidCallback onTap;

  const _LinhaMobile({required this.contagem, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final c = contagem;
    final quando = formatarCriadoEm(c.criadoEm, mobile: true);
    return InkWell(
      key: Key('contagem_${c.pedidoId}'),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 76),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: cores.hairline)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.fornecedor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textos.corpo.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text('#${c.pedidoId}', style: textos.apoio),
                    ],
                  ),
                  const SizedBox(height: 2),
                  _itens(context, c, max: 3),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _EtapaSelo(c.etapa),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          c.contador == null
                              ? quando
                              : '$quando · ${c.contador}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textos.apoio.copyWith(color: cores.textoApoio),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: cores.textoApoio),
          ],
        ),
      ),
    );
  }
}

class _LinhaDesktop extends StatelessWidget {
  final ContagemEmAndamento contagem;
  final VoidCallback onTap;

  const _LinhaDesktop({required this.contagem, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final c = contagem;
    return InkWell(
      key: Key('contagem_${c.pedidoId}'),
      onTap: onTap,
      hoverColor: cores.selecaoFundo,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: cores.hairline)),
        ),
        child: Row(
          children: [
            SizedBox(
                width: 90, child: Text('#${c.pedidoId}', style: textos.codigo)),
            Expanded(
              flex: 20,
              child: Text(
                c.fornecedor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textos.corpo.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(flex: 34, child: _itens(context, c, max: 4)),
            const SizedBox(width: 16),
            SizedBox(
              width: 110,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _EtapaSelo(c.etapa),
              ),
            ),
            SizedBox(
              width: 130,
              child: Text(
                formatarCriadoEm(c.criadoEm, mobile: false),
                style: textos.apoio,
              ),
            ),
            Expanded(
              flex: 14,
              child: Text(
                c.contador ?? '—',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textos.corpo,
              ),
            ),
            Icon(Icons.chevron_right, color: cores.textoApoio),
          ],
        ),
      ),
    );
  }
}

const _rotulosEtapa = {
  'contando': 'Contando',
  'associando': 'Associar',
  'etiquetando': 'Etiquetas',
  'conferindo': 'Conferir',
};

/// Etapa da trilha da contagem; "Associar" chama atenção (falta referência).
class _EtapaSelo extends StatelessWidget {
  final String etapa;

  const _EtapaSelo(this.etapa);

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final atencao = etapa == 'associando';
    return Container(
      key: Key('contagem_etapa_$etapa'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: atencao ? cores.atencaoFundo : cores.superficieRecuada,
        border:
            Border.all(color: atencao ? cores.atencaoBorda : cores.hairline),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _rotulosEtapa[etapa] ?? etapa,
        style: context.sivTextos.apoio.copyWith(
          color: atencao ? cores.parcialTexto : cores.acoEscuro,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
