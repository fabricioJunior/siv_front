import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/presentation/bloc/pessoa_bloc/pessoa_bloc.dart';

class PessoaVisualizacaoPage extends StatefulWidget {
  final int idPessoa;

  const PessoaVisualizacaoPage({
    required this.idPessoa,
    super.key,
  });

  @override
  State<PessoaVisualizacaoPage> createState() => _PessoaVisualizacaoPageState();
}

class _PessoaVisualizacaoPageState extends State<PessoaVisualizacaoPage> {
  late final PessoaBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<PessoaBloc>()
      ..add(
        PessoaIniciou(
          idPessoa: widget.idPessoa,
          tipoPessoa: TipoPessoa.fisica,
        ),
      );
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PessoaBloc>.value(
      value: _bloc,
      child: Scaffold(
        floatingActionButton: ElevatedButton.icon(
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Editar'),
          onPressed: _editarPessoa,
        ),
        appBar: AppBar(
          title: Text('Pessoa #${widget.idPessoa}'),
        ),
        body: BlocBuilder<PessoaBloc, PessoaState>(
          builder: (context, state) {
            if (state.pessoaStep == PessoaStep.carregando &&
                state.nome == null) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildAcoesRapidas(context, state),
                const SizedBox(height: 8),
                _buildLinha('ID', state.id?.toString() ?? '-'),
                _buildLinha('Nome', _valorOuTraco(state.nome)),
                _buildLinha('Documento', _valorOuTraco(state.documento)),
                _buildLinha('Data de nascimento',
                    _formatarData(state.dataDeNascimento)),
                _buildLinha('Contato', _valorOuTraco(state.contato)),
                _buildLinha('E-mail', _valorOuTraco(state.email)),
                _buildLinha('Inscrição estadual',
                    _valorOuTraco(state.inscricaoEstadual)),
                _buildLinha('UF', _valorOuTraco(state.uf)),
                _buildLinha('Tipo', _descricaoTipoPessoa(state.tipoPessoa)),
                _buildLinha('Vínculo', _descricaoVinculo(state)),
                _buildLinha('Situação',
                    (state.bloqueado ?? false) ? 'Bloqueado' : 'Ativo'),
                if (state.eFuncionario ?? false) ...[
                  _buildLinha(
                    'Tipo de funcionário',
                    _descricaoTipoFuncionario(state.tipoFuncionario),
                  ),
                  _buildLinha(
                    'Empresa ID',
                    state.funcionarioEmpresaId?.toString() ?? '-',
                  ),
                  _buildLinha(
                    'Empresa',
                    _valorOuTraco(state.funcionarioEmpresaNome),
                  ),
                  _buildLinha(
                    'Ativo',
                    _descricaoAtivoFuncionario(state),
                  ),
                  _buildLinha(
                    'Nome de funcionário',
                    _valorOuTraco(state.funcionarioNome),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLinha(String label, String valor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(label),
        subtitle: Text(valor),
      ),
    );
  }

  Widget _buildAcoesRapidas(BuildContext context, PessoaState state) {
    final idPessoa = state.id;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: idPessoa == null
                  ? null
                  : () {
                      Navigator.of(context).pushNamed(
                        '/pontos_page',
                        arguments: {'idPessoa': idPessoa},
                      );
                    },
              icon: const Icon(Icons.stars_outlined),
              label: const Text('Pontos'),
            ),
            OutlinedButton.icon(
              onPressed: idPessoa == null
                  ? null
                  : () {
                      Navigator.of(context).pushNamed(
                        '/enderecos_page',
                        arguments: {'idPessoa': idPessoa},
                      );
                    },
              icon: const Icon(Icons.location_on_outlined),
              label: const Text('Endereços'),
            ),
            OutlinedButton.icon(
              onPressed: _editarPessoa,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar'),
            ),
          ],
        ),
      ),
    );
  }

  String _descricaoVinculo(PessoaState state) {
    final vinculos = <String>[];
    if (state.eCliente ?? false) vinculos.add('Cliente');
    if (state.eFornecedor ?? false) vinculos.add('Fornecedor');
    if (state.eFuncionario ?? false) vinculos.add('Funcionário');
    if (vinculos.isEmpty) return '-';
    return vinculos.join(', ');
  }

  String _descricaoTipoPessoa(TipoPessoa? tipoPessoa) {
    switch (tipoPessoa) {
      case TipoPessoa.fisica:
        return 'Física';
      case TipoPessoa.juridica:
        return 'Jurídica';
      case null:
        return '-';
    }
  }

  String _formatarData(DateTime? date) {
    if (date == null) return '-';
    final dia = date.day.toString().padLeft(2, '0');
    final mes = date.month.toString().padLeft(2, '0');
    final ano = date.year.toString();
    return '$dia/$mes/$ano';
  }

  String _valorOuTraco(String? valor) {
    final texto = valor?.trim() ?? '';
    return texto.isEmpty ? '-' : texto;
  }

  String _descricaoTipoFuncionario(TipoFuncionario? tipo) {
    switch (tipo) {
      case TipoFuncionario.comprador:
        return 'Comprador';
      case TipoFuncionario.vendedor:
        return 'Vendedor';
      case TipoFuncionario.caixa:
        return 'Caixa';
      case TipoFuncionario.gerente:
        return 'Gerente';
      case null:
        return '-';
    }
  }

  String _descricaoAtivoFuncionario(PessoaState state) {
    if (state.tipoFuncionario == null &&
        (state.funcionarioNome?.trim().isEmpty ?? true)) {
      return '-';
    }
    return state.funcionarioInativo ? 'Não' : 'Sim';
  }

  Future<void> _editarPessoa() async {
    final alterou = await Navigator.of(context).pushNamed(
      '/pessoa',
      arguments: {
        'idPessoa': widget.idPessoa,
      },
    );

    if (!mounted) return;

    if (alterou == true) {
      _bloc.add(
        PessoaIniciou(
          idPessoa: widget.idPessoa,
          tipoPessoa: TipoPessoa.fisica,
        ),
      );
    }
  }
}
