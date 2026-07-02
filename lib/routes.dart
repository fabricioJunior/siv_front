import 'package:autenticacao/pages.dart' hide SelecionarEmpresaPage;
import 'package:autenticacao/models.dart' show TerminalDoUsuario;
import 'package:comercial/pages.dart';
import 'package:empresas/presentation.dart';
import 'package:estoque/presentation.dart';
import 'package:core/injecoes.dart';
import 'package:core/permissoes/componente_controlado_wiget.dart';
import 'package:core/sessao.dart';
import 'package:financeiro/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pessoas/models.dart' show TipoFuncionario;
import 'package:pessoas/pages.dart';
import 'package:pessoas/presentation/pages/pontos_page.dart';
import 'package:pagamentos/pages.dart';
import 'package:precos/presentation.dart';
import 'package:produtos/presentation.dart';
import 'package:sistema/pages.dart';
import 'package:siv_front/presentation/pages/administracao_menu_page.dart';
import 'package:siv_front/presentation/pages/selecionar_terminal_page.dart';
import 'package:siv_front/presentation/pages/home_page.dart';
import 'package:siv_front/presentation/pages/selecionar_empresa_page.dart';
import 'package:siv_front/presentation/pages/splash_page.dart';
import 'package:siv_front/presentation/pages/sync_page.dart';
import 'package:core/impressora.dart';

Map<String, Widget Function(BuildContext)> routes = {
  '/': (context) => const SplashPage(),
  '/home': (context) => const HomePage(),
  '/sincronizacao': (context) => const SyncPage(),
  '/impressao_progress': (context) => ImpressaoProgressPage(
    itens: args(context)['itens'],
    quantidadeDeVias: args(context)['quantidadeDeVias'] ?? 1,
  ),
  ////AUTENTICACAO:
  '/login': (context) =>
      LoginPage(trocandoDeEmpresa: args(context)['trocandoDeEmpresa'] ?? false),
  '/usuarios': (context) => const UsuariosPage(),
  '/usuario': (context) {
    return UsuarioPage(idUsuario: args(context)['idUsuario']);
  },
  '/grupos_de_acesso': (context) {
    return const GruposDeAcessoPage();
  },
  '/grupo_de_acesso': (context) {
    return GrupoDeAcessoPage(idGrupoDeAcesso: args(context)['idGrupoDeAcesso']);
  },
  '/vinculos_grupo_de_acesso_com_usuario': (context) {
    return VinculosGrupoDeAcessoComUsuarioPage(
      idUsuario: args(context)['idUsuario'],
    );
  },
  '/vinculos_terminais_com_usuario': (context) {
    return TerminaisDoUsuarioPage(idUsuario: args(context)['idUsuario']);
  },
  '/selecionar_empresa': (context) {
    return const SelecionarEmpresaPage();
  },
  '/selecionar_terminal': (context) {
    final terminaisArg = args(context)['terminais'];
    final terminais = terminaisArg is List<TerminalDoUsuario>
        ? terminaisArg
        : const <TerminalDoUsuario>[];

    return SelecionarTerminalPage(terminais: terminais);
  },

  ///EMPRESAS:
  '/empresas': (context) {
    return const EmpresasPage();
  },
  '/empresa': (context) {
    return EmpresaPage(idEmpresa: args(context)['idEmpresa']);
  },
  '/terminais': (context) {
    final empresaIdArg = args(context)['empresaId'];
    final empresaId = empresaIdArg is int
        ? empresaIdArg
        : int.tryParse(empresaIdArg?.toString() ?? '') ?? 0;
    return TerminaisPage(empresaId: empresaId);
  },

  ///PESSOAS:
  '/pessoas': (context) {
    return _rotaProtegida(route: '/pessoas', child: const PessoasPage());
  },
  '/pessoa': (context) {
    return PessoaPage(idPessoa: args(context)['idPessoa']);
  },
  '/pessoa_visualizacao': (context) {
    return PessoaVisualizacaoPage(idPessoa: args(context)['idPessoa']);
  },
  '/pontos_page': (context) {
    return PontosPage(idPessoa: args(context)['idPessoa']);
  },
  '/enderecos_page': (context) {
    return EnderecosPage(idPessoa: args(context)['idPessoa']);
  },
  '/selecionar_pessoa': (context) {
    final retorno = args(context)['retornarSomenteId'];
    final retornarSomenteId = retorno == true || retorno == 'true';
    return SelecionarPessoaPage(retornarSomenteId: retornarSomenteId);
  },

  ///PAGAMENTOS:
  '/pagamentos_avulsos': (context) {
    return _rotaProtegida(
      route: '/pagamentos_avulsos',
      child: const PagamentosAvulsosPage(),
    );
  },
  '/pagamento_avulso': (context) {
    return _rotaProtegida(
      route: '/pagamento_avulso',
      child: PagamentoAvulsoPage(),
    );
  },
  '/formas_de_pagamento': (context) {
    return _rotaProtegida(
      route: '/formas_de_pagamento',
      child: FormasDePagamentoPage(),
    );
  },
  '/forma_de_pagamento': (context) {
    return FormaDePagamentoPage(
      idFormaDePagamento: args(context)['idFormaDePagamento'],
    );
  },
  '/financeiro': (context) {
    return _rotaProtegida(
      route: '/financeiro',
      child: const FinanceiroMenuPage(),
    );
  },
  '/fluxo_de_caixa': (context) {
    final sessao = sl<IAcessoGlobalSessao>();
    final empresaIdArg = args(context)['empresaId'];
    final terminalIdArg = args(context)['terminalId'];

    final empresaId = empresaIdArg is int
        ? empresaIdArg
        : int.tryParse(empresaIdArg?.toString() ?? '');
    final terminalId = terminalIdArg is int
        ? terminalIdArg
        : int.tryParse(terminalIdArg?.toString() ?? '');

    return _rotaProtegida(
      route: '/fluxo_de_caixa',
      child: FluxoDeCaixaPage(
        empresaId: empresaId ?? sessao.empresaIdDaSessao,
        terminalId: terminalId ?? sessao.terminalIdDaSessao,
      ),
    );
  },
  '/suprimentos': (context) {
    final caixaIdArg = args(context)['caixaId'];
    final caixaId = caixaIdArg is int
        ? caixaIdArg
        : int.tryParse(caixaIdArg?.toString() ?? '') ?? 0;

    return _rotaProtegida(
      route: '/suprimentos',
      child: SuprimentosPage(caixaId: caixaId),
    );
  },
  '/suprimento': (context) {
    final caixaIdArg = args(context)['caixaId'];
    final caixaId = caixaIdArg is int
        ? caixaIdArg
        : int.tryParse(caixaIdArg?.toString() ?? '') ?? 0;

    return _rotaProtegida(
      route: '/suprimento',
      child: SuprimentoPage(caixaId: caixaId),
    );
  },
  '/sangrias': (context) {
    final caixaIdArg = args(context)['caixaId'];
    final caixaId = caixaIdArg is int
        ? caixaIdArg
        : int.tryParse(caixaIdArg?.toString() ?? '') ?? 0;

    return _rotaProtegida(
      route: '/sangrias',
      child: SangriasPage(caixaId: caixaId),
    );
  },
  '/sangria': (context) {
    final caixaIdArg = args(context)['caixaId'];
    final caixaId = caixaIdArg is int
        ? caixaIdArg
        : int.tryParse(caixaIdArg?.toString() ?? '') ?? 0;

    return _rotaProtegida(
      route: '/sangria',
      child: SangriaPage(caixaId: caixaId),
    );
  },
  '/contagem_do_caixa': (context) {
    final caixaIdArg = args(context)['caixaId'];
    final caixaId = caixaIdArg is int
        ? caixaIdArg
        : int.tryParse(caixaIdArg?.toString() ?? '') ?? 0;

    return _rotaProtegida(
      route: '/contagem_do_caixa',
      child: ContagemDoCaixaPage(caixaId: caixaId),
    );
  },
  '/administracao': (context) {
    return _rotaProtegida(
      route: '/administracao',
      child: const AdministracaoMenuPage(),
    );
  },

  ///COMERCIAL:
  '/comercial': (context) {
    return _rotaProtegida(
      route: '/comercial',
      child: const ComercialMenuPage(),
    );
  },
  '/venda': (context) {
    return _rotaProtegida(
      route: '/venda',
      child: VendaPage(
        pessoaSeletor: ({itemsSelecionadosInicial, onChanged, onlyView}) =>
            SeletorPessoa(
              titulo: 'Cliente',
              itemsSelecionadosInicial: itemsSelecionadosInicial,
              retornarSomenteId: false,
              onChanged: onChanged,
              onlyView: onlyView ?? false,
            ),
        vendedoresSeletor: ({itemsSelecionadosInicial, onChanged, onlyView}) =>
            FuncionarioSeletor(
              modo: FuncionarioSeletorModo.unica,
              tipoFuncionario: TipoFuncionario.vendedor,
              itemsSelecionadosInicial: itemsSelecionadosInicial ?? const [],
              onChanged: onChanged,
              onlyView: onlyView ?? false,
              titulo: 'Vendedor',
            ),
        tabelasDePrecoSeletor:
            ({itemsSelecionadosInicial, onChanged, onlyView}) =>
                TabelasDePrecoSeletor(
                  titulo: 'Tabela de preço',
                  modo: TabelasDePrecoSeletorModo.unica,
                  itemsSelecionadosInicial: itemsSelecionadosInicial,
                  onChanged: onChanged,
                  onlyView: onlyView ?? false,
                ),
        formasDePagamentoSeletor:
            ({itemsSelecionadosInicial, onChanged, onlyView}) =>
                FormasDePagamentoSeletor(
                  modo: FormasDePagamentoSeletorModo.unica,
                  itemsSelecionadosInicial: itemsSelecionadosInicial,
                  onChanged: onChanged,
                  onlyView: onlyView ?? false,
                  titulo: 'Forma de pagamento',
                ),
      ),
    );
  },
  '/devolucao': (context) {
    return _rotaProtegida(route: '/devolucao', child: const DevolucaoPage());
  },
  '/credito_devolucao_movimentacoes': (context) {
    final pessoaIdArg = args(context)['pessoaId'];
    final pessoaId = pessoaIdArg is int
        ? pessoaIdArg
        : int.tryParse(pessoaIdArg?.toString() ?? '');

    return _rotaProtegida(
      route: '/credito_devolucao_movimentacoes',
      child: CreditoDevolucaoMovimentacoesPage(pessoaId: pessoaId ?? 0),
    );
  },
  '/documentos_fiscais': (context) {
    return _rotaProtegida(
      route: '/documentos_fiscais',
      child: const DocumentosFiscaisPage(),
    );
  },
  '/documento_fiscal': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return _rotaProtegida(
      route: '/documento_fiscal',
      child: DocumentoFiscalPage(documentoId: args['id'] as int),
    );
  },
  '/configuracao_fiscal': (context) {
    return _rotaProtegida(
      route: '/configuracao_fiscal',
      child: const ConfiguracaoFiscalPage(),
    );
  },
  '/relatorio_faturamento': (context) {
    return _rotaProtegida(
      route: '/relatorio_faturamento',
      child: const RelatorioFaturamentoPage(),
    );
  },
  '/relatorio_curva_abc': (context) {
    return _rotaProtegida(
      route: '/relatorio_curva_abc',
      child: const RelatorioCurvaAbcPage(),
    );
  },
  '/relatorio_clientes_ativos': (context) {
    return _rotaProtegida(
      route: '/relatorio_clientes_ativos',
      child: const RelatorioClientesAtivosPage(),
    );
  },
  '/pedidos': (context) {
    return _rotaProtegida(route: '/pedidos', child: const PedidosPage());
  },
  '/pedido': (context) {
    return PedidoPage(
      idPedido: args(context)['idPedido'],
      funcionarioSeletor: ({itemsSelecionadosInicial, onChanged, onlyView}) =>
          FuncionarioSeletor(
            modo: FuncionarioSeletorModo.unica,
            itemsSelecionadosInicial: itemsSelecionadosInicial ?? const [],
            onChanged: onChanged,
            onlyView: onlyView ?? false,
            titulo: 'Funcionário',
          ),
      tabelaDePrecoSeletor: ({itemsSelecionadosInicial, onChanged, onlyView}) =>
          TabelasDePrecoSeletor(
            modo: TabelasDePrecoSeletorModo.unica,
            itemsSelecionadosInicial: itemsSelecionadosInicial,
            onChanged: onChanged,
            onlyView: onlyView ?? false,
            titulo: 'Tabela de preço',
          ),
    );
  },
  '/romaneios': (context) {
    return _rotaProtegida(route: '/romaneios', child: const RomaneiosPage());
  },
  '/romaneio': (context) {
    return RomaneioPage(
      idRomaneio: args(context)['idRomaneio'],
      permitirEdicao: args(context)['permitirEdicao'] ?? true,
      funcionarioSeletor: ({itemsSelecionadosInicial, onChanged, onlyView}) =>
          FuncionarioSeletor(
            modo: FuncionarioSeletorModo.unica,
            itemsSelecionadosInicial: itemsSelecionadosInicial ?? const [],
            onChanged: onChanged,
            onlyView: onlyView ?? false,
          ),
      tableDePrecoSeletor: ({itemsSelecionadosInicial, onChanged, onlyView}) =>
          TabelasDePrecoSeletor(
            modo: TabelasDePrecoSeletorModo.unica,
            itemsSelecionadosInicial: itemsSelecionadosInicial,
            onlyView: onlyView ?? false,
          ),
      pessoaSeletor: ({itemsSelecionadosInicial, onChanged, onlyView}) =>
          SeletorPessoa(
            itemsSelecionadosInicial: itemsSelecionadosInicial,
            retornarSomenteId: false,
            onChanged: onChanged,
            onlyView: onlyView ?? false,
          ),
    );
  },
  '/cancelar_romaneio': (context) {
    final idRomaneioArg = args(context)['idRomaneio'];
    final idRomaneio = idRomaneioArg is int
        ? idRomaneioArg
        : int.tryParse(idRomaneioArg?.toString() ?? '');

    return _rotaProtegida(
      route: '/cancelar_romaneio',
      child: CancelamentoRomaneioPage(idRomaneio: idRomaneio),
    );
  },

  '/criar_romaneio_por_parametros': (context) {
    final argumentos = args(context);
    final hashLista =
        (argumentos['listaCompartilhadaHash'] ?? argumentos['hashLista'])
            ?.toString() ??
        '';
    final descontoArg = argumentos['desconto'];
    final desconto = descontoArg is num
        ? descontoArg.toDouble()
        : double.tryParse(descontoArg?.toString() ?? '') ?? 0;
    final formasDePagamentoRaw =
        argumentos['formasDePagamentoRealizadas'] as List<dynamic>? ?? const [];
    final formasDePagamentoRealizadas = formasDePagamentoRaw
        .whereType<Map<String, dynamic>>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);

    return CriarRomaneioPorParametrosPage(
      hashLista: hashLista,
      formasDePagamentoRealizadas: formasDePagamentoRealizadas,
      desconto: desconto,
    );
  },

  ///PRODUTOS:
  '/menu_produtos': (context) {
    return _rotaProtegida(
      route: '/menu_produtos',
      child: const MenuProdutosPage(),
    );
  },
  '/tamanhos': (context) {
    return TamanhosPage();
  },
  '/cores': (context) {
    return CoresPage();
  },
  '/marcas': (context) {
    return MarcasPage();
  },
  '/categorias': (context) {
    return CategoriasPage();
  },
  '/produtos/categoria': (context) {
    return CategoriaPage(idCategoria: args(context)['idCategoria']);
  },
  '/referencias': (context) {
    return const ReferenciasPage();
  },
  '/referencias_pendentes_ncm': (context) {
    return const ReferenciasPendentesNcmPage();
  },
  '/referencia': (context) {
    return ReferenciaPage(idReferencia: args(context)['idReferencia']);
  },
  '/produtos': (context) {
    return ProdutosPage();
  },
  '/selecionar_produtos': (context) {
    final raw = args(context)['idsSelecionados'];
    final idsSelecionados = raw is List
        ? raw
              .map((e) => e is int ? e : int.tryParse(e.toString()))
              .whereType<int>()
              .toList()
        : const <int>[];
    return SelecionarProdutosPage(idsSelecionadosIniciais: idsSelecionados);
  },
  '/selecionar_referencias': (context) {
    final raw = args(context)['idsSelecionados'];
    final idsSelecionados = raw is List
        ? raw
              .map((e) => e is int ? e : int.tryParse(e.toString()))
              .whereType<int>()
              .toList()
        : const <int>[];
    return SelecionarReferenciasPage(idsSelecionadosIniciais: idsSelecionados);
  },
  '/selecionar_referencias_balanco': (context) {
    final raw = args(context)['idsSelecionados'];
    final idsSelecionados = raw is List
        ? raw
              .map((e) => e is int ? e : int.tryParse(e.toString()))
              .whereType<int>()
              .toList()
        : const <int>[];
    return SelecionarReferenciasPage(idsSelecionadosIniciais: idsSelecionados);
  },
  '/produto': (context) {
    return ProdutoPage(
      referenciaId: args(context)['referenciaId'],
      corId: args(context)['corId'],
      tamanhoId: args(context)['tamanhoId'],
    );
  },
  '/etiquetas': (context) {
    return _rotaProtegida(route: '/etiquetas', child: EtiquetasPage());
  },
  '/impressao_etiquetas': (context) {
    return _rotaProtegida(
      route: '/impressao_etiquetas',
      child: ImpressaoDeEtiquetasPage(
        tabelasDePrecoSeletor:
            ({itemsSelecionadosInicial, onChanged, onlyView}) =>
                TabelasDePrecoSeletor(
                  modo: TabelasDePrecoSeletorModo.unica,
                  itemsSelecionadosInicial: itemsSelecionadosInicial,
                  onChanged: onChanged,
                  onlyView: onlyView ?? false,
                  titulo: 'Tabela de preco',
                ),
      ),
    );
  },

  //Preços:
  '/tabelas_de_preco': (context) {
    return _rotaProtegida(
      route: '/tabelas_de_preco',
      child: TabelasDePrecoPage(),
    );
  },
  '/selecionar_tabela_de_preco': (context) {
    return SelecionarTabelaDePrecoPage();
  },
  '/tabela_de_preco_detalhe': (context) {
    return TabelaDePrecoDetalhePage(
      idTabelaDePreco: args(context)['idTabelaDePreco'],
    );
  },
  '/preco_da_referencia_page': (context) {
    return PrecoDaReferenciaPage(
      tabelaDePrecoId: args(context)['tabelaDePrecoId'],
      referenciaId: args(context)['referenciaId'],
      referenciaNome: args(context)['referenciaNome'],
      valorInicial: args(context)['valorInicial'],
      imagensDaReferencia: ReferenciaMidiasWidget(
        referenciaId: args(context)['referenciaId'],
      ),
    );
  },
  //Estoque:
  '/estoque': (context) {
    return _rotaProtegida(
      route: '/estoque',
      child: EstoqueSaldoPage(
        seletorCores: ({itemsSelecionadosInicial, onChanged, onlyView}) =>
            CorSeletor(modo: CorSeletorModo.multipla, onChanged: onChanged),
        seletorTamanhos: ({itemsSelecionadosInicial, onChanged, onlyView}) =>
            TamanhoSeletor(
              modo: TamanhoSeletorModo.multipla,
              onChanged: onChanged,
            ),
      ),
    );
  },
  '/entrada_manual_de_produtos': (context) {
    return _rotaProtegida(
      route: '/entrada_manual_de_produtos',
      child: EntradaManulDeProdutosPage(
        funcionariosSeletor:
            ({itemsSelecionadosInicial, onChanged, onlyView}) =>
                FuncionarioSeletor(
                  modo: FuncionarioSeletorModo.unica,
                  onChanged: onChanged,
                  itemsSelecionadosInicial:
                      itemsSelecionadosInicial ?? const [],
                ),
        tabelasDePrecoSeletor:
            ({itemsSelecionadosInicial, onChanged, onlyView}) =>
                TabelasDePrecoSeletor(
                  modo: TabelasDePrecoSeletorModo.unica,
                  onChanged: onChanged,
                ),
      ),
    );
  },

  // Balanço:
  '/balancos': (context) {
    return _rotaProtegida(
      route: '/balancos',
      child: BlocProvider(
        create: (_) => sl<BalancoBloc>(),
        child: const BalancosPage(),
      ),
    );
  },
  '/criar_balanco': (context) {
    return _rotaProtegida(
      route: '/criar_balanco',
      child: BlocProvider(
        create: (_) => sl<BalancoBloc>(),
        child: const CriarBalancoPage(),
      ),
    );
  },
  '/detalhes_balanco': (context) {
    final balancoId = args(context)['balancoId'] ?? 0;
    return _rotaProtegida(
      route: '/detalhes_balanco',
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<BalancoBloc>()),
          BlocProvider(create: (_) => sl<BalancoItensBloc>()),
          BlocProvider(create: (_) => sl<LotesBloc>()),
        ],
        child: DetalhesBalancoPage(balancoId: balancoId),
      ),
    );
  },
  '/adicionar_itens_balanco': (context) {
    final balancoId = args(context)['balancoId'] ?? 0;
    return _rotaProtegida(
      route: '/adicionar_itens_balanco',
      child: BlocProvider(
        create: (_) => sl<BalancoBloc>(),
        child: AdicionarItensBalancoPage(balancoId: balancoId),
      ),
    );
  },
  '/criar_lote_balanco': (context) {
    final balancoId = args(context)['balancoId'] ?? 0;
    return _rotaProtegida(
      route: '/criar_lote_balanco',
      child: BlocProvider(
        create: (_) => sl<LoteBloc>(),
        child: CriarLoteBalancoPage(balancoId: balancoId),
      ),
    );
  },
  '/detalhes_lote_balanco': (context) {
    final arguments = args(context);
    final balancoId = arguments['balancoId'] ?? 0;
    final loteId = arguments['loteId'] ?? 0;
    final balancoFinalizado = arguments['balancoFinalizado'] == true;
    return _rotaProtegida(
      route: '/detalhes_lote_balanco',
      child: BlocProvider(
        create: (_) => sl<LoteBloc>(),
        child: DetalhesLoteBalancoPage(
          balancoId: balancoId,
          loteId: loteId,
          balancoFinalizado: balancoFinalizado,
        ),
      ),
    );
  },

  //CONFIGURACOES:
  '/configuracoes': (context) {
    return const ConfiguracoesPage();
  },
  '/configuracao_smtp': (context) {
    return ConfiguracaoSTMPPage();
  },
  '/configuracao_dispositivo': (context) {
    return const ConfiguracaoDispositivoPage();
  },
  '/parametros_empresa': (context) {
    return EmpresaParametrosPage(idEmpresa: args(context)['empresaId']);
  },
  // Impressoras:
  '/etiqueta_preview_page': (context) {
    final argumentos = args(context);
    final overridesRaw = argumentos['overrides'];
    final overrides = overridesRaw is Map
        ? overridesRaw.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          )
        : null;
    final retornarResultado = argumentos['retornarResultado'] == true;

    return EtiquetaPreviewPage(
      overrides: overrides,
      retornarResultado: retornarResultado,
    );
  },
};

Map<String, dynamic> args(BuildContext context) =>
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};

Widget _rotaProtegida({required String route, required Widget child}) {
  final componentes = _componentesDaRota[route];
  if (componentes == null || componentes.isEmpty) {
    return child;
  }

  if (componentes.any(PermissaoPorNome.acessoPermitido)) {
    return child;
  }

  return const _AcessoNegadoPage();
}

const Map<String, List<String>> _componentesDaRota = {
  '/comercial': ['PEDFC001', 'ROMFP001'],
  '/venda': ['PEDFC001', 'ROMFP001'],
  '/devolucao': ['PEDFC001', 'ROMFP001'],
  '/credito_devolucao_movimentacoes': ['PEDFC001', 'ROMFP001'],
  '/documentos_fiscais': ['FISFM001'],
  '/documento_fiscal': ['FISFM001'],
  '/configuracao_fiscal': ['FISFM001'],
  '/relatorio_faturamento': ['RELFC001'],
  '/relatorio_curva_abc': ['RELFC002'],
  '/relatorio_clientes_ativos': ['RELFC003'],
  '/pedidos': ['PEDFC001', 'PEDFM001'],
  '/romaneios': ['ROMFP001'],
  '/cancelar_romaneio': ['ROMFP001'],
  '/estoque': ['PRDFL001'],
  '/balancos': ['PRDFL001'],
  '/criar_balanco': ['PRDFL001'],
  '/detalhes_balanco': ['PRDFL001'],
  '/adicionar_itens_balanco': ['PRDFL001'],
  '/criar_lote_balanco': ['PRDFL001'],
  '/detalhes_lote_balanco': ['PRDFL001'],
  '/entrada_manual_de_produtos': ['ROMFP001', 'ROMFP002'],
  '/pessoas': ['PESFM001', 'PESFC001', 'PESFC002', 'PESFC003'],
  '/menu_produtos': ['PRDFM003', 'PRDFM001', 'PRDFM004', 'PRDFM006'],
  '/selecionar_produtos': ['PRDFM003', 'PRDFM001', 'PRDFM004', 'PRDFM006'],
  '/selecionar_referencias': ['PRDFM003', 'PRDFM001', 'PRDFM004', 'PRDFM006'],
  '/selecionar_referencias_balanco': [
    'PRDFM003',
    'PRDFM001',
    'PRDFM004',
    'PRDFM006',
  ],
  '/etiquetas': ['PRDFM003'],
  '/impressao_etiquetas': ['PRDFM003'],
  '/financeiro': ['GERFM001', 'FCXFP001', 'PRDFM010', 'PAGFM001'],
  '/formas_de_pagamento': ['GERFM001'],
  '/fluxo_de_caixa': ['FCXFP001', 'FCXFP002', 'FCXFL001'],
  '/tabelas_de_preco': ['PRDFM010'],
  '/pagamentos_avulsos': ['PAGFM001', 'PAGFP005'],
  '/pagamento_avulso': ['PAGFM001'],
  '/administracao': ['ADMFM001', 'ADMFM004', 'SYSFM001'],
};

class _AcessoNegadoPage extends StatelessWidget {
  const _AcessoNegadoPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acesso bloqueado')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline,
                size: 44,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Você não possui permissão para acessar esta funcionalidade. Consulte o administrador do sistema.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
