import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pagamentos/domain/models/pagamento_avulso.dart';

class PagamentoAvulsoDetalhesPage extends StatelessWidget {
  final PagamentoAvulso pagamento;

  const PagamentoAvulsoDetalhesPage({
    super.key,
    required this.pagamento,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do pagamento avulso'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _secao(
            context,
            titulo: 'Pagamento',
            children: [
              _resumoPagamento(context),
              const SizedBox(height: 8),
              if (pagamento.urlDePagamento != null)
                _itemInfoCopiavel(
                  context,
                  label: 'Link de pagamento',
                  value: pagamento.urlDePagamento!,
                ),
              if (pagamento.urlComprovante != null)
                _itemInfoCopiavel(
                  context,
                  label: 'Link do comprovante',
                  value: pagamento.urlComprovante!,
                ),
              if (pagamento.urlPagamentoAvulsoSiteEmpresa != null)
                _itemInfoCopiavel(
                  context,
                  label: 'Link do site da empresa',
                  value: pagamento.urlPagamentoAvulsoSiteEmpresa!,
                ),
              _itemInfo('ID', _textoOuTraco(pagamento.id?.toString() ?? '')),
              _itemInfo('Descricao', _textoOuTraco(pagamento.description)),
              _itemInfo(
                'Referencia externa',
                _textoOuTraco(pagamento.externalReference ?? ''),
              ),
              _itemInfo('Chave de Idempotencia',
                  _textoOuTraco(pagamento.idempotencyKey)),
              _itemInfo(
                'ID externo',
                _textoOuTraco(pagamento.externalId ?? ''),
              ),
              _itemInfo('Criado em', _formatarData(pagamento.criadoEm)),
              _itemInfo('Atualizado em', _formatarData(pagamento.atualizadoEm)),
              _itemInfo('Pago em', _formatarData(pagamento.pagoEm)),
              _itemInfo('Cancelado em', _formatarData(pagamento.canceladoEm)),
              _itemInfo(
                'Motivo do cancelamento',
                _textoOuTraco(pagamento.motivoCancelamento ?? ''),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _secao(
            context,
            titulo: 'Cliente',
            children: [
              _itemInfo('Nome', _textoOuTraco(pagamento.customer.nome)),
              _itemInfo(
                  'Documento', _textoOuTraco(pagamento.customer.documento)),
              _itemInfo('E-mail', _textoOuTraco(pagamento.customer.email)),
              _itemInfo('Telefone', _textoOuTraco(pagamento.customer.telefone)),
            ],
          ),
          const SizedBox(height: 12),
          _secao(
            context,
            titulo: 'Dados tecnicos',
            children: [
              Text(
                'Essas informacoes sao avancadas e geralmente nao sao necessarias para o cliente.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => _abrirDadosTecnicos(context),
                  icon: const Icon(Icons.visibility),
                  label: const Text('Visualizar detalhes tecnicos'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _secao(
    BuildContext context, {
    required String titulo,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _itemInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: SelectableText(value),
          ),
        ],
      ),
    );
  }

  Widget _itemInfoCopiavel(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: value));
          if (!context.mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Link do comprovante copiado.')),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: SelectableText(value)),
                    const SizedBox(width: 4),
                    const Icon(Icons.copy, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resumoPagamento(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatarMoeda(pagamento.amount),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('Status: ${_statusLabel(pagamento.status)}')),
              Chip(label: Text('Forma: ${_providerLabel(pagamento.provider)}')),
            ],
          ),
        ],
      ),
    );
  }

  String _providerLabel(String provider) {
    if (provider == 'infinitypay') {
      return 'InfinityPay';
    }
    if (provider == 'openpix') {
      return 'OpenPix';
    }
    return provider;
  }

  String _formatarMoeda(int amount) {
    return 'R\$ ${(amount / 100).toStringAsFixed(2)}';
  }

  String _textoOuTraco(String value) {
    if (value.trim().isEmpty) {
      return '-';
    }
    return value;
  }

  String _formatarData(DateTime? data) {
    if (data == null) {
      return '-';
    }
    final local = data.toLocal();
    return '${_doisDigitos(local.day)}/${_doisDigitos(local.month)}/${local.year} '
        '${_doisDigitos(local.hour)}:${_doisDigitos(local.minute)}';
  }

  String _formatarMapa(Map<String, dynamic> mapa) {
    if (mapa.isEmpty) {
      return '-';
    }
    return const JsonEncoder.withIndent('  ').convert(mapa);
  }

  String _doisDigitos(int valor) {
    return valor.toString().padLeft(2, '0');
  }

  String _statusLabel(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'pending':
        return 'Pendente';
      case 'paid':
        return 'Pago';
      case 'canceled':
      case 'cancelled':
        return 'Cancelado';
      case 'failed':
        return 'Falhou';
      default:
        return _textoOuTraco(status ?? '');
    }
  }

  String? _obterReceiptUrl() {
    final urlComprovante = pagamento.urlComprovante;
    if (urlComprovante != null && urlComprovante.trim().isNotEmpty) {
      return urlComprovante;
    }

    final urlDePagamento = pagamento.urlDePagamento;
    if (urlDePagamento != null && urlDePagamento.trim().isNotEmpty) {
      return urlDePagamento;
    }

    final dynamic receiptUrl = _buscarValorRecursivo(
      pagamento.respostaGateway,
      'receipt_url',
    );

    if (receiptUrl is String && receiptUrl.trim().isNotEmpty) {
      return receiptUrl;
    }

    return null;
  }

  dynamic _buscarValorRecursivo(Map<String, dynamic> mapa, String chave) {
    if (mapa.containsKey(chave)) {
      return mapa[chave];
    }

    for (final dynamic value in mapa.values) {
      if (value is Map<String, dynamic>) {
        final dynamic encontrado = _buscarValorRecursivo(value, chave);
        if (encontrado != null) {
          return encontrado;
        }
      }

      if (value is List) {
        for (final dynamic item in value) {
          if (item is Map<String, dynamic>) {
            final dynamic encontrado = _buscarValorRecursivo(item, chave);
            if (encontrado != null) {
              return encontrado;
            }
          }
        }
      }
    }

    return null;
  }

  Future<void> _abrirDadosTecnicos(BuildContext context) async {
    final metadata = _formatarMapa(pagamento.metadata);
    final requisicao = _formatarMapa(pagamento.requisicaoGateway);
    final resposta = _formatarMapa(pagamento.respostaGateway);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Dados tecnicos do gateway'),
          content: SizedBox(
            width: 720,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _blocoTecnico('Metadados', metadata),
                  const SizedBox(height: 12),
                  _blocoTecnico('Requisicao ao gateway', requisicao),
                  const SizedBox(height: 12),
                  _blocoTecnico('Resposta do gateway', resposta),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Widget _blocoTecnico(String titulo, String conteudo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        SelectableText(conteudo),
      ],
    );
  }
}
