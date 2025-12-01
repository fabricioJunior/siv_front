import 'package:autenticacao/pages.dart';
import 'package:empresas/presentation.dart';
import 'package:flutter/material.dart';
import 'package:pessoas/pages.dart';
import 'package:pessoas/presentation/pages/pontos_page.dart';
import 'package:siv_front/pages/home_page.dart';
import 'package:siv_front/pages/splash_page.dart';

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
    return SelecionarEmpresaPage();
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
    return PessoasPage();
  },
  '/pessoa': (context) {
    return PessoaPage(
      idPessoa: args(context)['idPessoa'],
    );
  },
  '/pontos_page': (context) {
    return PontosPage(
      idPessoa: args(context)['idPessoa'],
    );
  }
};

Map<String, dynamic> args(BuildContext context) =>
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
