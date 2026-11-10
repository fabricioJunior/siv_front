// Domínio puro (sem Flutter), ao lado de trilha_entrada.dart: a função é consumida por
// qualquer camada (BLoC/UI) e testável sem widget.
import 'package:comercial/domain/models/pedido.dart';
import 'package:comercial/domain/models/pedido_item.dart';
import 'package:comercial/domain/models/pedido_pagamento.dart';
import 'package:core/equals.dart';

enum TipoTrilhaPedido {
  ecommerceRetirada,
  ecommerceEntrega,
  vendaRetirada,
  vendaEntregaOnline,
  vendaEntregaNoAto,
  minima,
  entrada,
}

enum IdEtapaPedido {
  assumir,
  conferir,
  itens,
  pagamento,
  confirmacao,
  embalar,
  retirada,
  chamarEntregador,
  entregue,
  acerto,
  faturar,
}

enum EstadoEtapa { feita, atual, futura }

/// Ação principal (F9) da etapa.
enum AcaoPedido {
  assumirPedido,
  concluirConferencia,
  irParaPagamento,
  lancarPagamento,
  faturar,
  marcarEmbalado,
  confirmarRetirada,
  chamarEntregador,
  confirmarEntrega,
  fecharAcerto,
}

/// T5: onde o faturamento acontece. Decisão de produto: no acerto.
/// Trocar para [antesDaSaida] insere a etapa Confirmação (faturar) antes de Embalar.
enum PontoFaturamentoT5 { acerto, antesDaSaida }

const pontoFaturamentoT5Padrao = PontoFaturamentoT5.acerto;

/// O backend só fatura pedido de ENTREGA depois de `entregue` (PedidoService.faturar).
/// true: T4 fatura depois da entrega (Confirmação só confirma pagamentos; etapa Faturar no fim)
/// e o Acerto da T5 confirma a entrega antes de faturar. false: ordem original do handoff
/// (fatura na Confirmação), para quando o backend deixar faturar antes de entregar.
const faturaEntregaDepoisDeEntregar = true;

extension IdEtapaPedidoX on IdEtapaPedido {
  String get titulo => switch (this) {
        IdEtapaPedido.assumir => 'Assumir',
        IdEtapaPedido.conferir => 'Conferir',
        IdEtapaPedido.itens => 'Itens',
        IdEtapaPedido.pagamento => 'Pagamento',
        IdEtapaPedido.confirmacao => 'Confirmação',
        IdEtapaPedido.embalar => 'Embalar',
        IdEtapaPedido.retirada => 'Retirada',
        IdEtapaPedido.chamarEntregador => 'Chamar entregador',
        IdEtapaPedido.entregue => 'Entregue',
        IdEtapaPedido.acerto => 'Acerto',
        IdEtapaPedido.faturar => 'Faturar',
      };

  AcaoPedido get acao => switch (this) {
        IdEtapaPedido.assumir => AcaoPedido.assumirPedido,
        IdEtapaPedido.conferir => AcaoPedido.concluirConferencia,
        IdEtapaPedido.itens => AcaoPedido.irParaPagamento,
        IdEtapaPedido.pagamento => AcaoPedido.lancarPagamento,
        IdEtapaPedido.confirmacao => AcaoPedido.faturar,
        IdEtapaPedido.embalar => AcaoPedido.marcarEmbalado,
        IdEtapaPedido.retirada => AcaoPedido.confirmarRetirada,
        IdEtapaPedido.chamarEntregador => AcaoPedido.chamarEntregador,
        IdEtapaPedido.entregue => AcaoPedido.confirmarEntrega,
        IdEtapaPedido.acerto => AcaoPedido.fecharAcerto,
        IdEtapaPedido.faturar => AcaoPedido.faturar,
      };
}

class EtapaPedido extends Equatable {
  final IdEtapaPedido id;
  final EstadoEtapa estado;
  final String subtitulo;
  final AcaoPedido acao;

  /// Título próprio da trilha (T5: "Forma prevista"); null = título padrão do [id].
  final String? rotulo;

  /// Só preenchido na etapa atual quando a ação F9 não pode rodar ainda.
  final String? motivoDesabilitada;

  const EtapaPedido({
    required this.id,
    required this.estado,
    required this.subtitulo,
    required this.acao,
    this.rotulo,
    this.motivoDesabilitada,
  });

  String get titulo => rotulo ?? id.titulo;

  @override
  List<Object?> get props => [id, estado, subtitulo, acao, rotulo, motivoDesabilitada];
}

class TrilhaPedido extends Equatable {
  final TipoTrilhaPedido tipo;
  final List<EtapaPedido> etapas;

  /// Pedido de entrada: a tela abre `/pedido_entrada` (sem etapas).
  final bool abreEntrada;
  final bool cancelado;

  /// Retirada sem código (parâmetro desligado): etapa Retirada só tem F9.
  final bool exigeCodigoRetirada;

  /// Etapa Conferir sobre pedido já encerrado: usar `marcarConferido` (senão `conferir`).
  final bool conferenciaRetroativa;

  const TrilhaPedido({
    required this.tipo,
    this.etapas = const [],
    this.abreEntrada = false,
    this.cancelado = false,
    this.exigeCodigoRetirada = true,
    this.conferenciaRetroativa = false,
  });

  EtapaPedido? get atual {
    for (final e in etapas) {
      if (e.estado == EstadoEtapa.atual) return e;
    }
    return null;
  }

  AcaoPedido? get acaoPrincipal => atual?.acao;
  String? get motivoDesabilitada => atual?.motivoDesabilitada;
  bool get acaoPrincipalHabilitada => atual != null && atual!.motivoDesabilitada == null;
  bool get concluida => !abreEntrada && !cancelado && etapas.isNotEmpty && atual == null;

  /// Antes de assumir, a tela inteira é só leitura.
  bool get somenteLeitura => atual?.id == IdEtapaPedido.assumir;

  @override
  List<Object?> get props =>
      [tipo, etapas, abreEntrada, cancelado, exigeCodigoRetirada, conferenciaRetroativa];
}

const _rankEntrega = {
  'aguardando_chamada': 1,
  'embalado': 2,
  'chamado': 3,
  'entregue': 4,
};

String _brl(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

class _Ctx {
  final Pedido p;
  final List<PedidoPagamento> pagamentos;
  final List<PedidoItem> itens;
  final double? totalPedido;
  _Ctx(this.p, this.pagamentos, this.itens, this.totalPedido);

  bool get faturado => p.situacao == 'faturado' || p.situacao == 'encerrado';
  bool get encerrado => p.situacao == 'encerrado';
  int get rankEntrega => _rankEntrega[p.situacaoEntrega] ?? 0;
  double get total => totalPedido ?? p.valorTotal ?? 0;
  bool get entrega => p.modalidadeEntrega == 'entrega';
  double get lancado => pagamentos.fold(0, (s, x) => s + (x.valorEsperado ?? 0));
  double get recebido => pagamentos
      .where((x) => x.confirmadoEm != null)
      .fold(0, (s, x) => s + (x.valorConfirmado ?? x.valorEsperado ?? 0));
  bool get pagamentoCompleto => pagamentos.isNotEmpty && lancado + 0.005 >= total;
  int get naoConfirmados => pagamentos.where((x) => x.confirmadoEm == null).length;
  int get onlinePendentes =>
      pagamentos.where((x) => x.confirmadoEm == null && x.tipo == 'controlado').length;
  bool get tudoConfirmado => pagamentos.isNotEmpty && naoConfirmados == 0;
  // Retirada encerrada com nao_aplicavel = pedido antigo, embalado implícito.
  bool get embaladoRetirada =>
      p.retiradoEm != null || rankEntrega >= 2 || (encerrado && rankEntrega == 0);
}

bool _feita(IdEtapaPedido id, _Ctx c) {
  final p = c.p;
  switch (id) {
    case IdEtapaPedido.assumir:
      return p.funcionarioId != null;
    case IdEtapaPedido.conferir:
      return p.conferidoEm != null;
    case IdEtapaPedido.itens:
      return c.faturado || (c.itens.isNotEmpty && c.pagamentos.isNotEmpty);
    case IdEtapaPedido.pagamento:
      return c.faturado || c.pagamentoCompleto;
    case IdEtapaPedido.confirmacao:
      return c.faturado ||
          (faturaEntregaDepoisDeEntregar && c.entrega && c.tudoConfirmado);
    case IdEtapaPedido.faturar:
      return c.faturado;
    case IdEtapaPedido.embalar:
      return p.modalidadeEntrega == 'entrega'
          ? c.rankEntrega >= 2
          : c.embaladoRetirada;
    case IdEtapaPedido.retirada:
      return p.retiradoEm != null;
    case IdEtapaPedido.chamarEntregador:
      return c.rankEntrega >= 3;
    case IdEtapaPedido.entregue:
      return c.rankEntrega >= 4;
    case IdEtapaPedido.acerto:
      return c.rankEntrega >= 4 && c.faturado;
  }
}

String? _motivo(IdEtapaPedido id, _Ctx c, {required bool t5}) {
  final p = c.p;
  switch (id) {
    case IdEtapaPedido.itens:
      return c.itens.isEmpty ? 'Adicione ao menos um item.' : null;
    case IdEtapaPedido.faturar:
      return c.itens.isEmpty && p.tipo != 'taxa_entrega'
          ? 'Adicione ao menos um item.'
          : null;
    case IdEtapaPedido.confirmacao:
      if (c.onlinePendentes > 0) return 'Aguardando pagamento online.';
      if (c.naoConfirmados > 0) return 'Confirme ${c.naoConfirmados} pagamento(s).';
      return c.pagamentos.isEmpty ? 'Nenhum pagamento lançado.' : null;
    case IdEtapaPedido.embalar:
      if (p.modalidadeEntrega == 'entrega') {
        // T5 embala antes de faturar; o backend precisa aceitar (ver pendências).
        if (t5) return null;
        return p.situacaoEntrega == 'aguardando_chamada'
            ? null
            : 'Aguardando liberação da entrega.';
      }
      return c.encerrado ? null : 'Fature o pedido antes de embalar.';
    case IdEtapaPedido.retirada:
      return c.encerrado ? null : 'Pedido ainda não faturado.';
    case IdEtapaPedido.acerto:
      if (!c.tudoConfirmado) {
        final falta = c.total - c.recebido;
        return falta > 0.005 ? 'Faltam ${_brl(falta)} a receber.' : 'Nenhuma forma prevista.';
      }
      return null;
    default:
      return null;
  }
}

String _subtitulo(IdEtapaPedido id, EstadoEtapa estado, _Ctx c) {
  final feita = estado == EstadoEtapa.feita;
  switch (id) {
    case IdEtapaPedido.assumir:
      return feita ? (c.p.funcionarioNome ?? 'Assumido') : 'Escolha o vendedor';
    case IdEtapaPedido.conferir:
      return feita ? 'Conferido' : 'Leia as peças';
    case IdEtapaPedido.itens:
      return '${c.itens.length} item(ns)';
    case IdEtapaPedido.pagamento:
      if (feita) return _brl(c.lancado);
      final falta = c.total - c.lancado;
      return falta > 0.005 ? 'Faltam ${_brl(falta)}' : 'Lançar';
    case IdEtapaPedido.confirmacao:
      return feita ? (c.faturado ? 'Faturado' : 'Confirmado') : '${c.pagamentos.length - c.naoConfirmados}/${c.pagamentos.length} confirmados';
    case IdEtapaPedido.faturar:
      return feita ? 'Faturado' : 'Pendente';
    case IdEtapaPedido.embalar:
      return feita ? 'Embalado' : 'Pendente';
    case IdEtapaPedido.retirada:
      return feita ? 'Retirado' : 'Aguardando retirada';
    case IdEtapaPedido.chamarEntregador:
      return feita ? 'Entregador chamado' : 'Pendente';
    case IdEtapaPedido.entregue:
      return feita ? 'Entregue' : 'A caminho';
    case IdEtapaPedido.acerto:
      return feita ? 'Acertado' : 'Receber ${_brl(c.total - c.recebido)}';
  }
}

TrilhaPedido _monta(
  TipoTrilhaPedido tipo,
  List<IdEtapaPedido> ids,
  _Ctx c, {
  bool t5 = false,
}) {
  final cancelado = c.p.situacao == 'cancelado';
  var achouAtual = cancelado;
  final etapas = <EtapaPedido>[];
  for (final id in ids) {
    final EstadoEtapa estado;
    if (_feita(id, c)) {
      estado = EstadoEtapa.feita;
    } else if (!achouAtual) {
      estado = EstadoEtapa.atual;
      achouAtual = true;
    } else {
      estado = EstadoEtapa.futura;
    }
    etapas.add(EtapaPedido(
      id: id,
      estado: estado,
      subtitulo: _subtitulo(id, estado, c),
      acao: id.acao,
      rotulo: t5 && id == IdEtapaPedido.pagamento ? 'Forma prevista' : null,
      motivoDesabilitada: estado == EstadoEtapa.atual ? _motivo(id, c, t5: t5) : null,
    ));
  }
  return TrilhaPedido(
    tipo: tipo,
    etapas: etapas,
    cancelado: cancelado,
    exigeCodigoRetirada: c.p.exigeCodigoRetirada,
    conferenciaRetroativa: ids.contains(IdEtapaPedido.conferir) && c.encerrado,
  );
}

const _entradas = {'compra', 'transferencia_entrada'};

/// Escolhe a trilha (handoff §2) e deriva o estado de cada etapa.
///
/// `taxa_entrega` (pedido-complemento de entrega, sem itens, faturado como venda):
/// mesma trilha de venda·entrega sem a etapa Itens, T4/T5 conforme `pagamentoNaEntrega`.
/// `transferencia_saida` (e tipos sem trilha própria): trilha mínima de 1 etapa (Faturar).
TrilhaPedido derivarTrilhaPedido(
  Pedido pedido,
  List<PedidoPagamento> pagamentos,
  List<PedidoItem> itens, {
  PontoFaturamentoT5 pontoT5 = pontoFaturamentoT5Padrao,

  /// Total a cobrir (itens − desconto + taxa). O `valorTotal` do backend não desconta o
  /// desconto de nível pedido; a tela passa `PedidoState.valorTotalGeral`.
  double? total,
}) {
  final c = _Ctx(pedido, pagamentos, itens, total);
  final tipo = pedido.tipo;
  final entrega = pedido.modalidadeEntrega == 'entrega';

  if (_entradas.contains(tipo)) {
    return TrilhaPedido(
      tipo: TipoTrilhaPedido.entrada,
      abreEntrada: true,
      cancelado: pedido.situacao == 'cancelado',
    );
  }

  if (pedido.origem == 'ecommerce') {
    final base = [IdEtapaPedido.assumir, IdEtapaPedido.conferir, IdEtapaPedido.embalar];
    return entrega
        ? _monta(TipoTrilhaPedido.ecommerceEntrega,
            [...base, IdEtapaPedido.chamarEntregador, IdEtapaPedido.entregue], c)
        : _monta(TipoTrilhaPedido.ecommerceRetirada, [...base, IdEtapaPedido.retirada], c);
  }

  if (tipo == null || tipo == 'venda' || tipo == 'taxa_entrega') {
    final itensEtapa = tipo == 'taxa_entrega' ? <IdEtapaPedido>[] : [IdEtapaPedido.itens];
    if (!entrega) {
      return _monta(
        TipoTrilhaPedido.vendaRetirada,
        [
          ...itensEtapa,
          IdEtapaPedido.pagamento,
          IdEtapaPedido.confirmacao,
          IdEtapaPedido.embalar,
          IdEtapaPedido.retirada,
        ],
        c,
      );
    }
    if (pedido.pagamentoNaEntrega) {
      return _monta(
        TipoTrilhaPedido.vendaEntregaNoAto,
        [
          ...itensEtapa,
          IdEtapaPedido.pagamento,
          if (pontoT5 == PontoFaturamentoT5.antesDaSaida) IdEtapaPedido.confirmacao,
          IdEtapaPedido.embalar,
          IdEtapaPedido.chamarEntregador,
          IdEtapaPedido.acerto,
        ],
        c,
        t5: true,
      );
    }
    return _monta(
      TipoTrilhaPedido.vendaEntregaOnline,
      [
        ...itensEtapa,
        IdEtapaPedido.pagamento,
        IdEtapaPedido.confirmacao,
        IdEtapaPedido.embalar,
        IdEtapaPedido.chamarEntregador,
        IdEtapaPedido.entregue,
        if (faturaEntregaDepoisDeEntregar) IdEtapaPedido.faturar,
      ],
      c,
    );
  }

  return _monta(TipoTrilhaPedido.minima, [IdEtapaPedido.faturar], c);
}
