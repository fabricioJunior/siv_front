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

Map<String, Widget Function(BuildContext)> routes = {
  '/': (context) => const SplashPage(),
  '/home': (context) => const HomePage(),
  '/sincronizacao': (context) => const SyncPage(),
  ////AUTENTICACAO:
  '/login': (context) => const LoginPage(),
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
  '/pedidos': (context) {
    return _rotaProtegida(route: '/pedidos', child: const PedidosPage());
  },
  '/pedido': (context) {
    return PedidoPage(idPedido: args(context)['idPedido']);
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

  '/criar_romaneio_por_parametros': (context) {
    final argumentos = args(context);
    final hashLista =
        (argumentos['listaCompartilhadaHash'] ?? argumentos['hashLista'])
            ?.toString() ??
        '';

    return CriarRomaneioPorParametrosPage(hashLista: hashLista);
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
  '/referencia': (context) {
    return ReferenciaPage(idReferencia: args(context)['idReferencia']);
  },
  '/produtos': (context) {
    return ProdutosPage();
  },
  '/produto': (context) {
    return ProdutoPage(
      referenciaId: args(context)['referenciaId'],
      corId: args(context)['corId'],
      tamanhoId: args(context)['tamanhoId'],
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

  //CONFIGURACOES:
  '/configuracao_smtp': (context) {
    return ConfiguracaoSTMPPage();
  },
  '/parametros_empresa': (context) {
    return EmpresaParametrosPage(idEmpresa: args(context)['empresaId']);
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
  '/pedidos': ['PEDFC001', 'PEDFM001'],
  '/romaneios': ['ROMFP001'],
  '/estoque': ['PRDFL001'],
  '/entrada_manual_de_produtos': ['ROMFP001', 'ROMFP002'],
  '/pessoas': ['PESFM001'],
  '/menu_produtos': ['PRDFM003', 'PRDFM001', 'PRDFM004', 'PRDFM006'],
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
