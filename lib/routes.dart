import 'package:autenticacao/pages.dart' hide SelecionarEmpresaPage;
import 'package:empresas/presentation.dart';
import 'package:estoque/presentation.dart';
import 'package:flutter/material.dart';
import 'package:pessoas/pages.dart';
import 'package:pessoas/presentation/pages/pontos_page.dart';
import 'package:pagamentos/pages.dart';
import 'package:precos/presentation.dart';
import 'package:produtos/presentation.dart';
import 'package:sistema/pages.dart';
import 'package:siv_front/presentation/pages/home_page.dart';
import 'package:siv_front/presentation/pages/selecionar_empresa_page.dart';
import 'package:siv_front/presentation/pages/splash_page.dart';

Map<String, Widget Function(BuildContext)> routes = {
  '/': (context) => const SplashPage(),
  '/home': (context) => const HomePage(),
  ////AUTENTICACAO:
  '/login': (context) => const LoginPage(),
  '/usuarios': (context) => const UsuariosPage(),
  '/usuario': (context) {
    return UsuarioPage(
      idUsuario: args(context)['idUsuario'],
    );
  },
  '/grupos_de_acesso': (context) {
    return const GruposDeAcessoPage();
  },
  '/grupo_de_acesso': (context) {
    return GrupoDeAcessoPage(
      idGrupoDeAcesso: args(context)['idGrupoDeAcesso'],
    );
  },
  '/vinculos_grupo_de_acesso_com_usuario': (context) {
    return VinculosGrupoDeAcessoComUsuarioPage(
      idUsuario: args(context)['idUsuario'],
    );
  },
  '/selecionar_empresa': (context) {
    return const SelecionarEmpresaPage();
  },

  ///EMPRESAS:
  '/empresas': (context) {
    return const EmpresasPage();
  },
  '/empresa': (context) {
    return EmpresaPage(
      idEmpresa: args(context)['idEmpresa'],
    );
  },

  ///PESSOAS:
  '/pessoas': (context) {
    return const PessoasPage();
  },
  '/pessoa': (context) {
    return PessoaPage(
      idPessoa: args(context)['idPessoa'],
    );
  },
  '/pessoa_visualizacao': (context) {
    return PessoaVisualizacaoPage(
      idPessoa: args(context)['idPessoa'],
    );
  },
  '/pontos_page': (context) {
    return PontosPage(
      idPessoa: args(context)['idPessoa'],
    );
  },
  '/enderecos_page': (context) {
    return EnderecosPage(
      idPessoa: args(context)['idPessoa'],
    );
  },
  '/selecionar_pessoa': (context) {
    final retorno = args(context)['retornarSomenteId'];
    final retornarSomenteId = retorno == true || retorno == 'true';
    return SelecionarPessoaPage(
      retornarSomenteId: retornarSomenteId,
    );
  },

  ///PAGAMENTOS:
  '/pagamentos_avulsos': (context) {
    return const PagamentosAvulsosPage();
  },
  '/pagamento_avulso': (context) {
    return PagamentoAvulsoPage();
  },

  ///PRODUTOS:
  '/menu_produtos': (context) {
    return const MenuProdutosPage();
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
    return CategoriaPage(
      idCategoria: args(context)['idCategoria'],
    );
  },
  '/referencias': (context) {
    return const ReferenciasPage();
  },
  '/referencia': (context) {
    return ReferenciaPage(
      idReferencia: args(context)['idReferencia'],
    );
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
    return TabelasDePrecoPage();
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
  '/estoque': (context) {
    return EstoqueSaldoPage(
      seletorCores: CorSeletor(modo: CorSeletorModo.multipla),
      seletorTamanhos: TamanhoSeletor(modo: TamanhoSeletorModo.multipla),
    );
  },

  //CONFIGURACOES:
  '/configuracao_smtp': (context) {
    return ConfiguracaoSTMPPage();
  },
  '/parametros_empresa': (context) {
    return EmpresaParametrosPage(
      idEmpresa: args(context)['empresaId'],
    );
  },
};

Map<String, dynamic> args(BuildContext context) =>
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
