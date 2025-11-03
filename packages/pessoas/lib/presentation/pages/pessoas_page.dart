import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:pessoas/presentation/bloc/pessoas_bloc/pessoas_bloc.dart';

class PessoasPage extends StatelessWidget {
  const PessoasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PessoasBloc>(
      create: (context) => sl<PessoasBloc>()..add(PessoasIniciou()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Pessoas'),
        ),
        body: Column(
          children: [
            BlocBuilder<PessoasBloc, PessoasState>(builder: (context, state) {
              switch (state.runtimeType) {
                case const (PessoasCarregarEmProgresso):
                  return _load();
                default:
                  return SizedBox();
              }
            })
          ],
        ),
      ),
    );
  }

  Widget _load() => Column(
        children: [CircularProgressIndicator.adaptive()],
      );
}
