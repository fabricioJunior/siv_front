import 'dart:convert';

import 'package:comercial/domain/models/documento_fiscal.dart';
import 'package:comercial/domain/models/documento_fiscal_extensoes.dart';
import 'package:comercial/domain/models/romaneio.dart';
import 'package:comercial/domain/models/romaneio_item.dart';
import 'package:comercial/domain/models/romaneio_item_devolvido.dart';
import 'package:comercial/presentation/blocs/documento_fiscal_detalhe_bloc/documento_fiscal_detalhe_bloc.dart';
import 'package:comercial/presentation/relatorios/pdf/nota_fiscal_pdf_exporter.dart';
import 'package:comercial/presentation/relatorios/pdf/romaneio_pdf_exporter.dart';
import 'package:comercial/presentation/widgets/impressao_documento_helper.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DocumentoFiscalPage extends StatefulWidget {
  final int documentoId;
  const DocumentoFiscalPage({super.key, required this.documentoId});

  @override
  State<DocumentoFiscalPage> createState() => _DocumentoFiscalPageState();
}

class _DocumentoFiscalPageState extends State<DocumentoFiscalPage> {
  late final DocumentoFiscalDetalheBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<DocumentoFiscalDetalheBloc>()
      ..add(DocumentoFiscalDetalheCarregar(widget.documentoId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Color _corStatus(String status) => switch (status) {
        'emitida' => const Color(0xFF2E7D32),
        'pendente' => Colors.amber.shade700,
        'pendente_edicao' => Colors.orange.shade700,
        'falha' => Colors.red.shade700,
        'cancelada' => Colors.grey,
        _ => Colors.blueGrey,
      };

  String _fmtDt(DateTime? dt) {
    if (dt == null) return '-';
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  String _prettyJson(dynamic value) {
    if (value == null) return '-';
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DocumentoFiscalDetalheBloc>.value(
      value: _bloc,
      child: BlocBuilder<DocumentoFiscalDetalheBloc, DocumentoFiscalDetalheState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Documento #${widget.documentoId}'),
              backgroundColor: const Color(0xFF283593),
              foregroundColor: Colors.white,
            ),
            body: switch (state.step) {
              DocumentoFiscalDetalheStep.carregando ||
              DocumentoFiscalDetalheStep.inicial =>
                const Center(child: CircularProgressIndicator()),
              DocumentoFiscalDetalheStep.falha => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.erro ?? 'Erro ao carregar'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => _bloc.add(
                          DocumentoFiscalDetalheCarregar(widget.documentoId),
                        ),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              DocumentoFiscalDetalheStep.sucesso =>
                _Body(
                  detalhe: state.detalhe!,
                  corStatus: _corStatus,
                  fmtDt: _fmtDt,
                  prettyJson: _prettyJson,
                  onVerRomaneio: () => Navigator.pushNamed(
                    context,
                    '/romaneio',
                    arguments: {
                      'idRomaneio': state.detalhe!.documento.romaneioId,
                      'permitirEdicao': false,
                    },
                  ),
                  romaneioParaImpressao: state.romaneioParaImpressao,
                  itensParaImpressao: state.itensParaImpressao,
                  itensDevolvidosParaImpressao:
                      state.itensDevolvidosParaImpressao,
                ),
            },
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final DocumentoFiscalDetalhe detalhe;
  final Color Function(String) corStatus;
  final String Function(DateTime?) fmtDt;
  final String Function(dynamic) prettyJson;
  final VoidCallback onVerRomaneio;
  final Romaneio? romaneioParaImpressao;
  final List<RomaneioItem> itensParaImpressao;
  final List<RomaneioItemDevolvido> itensDevolvidosParaImpressao;

  const _Body({
    required this.detalhe,
    required this.corStatus,
    required this.fmtDt,
    required this.prettyJson,
    required this.onVerRomaneio,
    this.romaneioParaImpressao,
    this.itensParaImpressao = const [],
    this.itensDevolvidosParaImpressao = const [],
  });

  @override
  Widget build(BuildContext context) {
    final doc = detalhe.documento;
    final cor = corStatus(doc.status);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Status banner
        _StatusBanner(status: doc.status, cor: cor),
        const SizedBox(height: 12),
        if (doc.status != 'falha')
          FilledButton.icon(
            onPressed: () {
              final adaptado = comAvisoServidor(
                () => NotaFiscalPdfExporter.gerarBytes(doc, romaneio: romaneioParaImpressao),
              );
              imprimirDocumentoPdf(
                context,
                titulo: 'Imprimir nota fiscal',
                nomeDocumento: 'Nota Fiscal #${doc.id}',
                gerarBytes: adaptado.gerarBytes,
                obterAvisoServidor: adaptado.obterAvisoServidor,
              );
            },
            icon: const Icon(Icons.print_outlined),
            label: const Text('Imprimir Nota Fiscal'),
          )
        else if (romaneioParaImpressao != null)
          FilledButton.icon(
            onPressed: () => imprimirDocumentoPdf(
              context,
              titulo: 'Imprimir romaneio',
              nomeDocumento: 'Romaneio #${doc.romaneioId}',
              gerarBytes: () => RomaneioPdfExporter.gerarBytes(
                romaneioParaImpressao!,
                itensParaImpressao,
                itensDevolvidosParaImpressao,
              ),
            ),
            icon: const Icon(Icons.print_outlined),
            label: const Text('Imprimir Romaneio'),
          ),
        const SizedBox(height: 16),

        // Dados da Nota
        _Secao(titulo: 'Dados da Nota', children: [
          _InfoRow('Status', doc.status.replaceAll('_', ' ')),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 120,
                  child: Text('Romaneio',
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                ),
                Expanded(
                  child: Text('#${doc.romaneioId}', style: const TextStyle(fontSize: 13)),
                ),
                TextButton.icon(
                  onPressed: onVerRomaneio,
                  icon: const Icon(Icons.local_shipping_outlined, size: 16),
                  label: const Text('Ver romaneio'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
          _InfoRow('Cliente', doc.pessoaNome ?? '-'),
          _InfoRow('Tipo da Nota', doc.tipoNota),
          _InfoRow('Ambiente', doc.ambienteEmissao),
          _InfoRow('CPF/CNPJ Emissão', doc.cpfOuCnpjEmissao, copiavel: true),
          _InfoRow('Valor Total', 'R\$ ${doc.valorTotalNota.toStringAsFixed(2)}'),
          if (doc.urlDanfe != null)
            _InfoRow('URL da Nota', doc.urlDanfe!, copiavel: true),
          if (doc.produtosDaNota.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 4),
              child: Text('Produtos',
                  style: TextStyle(fontSize: 12, color: Colors.black54)),
            ),
            ...doc.produtosDaNota.map((p) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '${p.quantidade}x ${p.nome} — R\$ ${p.valor.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                )),
          ],
        ]),

        // Erro
        if (doc.erroMensagem != null) ...[
          const SizedBox(height: 16),
          _SecaoErro(mensagem: doc.erroMensagem!),
        ],

        // Dados Técnicos
        const SizedBox(height: 16),
        _SecaoSecundaria(titulo: 'Dados Técnicos', children: [
          _InfoRow('ID', '#${doc.id}'),
          if (doc.pedidoId != null) _InfoRow('Pedido', '#${doc.pedidoId}'),
          _InfoRow('Ação', doc.acao),
          _InfoRow('Provider', doc.provider.toUpperCase()),
          _InfoRow('Criado em', fmtDt(doc.createdAt)),
          _InfoRow('Atualizado em', fmtDt(doc.updatedAt)),
          if (doc.chaveAcesso != null) ...[
            const SizedBox(height: 6),
            _InfoRow('Chave de Acesso', doc.chaveAcesso!, copiavel: true),
          ],
          if (doc.protocolo != null)
            _InfoRow('Protocolo', doc.protocolo!, copiavel: true),
          if (doc.payload != null) ...[
            const SizedBox(height: 10),
            _JsonBloco(label: 'Body da Requisição', valor: prettyJson(doc.payload)),
          ],
          if (doc.respostaGateway != null) ...[
            const SizedBox(height: 10),
            _JsonBloco(label: 'Resposta do Servidor', valor: prettyJson(doc.respostaGateway)),
          ],
        ]),

        // Eventos (secundário)
        const SizedBox(height: 20),
        _SecaoSecundaria(
          titulo: 'Histórico de tentativas (${detalhe.eventos.length})',
          children: detalhe.eventos.isEmpty
              ? [const _InfoRow('', 'Nenhuma tentativa registrada')]
              : detalhe.eventos
                  .map((evento) => _EventoCard(
                        evento: evento,
                        fmtDt: fmtDt,
                        prettyJson: prettyJson,
                      ))
                  .toList(),
        ),
      ],
    );
  }
}

extension _DocumentoFiscalExtracao on DocumentoFiscal {
  Map<String, dynamic>? get _webmania {
    final wm = payload?['webmania'];
    return wm is Map<String, dynamic> ? wm : null;
  }

  Map<String, dynamic>? get _webmaniaPayload {
    final p = _webmania?['payload'];
    return p is Map<String, dynamic> ? p : null;
  }

  Map<String, dynamic>? get _respostaGatewayMap {
    final r = respostaGateway;
    return r is Map<String, dynamic> ? r : null;
  }

  String get cpfOuCnpjEmissao {
    final destinatario = _webmaniaPayload?['destinatario'];
    if (destinatario is Map) {
      final cpf = destinatario['cpf'] as String?;
      if (cpf != null && cpf.isNotEmpty) return cpf;
      final cnpj = destinatario['cnpj'] as String?;
      if (cnpj != null && cnpj.isNotEmpty) return cnpj;
    }
    return payload?['pessoaDocumento'] as String? ?? '-';
  }

  List<({String nome, num quantidade, num valor})> get produtosDaNota {
    final produtos = _webmaniaPayload?['produtos'];
    if (produtos is! List) return const [];
    return produtos.whereType<Map>().map((p) {
      return (
        nome: (p['nome'] as String?) ?? '-',
        quantidade: (p['quantidade'] as num?) ?? 0,
        valor: (p['total'] as num?) ?? (p['subtotal'] as num?) ?? 0,
      );
    }).toList();
  }

  num get valorTotalNota {
    final pedido = _webmaniaPayload?['pedido'];
    if (pedido is Map && pedido['total'] is num) return pedido['total'] as num;
    return (payload?['valorLiquido'] as num?) ?? 0;
  }

  String get ambienteEmissao {
    final tpAmb = _respostaGatewayMap?['log'] is Map
        ? (_respostaGatewayMap!['log'] as Map)['tpAmb']
        : null;
    if (tpAmb == '1') return 'Produção';
    if (tpAmb == '2') return 'Homologação';
    final homologacao = _webmania?['homologacao'];
    if (homologacao is bool) {
      return homologacao ? 'Homologação (não emitida)' : 'Produção (não emitida)';
    }
    return 'Não emitida ainda';
  }

  String get tipoNota {
    final modelo = _webmaniaPayload?['modelo'];
    if (modelo == 1) return 'NF-e';
    if (modelo == 2) return 'NFC-e';
    return tipoDocumento;
  }
}

class _StatusBanner extends StatelessWidget {
  final String status;
  final Color cor;
  const _StatusBanner({required this.status, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            status.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
              color: cor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  final String titulo;
  final List<Widget> children;
  const _Secao({required this.titulo, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

class _SecaoSecundaria extends StatelessWidget {
  final String titulo;
  final List<Widget> children;
  const _SecaoSecundaria({required this.titulo, required this.children});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 8),
        title: Text(
          titulo,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool copiavel;
  const _InfoRow(this.label, this.value, {this.copiavel = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            SizedBox(
              width: 120,
              child: Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ),
          ],
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
          if (copiavel)
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copiado!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.copy_outlined, size: 16, color: Colors.black38),
              ),
            ),
        ],
      ),
    );
  }
}

class _SecaoErro extends StatelessWidget {
  final String mensagem;
  const _SecaoErro({required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.error_outline, size: 16, color: Colors.red.shade700),
            const SizedBox(width: 6),
            Text('Erro',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.red.shade700)),
          ]),
          const SizedBox(height: 6),
          Text(mensagem,
              style: TextStyle(fontSize: 12, color: Colors.red.shade800)),
        ],
      ),
    );
  }
}

class _EventoCard extends StatefulWidget {
  final DocumentoFiscalEvento evento;
  final String Function(DateTime?) fmtDt;
  final String Function(dynamic) prettyJson;
  const _EventoCard({
    required this.evento,
    required this.fmtDt,
    required this.prettyJson,
  });

  @override
  State<_EventoCard> createState() => _EventoCardState();
}

class _EventoCardState extends State<_EventoCard> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.evento;
    final cor = e.sucesso ? const Color(0xFF2E7D32) : Colors.red.shade700;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () => setState(() => _expandido = !_expandido),
            child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: cor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Icon(
                          e.sucesso ? Icons.check_circle_outline : Icons.cancel_outlined,
                          size: 16,
                          color: cor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Tentativa ${e.tentativa}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          e.sucesso ? 'Sucesso' : 'Falha',
                          style: TextStyle(fontSize: 12, color: cor),
                        ),
                        if (e.requestUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Icon(Icons.http, size: 14, color: Colors.blueGrey.shade300),
                          ),
                        const Spacer(),
                        Text(
                          widget.fmtDt(e.criadoEm),
                          style: const TextStyle(fontSize: 11, color: Colors.black45),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _expandido ? Icons.expand_less : Icons.expand_more,
                          size: 18,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ),

          // Detalhe expandível
          if (_expandido) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (e.erroMensagem != null) ...[
                    _SecaoErro(mensagem: e.erroMensagem!),
                    const SizedBox(height: 10),
                  ],
                  if (e.requestUrl != null) ...[
                    _LabelBloco(
                      label: 'URL da Requisição',
                      valor: e.requestUrl!,
                      copiavel: true,
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (e.requestBody != null) ...[
                    _JsonBloco(
                      label: 'Body da Requisição',
                      valor: widget.prettyJson(e.requestBody),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (e.resposta != null) ...[
                    _JsonBloco(
                      label: 'Resposta do Servidor',
                      valor: widget.prettyJson(e.resposta),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LabelBloco extends StatelessWidget {
  final String label;
  final String valor;
  final bool copiavel;
  const _LabelBloco({required this.label, required this.valor, this.copiavel = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54)),
            if (copiavel) ...[
              const Spacer(),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: valor));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Copiado!'),
                        duration: Duration(seconds: 1)),
                  );
                },
                child: const Icon(Icons.copy_outlined, size: 14, color: Colors.black38),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(valor, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
        ),
      ],
    );
  }
}

class _JsonBloco extends StatelessWidget {
  final String label;
  final String valor;
  const _JsonBloco({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54)),
            const Spacer(),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: valor));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Copiado!'),
                      duration: Duration(seconds: 1)),
                );
              },
              child: const Icon(Icons.copy_outlined, size: 14, color: Colors.black38),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              valor,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
        ),
      ],
    );
  }
}
