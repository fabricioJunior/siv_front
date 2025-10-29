import 'package:autenticacao/models.dart';
import 'package:autenticacao/presentation/bloc/grupos_de_acesso_bloc/grupos_de_acesso_bloc.dart';
import 'package:autenticacao/presentation/bloc/vinculos_grupo_de_acesso_usuario_bloc/vinculos_grupo_de_acesso_usuario_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes/injecoes.dart';
import 'package:flutter/material.dart';

class VinculosGrupoDeAcessoComUsuarioPage extends StatelessWidget {
  final int idUsuario;

  VinculosGrupoDeAcessoComUsuarioPage({super.key, required this.idUsuario});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<VinculosGrupoDeAcessoUsuarioBloc>()
        ..add(VinculosGrupoDeAcessoIniciou(idUsuario: idUsuario)),
      child: Scaffold(
        floatingActionButton: BlocBuilder<VinculosGrupoDeAcessoUsuarioBloc,
            VinculosGrupoDeAcessoUsuarioState>(
          builder: (context, state) {
            if (state is VinculosGrupoDeAcessoUsuarioCarregarSucesso ||
                state is VinculosGrupoDeAcessoUsuarioVincularSucesso)
              return FloatingActionButton(
                  child: Icon(Icons.add),
                  onPressed: () {
                    _onAdionouNovoVinculo(context, state.empresas);
                  });

            return CircularProgressIndicator.adaptive();
          },
        ),
        appBar: AppBar(
          title: Text('Grupos de Acesso do Usuário'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(
                height: 16,
              ),
              Expanded(
                child: BlocBuilder<VinculosGrupoDeAcessoUsuarioBloc,
                    VinculosGrupoDeAcessoUsuarioState>(
                  builder: (context, state) {
                    switch (state.runtimeType) {
                      case VinculosGrupoDeAcessoUsuarioCarregarEmProgresso:
                      case VinculosGrupoDeAcessoUsuarioVincularEmProgresso:
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      case VinculosGrupoDeAcessoUsuarioCarregarFalha:
                        return Center(
                          child: Text('Falha ao carregar vínculos.'),
                        );
                    }
                    return ListView.builder(
                      itemCount: state.vinculos.length,
                      itemBuilder: (context, index) {
                        var vinculo = state.vinculos[index];
                        return ListTile(
                          title: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${vinculo.grupoDeAcesso?.nome} - '
                                '${vinculo.empresa?.nome}',
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onAdionouNovoVinculo(
    BuildContext context,
    List<Empresa> empresas,
  ) async {
    final bloc = BlocProvider.of<VinculosGrupoDeAcessoUsuarioBloc>(context);
    Empresa? empresa = await _EmpresasModal.show(context, empresas);

    if (empresa == null) {
      return;
    }
    GrupoDeAcesso? grupoDeAcesso = await _GruposDeAcessoModal.show(context);

    if (grupoDeAcesso == null) {
      return;
    }
    bloc.add(VinculosGrupoDeAcessoVinculou(
      idEmpresa: empresa.id,
      idGrupoDeAcesso: grupoDeAcesso.id!,
    ));
  }
}

class _EmpresasModal extends StatelessWidget {
  final List<Empresa> empresas;

  static Future<Empresa?> show(
      BuildContext context, List<Empresa> empresas) async {
    if (empresas.length == 1) {
      return empresas.first;
    }
    return showModalBottomSheet<Empresa>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => _EmpresasModal(empresas: empresas),
    );
  }

  const _EmpresasModal({required this.empresas});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Selecione a empresa para o vínculo:'),
        Expanded(
            child: ListView.builder(
          itemCount: empresas.length,
          itemBuilder: (context, index) {
            var empresa = empresas[index];
            return ListTile(
              title: Text(empresa.nome),
              onTap: () {
                Navigator.of(context).pop(empresa);
              },
            );
          },
        )),
      ],
    );
  }
}

class _GruposDeAcessoModal extends StatelessWidget {
  static Future<GrupoDeAcesso?> show(
    BuildContext context,
  ) async {
    return showModalBottomSheet<GrupoDeAcesso?>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => _GruposDeAcessoModal(),
    );
  }

  const _GruposDeAcessoModal();
  @override
  Widget build(BuildContext context) {
    return BlocProvider<GruposDeAcessoBloc>(
      create: (context) =>
          sl<GruposDeAcessoBloc>()..add(GruposDeAcessoIniciouEvent()),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text('Selecione o grupo de acesso:'),
            Expanded(
                child: BlocBuilder<GruposDeAcessoBloc, GruposDeAcessoState>(
              builder: (context, state) {
                switch (state.runtimeType) {
                  case GruposDeAcessoCarregarEmProgresso:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  case GruposDeAcessoCarregarError:
                    return Center(
                      child: Text('Falha ao carregar grupos de acesso.'),
                    );
                }
                if (state is GruposDeAcessoCarregarSucesso) {
                  return ListView.builder(
                    itemCount: state.grupos.length,
                    itemBuilder: (context, index) {
                      var grupo = state.grupos[index];
                      return ListTile(
                        title: Card(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(grupo.nome),
                        )),
                        onTap: () {
                          Navigator.of(context).pop(grupo);
                        },
                      );
                    },
                  );
                }
                return SizedBox();
              },
            )),
          ],
        ),
      ),
    );
  }
}
