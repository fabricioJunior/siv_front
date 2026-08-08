import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:empresas/domain/entities/empresa.dart';
import 'package:empresas/presentation/blocs/empresas_bloc/empresas_bloc.dart';
import 'package:flutter/material.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/presentation/bloc/funcionario_vinculos_bloc/funcionario_vinculos_bloc.dart';

/// Gerencia os vínculos de um funcionário já existente com múltiplas
/// empresas (criar, desativar e reativar). Não é usado no fluxo de criação
/// do funcionário -- ali o vínculo inicial ainda é escolhido via
/// `/selecionar_empresa` direto no POST, pois o funcionário nem existe.
class FuncionarioVinculosPainel extends StatefulWidget {
  final int idFuncionario;

  const FuncionarioVinculosPainel({required this.idFuncionario, super.key});

  @override
  State<FuncionarioVinculosPainel> createState() =>
      _FuncionarioVinculosPainelState();
}

class _FuncionarioVinculosPainelState
    extends State<FuncionarioVinculosPainel> {
  late final FuncionarioVinculosBloc _vinculosBloc;
  late final EmpresasBloc _empresasBloc;

  @override
  void initState() {
    super.initState();
    _vinculosBloc = sl<FuncionarioVinculosBloc>()
      ..add(FuncionarioVinculosIniciou(idFuncionario: widget.idFuncionario));
    _empresasBloc = sl<EmpresasBloc>()..add(EmpresasIniciou());
  }

  @override
  void dispose() {
    _vinculosBloc.close();
    _empresasBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FuncionarioVinculosBloc>.value(value: _vinculosBloc),
        BlocProvider<EmpresasBloc>.value(value: _empresasBloc),
      ],
      child: Builder(builder: _build),
    );
  }

  Widget _build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<FuncionarioVinculosBloc, FuncionarioVinculosState>(
      listenWhen: (previous, current) =>
          previous.erro != current.erro && current.erro != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.erro!)),
        );
      },
      builder: (context, vinculosState) {
        return BlocBuilder<EmpresasBloc, EmpresasState>(
          builder: (context, empresasState) {
            final empresas = empresasState is EmpresasCarregarSucesso
                ? empresasState.empresas
                : const <Empresa>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Empresas vinculadas', style: theme.textTheme.titleSmall),
                    TextButton.icon(
                      onPressed: () => _adicionarEmpresa(context),
                      icon: const Icon(Icons.add_business_outlined),
                      label: const Text('Adicionar empresa'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (vinculosState.step == FuncionarioVinculosStep.carregando)
                  const Center(child: CircularProgressIndicator.adaptive())
                else if (vinculosState.step == FuncionarioVinculosStep.falha)
                  Text(
                    'Não foi possível carregar os vínculos.',
                    style: TextStyle(color: theme.colorScheme.error),
                  )
                else if (vinculosState.vinculos.isEmpty)
                  const Text('Nenhuma empresa vinculada.')
                else
                  ...vinculosState.vinculos.map(
                    (vinculo) => _vinculoTile(
                      context,
                      vinculo,
                      _nomeEmpresa(empresas, vinculo.empresaId),
                      vinculosState.processandoEmpresaId == vinculo.empresaId,
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  String _nomeEmpresa(List<Empresa> empresas, int idEmpresa) {
    for (final empresa in empresas) {
      if (empresa.id == idEmpresa) return empresa.nome;
    }
    return 'Empresa #$idEmpresa';
  }

  Widget _vinculoTile(
    BuildContext context,
    FuncionarioEmpresaVinculo vinculo,
    String nomeEmpresa,
    bool processando,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(nomeEmpresa),
        subtitle: Text('ID: ${vinculo.empresaId}'),
        leading: Chip(
          label: Text(vinculo.ativo ? 'Ativo' : 'Inativo'),
          backgroundColor: vinculo.ativo
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.errorContainer,
        ),
        trailing: processando
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              )
            : TextButton(
                onPressed: () => vinculo.ativo
                    ? _confirmarDesativacao(context, vinculo, nomeEmpresa)
                    : context.read<FuncionarioVinculosBloc>().add(
                          FuncionarioVinculosReativarSolicitado(
                            idEmpresa: vinculo.empresaId,
                          ),
                        ),
                child: Text(vinculo.ativo ? 'Desativar' : 'Reativar'),
              ),
      ),
    );
  }

  Future<void> _confirmarDesativacao(
    BuildContext context,
    FuncionarioEmpresaVinculo vinculo,
    String nomeEmpresa,
  ) async {
    final bloc = context.read<FuncionarioVinculosBloc>();
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Desativar vínculo'),
        content: Text(
          'Ao desativar o vínculo com "$nomeEmpresa", o funcionário não '
          'poderá mais ser usado em novas operações (romaneio, pedido, '
          'consignação) nessa empresa. O histórico já registrado não é '
          'afetado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Desativar'),
          ),
        ],
      ),
    );

    if (confirmou == true) {
      bloc.add(
        FuncionarioVinculosDesativarSolicitado(idEmpresa: vinculo.empresaId),
      );
    }
  }

  Future<void> _adicionarEmpresa(BuildContext context) async {
    final bloc = context.read<FuncionarioVinculosBloc>();
    final resultado =
        await Navigator.of(context).pushNamed('/selecionar_empresa');

    if (!mounted || resultado is! Map) return;

    final idEmpresa = resultado['idEmpresa'];
    if (idEmpresa is! int) return;

    bloc.add(FuncionarioVinculosEmpresaAdicionada(idEmpresa: idEmpresa));
  }
}
