import 'package:core/seletores/i_seletor.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/widgets/etiqueta_status_entrada.dart';
import 'package:produtos/presentantion/widgets/foto_do_fornecedor_referencia.dart';

/// Identidade de fornecimento da referência: fornecedor, código no fornecedor e
/// status de entrada (informativo; nada aqui bloqueia o cadastro nem a entrada).
class ReferenciaEsperaSecao extends StatelessWidget {
  final SeletorWidget? fornecedorSeletor;
  final SelectData? fornecedor;
  final ValueChanged<SelectData?> onFornecedor;
  final TextEditingController codigoNoFornecedor;
  final ReferenciaStatusEntrada? status;
  final bool aguardandoReposicao;
  final ValueChanged<bool> onAguardandoReposicao;
  final DateTime? previsaoChegada;
  final ValueChanged<DateTime?> onPrevisaoChegada;
  final TextEditingController quantidadeEsperada;
  final int? referenciaId;

  const ReferenciaEsperaSecao({
    super.key,
    required this.fornecedorSeletor,
    required this.fornecedor,
    required this.onFornecedor,
    required this.codigoNoFornecedor,
    required this.status,
    required this.aguardandoReposicao,
    required this.onAguardandoReposicao,
    required this.previsaoChegada,
    required this.onPrevisaoChegada,
    required this.quantidadeEsperada,
    this.referenciaId,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final primeiraEntrada = status?.aguardandoPrimeiraEntrada ?? false;
    final mostraQuantidade = primeiraEntrada || aguardandoReposicao;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _rotulo(context, 'CÓDIGO NO FORNECEDOR'),
        const SizedBox(height: 4),
        TextFormField(
          controller: codigoNoFornecedor,
          decoration: const InputDecoration(hintText: 'Ex.: DL-2231'),
        ),
        if (fornecedorSeletor != null) ...[
          const SizedBox(height: 12),
          _rotulo(context, 'FORNECEDOR'),
          const SizedBox(height: 4),
          fornecedorSeletor!(
            SeletorData(
              itemsSelecionadosInicial: fornecedor == null
                  ? null
                  : [fornecedor!],
              onChanged: (itens) =>
                  onFornecedor(itens.isEmpty ? null : itens.first),
              compacto: true,
            ),
          ),
        ],
        const SizedBox(height: 16),
        _rotulo(context, 'STATUS DE ENTRADA'),
        const SizedBox(height: 6),
        if (status == null || status!.semStatus)
          Text(
            'Sem pendência de entrada.',
            style: textos.apoio.copyWith(color: cores.textoApoio),
          )
        else
          EtiquetaStatusEntrada(status: status),
        const SizedBox(height: 8),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('Aguardando reposição'),
          subtitle: primeiraEntrada
              ? Text(
                  'Disponível depois da 1ª entrada.',
                  style: textos.apoio.copyWith(color: cores.textoApoio),
                )
              : null,
          value: aguardandoReposicao,
          onChanged: primeiraEntrada ? null : onAguardandoReposicao,
        ),
        if (aguardandoReposicao) ...[
          const SizedBox(height: 8),
          _rotulo(context, 'PREVISÃO DE CHEGADA'),
          const SizedBox(height: 4),
          _CampoData(valor: previsaoChegada, onChanged: onPrevisaoChegada),
        ],
        if (mostraQuantidade) ...[
          const SizedBox(height: 12),
          _rotulo(context, 'QUANTIDADE ESPERADA (PEÇAS)'),
          const SizedBox(height: 4),
          TextFormField(
            controller: quantidadeEsperada,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              hintText: 'Informativo, não bloqueia a entrada',
            ),
            validator: (valor) {
              final texto = valor?.trim() ?? '';
              if (texto.isEmpty) return null;
              return (int.tryParse(texto) ?? 0) > 0
                  ? null
                  : 'Informe um número maior que zero.';
            },
          ),
        ],
        if (referenciaId != null && referenciaId! > 0) ...[
          const SizedBox(height: 16),
          FotoDoFornecedorReferencia(referenciaId: referenciaId!),
        ],
      ],
    );
  }

  Widget _rotulo(BuildContext context, String texto) => Text(
    texto,
    style: context.sivTextos.apoio.copyWith(
      color: context.sivColors.textoApoio,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
    ),
  );
}

class _CampoData extends StatelessWidget {
  final DateTime? valor;
  final ValueChanged<DateTime?> onChanged;

  const _CampoData({required this.valor, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final texto = valor == null
        ? 'Sem data'
        : '${valor!.day.toString().padLeft(2, '0')}/'
              '${valor!.month.toString().padLeft(2, '0')}/${valor!.year}';
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final hoje = DateTime.now();
              final data = await showDatePicker(
                context: context,
                initialDate: valor ?? hoje,
                firstDate: DateTime(hoje.year - 1),
                lastDate: DateTime(hoje.year + 3),
              );
              if (data != null) onChanged(data);
            },
            icon: const Icon(Icons.event, size: 18),
            label: Align(alignment: Alignment.centerLeft, child: Text(texto)),
          ),
        ),
        if (valor != null)
          IconButton(
            tooltip: 'Limpar data',
            onPressed: () => onChanged(null),
            icon: const Icon(Icons.close, size: 18),
          ),
      ],
    );
  }
}
