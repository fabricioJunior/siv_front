import 'dart:async';

import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:siv_front/presentation/bloc/app_bloc/app_bloc.dart';

// Rota '/' é o fallback do Navigator (ex.: browser back no web voltando até
// a entrada de histórico anterior a qualquer navegação da SPA). Sem
// redirecionamento, a tela ficava presa aqui indefinidamente -- nada mais
// navegava pra fora dela.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  StreamSubscription<AppState>? _subscription;

  @override
  void initState() {
    super.initState();
    final appBloc = sl<AppBloc>();
    _tentarRedirecionar(appBloc.state);
    _subscription = appBloc.stream.listen(_tentarRedirecionar);
  }

  void _tentarRedirecionar(AppState state) {
    final destino = switch (state.statusAutenticacao) {
      StatusAutenticacao.autenticado => '/home',
      StatusAutenticacao.naoAutenticao => '/login',
      _ => null,
    };
    if (destino == null || !mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pushReplacementNamed(destino);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
        ],
      )),
    );
  }
}
