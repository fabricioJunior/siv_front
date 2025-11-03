import 'package:autenticacao/domain/models/empresa.dart';
import 'package:autenticacao/presentation/bloc/login_bloc/login_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

class SelecionarEmpresaPage extends StatelessWidget {
  final bloc = sl<LoginBloc>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Selecione a Empresa',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: BlocBuilder<LoginBloc, LoginState>(
        bloc: bloc,
        builder: (context, state) {
          if (state is LoginAutenticarEmProgresso) {
            return CircularProgressIndicator.adaptive();
          }
          return ListView.builder(
            itemCount: state.empresas?.length,
            itemBuilder: (context, index) {
              var empresa = state.empresas![index];
              return _empresaCard(empresa);
            },
          );
        },
      ),
    );
  }

  Widget _empresaCard(Empresa empresa) => ListTile(
        onTap: () {
          bloc.add(
            LoginAutenticou(empresa: empresa),
          );
        },
        title: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${empresa.nome}',
            ),
          ),
        ),
      );
}
