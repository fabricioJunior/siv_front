import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/presentation/bloc/enderecos_bloc/enderecos_bloc.dart';
import 'package:pessoas/presentation/bloc/pessoa_bloc/pessoa_bloc.dart';
import 'package:pessoas/presentation/bloc/pontos_bloc/pontos_bloc.dart';

import '../widgets/cliente_abas.dart';
import '../widgets/cliente_cabecalho.dart';
import '../widgets/cliente_dados_aba.dart';
import '../widgets/cliente_enderecos_aba.dart';
import '../widgets/cliente_pontos_aba.dart';

typedef ClienteAbaBuilder = Widget Function(
  BuildContext context,
  int idPessoa,
  String nome,
);

/// Tela do cliente com abas (Dados, Endereços, Compras, Pontos, Crédito).
/// Mantém o nome histórico da classe usado em routes.dart.
class PessoaVisualizacaoPage extends StatefulWidget {
  final int idPessoa;
  final ClienteAba aba;

  /// Abre a transferência de crédito do cliente não cadastrado para esta
  /// pessoa; montado em routes.dart (pessoas não depende de comercial).
  final Future<bool> Function(BuildContext context, int idPessoa, String nome)?
      aoTransferirCredito;

  /// Conteúdo das abas de comercial, montado em routes.dart.
  final ClienteAbaBuilder? abaComprasBuilder;
  final ClienteAbaBuilder? abaCreditoBuilder;

  /// Dados do card Resumo que vêm de comercial, montados em routes.dart.
  final Future<ResumoCreditoCliente> Function(int idPessoa)? buscarSaldoCredito;
  final Future<String?> Function(int idPessoa)? buscarUltimaCompra;

  const PessoaVisualizacaoPage({
    required this.idPessoa,
    this.aba = ClienteAba.dados,
    this.aoTransferirCredito,
    this.abaComprasBuilder,
    this.abaCreditoBuilder,
    this.buscarSaldoCredito,
    this.buscarUltimaCompra,
    super.key,
  });

  @override
  State<PessoaVisualizacaoPage> createState() => _PessoaVisualizacaoPageState();
}

class _PessoaVisualizacaoPageState extends State<PessoaVisualizacaoPage> {
  late final PessoaBloc _bloc;
  late final PontosBloc _pontos;
  late final EnderecosBloc _enderecos;
  final _acoes = ClienteAcoes();
  late ClienteAba _aba = widget.aba;
  Future<ResumoCreditoCliente>? _saldo;
  Future<String?>? _ultimaCompra;

  @override
  void initState() {
    super.initState();
    _bloc = sl<PessoaBloc>()..add(_iniciar);
    _pontos = sl<PontosBloc>()..add(PontosIniciou(idPessoa: widget.idPessoa));
    _enderecos = sl<EnderecosBloc>()
      ..add(EnderecosIniciou(idPessoa: widget.idPessoa));
    _carregarResumo();
  }

  PessoaIniciou get _iniciar => PessoaIniciou(
        idPessoa: widget.idPessoa,
        tipoPessoa: TipoPessoa.fisica,
      );

  void _carregarResumo() {
    _saldo = widget.buscarSaldoCredito?.call(widget.idPessoa);
    _ultimaCompra = widget.buscarUltimaCompra?.call(widget.idPessoa);
  }

  @override
  void dispose() {
    _bloc.close();
    _pontos.close();
    _enderecos.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PessoaBloc>.value(value: _bloc),
        BlocProvider<PontosBloc>.value(value: _pontos),
        BlocProvider<EnderecosBloc>.value(value: _enderecos),
      ],
      child: ClienteAcoesEscopo(
        acoes: _acoes,
        child: Scaffold(
          backgroundColor: context.sivColors.papel,
          body: BlocBuilder<PessoaBloc, PessoaState>(
            builder: (context, state) {
              if (state.pessoaStep == PessoaStep.carregando &&
                  state.nome == null) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }
              return ListenableBuilder(
                listenable: _acoes,
                builder: (context, _) => _corpo(context, state),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _corpo(BuildContext context, PessoaState state) {
    final mobile =
        MediaQuery.sizeOf(context).width < SivDimensoes.breakpointMenuDrawer;
    final nome = state.nome ?? 'Pessoa #${widget.idPessoa}';
    final cidade = context
        .watch<EnderecosBloc>()
        .state
        .enderecos
        .where((e) => e.principal)
        .firstOrNull
        ?.municipio;
    final subtitulo = [_mascarar(state.documento), cidade]
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .join(' · ');
    final acoes = _acoesDaAba(state, nome);
    final principal = acoes.where((a) => a.primaria).firstOrNull;
    final secundaria = acoes.where((a) => !a.primaria).firstOrNull;

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: ClienteCabecalho(
            nome: nome,
            subtitulo: subtitulo.isEmpty ? null : subtitulo,
            bloqueado: state.bloqueado ?? false,
            mobile: mobile,
            acoes: acoes,
            aoEditar: PermissaoPorNome.acessoPermitido('PESFM001')
                ? _editarPessoa
                : null,
          ),
        ),
        ClienteAbas(
          selecionada: _aba,
          mobile: mobile,
          aoSelecionar: _abrirAba,
        ),
        Expanded(child: _conteudo(context, nome, mobile)),
        if (mobile && principal != null)
          SivRodapeAcoes(
            mobile: true,
            status: nome,
            secundaria: secundaria?.botao(),
            primaria: principal.botao(),
          ),
      ],
    );
  }

  Widget _conteudo(BuildContext context, String nome, bool mobile) {
    final id = widget.idPessoa;
    return switch (_aba) {
      ClienteAba.dados => ClienteDadosAba(
          mobile: mobile,
          saldoCredito: _saldo,
          ultimaCompra: _ultimaCompra,
          aoAbrirAba: _abrirAba,
        ),
      ClienteAba.compras =>
        widget.abaComprasBuilder?.call(context, id, nome) ?? _emBreve(),
      ClienteAba.credito =>
        widget.abaCreditoBuilder?.call(context, id, nome) ?? _emBreve(),
      ClienteAba.enderecos => ClienteEnderecosAba(idPessoa: id),
      ClienteAba.pontos => ClientePontosAba(idPessoa: id),
    };
  }

  /// Ao voltar para Dados, recarrega o resumo (crédito pode ter mudado).
  void _abrirAba(ClienteAba a) => setState(() {
        if (a == ClienteAba.dados && _aba != a) _carregarResumo();
        _aba = a;
      });

  Widget _emBreve() => Center(
        child: Text(
          _aba.rotulo,
          style: context.sivTextos.apoio
              .copyWith(color: context.sivColors.textoApoio),
        ),
      );

  List<ClienteAcaoBotao> _acoesDaAba(PessoaState state, String nome) {
    ClienteAcaoBotao? registrada(
      ClienteAcao acao,
      String rotulo,
      IconData icone, {
      bool primaria = false,
    }) {
      final cb = _acoes[acao];
      return cb == null
          ? null
          : ClienteAcaoBotao(
              rotulo: rotulo,
              icone: icone,
              aoPressionar: cb,
              primaria: primaria,
            );
    }

    final List<ClienteAcaoBotao?> lista = switch (_aba) {
      ClienteAba.dados => [
          if (PermissaoPorNome.acessoPermitido('PESFM001'))
            ClienteAcaoBotao(
              rotulo: 'Editar cadastro',
              icone: Icons.edit_outlined,
              aoPressionar: _editarPessoa,
            ),
        ],
      ClienteAba.enderecos => [
          registrada(ClienteAcao.novoEndereco, 'Novo endereço', Icons.add,
              primaria: true),
        ],
      ClienteAba.pontos => [
          registrada(
              ClienteAcao.resgatarPontos, 'Resgatar pontos', Icons.redeem),
          registrada(ClienteAcao.lancarPontos, 'Lançar pontos', Icons.add,
              primaria: true),
        ],
      ClienteAba.credito => [
          if (widget.aoTransferirCredito != null &&
              !(state.pessoa?.generica ?? false) &&
              PermissaoPorNome.acessoPermitido('PESFM004') &&
              PermissaoPorNome.acessoPermitido('PESFC004'))
            ClienteAcaoBotao(
              rotulo: 'Transferir do não cadastrado',
              icone: Icons.swap_horiz,
              aoPressionar: () async {
                final ok = await widget.aoTransferirCredito!(
                  context,
                  widget.idPessoa,
                  nome,
                );
                if (ok && mounted) setState(_carregarResumo);
              },
            ),
          registrada(ClienteAcao.adicionarCredito, 'Adicionar crédito',
              Icons.add,
              primaria: true),
        ],
      ClienteAba.compras => <ClienteAcaoBotao?>[],
    };
    return lista.whereType<ClienteAcaoBotao>().toList();
  }

  String? _mascarar(String? documento) {
    final d = (documento ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (d.length == 11) return '${d.substring(0, 3)}.***.***-${d.substring(9)}';
    if (d.length == 14) {
      return '${d.substring(0, 2)}.***.***/****-${d.substring(12)}';
    }
    return null;
  }

  Future<void> _editarPessoa() async {
    final alterou = await Navigator.of(context).pushNamed(
      '/pessoa',
      arguments: {'idPessoa': widget.idPessoa},
    );
    if (!mounted) return;
    if (alterou == true) _bloc.add(_iniciar);
  }
}
