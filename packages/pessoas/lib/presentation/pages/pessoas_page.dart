import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/presentation/bloc/pessoas_bloc/pessoas_bloc.dart';

import '../widgets/cliente_aba_comum.dart';
import '../widgets/pessoa_documento.dart';

class PessoasPage extends StatefulWidget {
  const PessoasPage({super.key});

  @override
  State<PessoasPage> createState() => _PessoasPageState();
}

class _PessoasPageState extends State<PessoasPage> {
  late final PessoasBloc bloc;
  late final Debouncer debouncer;
  late final ScrollController _scrollController;
  String _buscaAtual = '';
  bool _fornecedores = false;

  @override
  void initState() {
    super.initState();
    bloc = sl<PessoasBloc>();
    debouncer = Debouncer(milliseconds: 400);
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _recarregar() => bloc.add(
        PessoasIniciou(
          busca: _buscaAtual,
          eCliente: _fornecedores ? null : true,
          eFornecedor: _fornecedores ? true : null,
        ),
      );

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final limite = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= limite) {
      bloc.add(PessoasCarregouMais());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final mobile =
        MediaQuery.sizeOf(context).width < SivDimensoes.breakpointMenuDrawer;
    final pad = mobile ? 16.0 : SivDimensoes.paddingBarraTituloHorizontal;

    final busca = SizedBox(
      width: mobile ? null : 300,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar por nome, CPF/CNPJ',
          prefixIcon: const Icon(Icons.search),
          isDense: true,
        ),
        onChanged: (value) => debouncer.run(() {
          _buscaAtual = value;
          _recarregar();
        }),
        onSubmitted: (value) {
          _buscaAtual = value;
          _recarregar();
        },
      ),
    );
    final filtro = SegmentedButton<bool>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(value: false, label: Text('Clientes')),
        ButtonSegment(value: true, label: Text('Fornecedores')),
      ],
      selected: {_fornecedores},
      onSelectionChanged: (s) {
        setState(() => _fornecedores = s.first);
        _recarregar();
      },
    );

    return BlocProvider<PessoasBloc>(
      create: (context) => bloc
        ..add(PessoasIniciou(eCliente: true)),
      child: Scaffold(
        backgroundColor: cores.superficie,
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: pad, vertical: 14),
              decoration: BoxDecoration(
                color: cores.superficie,
                border: Border(bottom: BorderSide(color: cores.hairline)),
              ),
              child: Row(
                children: [
                  Expanded(child: Text('Pessoas', style: textos.secao)),
                  if (PermissaoPorNome.acessoPermitido('PESFM001'))
                    Builder(
                      builder: (context) => FilledButton(
                        onPressed: () async {
                          await Navigator.of(context).pushNamed('/pessoa');
                          if (mounted) _recarregar();
                        },
                        child: const Text('+ Novo cliente'),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad, vertical: 12),
              child: mobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [busca, const SizedBox(height: 8), filtro],
                    )
                  : Row(children: [busca, const Spacer(), filtro]),
            ),
            Expanded(
              child: BlocBuilder<PessoasBloc, PessoasState>(
                builder: (context, state) {
                  if (state is PessoasCarregarEmProgresso) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  if (state is! PessoasCarregarSucesso) {
                    return const SizedBox();
                  }
                  if (state.pessoas.isEmpty) return _vazio(textos);
                  return SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: pad),
                    child: Column(
                      children: [
                        mobile
                            ? _lista(context, state.pessoas)
                            : _tabela(context, state.pessoas),
                        if (state.carregandoMais)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator.adaptive(),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vazio(SivTextStyles textos) {
    final tipo = _fornecedores ? 'fornecedor' : 'cliente';
    return Center(
      child: Text(
        _buscaAtual.isEmpty
            ? 'Nenhum $tipo cadastrado ainda.'
            : 'Nenhum $tipo encontrado para "$_buscaAtual".',
        style: textos.apoio,
      ),
    );
  }

  void _abrir(Pessoa p) => Navigator.of(context).pushNamed(
        '/pessoa_visualizacao',
        arguments: {'idPessoa': p.id},
      );

  Widget _situacao(BuildContext context, Pessoa p) {
    final cores = context.sivColors;
    return p.bloqueado
        ? ClienteTag('Bloqueado',
            cor: cores.vinho, fundo: cores.vinho.withValues(alpha: 0.1))
        : const ClienteTag('Ativo');
  }

  Widget _tabela(BuildContext context, List<Pessoa> pessoas) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return SivTabela(
      colunas: const [
        SivTabelaColuna(titulo: 'NOME', flex: 4),
        SivTabelaColuna(titulo: 'CPF/CNPJ', flex: 2),
        SivTabelaColuna(titulo: 'UF', flex: 1),
        SivTabelaColuna(titulo: 'CONTATO', flex: 3),
        SivTabelaColuna(
            titulo: 'SITUAÇÃO', flex: 2, alinhamento: TextAlign.right),
      ],
      quantidadeLinhas: pessoas.length,
      onLinhaTap: (i) => _abrir(pessoas[i]),
      linhaBuilder: (context, i) {
        final p = pessoas[i];
        return [
          Text.rich(
            TextSpan(
              text: p.nome,
              style: textos.corpo,
              children: [
                if (p.tipoPessoa == TipoPessoa.juridica)
                  TextSpan(
                    text: '  PJ',
                    style: textos.apoio.copyWith(color: cores.textoApoio),
                  ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(mascararDocumento(p.documento) ?? '—', style: textos.apoio),
          Text(_ouTraco(p.uf), style: textos.apoio),
          Text(_ouTraco(p.contato),
              style: textos.apoio, overflow: TextOverflow.ellipsis),
          Align(
            alignment: Alignment.centerRight,
            child: _situacao(context, p),
          ),
        ];
      },
    );
  }

  String _ouTraco(String? s) => (s == null || s.isEmpty) ? '—' : s;

  Widget _lista(BuildContext context, List<Pessoa> pessoas) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return Column(
      children: [
        for (final p in pessoas)
          InkWell(
            onTap: () => _abrir(p),
            child: Container(
              constraints: const BoxConstraints(minHeight: 56),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: cores.hairline)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.nome,
                            style: textos.corpo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(
                          '${mascararDocumento(p.documento) ?? '—'} · ${_ouTraco(p.uf)}',
                          style: textos.apoio,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _situacao(context, p),
                  Icon(Icons.chevron_right, color: cores.textoApoio),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
