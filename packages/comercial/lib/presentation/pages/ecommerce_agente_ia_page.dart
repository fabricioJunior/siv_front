import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/presentation/blocs/ecommerce_chaves_mcp_bloc/ecommerce_chaves_mcp_bloc.dart';
import 'package:comercial/presentation/widgets/ecommerce_chave_mcp_dialogos.dart';
import 'package:core/bloc.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Chaves MCP do canal + dados de conexão do agente de IA do CRM.
class EcommerceAgenteIaPage extends StatefulWidget {
  final int ecommerceId;
  final String? tituloCanal;

  /// URL completa do MCP de vendas (base da API + `/v1/mcp/vendas`).
  final String urlMcp;
  final bool temPermissao;
  final EcommerceChavesMcpBloc Function() criarBloc;

  const EcommerceAgenteIaPage({
    super.key,
    required this.ecommerceId,
    this.tituloCanal,
    required this.urlMcp,
    this.temPermissao = true,
    required this.criarBloc,
  });

  @override
  State<EcommerceAgenteIaPage> createState() => _EcommerceAgenteIaPageState();
}

class _EcommerceAgenteIaPageState extends State<EcommerceAgenteIaPage> {
  EcommerceChavesMcpBloc? _bloc;

  @override
  void initState() {
    super.initState();
    if (widget.temPermissao) {
      _bloc = widget.criarBloc()..add(EcommerceChavesMcpIniciou(ecommerceId: widget.ecommerceId));
    }
  }

  @override
  void dispose() {
    _bloc?.close();
    super.dispose();
  }

  bool get _mobile => MediaQuery.sizeOf(context).width < SivDimensoes.breakpointMenuDrawer;

  Future<CriarChaveMcpResultado> _criar(String nome, List<String> escopos, DateTime? expiraEm) {
    final resposta = Completer<CriarChaveMcpResultado>();
    _bloc!.add(EcommerceChaveMcpCriou(nome: nome, escopos: escopos, expiraEm: expiraEm, resposta: resposta));
    return resposta.future;
  }

  Future<void> _abrirCriar() async {
    final mobile = _mobile;
    final resultado = await abrirModalChaveMcp<CriarChaveMcpResultado>(
      context,
      mobile: mobile,
      builder: (_) => CriarChaveMcpDialogo(
        mobile: mobile,
        tituloCanal: widget.tituloCanal ?? 'Canal ${widget.ecommerceId}',
        onCriar: _criar,
      ),
    );
    if (resultado == null || !mounted) return;
    await abrirModalChaveMcp<void>(
      context,
      mobile: mobile,
      dispensavel: false,
      builder: (_) => ChaveMcpExibicaoUnica(
        mobile: mobile,
        nome: resultado.registro.nome,
        chave: resultado.chave,
        urlMcp: widget.urlMcp,
        ecommerceId: widget.ecommerceId,
      ),
    );
    if (!mounted) return;
    SivAviso.mostrar(context, mensagem: 'Chave “${resultado.registro.nome}” criada. Configure-a no CRM.');
  }

  Future<void> _abrirRevogar(EcommerceChaveMcp chave) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: context.sivColors.acoEscuro.withValues(alpha: 0.45),
      builder: (_) => RevogarChaveMcpDialogo(
        chave: chave,
        onRevogar: () {
          final resposta = Completer<EcommerceChaveMcp>();
          _bloc!.add(EcommerceChaveMcpRevogou(chaveId: chave.id, resposta: resposta));
          return resposta.future;
        },
      ),
    );
    if (ok == true && mounted) SivAviso.mostrar(context, mensagem: 'Chave “${chave.nome}” revogada.');
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final titulo = widget.tituloCanal == null
        ? 'E-commerces / Agente de IA'
        : 'E-commerces / ${widget.tituloCanal} / Agente de IA';

    return Scaffold(
      backgroundColor: cores.superficie,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SivDimensoes.paginaHorizontal,
          vertical: SivDimensoes.paginaVertical,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SivTituloPagina(titulo: titulo),
            Expanded(child: widget.temPermissao ? _conteudo(context) : _semPermissao(context)),
          ],
        ),
      ),
    );
  }

  Widget _semPermissao(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 34, color: cores.aco),
            const SizedBox(height: 12),
            Text('Você não tem acesso a esta tela', style: textos.secao, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(children: [
                const TextSpan(text: 'Gerenciar as chaves do agente de vendas exige a permissão '),
                TextSpan(text: 'MCPFM001', style: textos.codigo),
                const TextSpan(text: '. Peça a um administrador para liberar no seu perfil.'),
              ]),
              textAlign: TextAlign.center,
              style: textos.corpo,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Voltar para E-commerces'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _conteudo(BuildContext context) {
    return BlocProvider<EcommerceChavesMcpBloc>.value(
      value: _bloc!,
      child: BlocBuilder<EcommerceChavesMcpBloc, EcommerceChavesMcpState>(
        builder: (context, state) {
          final mobile = _mobile;
          return ListView(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _abrirCriar,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('CRIAR CHAVE'),
                ),
              ),
              const SizedBox(height: SivDimensoes.gapCards),
              _DadosDeConexao(urlMcp: widget.urlMcp, ecommerceId: widget.ecommerceId, mobile: mobile),
              const SizedBox(height: SivDimensoes.gapCards),
              _cartaoChaves(context, state, mobile),
            ],
          );
        },
      ),
    );
  }

  Widget _cartaoChaves(BuildContext context, EcommerceChavesMcpState state, bool mobile) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    final carregado = state.step == EcommerceChavesMcpStep.carregado;

    final Widget corpo = switch (state.step) {
      EcommerceChavesMcpStep.carregando || EcommerceChavesMcpStep.inicial => _esqueleto(cores, textos),
      EcommerceChavesMcpStep.erro => _erro(cores, textos),
      EcommerceChavesMcpStep.vazio => _vazio(cores, textos),
      EcommerceChavesMcpStep.carregado => mobile
          ? Column(children: [for (final c in state.chaves) _CardChave(chave: c, onRevogar: _abrirRevogar)])
          : _tabela(context, state),
    };

    return _Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chaves de acesso', style: textos.secao),
                    Text(
                      'Cada chave é mostrada só uma vez, na criação. Aqui fica apenas a versão mascarada.',
                      style: textos.apoio.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (carregado)
                Text('${state.ativas} ${state.ativas == 1 ? 'ativa' : 'ativas'} · ${state.chaves.length} no total',
                    style: textos.apoio),
            ],
          ),
          const SizedBox(height: 12),
          corpo,
        ],
      ),
    );
  }

  Widget _esqueleto(SivColors cores, SivTextStyles textos) {
    Widget barra(double l, double a, double alpha) =>
        Container(width: l, height: a, color: cores.tinta.withValues(alpha: alpha));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [barra(130, 12, 0.09), const SizedBox(height: 6), barra(220, 10, 0.06)],
            ),
          ),
        Text('Carregando chaves…', style: textos.apoio.copyWith(fontSize: 12.5)),
      ],
    );
  }

  Widget _erro(SivColors cores, SivTextStyles textos) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: cores.falhaFundo, border: Border.all(color: cores.falhaBorda)),
      child: Wrap(
        spacing: 16,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Não foi possível carregar as chaves',
                  style: textos.secao.copyWith(color: cores.vinho, fontSize: 18)),
              Text('A conexão com o servidor falhou. Os dados de conexão acima continuam válidos.',
                  style: textos.apoio),
            ],
          ),
          OutlinedButton(
            onPressed: () => _bloc!.add(EcommerceChavesMcpIniciou(ecommerceId: widget.ecommerceId)),
            child: const Text('Tentar de novo'),
          ),
        ],
      ),
    );
  }

  Widget _vazio(SivColors cores, SivTextStyles textos) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(border: Border.all(color: cores.hairline)),
      child: Column(
        children: [
          Icon(Icons.vpn_key_outlined, size: 30, color: cores.aco),
          const SizedBox(height: 10),
          Text('Nenhuma chave criada', style: textos.secao),
          const SizedBox(height: 6),
          Text('Crie uma para conectar o agente de IA do CRM a este canal.',
              textAlign: TextAlign.center, style: textos.corpo),
          const SizedBox(height: 12),
          FilledButton(onPressed: _abrirCriar, child: const Text('CRIAR CHAVE')),
        ],
      ),
    );
  }

  Widget _tabela(BuildContext context, EcommerceChavesMcpState state) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    Widget cab(String t) => Text(t, style: textos.rotulo.copyWith(fontSize: 10.5));
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 9),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: cores.hairline))),
          child: _linhaTabela(
            cab('NOME / CHAVE'),
            cab('ESCOPOS'),
            cab('CRIADA EM'),
            cab('EXPIRA EM'),
            cab('ÚLTIMO ACESSO'),
            cab('SITUAÇÃO'),
            const SizedBox(),
          ),
        ),
        for (final c in state.chaves)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: cores.hairline))),
            child: _linhaTabela(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.nome, style: textos.secao.copyWith(fontSize: 16)),
                  Text(c.chaveMascarada, style: textos.codigo.copyWith(fontSize: 12)),
                ],
              ),
              _ChipsEscopos(escopos: c.escopos),
              Text(_data(c.criadoEm), style: textos.corpo),
              Text(c.expiraEm == null ? 'Sem expiração' : _data(c.expiraEm), style: textos.corpo),
              Text(_ultimoAcesso(c.ultimoAcessoEm), style: textos.corpo),
              _Situacao(chave: c),
              c.situacao == SituacaoChaveMcp.ativa
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _abrirRevogar(c),
                        style: TextButton.styleFrom(foregroundColor: cores.vinho),
                        child: const Text('Revogar'),
                      ),
                    )
                  : const SizedBox(),
            ),
          ),
      ],
    );
  }

  Widget _linhaTabela(Widget a, Widget b, Widget c, Widget d, Widget e, Widget f, Widget g) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 200, child: a),
          const SizedBox(width: 14),
          Expanded(child: b),
          const SizedBox(width: 14),
          SizedBox(width: 92, child: c),
          const SizedBox(width: 14),
          SizedBox(width: 110, child: d),
          const SizedBox(width: 14),
          SizedBox(width: 120, child: e),
          const SizedBox(width: 14),
          SizedBox(width: 124, child: f),
          const SizedBox(width: 14),
          SizedBox(width: 84, child: g),
        ],
      );
}

String _data(DateTime? d) => d == null ? '—' : formatarDataChaveMcp(d);

String _ultimoAcesso(DateTime? d) {
  if (d == null) return 'Nunca usada';
  final hm = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  final agora = DateTime.now();
  final hoje = d.year == agora.year && d.month == agora.month && d.day == agora.day;
  return hoje ? 'Hoje, $hm' : '${formatarDataChaveMcp(d)} $hm';
}

class _Cartao extends StatelessWidget {
  final Widget child;

  const _Cartao({required this.child});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    return Container(
      padding: const EdgeInsets.all(SivDimensoes.paddingCard),
      decoration: BoxDecoration(
        color: cores.superficie,
        border: Border.all(color: cores.hairline),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: child,
    );
  }
}

class _DadosDeConexao extends StatelessWidget {
  final String urlMcp;
  final int ecommerceId;
  final bool mobile;

  const _DadosDeConexao({required this.urlMcp, required this.ecommerceId, required this.mobile});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    Widget celula(String rotulo, Widget valor, String? apoio) => Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rotulo, style: textos.rotulo),
              const SizedBox(height: 8),
              valor,
              if (apoio != null) ...[
                const SizedBox(height: 8),
                Text(apoio, style: textos.apoio.copyWith(fontSize: 12)),
              ],
            ],
          ),
        );

    Widget comCopiar(Widget texto, String copiar) => Row(
          children: [
            Expanded(child: texto),
            const SizedBox(width: 10),
            BotaoCopiarChaveMcp(texto: copiar),
          ],
        );

    final url = celula(
      'URL DO MCP',
      comCopiar(SelectableText(urlMcp, style: textos.codigo.copyWith(fontSize: 13)), urlMcp),
      'Montada a partir da URL base da API.',
    );
    final id = celula(
      'ID DO E-COMMERCE',
      comCopiar(Text('$ecommerceId', style: textos.codigo.copyWith(fontSize: 20)), '$ecommerceId'),
      'Assina o token da conversa.',
    );
    final segredo = Container(
      color: cores.superficieRecuada,
      child: celula(
        'SEGREDO DA CONVERSA',
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.lock_outline, size: 15, color: cores.textoPrincipal.withValues(alpha: 0.6)),
              const SizedBox(width: 8),
              Text('Não é exibido aqui', style: textos.corpo),
            ]),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(children: [
                const TextSpan(text: 'Combine com o administrador o '),
                TextSpan(text: 'MCP_CONVERSA_SECRET', style: textos.codigo.copyWith(fontSize: 11.5)),
                const TextSpan(text: ', que fica no servidor e deve ser igual no CRM.'),
              ]),
              style: textos.apoio.copyWith(fontSize: 12),
            ),
          ],
        ),
        null,
      ),
    );

    return _Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DADOS DE CONEXÃO', style: textos.rotulo.copyWith(color: cores.aco)),
          Text('O que o CRM precisa para se conectar a este canal, além da chave.',
              style: textos.apoio.copyWith(fontSize: 13)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(border: Border.all(color: cores.hairline)),
            child: mobile
                ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [url, id, segredo])
                : IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 17, child: url),
                        Expanded(flex: 6, child: id),
                        Expanded(flex: 12, child: segredo),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChipsEscopos extends StatelessWidget {
  final List<String> escopos;

  const _ChipsEscopos({required this.escopos});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    Widget chip(String id) {
      final e = escoposMcp.where((x) => x.id == id).firstOrNull ??
          EscopoMcp(id, id, 'Escopo desconhecido');
      return Tooltip(
        richMessage: TextSpan(
          children: [
            TextSpan(text: '${e.id}\n', style: textos.codigo.copyWith(fontSize: 10.5, color: cores.ceu)),
            TextSpan(text: e.descricao, style: TextStyle(color: cores.textoSobreEscuroTitulo, fontSize: 12)),
            if (e.escrita)
              TextSpan(
                text: '\nEscrita: o agente cria registros no SIV.',
                style: TextStyle(color: cores.atencaoBorda, fontSize: 12),
              ),
          ],
        ),
        constraints: const BoxConstraints(maxWidth: 230),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: cores.acoEscuro),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: e.escrita ? cores.superficie : cores.selecaoFundo,
            border: e.escrita ? Border.all(color: cores.acoProfundo) : null,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (e.escrita) ...[
                Icon(Icons.edit_outlined, size: 10, color: cores.acoProfundo),
                const SizedBox(width: 5),
              ],
              Text(e.rotulo, style: textos.apoio.copyWith(fontSize: 11.5, color: cores.acoProfundo)),
            ],
          ),
        ),
      );
    }

    return Wrap(spacing: 5, runSpacing: 5, children: [for (final id in escopos) chip(id)]);
  }
}

class _Situacao extends StatelessWidget {
  final EcommerceChaveMcp chave;

  const _Situacao({required this.chave});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final (rotulo, fundo, texto, data) = switch (chave.situacao) {
      SituacaoChaveMcp.ativa => ('Ativa', cores.selecaoFundo, cores.acoProfundo, null),
      SituacaoChaveMcp.expirada => ('Expirada', cores.atencaoFundo, cores.atencao, chave.expiraEm),
      SituacaoChaveMcp.revogada => (
          'Revogada',
          cores.hairline,
          cores.textoPrincipal.withValues(alpha: 0.65),
          chave.revogadaEm,
        ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(color: fundo, borderRadius: BorderRadius.circular(3)),
          child: Text(rotulo, style: textos.apoio.copyWith(fontSize: 12, color: texto)),
        ),
        if (data != null)
          Text(
            chave.situacao == SituacaoChaveMcp.revogada
                ? 'em ${formatarDataChaveMcp(data)}'
                : formatarDataChaveMcp(data),
            style: textos.apoio.copyWith(fontSize: 11.5),
          ),
      ],
    );
  }
}

class _CardChave extends StatelessWidget {
  final EcommerceChaveMcp chave;
  final void Function(EcommerceChaveMcp) onRevogar;

  const _CardChave({required this.chave, required this.onRevogar});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    Widget linha(String r, String v) => Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(children: [
            SizedBox(width: 110, child: Text(r, style: textos.apoio.copyWith(fontSize: 12))),
            Expanded(child: Text(v, style: textos.corpo)),
          ]),
        );
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: cores.hairline),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chave.nome, style: textos.secao.copyWith(fontSize: 16)),
                    Text(chave.chaveMascarada, style: textos.codigo.copyWith(fontSize: 12)),
                  ],
                ),
              ),
              _Situacao(chave: chave),
            ],
          ),
          const SizedBox(height: 10),
          _ChipsEscopos(escopos: chave.escopos),
          const SizedBox(height: 6),
          linha('Criada em', _data(chave.criadoEm)),
          linha('Expira em', chave.expiraEm == null ? 'Sem expiração' : _data(chave.expiraEm)),
          linha('Último acesso', _ultimoAcesso(chave.ultimoAcessoEm)),
          if (chave.situacao == SituacaoChaveMcp.ativa)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => onRevogar(chave),
                style: TextButton.styleFrom(foregroundColor: cores.vinho),
                child: const Text('Revogar'),
              ),
            ),
        ],
      ),
    );
  }
}
