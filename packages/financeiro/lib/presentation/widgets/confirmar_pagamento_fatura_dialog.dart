import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/tema.dart';
import 'package:financeiro/domain/models/despesa_ocorrencia_calendario.dart';
import 'package:financeiro/domain/models/pagamento_de_fatura.dart';
import 'package:financeiro/domain/use_cases/pagar_fatura_de_cartao.dart';
import 'package:financeiro/presentation.dart';
import 'package:financeiro/presentation/utils/formatadores.dart';
import 'package:financeiro/presentation/utils/nomes_dos_meses.dart';
import 'package:flutter/material.dart';

/// Mostra a prévia de pagamento de fatura (quantidade + total + itens) e, ao
/// confirmar, chama `PagarFaturaDeCartao` -- loading/erro ficam dentro do
/// próprio diálogo, só fecha (retornando o resultado) em caso de sucesso.
Future<PagamentoDeFatura?> mostrarConfirmarPagamentoFaturaDialog(
  BuildContext context, {
  required int empresaId,
  required int origemPagamentoId,
  required String origemNome,
  required int ano,
  required int mes,
  required List<DespesaOcorrenciaCalendario> ocorrencias,
}) {
  return showDialog<PagamentoDeFatura>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ConfirmarPagamentoFaturaDialog(
      empresaId: empresaId,
      origemPagamentoId: origemPagamentoId,
      origemNome: origemNome,
      ano: ano,
      mes: mes,
      ocorrencias: ocorrencias,
    ),
  );
}

/// Fluxo completo: prévia + confirmação + snackbar de resultado + recarga do
/// calendário do mês (que por sua vez já recarrega o painel, via
/// `CalendarioDeDespesasBody.onAlterou`).
Future<void> confirmarEPagarFaturaDeCartao(
  BuildContext context, {
  required int empresaId,
  required int origemPagamentoId,
  required String origemNome,
  required int ano,
  required int mes,
  required List<DespesaOcorrenciaCalendario> ocorrenciasPendentes,
}) async {
  final resultado = await mostrarConfirmarPagamentoFaturaDialog(
    context,
    empresaId: empresaId,
    origemPagamentoId: origemPagamentoId,
    origemNome: origemNome,
    ano: ano,
    mes: mes,
    ocorrencias: ocorrenciasPendentes,
  );
  if (resultado == null || !context.mounted) return;

  final mensagem = resultado.atualizadas == 0
      ? 'Nada pendente no cartão $origemNome em ${nomesDosMeses[mes - 1]}.'
      : '${resultado.atualizadas} despesas do cartão $origemNome marcadas como pagas — '
          '${formatarReais(resultado.valorTotal)}.';
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));

  if (context.mounted) {
    context
        .read<CalendarioDeDespesasBloc>()
        .add(CalendarioDeDespesasMesAlterado(ano: ano, mes: mes));
  }
}

class _ConfirmarPagamentoFaturaDialog extends StatefulWidget {
  final int empresaId;
  final int origemPagamentoId;
  final String origemNome;
  final int ano;
  final int mes;
  final List<DespesaOcorrenciaCalendario> ocorrencias;

  const _ConfirmarPagamentoFaturaDialog({
    required this.empresaId,
    required this.origemPagamentoId,
    required this.origemNome,
    required this.ano,
    required this.mes,
    required this.ocorrencias,
  });

  @override
  State<_ConfirmarPagamentoFaturaDialog> createState() =>
      _ConfirmarPagamentoFaturaDialogState();
}

class _ConfirmarPagamentoFaturaDialogState
    extends State<_ConfirmarPagamentoFaturaDialog> {
  bool _carregando = false;
  String? _erro;

  double get _total =>
      widget.ocorrencias.fold(0.0, (soma, o) => soma + o.valor);

  bool get _temPrevista => widget.ocorrencias.any((o) => o.virtual);

  Future<void> _confirmar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final resultado = await sl<PagarFaturaDeCartao>().call(
        empresaId: widget.empresaId,
        origemPagamentoId: widget.origemPagamentoId,
        ano: widget.ano,
        mes: widget.mes,
      );
      if (!mounted) return;
      Navigator.of(context).pop(resultado);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _erro = 'Falha ao marcar o cartão como pago.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final n = widget.ocorrencias.length;

    return AlertDialog(
      title: Text(
        'Marcar cartão ${widget.origemNome} como pago — '
        '${nomesDosMeses[widget.mes - 1]}/${widget.ano}',
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$n despesa(s)', style: textos.secao.copyWith(fontSize: 18)),
                Text(formatarReais(_total),
                    style: textos.secao
                        .copyWith(fontSize: 18, color: cores.acoAtivo)),
              ],
            ),
            const SizedBox(height: 10),
            if (n > 0)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: n,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: cores.hairline),
                  itemBuilder: (_, i) {
                    final o = widget.ocorrencias[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(o.descricao,
                                  style: textos.corpo.copyWith(fontSize: 13.5))),
                          Text(formatarReais(o.valor),
                              style: textos.corpo.copyWith(fontSize: 13.5)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            if (_temPrevista) ...[
              const SizedBox(height: 10),
              Text(
                'Itens previstos (recorrência ainda não lançada) podem não ser quitados nesta ação.',
                style: textos.apoio.copyWith(fontSize: 12, color: cores.textoApoio),
              ),
            ],
            if (_erro != null) ...[
              const SizedBox(height: 12),
              Text(_erro!, style: textos.apoio.copyWith(color: Colors.red)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _carregando ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _carregando ? null : _confirmar,
          child: _carregando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_erro != null ? 'Tentar de novo' : 'Marcar $n como pagas'),
        ),
      ],
    );
  }
}
