import 'package:comercial/presentation/blocs/creditos_devolucao_bloc/creditos_devolucao_bloc.dart';
import 'package:comercial/presentation/widgets/credito_form_comum.dart';
import 'package:comercial/presentation/widgets/transferir_credito_dialogo.dart'
    show formatarMoedaBr;
import 'package:core/tema.dart';
import 'package:empresas/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Envia o evento ao bloc e devolve a mensagem de erro (null = sucesso).
typedef AoConfirmarCredito = Future<String?> Function(
    CreditosDevolucaoEvent evento);

const motivosCreditoAvulso = <(String, String)>[
  ('cortesia', 'Cortesia'),
  ('ajuste', 'Ajuste de saldo'),
  ('devolucao_sem_romaneio', 'Devolução sem romaneio'),
  ('outro', 'Outro'),
];

/// 2b/2h: adicionar crédito avulso. [validadeDiasPadrao] vem da config da
/// empresa (null = sem validade). Loja só aparece com mais de uma empresa.
Future<void> mostrarAdicionarCredito(
  BuildContext context, {
  required String nome,
  required double saldoAtual,
  required AoConfirmarCredito aoConfirmar,
  int? validadeDiasPadrao,
  List<Empresa> empresas = const [],
  int? empresaIdInicial,
}) {
  return mostrarFormCredito(
    context,
    (_) => AdicionarCreditoForm(
      nome: nome,
      saldoAtual: saldoAtual,
      aoConfirmar: aoConfirmar,
      validadeDiasPadrao: validadeDiasPadrao,
      empresas: empresas,
      empresaIdInicial: empresaIdInicial,
    ),
  );
}

class AdicionarCreditoForm extends StatefulWidget {
  final String nome;
  final double saldoAtual;
  final AoConfirmarCredito aoConfirmar;
  final int? validadeDiasPadrao;
  final List<Empresa> empresas;
  final int? empresaIdInicial;

  const AdicionarCreditoForm({
    super.key,
    required this.nome,
    required this.saldoAtual,
    required this.aoConfirmar,
    this.validadeDiasPadrao,
    this.empresas = const [],
    this.empresaIdInicial,
  });

  @override
  State<AdicionarCreditoForm> createState() => _AdicionarCreditoFormState();
}

class _AdicionarCreditoFormState extends State<AdicionarCreditoForm> {
  final _formKey = GlobalKey<FormState>();
  final _valor = TextEditingController();
  final _observacao = TextEditingController();
  String? _motivo;
  String? _erro;
  var _enviando = false;
  late int? _dias = widget.validadeDiasPadrao;
  late DateTime? _validade = _dias == null ? null : _aPartirDeHoje(_dias!);
  late int? _empresaId = widget.empresaIdInicial;

  static DateTime _aPartirDeHoje(int dias) {
    final h = DateTime.now();
    return DateTime(h.year, h.month, h.day).add(Duration(days: dias));
  }

  @override
  void dispose() {
    _valor.dispose();
    _observacao.dispose();
    super.dispose();
  }

  double get _v => parseValorBr(_valor.text) ?? 0;

  Future<void> _escolherData() async {
    final hoje = _aPartirDeHoje(0);
    final d = await showDatePicker(
      context: context,
      initialDate: _validade ?? hoje.add(const Duration(days: 30)),
      firstDate: hoje,
      lastDate: hoje.add(const Duration(days: 3650)),
    );
    if (d != null) {
      setState(() {
        _dias = null;
        _validade = d;
      });
    }
  }

  Future<void> _confirmar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _enviando = true;
      _erro = null;
    });
    final erro = await widget.aoConfirmar(CreditosDevolucaoAdicionou(
      valor: _v,
      motivo: _motivo!,
      observacao: _observacao.text.trim(),
      validade: _validade,
      empresaId: _empresaId,
    ));
    if (!mounted) return;
    if (erro == null) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _enviando = false;
        _erro = erro;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final mobile = ehMobileCredito(context);
    final dias = {
      30,
      60,
      90,
      if (widget.validadeDiasPadrao != null) widget.validadeDiasPadrao!
    }.toList()
      ..sort();
    final depois = widget.saldoAtual + _v;
    final rotulo =
        _v > 0 ? 'Adicionar ${formatarMoedaBr(_v)}' : 'Adicionar crédito';

    return CreditoFormCasca(
      titulo: 'Adicionar crédito',
      subtitulo:
          '${widget.nome} · saldo atual ${formatarMoedaBr(widget.saldoAtual)}',
      rotuloConfirmar: rotulo,
      aoConfirmar: _confirmar,
      enviando: _enviando,
      erro: _erro,
      nota: 'Fica no extrato com seu usuário.',
      notaMobile: 'Saldo depois: ${formatarMoedaBr(depois)}',
      corpo: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _valor,
              autofocus: !mobile,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              style: textos.valor.copyWith(fontSize: 20),
              decoration:
                  const InputDecoration(labelText: 'Valor', prefixText: 'R\$ '),
              onChanged: (_) => setState(() {}),
              validator: (_) =>
                  _v > 0 ? null : 'O valor deve ser maior que zero.',
            ),
            const SizedBox(height: 16),
            FormField<String>(
              validator: (_) => _motivo == null ? 'Escolha o motivo.' : null,
              builder: (f) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CreditoOpcoes<String>(
                    rotulo: 'Motivo',
                    opcoes: motivosCreditoAvulso,
                    selecionado: _motivo,
                    aoEscolher: (m) {
                      setState(() => _motivo = m);
                      f.didChange(m);
                    },
                  ),
                  if (f.hasError)
                    Text(f.errorText!,
                        style: textos.apoio.copyWith(color: cores.vinho)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _observacao,
              maxLines: 2,
              maxLength: 300,
              decoration: const InputDecoration(labelText: 'Observação'),
              validator: (v) => (v ?? '').trim().length < 3
                  ? 'Informe a observação (mínimo 3 caracteres).'
                  : null,
            ),
            const SizedBox(height: 8),
            CreditoOpcoes<Object?>(
              rotulo: 'Validade',
              selecionado: _validade == null ? 'sem' : _dias ?? 'data',
              opcoes: [
                for (final d in dias)
                  (
                    d,
                    '$d dias${d == widget.validadeDiasPadrao ? ' · padrão' : ''}',
                  ),
                ('sem', 'Sem validade'),
                ('data', 'Escolher data…'),
              ],
              aoEscolher: (o) {
                if (o == 'data') {
                  _escolherData();
                } else {
                  setState(() {
                    _dias = o is int ? o : null;
                    _validade = o is int ? _aPartirDeHoje(o) : null;
                  });
                }
              },
            ),
            const SizedBox(height: 4),
            Text(
              _validade == null
                  ? 'Sem validade'
                  : 'Vence em ${formatarDiaMes(_validade!)}/${_validade!.year}',
              style: textos.apoio.copyWith(color: cores.textoApoio),
            ),
            if (widget.empresas.length > 1) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _empresaId,
                decoration: const InputDecoration(labelText: 'Loja'),
                items: [
                  for (final e in widget.empresas)
                    if (e.id != null)
                      DropdownMenuItem(
                        value: e.id,
                        child: Text(
                            e.nomeFantasia.isEmpty ? e.nome : e.nomeFantasia),
                      ),
                ],
                onChanged: (v) => setState(() => _empresaId = v),
              ),
            ],
            if (!mobile) ...[
              const SizedBox(height: 16),
              CreditoSaldoDepois(antes: widget.saldoAtual, depois: depois),
            ],
          ],
        ),
      ),
    );
  }
}
