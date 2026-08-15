import 'package:financeiro/models.dart';
import 'package:financeiro/presentation.dart';
import 'package:flutter/material.dart';
import 'package:promocoes/domain/models/promocao_forma_pagamento.dart';
import 'package:promocoes/domain/models/regra_desconto.dart';

// Restringe/sobrescreve o desconto por forma de pagamento. Reaproveita o
// FormasDePagamentoSeletor do financeiro (mesmo catalogo de GET
// /formas-de-pagamento usado em outras telas) em vez de duplicar a chamada.
class FormasPagamentoFormWidget extends StatelessWidget {
  final bool restringirFormasPagamento;
  final List<PromocaoFormaPagamento> formasPagamento;
  final List<FormaDePagamento> formasDisponiveis;
  final TipoDesconto tipoDesconto;
  final ValueChanged<bool> onRestringirChanged;
  final ValueChanged<List<PromocaoFormaPagamento>> onFormasPagamentoChanged;

  const FormasPagamentoFormWidget({
    super.key,
    required this.restringirFormasPagamento,
    required this.formasPagamento,
    required this.formasDisponiveis,
    required this.tipoDesconto,
    required this.onRestringirChanged,
    required this.onFormasPagamentoChanged,
  });

  @override
  Widget build(BuildContext context) {
    final formasSelecionadasAtuais = formasDisponiveis
        .where(
          (forma) => formasPagamento
              .any((item) => item.formaDePagamentoId == forma.id),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Formas de pagamento',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Restringir formas de pagamento'),
          subtitle: const Text(
            'Desligado: qualquer forma cadastrada pode pagar, usando o '
            'override abaixo se houver ou o desconto padrão da promoção.',
          ),
          value: restringirFormasPagamento,
          onChanged: onRestringirChanged,
        ),
        const SizedBox(height: 8),
        FormasDePagamentoSeletor(
          modo: FormasDePagamentoSeletorModo.multipla,
          titulo: restringirFormasPagamento
              ? 'Formas permitidas'
              : 'Formas com desconto específico (opcional)',
          formasSelecionadasIniciais: formasSelecionadasAtuais,
          onFormaDePagamentoChanged: (formas) {
            final atualizado = formas
                .map(
                  (forma) => formasPagamento.firstWhere(
                    (item) => item.formaDePagamentoId == forma.id,
                    orElse: () =>
                        PromocaoFormaPagamento(formaDePagamentoId: forma.id!),
                  ),
                )
                .toList();
            onFormasPagamentoChanged(atualizado);
          },
        ),
        ...formasPagamento.map((forma) {
          final descricao = _descricaoDaForma(forma.formaDePagamentoId);
          final valorAtual = forma.valorPara(tipoDesconto);

          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextFormField(
              key: ValueKey(
                'formaValor-${forma.formaDePagamentoId}-$tipoDesconto',
              ),
              initialValue: valorAtual?.toString() ?? '',
              decoration: InputDecoration(
                labelText: '$descricao — ${_labelValor(tipoDesconto)} '
                    '(opcional, senão usa o padrão)',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (value) {
                final atualizado = formasPagamento
                    .map(
                      (item) => item.formaDePagamentoId ==
                              forma.formaDePagamentoId
                          ? item.comValor(tipoDesconto, double.tryParse(value))
                          : item,
                    )
                    .toList();
                onFormasPagamentoChanged(atualizado);
              },
            ),
          );
        }),
      ],
    );
  }

  String _descricaoDaForma(int formaDePagamentoId) {
    for (final forma in formasDisponiveis) {
      if (forma.id == formaDePagamentoId) {
        final tipo = forma.tipoOperacao == TipoOperacaoFormaPagamento.online
            ? 'online'
            : 'manual';
        return '${forma.descricao} ($tipo)';
      }
    }
    return 'Forma #$formaDePagamentoId';
  }

  String _labelValor(TipoDesconto tipoDesconto) {
    switch (tipoDesconto) {
      case TipoDesconto.percentual:
        return 'percentual (%)';
      case TipoDesconto.valorFixo:
        return 'valor fixo (R\$)';
      case TipoDesconto.precoFixo:
        return 'preço fixo (R\$)';
    }
  }
}
