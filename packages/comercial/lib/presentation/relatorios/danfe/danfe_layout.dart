import 'package:comercial/domain/models/danfe.dart';

/// Alinhamento de texto agnostico de formato de saida (PDF ou ESC/POS).
enum DanfeAlinhamento { esquerda, centro, direita }

/// Descreve O QUE imprimir, sem saber COMO (isso e responsabilidade de
/// cada renderer -- ver `danfe_pdf_renderer.dart`/`danfe_esc_pos_renderer.dart`).
sealed class DanfeNode {
  const DanfeNode();
}

class DanfeTexto extends DanfeNode {
  final String texto;
  final DanfeAlinhamento alinhamento;
  final bool negrito;
  /// Escala relativa ao tamanho normal (1.0). Usado so pra titulos.
  final double escala;

  const DanfeTexto(
    this.texto, {
    this.alinhamento = DanfeAlinhamento.esquerda,
    this.negrito = false,
    this.escala = 1,
  });
}

/// Uma linha com texto alinhado a esquerda e a direita (ex:
/// "2 UN x R$ 10,00" ... "R$ 20,00").
class DanfeLinhaDupla extends DanfeNode {
  final String esquerda;
  final String direita;
  final bool negrito;

  const DanfeLinhaDupla(this.esquerda, this.direita, {this.negrito = false});
}

class DanfeSeparador extends DanfeNode {
  const DanfeSeparador();
}

class DanfeEspaco extends DanfeNode {
  final int linhas;
  const DanfeEspaco([this.linhas = 1]);
}

class DanfeQrCode extends DanfeNode {
  final String dado;
  const DanfeQrCode(this.dado);
}

/// Labels/textos fixos do layout, centralizados aqui pra nao espalhar
/// strings soltas pelos renderers.
class DanfeTextos {
  DanfeTextos._();

  static const naoPermiteCredito = 'Não permite aproveitamento de crédito de ICMS';
  static const consumidorNaoIdentificado = 'CONSUMIDOR NÃO IDENTIFICADO';
  static const cabecalhoItens = 'CÓDIGO / DESCRIÇÃO';
  static const valorProdutos = 'VALOR TOTAL DOS PRODUTOS';
  static const descontoLabel = 'DESCONTO';
  static const acrescimoLabel = 'ACRÉSCIMO';
  static const valorAPagar = 'VALOR A PAGAR';
  static const formaPagamentoTitulo = 'FORMA DE PAGAMENTO';
  static const trocoLabel = 'TROCO';
  static const tributosLabel = 'Valor aproximado dos tributos';
  static const chaveAcessoTitulo = 'Chave de acesso';
  static const consulteAutenticidade =
      'Consulte pela chave de acesso em www.nfce.fazenda.gov.br';
}

String _fmtMoeda(num? v) {
  final s = (v ?? 0).toStringAsFixed(2);
  final partes = s.split('.');
  final inteiro = partes[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]}.',
  );
  return 'R\$ $inteiro,${partes[1]}';
}

String _fmtQuantidade(num? v) {
  if (v == null) return '-';
  if (v == v.truncateToDouble()) return v.toInt().toString();
  return v.toStringAsFixed(3).replaceAll('.', ',');
}

String _fmtDt(DateTime? dt) {
  if (dt == null) return '-';
  final local = dt.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} '
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}

String _naoVazio(String? v, [String fallback = '-']) =>
    (v?.trim().isNotEmpty ?? false) ? v!.trim() : fallback;

/// Monta a arvore de nodes completa do DANFE a partir dos dados -- usada
/// igualmente pelo renderer de PDF e pelo de ESC/POS.
List<DanfeNode> construirDanfeNodes(DanfeLayoutData dados) => [
      ..._cabecalho(dados),
      const DanfeSeparador(),
      ..._tabelaProdutos(dados.itens),
      const DanfeSeparador(),
      ..._totais(dados.totais),
      const DanfeSeparador(),
      ..._pagamentos(dados.pagamentos, dados.troco),
      if (dados.tributosAproximados != null) ...[
        const DanfeSeparador(),
        DanfeLinhaDupla(DanfeTextos.tributosLabel, _fmtMoeda(dados.tributosAproximados)),
      ],
      const DanfeSeparador(),
      ..._consumidor(dados.consumidor),
      const DanfeSeparador(),
      ..._autorizacao(dados),
      if (dados.qrCodePayload != null) ...[
        const DanfeEspaco(),
        DanfeQrCode(dados.qrCodePayload!),
      ],
      ..._rodape(dados.mensagensRodape),
    ];

List<DanfeNode> _cabecalho(DanfeLayoutData dados) {
  final empresa = dados.empresa;
  final id = dados.identificacao;
  return [
    DanfeTexto(
      _naoVazio(empresa.nomeFantasia ?? empresa.razaoSocial),
      alinhamento: DanfeAlinhamento.centro,
      negrito: true,
      escala: 1.2,
    ),
    if (empresa.nomeFantasia != null && empresa.razaoSocial != empresa.nomeFantasia)
      DanfeTexto(empresa.razaoSocial, alinhamento: DanfeAlinhamento.centro),
    if (empresa.cnpj != null)
      DanfeTexto('CNPJ: ${empresa.cnpj}', alinhamento: DanfeAlinhamento.centro),
    if (empresa.inscricaoEstadual != null)
      DanfeTexto('IE: ${empresa.inscricaoEstadual}', alinhamento: DanfeAlinhamento.centro),
    if (empresa.endereco != null)
      DanfeTexto(empresa.endereco!, alinhamento: DanfeAlinhamento.centro),
    if (empresa.telefone != null)
      DanfeTexto('Tel: ${empresa.telefone}', alinhamento: DanfeAlinhamento.centro),
    const DanfeEspaco(),
    DanfeTexto(id.tipoDocumento, alinhamento: DanfeAlinhamento.centro, negrito: true),
    if (id.ehNfce)
      DanfeTexto(DanfeTextos.naoPermiteCredito, alinhamento: DanfeAlinhamento.centro),
    if (id.numero != null)
      DanfeTexto(
        '${id.tipoDocumento} nº ${id.numero} - Série ${id.serie}',
        alinhamento: DanfeAlinhamento.centro,
      ),
    DanfeTexto('Emissão: ${_fmtDt(id.dataEmissao)}', alinhamento: DanfeAlinhamento.centro),
  ];
}

List<DanfeNode> _tabelaProdutos(List<DanfeItem> itens) {
  final nodes = <DanfeNode>[DanfeTexto(DanfeTextos.cabecalhoItens, negrito: true)];
  for (final item in itens) {
    final codigo = item.codigo != null ? '${item.codigo} - ' : '';
    nodes.add(DanfeTexto('$codigo${item.descricao}'));
    nodes.add(DanfeLinhaDupla(
      '${_fmtQuantidade(item.quantidade)} ${item.unidade} x ${_fmtMoeda(item.valorUnitario)}',
      _fmtMoeda(item.valorTotal),
    ));
    if (item.desconto != null && item.desconto! > 0) {
      nodes.add(DanfeLinhaDupla('Desconto do item', '-${_fmtMoeda(item.desconto)}'));
    }
  }
  return nodes;
}

List<DanfeNode> _totais(DanfeTotais totais) => [
      DanfeLinhaDupla(DanfeTextos.valorProdutos, _fmtMoeda(totais.subtotal)),
      if (totais.descontos > 0)
        DanfeLinhaDupla(DanfeTextos.descontoLabel, '-${_fmtMoeda(totais.descontos)}'),
      if (totais.acrescimos > 0)
        DanfeLinhaDupla(DanfeTextos.acrescimoLabel, _fmtMoeda(totais.acrescimos)),
      DanfeLinhaDupla(DanfeTextos.valorAPagar, _fmtMoeda(totais.total), negrito: true),
    ];

List<DanfeNode> _pagamentos(List<DanfePagamento> pagamentos, num? troco) {
  if (pagamentos.isEmpty) return const [];
  return [
    DanfeTexto(DanfeTextos.formaPagamentoTitulo, negrito: true),
    for (final pagamento in pagamentos) DanfeLinhaDupla(pagamento.forma, _fmtMoeda(pagamento.valor)),
    if (troco != null && troco > 0) DanfeLinhaDupla(DanfeTextos.trocoLabel, _fmtMoeda(troco)),
  ];
}

List<DanfeNode> _consumidor(DanfeConsumidor consumidor) => [
      DanfeTexto(
        consumidor.identificado
            ? _naoVazio(consumidor.nome, DanfeTextos.consumidorNaoIdentificado)
            : DanfeTextos.consumidorNaoIdentificado,
        negrito: true,
      ),
      if (consumidor.documento != null) DanfeTexto('CPF/CNPJ: ${consumidor.documento}'),
    ];

List<DanfeNode> _autorizacao(DanfeLayoutData dados) {
  final auth = dados.autorizacao;
  return [
    if (auth.protocolo != null) DanfeTexto('Protocolo de autorização: ${auth.protocolo}'),
    if (auth.dataAutorizacao != null)
      DanfeTexto('Data de autorização: ${_fmtDt(auth.dataAutorizacao)}'),
    if (auth.chaveAcesso != null) ...[
      const DanfeEspaco(),
      DanfeTexto(DanfeTextos.chaveAcessoTitulo, negrito: true),
      DanfeTexto(auth.chaveAcesso!),
      DanfeTexto(DanfeTextos.consulteAutenticidade, alinhamento: DanfeAlinhamento.centro),
    ],
  ];
}

List<DanfeNode> _rodape(List<String> mensagens) => [
      const DanfeEspaco(),
      for (final mensagem in mensagens)
        DanfeTexto(mensagem, alinhamento: DanfeAlinhamento.centro),
    ];
