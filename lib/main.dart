import 'dart:developer';

import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/isar_anotacoes.dart';
import 'package:flutter/material.dart';
import 'package:siv_front/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:siv_front/injections.dart';
import 'package:siv_front/presentation/bloc/sync_data/sync_data_bloc.dart';
import 'package:siv_front/routes.dart';

//https://apollo-api-stg.coralcloud.app/docs

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await sl.reset();
    await configs();
    runApp(MyApp());
  } catch (e, s) {
    log('Falha na inicialização do app: $e', stackTrace: s, name: 'Startup');
    runApp(AppInitializationErrorApp(error: e, stackTrace: s));
  }
}

Future<void> configs() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initIsarDatabase();

  await resolverDependenciasApp();

  Bloc.observer = GlobalBlocObserver();
}

class MyApp extends StatelessWidget {
  final String? routeToTest;
  final NavigationObserver navigationObserver = NavigationObserver();

  MyApp({super.key, this.routeToTest});
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [navigationObserver],
      initialRoute:
          sl<AppBloc>().state.statusAutenticacao ==
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
                _navigateWhenReady(
                  (navigator) => navigator.pushNamed(routeToTest!),
                );
              } else {
                _navigateWhenReady(
                  (navigator) => navigator.pushNamedAndRemoveUntil(
                    '/home',
                    (route) => false,
                  ),
                );
              }
            }

            if (state.statusAutenticacao == StatusAutenticacao.naoAutenticao) {
              _navigateWhenReady(
                (navigator) => navigator.pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                ),
              );
            }
          },
          child: BlocBuilder<AppBloc, AppState>(
            bloc: sl<AppBloc>(),
            builder: (context, state) {
              if (state.statusAutenticacao ==
                  StatusAutenticacao.carregandoDados) {
                return AppLoadingView(
                  etapaAtual: state.etapaAtualInicializacao,
                  etapasConcluidas: state.etapasInicializacaoConcluidas,
                );
              }

              if (state.statusAutenticacao ==
                  StatusAutenticacao.falhaInicializacao) {
                return InitializationErrorView(
                  mensagem:
                      state.mensagemErroInicializacao ??
                      'Não foi possível iniciar o aplicativo.',
                  detalhesTecnicos: state.detalhesErroInicializacao,
                  onRetry: () => sl<AppBloc>().add(AppIniciou()),
                );
              }

              return child ?? const SizedBox.shrink();
            },
          ),
        );
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }

  void _navigateWhenReady(void Function(NavigatorState navigator) action) {
    final navigator = navigatorKey.currentState;
    if (navigator != null) {
      action(navigator);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final delayedNavigator = navigatorKey.currentState;
      if (delayedNavigator != null) {
        action(delayedNavigator);
      }
    });
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
    if (bloc is SyncDataBloc) {
    } else {
      log('${bloc.runtimeType} $change', name: 'Test log');
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (bloc is SyncDataBloc) {
    } else {
      log('${bloc.runtimeType} $transition', name: 'Test log');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    log('${bloc.runtimeType} $error $stackTrace', name: 'Test log');
  }
}

class AppLoadingView extends StatelessWidget {
  final String? etapaAtual;
  final List<String> etapasConcluidas;

  const AppLoadingView({
    super.key,
    this.etapaAtual,
    this.etapasConcluidas = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  'Carregando dados do aplicativo...',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  etapaAtual ?? 'Preparando ambiente',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (etapasConcluidas.isNotEmpty || etapaAtual != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Etapas de carregamento',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          ...etapasConcluidas.map(
                            (etapa) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(etapa)),
                                ],
                              ),
                            ),
                          ),
                          if (etapaAtual != null)
                            Row(
                              children: [
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(etapaAtual!)),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppInitializationErrorApp extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;

  const AppInitializationErrorApp({
    super.key,
    required this.error,
    required this.stackTrace,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InitializationErrorView(
        mensagem:
            'Não foi possível concluir a inicialização do aplicativo. Verifique a configuração e tente novamente.',
        detalhesTecnicos:
            'Origem: ${error.runtimeType}\n\nErro: $error\n\nStack trace:\n$stackTrace',
      ),
    );
  }
}

class InitializationErrorView extends StatelessWidget {
  final String mensagem;
  final String? detalhesTecnicos;
  final VoidCallback? onRetry;

  const InitializationErrorView({
    super.key,
    required this.mensagem,
    this.detalhesTecnicos,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 56,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Falha ao iniciar o aplicativo',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    mensagem,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      if (onRetry != null)
                        FilledButton.icon(
                          onPressed: onRetry,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar novamente'),
                        ),
                      OutlinedButton.icon(
                        onPressed: () => _mostrarDetalhes(context),
                        icon: const Icon(Icons.bug_report_outlined),
                        label: const Text('Informações técnicas'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarDetalhes(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Informações técnicas'),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: SelectableText(
                detalhesTecnicos?.trim().isNotEmpty == true
                    ? detalhesTecnicos!
                    : 'Sem detalhes técnicos disponíveis.',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}

class NavigationObserver extends RouteObserver<ModalRoute<void>> {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == '/entrada_manual_de_produtos') {
      sl<SyncDataBloc>().add(
        const SyncDataSolicitouSincronizacao(
          origem: SyncDataOrigem.entradaDeProdutos,
        ),
      );
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    log('Popped route: ${route.settings.name}', name: 'Navigation');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    log(
      'Replaced route: ${oldRoute?.settings.name} with ${newRoute?.settings.name}',
      name: 'Navigation',
    );
  }
}
