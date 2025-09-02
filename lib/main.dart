import 'dart:developer';

import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/isar_anotacoes.dart';
import 'package:flutter/material.dart';
import 'package:siv_front/bloc/app_bloc.dart';
import 'package:siv_front/injections.dart';
import 'package:siv_front/routes.dart';

//https://apollo-api-stg.coralcloud.app/docs

void main() async {
  await sl.reset();
  await configs();

  runApp(MyApp());
}

Future<void> configs() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initIsarDatabase();
  resolverDependenciasApp();

  Bloc.observer = GlobalBlocObserver();
}

class MyApp extends StatelessWidget {
  final String? routeToTest;

  MyApp({
    super.key,
    this.routeToTest,
  });
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: sl<AppBloc>().state.statusAutenticacao ==
              StatusAutenticacao.autenticado
          ? '/home'
          : '/login',
      routes: routes,
      navigatorKey: navigatorKey,
      title: 'Flutter Demo',
      builder: (context, child) {
        return BlocListener<AppBloc, AppState>(
          bloc: sl<AppBloc>(),
          listener: (context, state) {
            if (state.statusAutenticacao == StatusAutenticacao.autenticado) {
              if (routeToTest != null) {
                Navigator.of(navigatorKey.currentContext!)
                    .pushNamed(routeToTest!);
              } else {
                Navigator.of(navigatorKey.currentContext!).pushNamed('/home');
              }
            }
            if (state.statusAutenticacao == StatusAutenticacao.naoAutenticao) {
              Navigator.of(navigatorKey.currentContext!).pushNamed('/login');
            }
          },
          child: child,
        );
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}

class GlobalBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    log('${bloc.runtimeType} $event', name: 'Test log');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log('${bloc.runtimeType} $change', name: 'Test log');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    log('${bloc.runtimeType} $transition', name: 'Test log');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    log('${bloc.runtimeType} $error $stackTrace', name: 'Test log');
  }
}
