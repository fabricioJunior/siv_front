import 'package:comercial/models.dart';
import 'package:comercial/presentation/blocs/creditos_devolucao_bloc/creditos_devolucao_bloc.dart';
import 'package:comercial/presentation/widgets/adicionar_credito_modal.dart'
    show AoConfirmarCredito;
import 'package:comercial/presentation/widgets/credito_form_comum.dart';
import 'package:comercial/presentation/widgets/transferir_credito_dialogo.dart'
    show formatarMoedaBr;
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// 2d: confirmação curta para expirar o crédito agora (motivo opcional).
Future<void> mostrarExpirarCredito(
  BuildContext context, {
  required CreditoDevolucao credito,
  required String titulo,
  required AoConfirmarCredito aoConfirmar,
}) {
  return mostrarFormCredito(
    context,
    (_) => ExpirarCreditoDialogo(
      credito: credito,
      titulo: titulo,
      aoConfirmar: aoConfirmar,
    ),
  );
}

class ExpirarCreditoDialogo extends StatefulWidget {
  final CreditoDevolucao credito;
  final String titulo;
  final AoConfirmarCredito aoConfirmar;

  const ExpirarCreditoDialogo({
    super.key,
    required this.credito,
    required this.titulo,
    required this.aoConfirmar,
  });

  @override
  State<ExpirarCreditoDialogo> createState() => _ExpirarCreditoDialogoState();
}

class _ExpirarCreditoDialogoState extends State<ExpirarCreditoDialogo> {
  final _motivo = TextEditingController();
  String? _erro;
  var _enviando = false;

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    setState(() {
      _enviando = true;
      _erro = null;
    });
    final erro = await widget.aoConfirmar(CreditosDevolucaoExpirou(
      creditoId: widget.credito.id,
      motivo: _motivo.text.trim(),
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
    final valor = formatarMoedaBr(c.valorRestante);
    final prazo = c.validade == null
        ? ''
        : ' Pelo prazo, ele venceria em '
            '${formatarDiaMes(c.validade!)}/${c.validade!.year}.';

    return CreditoFormCasca(
      titulo: 'Expirar este crédito agora?',
      rotuloConfirmar: 'Expirar $valor',
      rotuloVoltar: 'Voltar',
      aoConfirmar: _confirmar,
      enviando: _enviando,
      erro: _erro,
      corpo: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              style: textos.corpo,
              children: [
                TextSpan(
                  text: valor,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: ' do crédito ${c.codigo} (${widget.titulo}) saem do '
                      'saldo hoje.$prazo',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _motivo,
            maxLength: 300,
            decoration: const InputDecoration(
              labelText: 'Motivo (opcional)',
              hintText: 'Ex.: cliente avisado, não vai usar',
            ),
          ),
          Text(
            'Não é preciso fazer isso sempre: créditos expiram sozinhos na '
            'data de validade.',
            style: textos.apoio.copyWith(color: cores.textoApoio),
          ),
        ],
      ),
    );
  }
}
