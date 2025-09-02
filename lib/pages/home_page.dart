import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:siv_front/bloc/app_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    BlocBuilder<AppBloc, AppState>(
                        bloc: sl<AppBloc>(),
                        builder: (context, state) {
                          if (state.usuarioDaSessao != null) {
                            return Text(state.usuarioDaSessao!.nome);
                          }
                          return const SizedBox();
                        }),
                    const SizedBox(
                      height: 32,
                    ),
                    const Text('Home page'),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/usuarios');
                      },
                      child: const Text('Usuários'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/grupos_de_acesso');
                      },
                      child: const Text('Grupos de Acesso'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/empresas');
                      },
                      child: const Text('Empresas'),
                    )
                  ],
                ),
              ],
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  key: const Key('sair_button'),
                  onPressed: () {
                    sl<AppBloc>().add(AppDesautenticou());
                  },
                  child: const Text('Sair'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
