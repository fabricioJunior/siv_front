import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:empresas/presentation/blocs/empresa_parametros_bloc/empresa_parametros_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmpresaParametrosPage extends StatelessWidget {
  final int idEmpresa;

  const EmpresaParametrosPage({
    super.key,
    required this.idEmpresa,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EmpresaParametrosBloc>(
      create: (_) =>
          sl<EmpresaParametrosBloc>()..add(EmpresaParametrosIniciou(idEmpresa)),
      child: BlocListener<EmpresaParametrosBloc, EmpresaParametrosState>(
        listenWhen: (previous, current) =>
            previous.step != current.step &&
            current.step == EmpresaParametrosStep.validacaoInvalida,
        listener: (context, state) {
          final descricao = state.descricaoParametroInvalido ?? 'Parâmetro';
          showDialog<void>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Validação'),
              content: Text(
                'Não é possível apagar um parâmetro com valor.\n\nParâmetro: $descricao',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Parâmetros da empresa')),
          floatingActionButton:
              BlocBuilder<EmpresaParametrosBloc, EmpresaParametrosState>(
            builder: (context, state) {
              if (state.parametros.isEmpty) {
                return const SizedBox.shrink();
              }
              final salvando = state.step == EmpresaParametrosStep.salvando;

              return FloatingActionButton(
                onPressed: salvando
                    ? null
                    : () => context
                        .read<EmpresaParametrosBloc>()
                        .add(EmpresaParametrosSalvou()),
                child: salvando
                    ? const CircularProgressIndicator.adaptive()
                    : const Icon(Icons.save),
              );
            },
          ),
          body: BlocBuilder<EmpresaParametrosBloc, EmpresaParametrosState>(
            builder: (context, state) {
              if (state.step == EmpresaParametrosStep.inicial ||
                  state.step == EmpresaParametrosStep.carregando) {
                return const Center(
                    child: CircularProgressIndicator.adaptive());
              }

              if (state.step == EmpresaParametrosStep.falha) {
                return const Center(
                  child: Text('Falha ao carregar parâmetros da empresa.'),
                );
              }

              if (state.parametros.isEmpty) {
                return const Center(
                  child: Text('Nenhum parâmetro cadastrado para esta empresa.'),
                );
              }

              final secoes = _agruparPorSecao(state.parametros);

              return SafeArea(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: secoes.length + 1,
                  itemBuilder: (context, index) {
                    if (index == secoes.length) {
                      return _StatusRodape(step: state.step);
                    }

                    final secao = secoes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        initiallyExpanded: index == 0,
                        title: Row(
                          children: [
                            _iconeDaSecao(secao.titulo),
                            const SizedBox(width: 8),
                            Expanded(child: Text(secao.titulo)),
                          ],
                        ),
                        subtitle:
                            Text('${secao.parametros.length} parâmetro(s)'),
                        children: secao.parametros
                            .map((parametro) =>
                                _buildParametroItem(context, parametro))
                            .toList(),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildParametroItem(
    BuildContext context,
    dynamic parametro,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            parametro.descricao,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (_ehParametroBooleano(parametro.chave))
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('Habilitado'),
              value: parametro.valorBooleano,
              onChanged: (value) {
                context.read<EmpresaParametrosBloc>().add(
                      EmpresaParametroCheckboxAlterado(
                        parametroId: parametro.id,
                        valor: value ?? false,
                      ),
                    );
              },
            )
          else
            TextFormField(
              initialValue: parametro.valorTexto ?? '',
              inputFormatters: _inputFormat(parametro.chave),
              decoration: const InputDecoration(
                labelText: 'Valor',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                context.read<EmpresaParametrosBloc>().add(
                      EmpresaParametroTextoAlterado(
                        parametroId: parametro.id,
                        valor: value,
                      ),
                    );
              },
            ),
        ],
      ),
    );
  }

  List<TextInputFormatter> _inputFormat(String chave) {
    const chavesDeNumericos = [
      'QT_DIAS_PRAZO_PAGAMENTO',
      'QT_DIAS_PRAZO_ENTREGA',
      'QT_DIAS_DEVOLUCAO',
      'QT_DIAS_TROCA',
      'CD_PRECO_PADRAO',
    ];
    if (chavesDeNumericos.contains(chave)) {
      return [FilteringTextInputFormatter.digitsOnly];
    }
    return [];
  }

  List<_SecaoParametros> _agruparPorSecao(List<dynamic> parametros) {
    final secoesMap = <String, List<dynamic>>{};

    for (final parametro in parametros) {
      final titulo = _tituloDaSecao(parametro.chave as String);
      secoesMap.putIfAbsent(titulo, () => []).add(parametro);
    }

    const ordem = [
      'Geral',
      'Faturamento',
      'Integração Infinity Pay',
      'Integração OpenPix',
      'Observações Padrão',
      'Prazos',
      'Outros',
    ];

    final secoes = secoesMap.entries
        .map((entry) => _SecaoParametros(entry.key, entry.value))
        .toList();

    secoes.sort((a, b) {
      final ia = ordem.indexOf(a.titulo);
      final ib = ordem.indexOf(b.titulo);
      final va = ia == -1 ? 999 : ia;
      final vb = ib == -1 ? 999 : ib;
      return va.compareTo(vb);
    });

    return secoes;
  }

  String _tituloDaSecao(String chave) {
    if (chave.startsWith('INTEGRACAO_INFINITY_PAY_')) {
      return 'Integração Infinity Pay';
    }

    if (chave.startsWith('INTEGRACAO_OPEN_PIX_')) {
      return 'Integração OpenPix';
    }

    if (chave.startsWith('OBS_PADRAO_')) {
      return 'Observações Padrão';
    }

    if (chave.startsWith('QT_DIAS_')) {
      return 'Prazos';
    }

    if (chave == 'CD_PRECO_PADRAO') {
      return 'Geral';
    }

    if (chave == 'DEVOLVER_SEM_ROMANEIO' ||
        chave == 'FATURAR_PEDIDO_SEM_CONFERENCIA') {
      return 'Faturamento';
    }

    return 'Outros';
  }

  bool _ehParametroBooleano(String chave) {
    return chave.endsWith('_HABILITADA') ||
        chave == 'DEVOLVER_SEM_ROMANEIO' ||
        chave == 'FATURAR_PEDIDO_SEM_CONFERENCIA';
  }

  Widget _iconeDaSecao(String secao) {
    if (secao == 'Integração Infinity Pay') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          'assets/logo_infinityPay.jpeg',
          package: 'empresas',
          width: 24,
          height: 24,
          fit: BoxFit.cover,
        ),
      );
    }

    if (secao == 'Integração OpenPix') {
      return const Icon(Icons.pix, size: 22, color: Colors.teal);
    }

    if (secao == 'Faturamento') {
      return const Icon(Icons.receipt_long, size: 22, color: Colors.orange);
    }

    if (secao == 'Observações Padrão') {
      return const Icon(Icons.sticky_note_2, size: 22, color: Colors.blueGrey);
    }

    if (secao == 'Prazos') {
      return const Icon(Icons.schedule, size: 22, color: Colors.indigo);
    }

    if (secao == 'Geral') {
      return const Icon(Icons.settings, size: 22, color: Colors.blue);
    }

    return const Icon(Icons.tune, size: 22, color: Colors.grey);
  }
}

class _SecaoParametros {
  final String titulo;
  final List<dynamic> parametros;

  _SecaoParametros(this.titulo, this.parametros);
}

class _StatusRodape extends StatelessWidget {
  final EmpresaParametrosStep step;

  const _StatusRodape({required this.step});

  @override
  Widget build(BuildContext context) {
    if (step == EmpresaParametrosStep.salvo) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('Parâmetros salvos com sucesso.'),
      );
    }

    if (step == EmpresaParametrosStep.editando) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('Existem alterações pendentes.'),
      );
    }

    return const SizedBox.shrink();
  }
}
