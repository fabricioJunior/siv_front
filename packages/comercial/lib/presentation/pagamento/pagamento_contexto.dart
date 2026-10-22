import 'package:comercial/domain/models/pagamentos_realizados_resumo.dart';
import 'package:comercial/presentation/blocs/pagamentos_realizados_bloc/pagamentos_realizados_bloc.dart';
import 'package:core/injecoes/injecoes.dart';

enum PagamentoOrigem { venda, romaneio, pedido, consignacaoAcerto }

/// manual/online filtram as formas; escolher mostra o segmentado no topo.
enum PagamentoTipoOperacao { manual, online, escolher }

/// Linha fixa do resumo que reduz o valor a pagar (adiantado, já lançado).
class PagamentoAbatimento {
  final String rotulo;
  final double valor;

  const PagamentoAbatimento({required this.rotulo, required this.valor});
}

/// O que a origem consome. Recurso desligado não é desenhado nem sai no
/// resultado (3.2 do handoff).
class PagamentoRecursos {
  final bool descontoItem;
  final bool descontoGeral;
  final bool promocoes;
  final bool cupom;
  final bool taxaEntrega;
  final bool cpfNota;
  final bool emailNota;
  final bool resgatePontos;
  final bool pontuarFidelidade;
  final bool creditoCliente;

  const PagamentoRecursos({
    this.descontoItem = true,
    this.descontoGeral = true,
    this.promocoes = true,
    this.cupom = true,
    this.taxaEntrega = true,
    this.cpfNota = true,
    this.emailNota = true,
    this.resgatePontos = false,
    this.pontuarFidelidade = false,
    this.creditoCliente = true,
  });

  static const venda = PagamentoRecursos(
    resgatePontos: true,
    pontuarFidelidade: true,
  );
  // ponytail: e-mail da nota no romaneio em andamento aguarda decisão.
  static const romaneio = PagamentoRecursos(emailNota: false);
  static const pedido = PagamentoRecursos(taxaEntrega: false);
  static const consignacaoAcerto = PagamentoRecursos();
}

class PagamentoContexto {
  final PagamentoOrigem origem;
  final String hashLista;
  final String titulo;
  final String? subtitulo;
  final String rotuloVoltar;
  final String rotuloConfirmar;
  final String? avisoConfirmar;
  final PagamentosRealizadosResumo? resumo;
  final double descontoInicial;
  final double taxaEntregaInicial;
  final List<PagamentoAbatimento> abatimentos;
  final PagamentoTipoOperacao tipoOperacao;
  final bool descontosTravados;
  final PagamentoRecursos recursos;
  final int? pessoaId;
  final String? cpfInicial;
  final bool clienteGenerico;
  final String? emailInicial;
  final bool enviarNotaPorEmailInicial;

  const PagamentoContexto({
    required this.origem,
    required this.hashLista,
    required this.titulo,
    required this.rotuloConfirmar,
    required this.recursos,
    this.subtitulo,
    this.rotuloVoltar = 'Voltar',
    this.avisoConfirmar,
    this.resumo,
    this.descontoInicial = 0,
    this.taxaEntregaInicial = 0,
    this.abatimentos = const [],
    this.tipoOperacao = PagamentoTipoOperacao.manual,
    this.descontosTravados = false,
    this.pessoaId,
    this.cpfInicial,
    this.clienteGenerico = false,
    this.emailInicial,
    this.enviarNotaPorEmailInicial = false,
  });

  factory PagamentoContexto.venda({
    required String hashLista,
    required PagamentosRealizadosResumo? resumo,
    String titulo = 'Pagamento',
    String? subtitulo,
    String rotuloVoltar = 'Voltar aos itens',
    String rotuloConfirmar = 'Confirmar e emitir',
    String? avisoConfirmar =
        'Ao confirmar, o romaneio é gerado e o estoque baixado.',
    double descontoInicial = 0,
    double taxaEntregaInicial = 0,
    int? pessoaId,
    String? cpfInicial,
    bool clienteGenerico = false,
    String? emailInicial,
    bool enviarNotaPorEmailInicial = false,
  }) =>
      PagamentoContexto(
        origem: PagamentoOrigem.venda,
        recursos: PagamentoRecursos.venda,
        hashLista: hashLista,
        resumo: resumo,
        titulo: titulo,
        subtitulo: subtitulo,
        rotuloVoltar: rotuloVoltar,
        rotuloConfirmar: rotuloConfirmar,
        avisoConfirmar: avisoConfirmar,
        descontoInicial: descontoInicial,
        taxaEntregaInicial: taxaEntregaInicial,
        pessoaId: pessoaId,
        cpfInicial: cpfInicial,
        clienteGenerico: clienteGenerico,
        emailInicial: emailInicial,
        enviarNotaPorEmailInicial: enviarNotaPorEmailInicial,
      );

  /// `descontoInicial = romaneio.desconto`, `taxaEntregaInicial = romaneio.valorTaxaEntrega`.
  factory PagamentoContexto.romaneio({
    required String hashLista,
    required PagamentosRealizadosResumo? resumo,
    String titulo = 'Pagamento',
    String? subtitulo,
    String rotuloVoltar = 'Voltar ao romaneio',
    String rotuloConfirmar = 'Confirmar pagamento',
    String? avisoConfirmar,
    double descontoInicial = 0,
    double taxaEntregaInicial = 0,
    int? pessoaId,
    String? cpfInicial,
    bool clienteGenerico = false,
  }) =>
      PagamentoContexto(
        origem: PagamentoOrigem.romaneio,
        recursos: PagamentoRecursos.romaneio,
        hashLista: hashLista,
        resumo: resumo,
        titulo: titulo,
        subtitulo: subtitulo,
        rotuloVoltar: rotuloVoltar,
        rotuloConfirmar: rotuloConfirmar,
        avisoConfirmar: avisoConfirmar,
        descontoInicial: descontoInicial,
        taxaEntregaInicial: taxaEntregaInicial,
        pessoaId: pessoaId,
        cpfInicial: cpfInicial,
        clienteGenerico: clienteGenerico,
      );

  /// `abatimentos` = pagamentos já lançados; `descontosTravados` = há pagamento lançado.
  factory PagamentoContexto.pedido({
    required String hashLista,
    required PagamentosRealizadosResumo? resumo,
    required String titulo,
    String? subtitulo,
    String rotuloVoltar = 'Voltar ao pedido',
    String rotuloConfirmar = 'Lançar pagamento',
    String? avisoConfirmar = 'Lança no pedido; a nota sai ao faturar.',
    double descontoInicial = 0,
    double taxaEntregaInicial = 0,
    List<PagamentoAbatimento> abatimentos = const [],
    PagamentoTipoOperacao tipoOperacao = PagamentoTipoOperacao.escolher,
    bool descontosTravados = false,
    int? pessoaId,
    String? cpfInicial,
    bool clienteGenerico = false,
    String? emailInicial,
    bool enviarNotaPorEmailInicial = false,
  }) =>
      PagamentoContexto(
        origem: PagamentoOrigem.pedido,
        recursos: PagamentoRecursos.pedido,
        hashLista: hashLista,
        resumo: resumo,
        titulo: titulo,
        subtitulo: subtitulo,
        rotuloVoltar: rotuloVoltar,
        rotuloConfirmar: rotuloConfirmar,
        avisoConfirmar: avisoConfirmar,
        descontoInicial: descontoInicial,
        taxaEntregaInicial: taxaEntregaInicial,
        abatimentos: abatimentos,
        tipoOperacao: tipoOperacao,
        descontosTravados: descontosTravados,
        pessoaId: pessoaId,
        cpfInicial: cpfInicial,
        clienteGenerico: clienteGenerico,
        emailInicial: emailInicial,
        enviarNotaPorEmailInicial: enviarNotaPorEmailInicial,
      );

  /// `abatimentos` = adiantado na saída (abate só sobre itens − desconto; a taxa entra depois).
  factory PagamentoContexto.consignacaoAcerto({
    required String hashLista,
    required PagamentosRealizadosResumo? resumo,
    required String titulo,
    String? subtitulo,
    String rotuloVoltar = 'Voltar ao acerto',
    String rotuloConfirmar = 'Confirmar acerto',
    String? avisoConfirmar =
        'Fecha o acerto, baixa o adiantado e emite a nota.',
    List<PagamentoAbatimento> abatimentos = const [],
    int? pessoaId,
    String? cpfInicial,
    String? emailInicial,
    bool enviarNotaPorEmailInicial = false,
  }) =>
      PagamentoContexto(
        origem: PagamentoOrigem.consignacaoAcerto,
        recursos: PagamentoRecursos.consignacaoAcerto,
        hashLista: hashLista,
        resumo: resumo,
        titulo: titulo,
        subtitulo: subtitulo,
        rotuloVoltar: rotuloVoltar,
        rotuloConfirmar: rotuloConfirmar,
        avisoConfirmar: avisoConfirmar,
        abatimentos: abatimentos,
        pessoaId: pessoaId,
        cpfInicial: cpfInicial,
        emailInicial: emailInicial,
        enviarNotaPorEmailInicial: enviarNotaPorEmailInicial,
      );

  double get abatimentoTotal =>
      abatimentos.fold(0, (soma, a) => soma + a.valor);

  PagamentosRealizadosIniciado get eventoInicial =>
      PagamentosRealizadosIniciado(
        hashLista: hashLista,
        resumoInicial: resumo,
        pessoaId: pessoaId,
        cpfClienteInicial: cpfInicial,
        clienteGenerico: clienteGenerico,
        descontoJaAplicadoNoRomaneio: descontoInicial,
        taxaEntregaJaAplicadaNoRomaneio: taxaEntregaInicial,
        abatimentoTotal: abatimentoTotal,
        abatimentoPermiteZero: origem == PagamentoOrigem.consignacaoAcerto,
        emailClienteInicial: emailInicial,
        enviarNotaPorEmailInicial:
            recursos.emailNota && enviarNotaPorEmailInicial,
      );

  /// Quem monta a tela de origem cria o bloc aqui e o mantém vivo (Esc preserva estado).
  PagamentosRealizadosBloc criarBloc() =>
      sl<PagamentosRealizadosBloc>()..add(eventoInicial);
}
