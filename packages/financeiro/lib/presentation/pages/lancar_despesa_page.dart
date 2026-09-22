import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';
import 'package:financeiro/presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Formulário de lançamento de despesa (avulsa, parcelada ou recorrente).
/// Reusado tanto pela rota própria (`/lancar_despesa`) quanto a partir da
/// tela de Caixa, passando [caixaId] para pré-vincular o pagamento ao caixa
/// aberto.
class LancarDespesaPage extends StatefulWidget {
  final int? caixaId;

  const LancarDespesaPage({super.key, this.caixaId});

  @override
  State<LancarDespesaPage> createState() => _LancarDespesaPageState();
}

class _LancarDespesaPageState extends State<LancarDespesaPage> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _diaVencimentoController = TextEditingController();
  final _parcelasController = TextEditingController();

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _diaVencimentoController.dispose();
    _parcelasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final empresaId = sl<IAcessoGlobalSessao>().empresaIdDaSessao ?? 0;

    return BlocProvider<LancarDespesaBloc>(
      create: (_) => sl<LancarDespesaBloc>()
        ..add(
          LancarDespesaIniciou(empresaId: empresaId, caixaId: widget.caixaId),
        ),
      child: BlocListener<LancarDespesaBloc, LancarDespesaState>(
        listenWhen: (previous, current) => previous.step != current.step,
        listener: (context, state) {
          if (state.step == LancarDespesaStep.validacaoInvalida ||
              state.step == LancarDespesaStep.falha) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.erro ?? 'Falha ao lançar despesa.')),
            );
          }
          if (state.step == LancarDespesaStep.criada) {
            Navigator.of(context).pop(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Lançar despesa')),
          floatingActionButton:
              BlocBuilder<LancarDespesaBloc, LancarDespesaState>(
            builder: (context, state) {
              final salvando = state.step == LancarDespesaStep.salvando ||
                  state.step == LancarDespesaStep.carregando;
              return FloatingActionButton(
                onPressed: salvando
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          context.read<LancarDespesaBloc>().add(
                                LancarDespesaSalvou(),
                              );
                        }
                      },
                child: salvando
                    ? const CircularProgressIndicator.adaptive()
                    : const Icon(Icons.check),
              );
            },
          ),
          body: BlocBuilder<LancarDespesaBloc, LancarDespesaState>(
            builder: (context, state) {
              if (state.step == LancarDespesaStep.carregando ||
                  state.step == LancarDespesaStep.inicial) {
                return const Center(child: CircularProgressIndicator.adaptive());
              }

              _sincronizarControllers(state);
              final bloc = context.read<LancarDespesaBloc>();

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SegmentedButton<ModoLancamentoDespesa>(
                          segments: const [
                            ButtonSegment(
                              value: ModoLancamentoDespesa.avulsa,
                              label: Text('Avulsa'),
                            ),
                            ButtonSegment(
                              value: ModoLancamentoDespesa.parcelada,
                              label: Text('Parcelada'),
                            ),
                            ButtonSegment(
                              value: ModoLancamentoDespesa.recorrente,
                              label: Text('Recorrente'),
                            ),
                          ],
                          selected: {state.modo},
                          onSelectionChanged: (selecionado) => bloc.add(
                            LancarDespesaCampoAlterado(
                              modo: selecionado.first,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descricaoController,
                          decoration:
                              const InputDecoration(labelText: 'Descrição'),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Informe a descrição'
                                  : null,
                          onChanged: (value) => bloc.add(
                            LancarDespesaCampoAlterado(descricao: value),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _valorController,
                          decoration: InputDecoration(
                            labelText: state.modo ==
                                    ModoLancamentoDespesa.parcelada
                                ? 'Valor de cada parcela'
                                : 'Valor',
                          ),
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*[.,]?\d*$'),
                            ),
                          ],
                          validator: (value) {
                            final valor =
                                double.tryParse((value ?? '').replaceAll(',', '.'));
                            if (valor == null || valor <= 0) {
                              return 'Informe um valor válido';
                            }
                            return null;
                          },
                          onChanged: (value) => bloc.add(
                            LancarDespesaCampoAlterado(
                              valor: double.tryParse(value.replaceAll(',', '.')),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          initialValue: state.categoriaId,
                          decoration:
                              const InputDecoration(labelText: 'Categoria'),
                          items: state.categorias
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.nome),
                                ),
                              )
                              .toList(),
                          validator: (value) =>
                              value == null ? 'Selecione a categoria' : null,
                          onChanged: (value) => bloc.add(
                            LancarDespesaCampoAlterado(categoriaId: value),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          initialValue: state.origemPagamentoId,
                          decoration: const InputDecoration(
                            labelText: 'Origem de pagamento',
                          ),
                          items: state.origens
                              .map(
                                (o) => DropdownMenuItem(
                                  value: o.id,
                                  child: Text(o.nome),
                                ),
                              )
                              .toList(),
                          validator: (value) => value == null
                              ? 'Selecione a origem de pagamento'
                              : null,
                          onChanged: (value) => bloc.add(
                            LancarDespesaCampoAlterado(
                              origemPagamentoId: value,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          initialValue: state.formaPagamentoId,
                          decoration: const InputDecoration(
                            labelText: 'Forma de pagamento (opcional)',
                          ),
                          items: state.formasDePagamento
                              .map(
                                (f) => DropdownMenuItem(
                                  value: f.id,
                                  child: Text(f.descricao),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => bloc.add(
                            LancarDespesaCampoAlterado(
                              formaPagamentoId: value,
                              limparFormaPagamento: value == null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (state.modo == ModoLancamentoDespesa.avulsa)
                          _CampoData(
                            data: state.dataPagamento,
                            onSelecionada: (data) => bloc.add(
                              LancarDespesaCampoAlterado(dataPagamento: data),
                            ),
                          ),
                        if (state.modo == ModoLancamentoDespesa.recorrente)
                          TextFormField(
                            controller: _diaVencimentoController,
                            decoration: const InputDecoration(
                              labelText: 'Dia de vencimento',
                              hintText: 'Ex: 10',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              final dia = int.tryParse(value ?? '');
                              if (dia == null || dia <= 0 || dia > 31) {
                                return 'Informe um dia válido (1-31)';
                              }
                              return null;
                            },
                            onChanged: (value) => bloc.add(
                              LancarDespesaCampoAlterado(
                                diaVencimento: int.tryParse(value),
                              ),
                            ),
                          ),
                        if (state.modo == ModoLancamentoDespesa.parcelada) ...[
                          TextFormField(
                            controller: _parcelasController,
                            decoration: const InputDecoration(
                              labelText: 'Número de parcelas',
                              hintText: 'Ex: 7',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              final parcelas = int.tryParse(value ?? '');
                              if (parcelas == null || parcelas <= 1) {
                                return 'Informe mais de 1 parcela';
                              }
                              return null;
                            },
                            onChanged: (value) => bloc.add(
                              LancarDespesaCampoAlterado(
                                parcelas: int.tryParse(value),
                              ),
                            ),
                          ),
                          if (state.previewParcelamento != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              state.previewParcelamento!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _sincronizarControllers(LancarDespesaState state) {
    final descricao = state.descricao ?? '';
    if (_descricaoController.text != descricao) {
      _descricaoController.value = TextEditingValue(
        text: descricao,
        selection: TextSelection.collapsed(offset: descricao.length),
      );
    }

    final valor = state.valor?.toString() ?? '';
    if (_valorController.text != valor) {
      _valorController.value = TextEditingValue(
        text: valor,
        selection: TextSelection.collapsed(offset: valor.length),
      );
    }

    final diaVencimento = state.diaVencimento?.toString() ?? '';
    if (_diaVencimentoController.text != diaVencimento) {
      _diaVencimentoController.value = TextEditingValue(
        text: diaVencimento,
        selection: TextSelection.collapsed(offset: diaVencimento.length),
      );
    }

    final parcelas =
        (state.modo == ModoLancamentoDespesa.parcelada ? state.parcelas : null)
                ?.toString() ??
            '';
    if (_parcelasController.text != parcelas) {
      _parcelasController.value = TextEditingValue(
        text: parcelas,
        selection: TextSelection.collapsed(offset: parcelas.length),
      );
    }
  }
}

class _CampoData extends StatelessWidget {
  final DateTime? data;
  final ValueChanged<DateTime> onSelecionada;

  const _CampoData({required this.data, required this.onSelecionada});

  @override
  Widget build(BuildContext context) {
    final texto = data == null
        ? 'Selecione a data'
        : '${data!.day.toString().padLeft(2, '0')}/'
            '${data!.month.toString().padLeft(2, '0')}/${data!.year}';

    return InkWell(
      onTap: () async {
        final selecionada = await showDatePicker(
          context: context,
          initialDate: data ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (selecionada != null) onSelecionada(selecionada);
      },
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Data de pagamento'),
        child: Text(texto),
      ),
    );
  }
}
