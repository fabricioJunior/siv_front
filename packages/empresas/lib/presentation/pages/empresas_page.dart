import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/empresa.dart';
import '../blocs/empresas_bloc/empresas_bloc.dart';

class EmpresasPage extends StatelessWidget {
  const EmpresasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EmpresasBloc>(
      create: (context) => sl<EmpresasBloc>()..add(EmpresasIniciou()),
      child: Scaffold(
        floatingActionButton: _novaEmpresaButton(context),
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              BlocBuilder<EmpresasBloc, EmpresasState>(
                builder: (context, state) {
                  if (state is EmpresasCarregarEmProgresso) {
                    return CircularProgressIndicator.adaptive();
                  }
                  if (state is EmpresasCarregarFalha) {
                    return Text(
                      'Falhao ao carregar empresas',
                    );
                  }
                  if (state is EmpresasCarregarSucesso &&
                      state.empresas.isEmpty) {
                    return Text(
                        'Nenhuma empresa cadastrada, para criar um nova empresa toque no botão + no canto inferior direito da tela');
                  }

                  if (state is EmpresasCarregarSucesso) {
                    return ListView.builder(
                      itemCount: state.empresas.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return _empresaCard(context, state.empresas[index]);
                      },
                    );
                  }
                  return SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _novaEmpresaButton(BuildContext _) =>
      BlocBuilder<EmpresasBloc, EmpresasState>(
        builder: (context, state) {
          return FloatingActionButton(
            onPressed: () async {
              await Navigator.of(context).pushNamed(
                '/empresa',
              );
              // ignore: use_build_context_synchronously
              context.read<EmpresasBloc>().add(EmpresasIniciou());
            },
            child: const Icon(Icons.add),
          );
        },
      );

  Widget _empresaCard(BuildContext context, Empresa empresa) => Card(
        child: Ink(
          child: InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                '/empresa',
                arguments: {
                  'idEmpresa': empresa.id,
                },
              );
            },
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(empresa.nome),
                      Text(empresa.cnpj),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(empresa.nomeFantasia),
                ],
              ),
            ),
          ),
        ),
      );
}
