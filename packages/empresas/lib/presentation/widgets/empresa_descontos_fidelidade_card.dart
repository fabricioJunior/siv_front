import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:empresas/domain/entities/desconto_fidelidade.dart';
import 'package:empresas/presentation/blocs/descontos_fidelidade_bloc/descontos_fidelidade_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Faixas de desconto por pontos de fidelidade. Só montar com permissão PESFM003.
class EmpresaDescontosFidelidadeCard extends StatelessWidget {
  final int idEmpresa;

  const EmpresaDescontosFidelidadeCard({super.key, required this.idEmpresa});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DescontosFidelidadeBloc>(
      create: (_) => sl<DescontosFidelidadeBloc>()
        ..add(DescontosFidelidadeCarregou(idEmpresa)),
      child: BlocConsumer<DescontosFidelidadeBloc, DescontosFidelidadeState>(
        listenWhen: (a, b) => b.erro != null && a.erro != b.erro,
        listener: (context, s) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(s.erro!))),
        builder: (context, s) {
          final textos = context.sivTextos;
          final bloc = context.read<DescontosFidelidadeBloc>();
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SivCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('Descontos por pontos', style: textos.secao),
                      ),
                      TextButton.icon(
                        onPressed: () => _editar(context, bloc, null),
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar'),
                      ),
                    ],
                  ),
                  if (s.carregando)
                    const Center(child: CircularProgressIndicator.adaptive())
                  else if (s.faixas.isEmpty)
                    Text('Nenhuma faixa cadastrada.', style: textos.apoio),
                  for (final f in s.faixas)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${f.pontos} pts → ${f.tipo == 'percentual' ? '${_n(f.valor)}%' : 'R\$ ${f.valor.toStringAsFixed(2)}'}',
                      ),
                      subtitle: Text([
                        f.cumulativo ? 'Cumulativo' : 'Não cumulativo',
                        if (!f.ativo) 'Inativo',
                      ].join(' · ')),
                      onTap: () => _editar(context, bloc, f),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => bloc.add(DescontosFidelidadeExcluiu(f.id!)),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

  Future<void> _editar(
    BuildContext context,
    DescontosFidelidadeBloc bloc,
    DescontoFidelidade? atual,
  ) async {
    final novo = await showDialog<DescontoFidelidade>(
      context: context,
      builder: (_) => _FaixaDialog(atual: atual),
    );
    if (novo != null) bloc.add(DescontosFidelidadeSalvou(novo));
  }
}

class _FaixaDialog extends StatefulWidget {
  final DescontoFidelidade? atual;

  const _FaixaDialog({this.atual});

  @override
  State<_FaixaDialog> createState() => _FaixaDialogState();
}

class _FaixaDialogState extends State<_FaixaDialog> {
  late final _pontos = TextEditingController(text: '${widget.atual?.pontos ?? ''}');
  late final _valor = TextEditingController(
    text: widget.atual == null ? '' : widget.atual!.valor.toString(),
  );
  late String _tipo = widget.atual?.tipo ?? 'valor';
  late bool _cumulativo = widget.atual?.cumulativo ?? false;
  late bool _ativo = widget.atual?.ativo ?? true;
  String? _erro;

  @override
  void dispose() {
    _pontos.dispose();
    _valor.dispose();
    super.dispose();
  }

  void _confirmar() {
    final pontos = int.tryParse(_pontos.text);
    final valor = double.tryParse(_valor.text.replaceAll(',', '.'));
    if (pontos == null || pontos <= 0 || valor == null || valor <= 0) {
      setState(() => _erro = 'Informe pontos e valor maiores que zero.');
      return;
    }
    if (_tipo == 'percentual' && valor > 100) {
      setState(() => _erro = 'Percentual máximo é 100.');
      return;
    }
    Navigator.pop(
      context,
      DescontoFidelidade(
        id: widget.atual?.id,
        pontos: pontos,
        tipo: _tipo,
        valor: double.parse(valor.toStringAsFixed(2)),
        cumulativo: _cumulativo,
        ativo: _ativo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.atual == null ? 'Nova faixa' : 'Editar faixa'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _pontos,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Pontos'),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 'valor', label: Text('Valor (R\$)')),
                ButtonSegment(value: 'percentual', label: Text('Percentual (%)')),
              ],
              selected: {_tipo},
              onSelectionChanged: (s) => setState(() => _tipo = s.first),
            ),
            TextField(
              controller: _valor,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: _tipo == 'valor' ? 'Desconto (R\$)' : 'Desconto (%)',
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Cumulativo com outros descontos'),
              value: _cumulativo,
              onChanged: (v) => setState(() => _cumulativo = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ativo'),
              value: _ativo,
              onChanged: (v) => setState(() => _ativo = v),
            ),
            if (_erro != null)
              Text(_erro!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: _confirmar, child: const Text('Salvar')),
      ],
    );
  }
}
