import 'package:autenticacao/presentation/pages/login_page.dart';
import 'package:autenticacao/presentation/pages/usuario_page.dart';
import 'package:autenticacao/presentation/pages/usuarios_page.dart';
import 'package:empresas/presentation.dart';
import 'package:flutter/material.dart';
import 'package:siv_front/pages/home_page.dart';
import 'package:siv_front/pages/splash_page.dart';

Map<String, Widget Function(BuildContext)> routes = {
  '/': (context) => const SplashPage(),
  '/home': (context) => const HomePage(),
  '/login': (context) => const LoginPage(),
  '/usuarios': (context) => const UsuariosPage(),
  '/usuario': (context) {
    return UsuarioPage(
      idUsuario: args(context)['idUsuario'],
    );
  },
  '/empresas': (context) {
    return const EmpresasPage();
  },
  '/empresa': (context) {
    return EmpresaPage(
      idEmpresa: args(context)['idEmpresa'],
    );
  }
};

Map<String, dynamic> args(BuildContext context) =>
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
