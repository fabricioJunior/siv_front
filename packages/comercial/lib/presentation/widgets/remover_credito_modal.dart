import 'package:comercial/models.dart';
import 'package:comercial/presentation/blocs/creditos_devolucao_bloc/creditos_devolucao_bloc.dart';
import 'package:comercial/presentation/widgets/adicionar_credito_modal.dart'
    show AoConfirmarCredito;
import 'package:comercial/presentation/widgets/credito_form_comum.dart';
import 'package:comercial/presentation/widgets/transferir_credito_dialogo.dart'
    show formatarMoedaBr;
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _motivos = <(String, String)>[
  ('lancado_errado', 'Lançado errado'),
  ('duplicidade', 'Duplicidade'),
  ('acordo_cliente', 'Acordo com cliente'),
  ('outro', 'Outro'),
];

/// 2c/2g: remover todo o restante ou só uma parte. [titulo] é o nome do
/// crédito (ex.: "Avulso · Cortesia").
Future<void> mostrarRemoverCredito(
  BuildContext context, {
  required CreditoDevolucao credito,
  required String titulo,
  required AoConfirmarCredito aoConfirmar,
}) {
  return mostrarFormCredito(
    context,
    (_) => RemoverCreditoForm(
      credito: credito,
      titulo: titulo,
      aoConfirmar: aoConfirmar,
    ),
  );
}

class RemoverCreditoForm extends StatefulWidget {
  final CreditoDevolucao credito;
  final String titulo;
  final AoConfirmarCredito aoConfirmar;

  const RemoverCreditoForm({
    super.key,
    required this.credito,
    required this.titulo,
    required this.aoConfirmar,
  });

  @override
  State<RemoverCreditoForm> createState() => _RemoverCreditoFormState();
}

class _RemoverCreditoFormState extends State<RemoverCreditoForm> {
  final _formKey = GlobalKey<FormState>();
  final _parte = TextEditingController();
  final _observacao = TextEditingController();
  var _soUmaParte = false;
  String? _motivo;
  String? _erro;
  var _enviando = false;

  double get _restante => widget.credito.valorRestante;

  double get _valor =>
      _soUmaParte ? (parseValorBr(_parte.text) ?? 0) : _restante;

  @override
  void dispose() {
    _parte.dispose();
    _observacao.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _enviando = true;
      _erro = null;
    });
    final erro = await widget.aoConfirmar(CreditosDevolucaoRemoveu(
      creditoId: widget.credito.id,
      valor: _soUmaParte ? _valor : null,
      motivo: _motivo!,
      observacao: _observacao.text.trim(),
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
    final c = widget.credito;
    final venc = c.validade == null
        ? 'sem validade'
        : 'vence ${formatarDiaMes(c.validade!)}/${c.validade!.year}';

    return CreditoFormCasca(
      titulo: 'Remover crédito',
      rotuloConfirmar:
          _valor > 0 ? 'Remover ${formatarMoedaBr(_valor)}' : 'Remover crédito',
      aoConfirmar: _confirmar,
      enviando: _enviando,
      erro: _erro,
      perigo: true,
      corpo: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: cores.hairline),
                borderRadius: BorderRadius.circular(SivDimensoes.raio),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.titulo, style: textos.secao),
                        Text('${c.codigo} · $venc',
                            style:
                                textos.apoio.copyWith(color: cores.textoApoio)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('RESTANTE',
                          style:
                              textos.rotulo.copyWith(color: cores.textoApoio)),
                      Text(formatarMoedaBr(_restante),
                          style: textos.valor.copyWith(fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CreditoOpcoes<bool>(
              rotulo: 'Quanto remover',
              opcoes: const [
                (false, 'Todo o restante'),
                (true, 'Só uma parte')
              ],
              selecionado: _soUmaParte,
              aoEscolher: (v) => setState(() => _soUmaParte = v),
            ),
            if (_soUmaParte) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _parte,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: InputDecoration(
                  labelText: 'Valor a remover',
                  prefixText: 'R\$ ',
                  helperText: 'No máximo ${formatarMoedaBr(_restante)}',
                ),
                onChanged: (_) => setState(() {}),
                validator: (_) => _valor <= 0
                    ? 'O valor deve ser maior que zero.'
                    : _valor > _restante
                        ? 'O valor passa do restante.'
                        : null,
              ),
            ],
            const SizedBox(height: 16),
            FormField<String>(
              validator: (_) => _motivo == null ? 'Escolha o motivo.' : null,
              builder: (f) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CreditoOpcoes<String>(
                    rotulo: 'Motivo',
                    opcoes: _motivos,
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
              decoration: const InputDecoration(
                labelText: 'Observação',
                hintText: 'Opcional, exceto em "Outro"',
              ),
              validator: (v) {
                final t = (v ?? '').trim();
                if (_motivo == 'outro' && t.length < 3) {
                  return 'Informe a observação (obrigatória em "Outro").';
                }
                return t.isNotEmpty && t.length < 3
                    ? 'Mínimo de 3 caracteres.'
                    : null;
              },
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cores.falhaFundo,
                borderRadius: BorderRadius.circular(SivDimensoes.raio),
              ),
              child: Text(
                'O cliente não recebe dinheiro de volta. O valor sai do saldo '
                'e fica no extrato como Removido, com o seu usuário. '
                'Não dá para desfazer pela tela.',
                style: textos.apoio.copyWith(color: cores.vinho),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
